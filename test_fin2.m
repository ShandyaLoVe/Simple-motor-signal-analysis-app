clc,clear,close all

N = 100;                           
k = 1:N;                            
s = 2 * k .* (0.5 .^ k);            
mean_noise = 0;                     % 噪声均值
variance_noise = 0.001;                 % 噪声方差
d = mean_noise + sqrt(variance_noise) * randn(1, N);  
f = s + d;                          
M = 9;                            
b_ma = ones(1, M) / M;            
y_ma = filter(b_ma, 1, f);          
Fs = 1;                            
fc = 0.2;                         
L = 21;                            
b_fir = fir1(L-1, fc, hamming(L));  
y_fir = filter(b_fir, 1, f);       
mse_ma = mean((s - y_ma).^2);     
mse_fir = mean((s - y_fir).^2);    
fprintf('滑动平均滤波的 MSE: %.4f\n', mse_ma);   
fprintf('FIR 滤波的 MSE: %.4f\n', mse_fir);      
fprintf('噪声的均值: %.4f, 方差: %.4f\n', mean_noise, variance_noise); 


figure;
subplot(3, 1, 1);
plot(k, f, 'b-', 'LineWidth', 1); hold on;
plot(k, s, 'r--', 'LineWidth', 1); 
title('原始信号和含噪声信号');
legend('含噪声信号', '原始信号');
grid on;
subplot(3, 1, 2);
plot(k, y_ma, 'g-', 'LineWidth', 1.5); hold on;
plot(k, s, 'r--', 'LineWidth', 1);  
title('滑动平均滤波结果');
legend('滑动平均滤波', '原始信号');
grid on;
subplot(3, 1, 3);
plot(k, y_fir, 'm-', 'LineWidth', 1.5); hold on;
plot(k, s, 'r--', 'LineWidth', 1);     
title('FIR 滤波结果');
legend('FIR 滤波', '原始信号');
grid on;
figure;
plot(k, s, 'r--', 'LineWidth', 1.5); hold on;   
plot(k, y_ma, 'g-', 'LineWidth', 1);             
plot(k, y_fir, 'm-', 'LineWidth', 1);         
title('滑动平均滤波与 FIR 滤波比较');
legend('原始信号', '滑动平均滤波', 'FIR 滤波');
grid on;