# 05. Simulink 入門

> **這一章在解什麼問題？**
>
> 1980 年代以前，控制工程師設計一個系統要做四件事：(1) 寫微分方程、(2) 用 FORTRAN 寫程式跑模擬、(3) 焊一個類比電路驗證、(4) 上機台實測。**每一步都要 1-3 個月**。一個閉迴路系統從紙上設計到上線常常要 1-2 年。
>
> 更糟的是「**跨領域溝通**」：機械工程師畫的是受力分析圖、電機工程師畫的是電路圖、控制工程師寫的是微分方程、軟體工程師看的是 C 程式碼 — 四個人開會時根本對不上話。
>
> 1984 年新墨西哥大學的 Cleve Moler 為了教線性代數，寫了個簡單包裝 LINPACK 與 EISPACK 的工具叫 **MATLAB**（**MAT**rix **LAB**oratory）。1989 年他與 Jack Little 創立 MathWorks，1990 年發表 **Simulink** — 直接拿圖形化方塊圖當工程語言，讓四個領域的工程師「**畫同一張圖、講同一種語言**」。
>
> **Simulink 是過去 35 年「Model-Based Design」（模型驅動設計）哲學的代表作**。今天的汽車、航太、國防、半導體、能源產業大多以 Simulink 為標準工具：
> - **Toyota Prius 的混合動力控制邏輯** — 100% 用 Simulink 設計、自動生成 C 程式碼燒進 ECU
> - **Airbus A380 的飛控系統** — Simulink 模型先在 HIL 平台跑幾百萬小時模擬才上實機
> - **特斯拉 Model S 的電池管理系統** — 用 Simulink + Stateflow 設計
> - **SpaceX Dragon 太空船的對接控制** — Simulink 是核心工具鏈之一
>
> 這一章用「**程式化建模**」方式建立兩個 Simulink 模型 — 比手拉 GUI 對教學更可重現，且能完全用 `matlab -batch` 自動產出截圖。內容雖然是入門，但流程跟業界真實工作流程一致。

| # | 腳本 | 主題 |
|---|------|------|
| 01 | [`01_build_spring_model.m`](scripts/01_build_spring_model.m) | 用 `add_block` 建立彈簧質量阻尼模型 |
| 02 | [`02_build_pid_motor.m`](scripts/02_build_pid_motor.m) | DC 馬達 + PID 控制器閉迴路 |

實際儲存的 `.slx` 檔案在 [`models/`](models/) — 可用 MATLAB 直接 `open smd_open.slx` 打開來玩。

---

## 1. 第一個 Simulink 模型：彈簧質量阻尼

### 歷史脈絡：類比計算機到方塊圖建模

1940-50 年代軍方為了模擬導彈、飛機、火箭，發明了「**類比計算機**」 — 用運算放大器、電阻、電容組合出可解 ODE 的電路。**每一條微分方程都是一面實體的「配線板」**，幾百個運算放大器接成的迷宮裡跑「電壓代替變數」的模擬。MIT、Caltech、霍尼韋爾都有這種機台，**操作員需要學專業課程才會用**。

1970 年代電子計算機普及後類比計算機被淘汰，但其「**方塊圖建模**」的思想保留下來。1980 年代麻省理工的 Stephen Cooper、David Ferguson 在電腦上實現可視化的方塊圖模擬器，**Simulink (1990) 把這個概念推向工業界**。

到 21 世紀，**Model-Based Design 在汽車工業的崛起**讓 Simulink 變成業界標準：
- 2000 年福斯集團（VW Group）採用 Simulink 作為動力總成設計標準
- 2003 年 GM 用 Simulink + Stateflow 設計 OnStar 系統
- 2010 年代豐田、本田、特斯拉的所有 ECU 開發都從 Simulink 起步

### 為什麼用 Simulink 而不是 ODE？

對單純的線性系統，第 3 章的 `ode45` 就夠。Simulink 的優勢出現在：

- **多個子系統耦合**（例如：感測器動態 + 控制器 + 致動器 + plant）
- **包含非線性**（飽和、死區、量化）
- **多速率**（連續 plant + 離散 controller）
- **可生成 C 程式碼**到 ESP32、STM32、Arduino
- **硬體在迴路 (HIL) 測試**
- **跨團隊溝通**：機械、電機、控制、軟體工程師看同一張圖

### 程式化建模 vs GUI

兩種方式建出的模型完全一樣。GUI 適合 prototyping，程式化適合：

- 自動化測試（不同參數重建模型）
- 版本控制（`.slx` 是二進位，不容易 diff）
- 教學示範（可重現的 baseline）
- **大規模重構**：把 100 個變數從一種命名規則改成另一種，手拉 GUI 要半天，程式 30 秒

### 建模流程

```matlab
modelName = 'smd_open';
new_system(modelName);
open_system(modelName);

% 1. 加方塊
add_block('simulink/Sources/Step', [modelName '/Step'], ...
    'Position', [50, 100, 80, 130], ...
    'Time', '0', 'After', '1');

% 2. 連線
add_line(modelName, 'Step/1', 'Sum/1');

% 3. 設定 solver
set_param(modelName, 'StopTime', '15', 'Solver', 'ode45');

% 4. 跑模擬
simOut = sim(modelName);
```

### 結果：彈簧質量阻尼方塊圖

![smd diagram](images/01_smd_diagram.png)

對照數學：

```
m·x'' + c·x' + k·x = u
=>  x'' = (u - c·x' - k·x) / m
```

方塊圖讀法：
1. Sum 計算 `u - c·v - k·x`
2. 乘 `1/m` 得到 `x''`（加速度）
3. 第一個 Integrator 積分得到 `v = x'`（速度）
4. 第二個 Integrator 再積分得到 `x`（位置）
5. v 經 `c_gain` 回授到 Sum
6. x 經 `k_gain` 回授到 Sum

這就是「**用積分器搭出 ODE**」的標準寫法 — 高階導數從 Sum 出來，每經過一個 Integrator 階數降一階。**這個結構繼承自 1950 年代類比計算機的配線哲學** — 雖然底層實作完全不同，但設計思維沒變。

### 模擬結果

![smd response](images/01_smd_response.png)

對 1N 階躍輸入，位移收斂到 1/k = 0.25 m（彈簧的胡克定律穩態）。與第 3 章的 ode45 結果完全一致。

---

## 2. DC 馬達 PID 閉迴路

### 歷史脈絡：從紙本配線到自動生成 C 程式碼

1980 年代以前，工程師設計好 PID 後要做以下流程：
1. 把 PID 公式用 C 或 FORTRAN 重新編碼
2. 在主機板上手測各種 corner case
3. 燒進 EPROM 或 ROM
4. 上機驗收
5. 出問題就重新走一遍

**每次迭代以週或月為單位**。

Simulink + Embedded Coder（2002 年發表）改變了這個流程：**直接在 Simulink 畫的 PID 控制器，按一個按鈕就生成 production-grade C 程式碼**。豐田、本田、福斯都在 2000 年代初導入，**Toyota Prius (2003 年第二代) 的混合動力控制就是這套流程的代表作**。

今天的「**Model-Based Design 五步驟**」是業界標準：
1. **建模** (Modeling)：Simulink 畫系統
2. **模擬** (Simulation)：在電腦上跑各種 scenario
3. **硬體在迴路** (HIL)：把控制器跑在實機晶片上，plant 還是模擬
4. **快速控制原型** (RCP)：控制器在實機、plant 是真物
5. **量產代碼** (Production Code)：自動生成可上產品的 C 程式

### 模型結構

![motor pid diagram](images/02_motor_pid_diagram.png)

從左到右：
1. **Ref**：階躍 1 rad/s
2. **Error**：Sum 算 `e = ref - omega`
3. **PID**：用第 4 章 `pidtune` 得到的 Kp/Ki/Kd
4. **Motor**：DC 馬達傳遞函數 `Kt/R / (J·s + B + Kt·Kb/R)`
5. **回授**：Motor 輸出接回 Error 的負端

```matlab
add_block('simulink/Continuous/PID Controller', [modelName '/PID'], ...
    'Position', [200, 90, 260, 140], ...
    'P', '14.33', 'I', '260', 'D', '0');

add_block('simulink/Continuous/Transfer Fcn', [modelName '/Motor'], ...
    'Numerator', mat2str(num), ...
    'Denominator', mat2str([den_a, den_b]));
```

Simulink 內建的 **PID Controller** 方塊比手寫 PID 強：
- 自動處理「積分飽和」(anti-windup) — 1980 年代 Karl Åström 在 ABB 發現的問題，現在內建解決方案
- 支援離散時間實作
- 可從 Simulink Tuner 互動調參
- **可直接 generate C code** 給嵌入式系統用

### 結果

![motor pid response](images/02_motor_pid_response.png)

對照組「開迴路直接餵 1V」最終穩態大概 0.09 rad/s — 因為 1V 在這個 plant 設定下根本不夠。
PID 閉迴路會自動把控制電壓加大到讓 omega 達到目標 1 rad/s，且收斂時間 < 0.5s。

**這個模型如果用 Embedded Coder 生成 C code**：大約 50 行 C 程式可以燒進任何 32-bit MCU（STM32、ESP32、TI C2000），即時運行 10 kHz 控制週期。這就是業界從「Simulink 設計」到「實機運行」的最後一哩路。

---

## 程式化建模常用 API

| 函式 | 作用 |
|------|------|
| `new_system(name)` | 建立空模型 |
| `open_system(name)` | 開啟（可選） |
| `add_block(libpath, fullpath, ...)` | 加方塊 |
| `add_line(model, src, dst, 'autorouting', 'on')` | 連線 |
| `set_param(blockpath, 'Param', 'Value')` | 改方塊或模型參數 |
| `sim(name)` | 跑模擬，回傳 SimulationOutput |
| `save_system(name, path)` | 存成 .slx |
| `bdclose(name)` | 關閉 |
| `print('-s' + name, '-dpng', '-rDPI', file)` | 截 block diagram |

### 常用方塊路徑

| 用途 | libpath |
|------|---------|
| Step input | `simulink/Sources/Step` |
| Constant | `simulink/Sources/Constant` |
| Sine | `simulink/Sources/Sine Wave` |
| Sum | `simulink/Math Operations/Sum` |
| Gain | `simulink/Math Operations/Gain` |
| Integrator | `simulink/Continuous/Integrator` |
| Transfer Fcn | `simulink/Continuous/Transfer Fcn` |
| State-Space | `simulink/Continuous/State-Space` |
| PID Controller | `simulink/Continuous/PID Controller` |
| Saturation | `simulink/Discontinuities/Saturation` |
| Scope | `simulink/Sinks/Scope` |
| To Workspace | `simulink/Sinks/To Workspace` |

### Sum 方塊的端口字串

`'Inputs'` 參數用 `+`/`-` 表示每個端口的符號：

- `'++'`：兩個正端口
- `'+-'`：第一正第二負（最常見的誤差訊號）
- `'+--'`：一正兩負（彈簧質量阻尼裡的 `u - c·v - k·x`）

---

## 怎麼從 Simulink 拿結果回 MATLAB

兩種主流做法：

### 1. To Workspace 方塊

```matlab
add_block('simulink/Sinks/To Workspace', [modelName '/Out'], ...
    'VariableName', 'w_out', ...
    'SaveFormat', 'Structure With Time');

simOut = sim(modelName);
t = simOut.w_out.time;
y = simOut.w_out.signals.values;
```

### 2. Outport + sim 回傳

模型加 Outport (`simulink/Ports & Subsystems/Out1`)，然後：

```matlab
simOut = sim(modelName, 'SaveOutput', 'on');
y = simOut.yout{1}.Values;   % timeseries object
```

兩種都行，依個人偏好。教學用第一種比較直接。

---

## 進階：可以走的方向

本教程到這裡就把「基礎」帶完了。如果要深入，下面這幾個方向是工業界最常用的（**括號內是業界代表性使用者**）：

1. **Stateflow**：在 Simulink 裡嵌入有限狀態機（FSM）
   — 適合「正常 / 啟動 / 故障」這種模式切換邏輯
   — 用例：**Toyota Hybrid System 的混合動力模式切換**、**飛機自動駕駛的階段管理**

2. **Simscape**：第一性原理物理建模
   — 不用手寫 ODE，直接拉「彈簧」「阻尼」「電阻」「電容」這種物理元件方塊
   — 用例：**福斯動力總成模擬**、**液壓系統設計**

3. **Simscape Multibody**：3D 多體機械系統
   — 機械手臂、四足機器人、車輛動力學
   — 用例：**Boston Dynamics 的 Spot 機器狗**、**KUKA 機械手臂**

4. **Embedded Coder**：把 Simulink 模型自動生成 C/C++ 程式碼
   — 燒到 STM32、Speedgoat、dSPACE 等即時平台
   — 用例：**特斯拉 Model S 的 BMS 自動代碼生成**、**Airbus A380 飛控**

5. **Reinforcement Learning Toolbox**：訓練 RL agent 取代 LQR/PID
   — 對非線性、高維度、模型未知的系統
   — 用例：**DeepMind AlphaFold 之外的工程應用**、**MathWorks 內部的駕駛決策實驗**

6. **Linear Analysis Tool**：在 Simulink 模型任一點線性化、做 Bode/Nyquist
   — 非線性 plant 也能用線性工具設計局部控制器
   — 用例：**所有用 Simulink 設計的非線性系統的標準分析流程**

---

## 結語

> **從 1788 年瓦特的飛球調速器到今天的特斯拉 Autopilot，控制工程走了 237 年。**
>
> 這條學科發展史上有四個關鍵轉折：
>
> 1. **1868 年馬克士威**用微分方程證明調速器穩定性 — 控制理論誕生
> 2. **1932-1948 年 Nyquist / Bode / Evans** 在貝爾實驗室建立頻域分析 — 工程師有了直觀的設計工具
> 3. **1960 年 Kalman** 提出狀態空間 + Kalman filter + LQR — 現代控制理論誕生、直接讓阿波羅登月成為可能
> 4. **1990 年 Simulink** 把這 200 年累積的工具圖形化、自動化、可生成 production code — 控制工程從學術變成大眾化

到這裡你應該對 MATLAB 在工程數學、物理模擬、自動控制上的角色有了完整的圖像：

- **MATLAB 是「向量化的計算機」** — 把 17 世紀以來的數學工具變成可跑的程式
- **第 1~2 章建立的工具**（ODE、線代、頻域）是 19 世紀數學物理學家的遺產
- **第 3 章的物理模擬**示範了「寫下方程 → 改狀態向量 → ode45」這條從伽利略到今天通用的 SOP
- **第 4 章的控制設計**串起馬克士威、Nyquist、Bode、Ziegler-Nichols、Kalman 的 150 年累積
- **第 5 章的 Simulink** 把這些工具用方塊圖視覺化、並通向實機部署 — 是當代工業界的標配

**接下來最有效的學習方式是**：拿一個你關心的物理系統（馬達、無人機、化學反應器、暖氣機⋯），照本教程的 SOP 走一遍。讀十遍書不如自己做一個 prototype。

工程史上每一個關鍵突破背後都有「**遇到問題 → 沒有工具 → 發明工具**」的故事。你今天用一行 `ode45` 解的方程式，當年歐拉手算了一輩子；你用 `pidtune` 一秒生成的 PID，當年 Ziegler-Nichols 跑遍幾百個工廠才歸納出規則。**站在這些巨人的肩膀上，你能做的事多得多** — 這就是這套教程想傳達的精神。
