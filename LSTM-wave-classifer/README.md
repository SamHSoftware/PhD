# README for project: LSTM-wave-classifer

## Author details: 
Name: Sam Huguet  
E-mail: samhuguet1@gmail.com
Date created: 9<sup>th</sup> December 2020

## Description: 
- This code is designed to train an classify single-feature time series data as either 'class 0' or 'class 1'. This data is related to my PhD, and will not be extensivly described here until the publishing of this work. Thus, certain references to the data may seem vague unless you are working within our research group. 
- The classification is achieved using a Long-Short-Term-Memory (LSTM) model constructed using the Pytorch package.
- LSTMs are a type of RNN, and are commonly used to make predictions based on a series of data with repeating tendancies. For instance, given past data, you can use LSTMs to predict global temperatures, share prices, or (as in this instance) you can consider time series data and classify it into different groups.
- For each python file, there is a .ipynb file for those who use JupyterLab.
- The code will provide a number of outputs, including the trained model, and a list of the excel files which correspond to class '1' data. 

## Here's how to unit test the code before using it: 