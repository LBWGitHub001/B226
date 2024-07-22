function [fitresult, gof] = FitPlane(x, y, z)
%CREATEFIT(X,Y,Z)
%  创建一个拟合。
%
%  要进行 '无标题拟合 1' 拟合的数据:
%      X 输入: x
%      Y 输入: y
%      Z 输出: z
%  输出:
%      fitresult: 表示拟合的拟合对象。
%      gof: 带有拟合优度信息的结构体。
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 22-Jul-2024 10:46:57 自动生成


%% 拟合: '无标题拟合 1'。
[xData, yData, zData] = prepareSurfaceData( x, y, z );

% 设置 fittype 和选项。
ft = fittype( 'poly11' );

% 对数据进行模型拟合。
[fitresult, gof] = fit( [xData, yData], zData, ft );
% 
% % 绘制数据拟合图。
% figure( 'Name', '海底平面拟合图 1' );
% h = plot( fitresult, [xData, yData], zData );
% legend( h, '拟合平面 1', 'z vs. x, y', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % 为坐标区加标签
% xlabel( 'x', 'Interpreter', 'none' );
% ylabel( 'y', 'Interpreter', 'none' );
% zlabel( 'z', 'Interpreter', 'none' );
% grid on
% view( -15.0, 18.6 );


