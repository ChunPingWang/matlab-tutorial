# MATLAB 工程實作教程：自動控制 × 物理模型 × 語法基礎

寫給有基本理工背景、第一次認真用 MATLAB 的初學者。教學目標是讓你能：

1. 看懂 MATLAB 的向量化思維與常用語法
2. 用 MATLAB 把微分方程、線性代數、傅立葉拿來解工程問題
3. 模擬常見物理模型（彈簧、單擺、電路、熱傳導）
4. 設計與分析經典控制系統（PID、根軌跡、Bode、狀態空間、LQR）
5. 用 Simulink 把控制迴路接起來

每章都附 `.m` 腳本，跑過就會在 `images/` 產出書中所有圖。不依賴互動 GUI，所有圖都能用 `matlab -batch` 重現。

## 章節地圖

| 章節 | 主題 | 你會學到 |
|------|------|---------|
| [01 MATLAB 語法基礎](01-matlab-basics/README.md) | 向量、矩陣、繪圖、函式、檔案 I/O | 把「Python/C 思維」切換成「向量化思維」 |
| [02 數學與物理觀念](02-math-physics/README.md) | 符號運算、ODE、線代、複數頻域 | 接下來控制章節的數學底子 |
| [03 物理模型模擬](03-physics-simulation/README.md) | 拋體、彈簧質量、單擺、RLC、1D 熱傳 | 把課本公式變成可跑的程式 |
| [04 自動控制](04-control-systems/README.md) | 傳遞函數、PID、根軌跡、Bode、狀態空間、LQR | 完整一條「建模 → 分析 → 控制」流程 |
| [05 Simulink 入門](05-simulink/README.md) | 程式化建模、scope、線性化 | 圖形化建構控制系統 |

## 環境需求

- macOS / Linux / Windows 任一
- MATLAB R2024a 或更新版（本教程在 R2025a 驗證）
- 需要的 toolbox：
  - Control System Toolbox（控制章節）
  - Symbolic Math Toolbox（符號運算）
  - Signal Processing Toolbox（FFT 範例）
  - Simulink（第 5 章）
  - Partial Differential Equation Toolbox（1D 熱傳）

## 如何閱讀

每個章節資料夾長這樣：

```
0X-章節名/
├── README.md       ← 主要教材，邊讀邊看圖
├── scripts/        ← 對應的可執行 .m 檔
└── images/         ← 跑 scripts 自動產出的 PNG
```

建議讀法：
1. 開著章節 `README.md` 看
2. 同時在 MATLAB Editor 開對應的 `scripts/NN_xxx.m`
3. 一段一段 F9（在 MATLAB Editor 中是「Run Section」）執行，邊跑邊改參數

## 重跑所有圖

`images/` 是版本控制的，但隨時可以重新產生：

```bash
# 全部重跑（耗時 5~10 分鐘）
./tools/run_all.sh

# 只跑單章
./tools/run_all.sh 03-physics-simulation
```

腳本會呼叫 `matlab -batch` 跑每個 `scripts/*.m`，把產出的 PNG 寫回 `images/`。

## 開始之前的心理建設

MATLAB 不是 Python：
- **陣列從 1 開始**，不是 0
- **預設操作是矩陣級**，`A*B` 是矩陣乘法，要逐元素得寫 `A.*B`
- **沒有強型別**，但函式回傳值用 `[a, b] = foo()` 拿
- **檔案就是函式**：`foo.m` 裡只能有一個 `function foo(...)`（或一個 script）

剩下的邊看邊學。先到 [01 MATLAB 語法基礎](01-matlab-basics/README.md)。
