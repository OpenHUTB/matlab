function board=getHardwareBoard(sys)
    cs=getActiveConfigSet(sys);
    board=get_param(cs,'HardwareBoard');
end