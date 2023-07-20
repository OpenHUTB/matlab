function isFastRestart=is_fastRestart_l(sys)




    isFastRestart=false;


    if strcmp(get_param(sys,'InitializeInteractiveRuns'),'on')
        isFastRestart=true;
    end;
