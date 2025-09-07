# Predictive analytics

A comprehensive machine learning solution for demand forecasting and business intelligence. This pipeline implements multiple forecasting approaches, from statistical baselines to advanced regression models, delivering  insights for inventory optimization and strategic planning.

## Project overview

This project implements predictive analytics capabilities, demonstrating best practices in:
- Time series forecasting with multiple methodologies (ARIMA, Prophet, Moving Averages)
- Scalable regression modeling with feature engineering for demand prediction
- Regional growth analysis using polynomial trend modeling
- Supply chain optimization through predictive material requirement planning
- Comprehensive model validation and performance comparison

## Project structure

```
aw_ml-ds/
├── README.md 
├── 1. Previsão de demanda.ipynb            # Product/store demand forecasting
├── 2. Viabilidade de modelos de regressao.ipynb       # Regression model evaluation
├── 3. Crescimento por centro de distribuicao.ipynb    # Regional growth analysis
└─── 4. Estimativa de zipers.ipynb        # Supply chain optimization
```

## Getting started

### Prerequisites

- **Databricks environment**

## Business problems solved

### 1. Demand forecasting ([1. Previsão de demanda.ipynb](https://github.com/YasmimAbrahao/AW-LH-CHECKPOINT/blob/develop/aw_ml-ds/1.%20Previs%C3%A3o%20de%20demanda.ipynb))

**Objective**: Predict demand for the next 3 months at product-store granularity

**Approach**:
- **Baseline Models**: 3-month and 12-month moving averages
- **Statistical Models**: ARIMA with automatic parameter selection
- **Modern Forecasting**: Prophet with seasonality detection
- **Model Selection**: MAE-based performance comparison

**Results**:
- Identified optimal forecasting approach varies by product volatility
- Simple baselines often outperform complex models for volatile items
- Clear visualization of forecast vs. historical patterns

### 2. Regression model viability ([2. Viabilidade de modelos de regressao.ipynb](https://github.com/YasmimAbrahao/AW-LH-CHECKPOINT/blob/develop/aw_ml-ds/2.%20Viabilidade%20de%20modelos%20de%20regressao.ipynb))

**Objective**: Evaluate scalable regression approaches for portfolio-wide forecasting

**Approach**:
- **Feature Engineering**: Lag features (1, 2, 3, 6, 12 months), moving averages (3, 6, 12 months), seasonal indicators
- **Model Comparison**: Linear Regression, Random Forest, XGBoost
- **Validation**: Time Series Cross-Validation with 5 folds
- **Baseline**: Simple mean as performance benchmark

**Results**:
- **XGBoost achieves 54.6% improvement** over baseline (102.1% vs 225.2% MAPE)
- **R² of 0.480** indicating reasonable predictive power
- Scalable solution for entire product catalog

### 3. Regional growth analysis ([3. Crescimento por centro de distribuicao.ipynb](https://github.com/YasmimAbrahao/AW-LH-CHECKPOINT/blob/develop/aw_ml-ds/3.%20Crescimento%20por%20centro%20de%20distribuicao.ipynb))

**Objective**: Compare growth trajectories between US provinces and international markets

**Approach**:
- **Trend Extraction**: 12-month moving average
- **Polynomial Modeling**: 2nd-degree polynomial trend fitting
- **Growth Projection**: 3-month forward trend extrapolation
- **Statistical Validation**: R² > 0.92 for model quality assurance

**Results**:
- **International markets**: +30.0% projected growth
- **US provinces**: -4.8% projected decline
- Clear strategic direction for market investment

### 4. Supply chain optimization ([4. Estimativa de zipers.ipynb](https://github.com/YasmimAbrahao/AW-LH-CHECKPOINT/blob/develop/aw_ml-ds/4.%20Estimativa%20de%20zipers.ipynb))

**Objective**: Calculate zipper requirements for glove production over next 3 months

**Approach**:
- **Product Focus**: Half-Finger Gloves demand forecasting
- **Model Comparison**: ARIMA, Prophet vs. Moving Average baselines
- **Volatility Management**: Conservative estimation using 12-month average
- **Business Rule**: 2 zippers per glove pair conversion

**Results**:
- **Recommended zipper order**: 83,080 units
- **Methodology**: 12-month moving average (more stable than complex models)
- **Business Impact**: Prevents stockouts while minimizing inventory costs

## Model performance and validation

### Evaluation metrics

Multiple metrics were used to ensure robust model evaluation:

```python
def calculate_metrics(actual, predicted):
    """Comprehensive model evaluation metrics"""
    mae = mean_absolute_error(actual, predicted)
    rmse = np.sqrt(mean_squared_error(actual, predicted))
    mape = mean_absolute_percentage_error(actual, predicted) * 100
    r2 = r2_score(actual, predicted)
    
    return {
        'MAE': mae,
        'RMSE': rmse, 
        'MAPE': mape,
        'R²': r2
    }
```

### Cross-validation strategy

**Time series split**: Prevents data leakage by maintaining temporal order
```python
from sklearn.model_selection import TimeSeriesSplit

tscv = TimeSeriesSplit(n_splits=5)
for train_idx, test_idx in tscv.split(X):
    # Train on historical data
    # Test on future periods
    # Accumulate performance metrics
```

## Visualization and reporting

### Performance dashboard
- Model comparison charts (MAE, RMSE, MAPE)
- Prediction vs. actual scatter plots
- Time series forecast plots with confidence bands
- Regional growth trend comparisons

