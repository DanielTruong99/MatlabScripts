%% Include file
current_path = string(pwd); current_path = split(current_path, "\");
root_path = current_path; root_path( find(current_path == "MatlabScripts") + 1:end ) = [];
root_path = join(root_path, "\");
class_path = fullfile(root_path, "Class");
addpath(class_path);

%%
clear
clc
clf

sub_plot_x = subplot(2, 2, 1);
x_animate_handle = animatedline('Color','b','LineWidth', 1);
x_axes = gca;
% x_axes.YLim = [-50/100 50/100]; 
x_axes.XLabel.String = "Time (s)";
x_axes.YLabel.String = "x (m)";
x_axes.Title.String = "Cart's Position";
x_axes.XGrid = true;
x_axes.YGrid = true;

sub_plot_angle = subplot(2, 2, 2);
angle_animate_handle = animatedline('Color','b','LineWidth', 1);
angle_axes = gca;
% angle_axes.YLim = [-2*pi 2*pi]; 
angle_axes.XLabel.String = "Time (s)";
angle_axes.YLabel.String = "\theta (rad)";
angle_axes.Title.String = "Pendullum's Angle";
angle_axes.XGrid = true;
angle_axes.YGrid = true;

sub_plot_v = subplot(2, 2, 3);
v_animate_handle = animatedline('Color','b','LineWidth', 1);
v_axes = gca;
% v_axes.YLim = [-5 5]; 
v_axes.XLabel.String = "Time (s)";
v_axes.YLabel.String = "v (m/s)";
v_axes.Title.String = "Cart's Velocity";
v_axes.XGrid = true;
v_axes.YGrid = true;

sub_plot_w = subplot(2, 2, 4);
w_animate_handle = animatedline('Color','b','LineWidth', 1);
w_axes = gca;
% w_axes.YLim = [-10 10]; 
w_axes.XLabel.String = "Time (s)";
w_axes.YLabel.String = "\omega (rad/s)";
w_axes.Title.String = "Pendullum's Angular Velocity";
w_axes.XGrid = true;
w_axes.YGrid = true;

animate_handles = [x_animate_handle, v_animate_handle, angle_animate_handle, w_animate_handle];
axeses = [x_axes, v_axes, angle_axes, w_axes];

data_pool = SharedData();

%% Serial configuration
s = SerialCommunicator(data_pool);

%% Timer configuration
[t1, t2] = Timer(s, data_pool, animate_handles, axeses);
