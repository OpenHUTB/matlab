function setJavaDesktopEnabled(isEnabled)
    % 启用/禁用与Java桌面主窗口交互的Matlab API
    % isEnabled (1,1) logical;
 
    com.mathworks.mde.desk.MLDesktop.getInstance().getMainFrame().setEnabled(isEnabled);
end