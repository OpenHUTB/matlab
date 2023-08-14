function[helpInfo]=getHelpInfo(this,blkPath)

    if contains(blkPath,'.')

        [libname,~]=split(blkPath,'.');
    else
        [libname,~]=split(blkPath,'/');
    end

    helpInfo.hTargets=true;
    libtocheck=libname{1};

    if strncmpi(libtocheck,'dsp',3)
        helpInfo.hTag='dsp';
        helpInfo.hTargets=false;
    elseif contains(libtocheck,'commhdl')||strncmpi(libtocheck,'whdl',4)

        helpInfo.hTag='wireless-hdl';
        helpInfo.hTargets=false;
    elseif strncmpi(libtocheck,'sf_lib',5)


        helpInfo.hTag='stateflow';
        helpInfo.hTargets=false;
    elseif strncmpi(libtocheck,'built-in',8)||contains(libtocheck,'simulink')||strncmpi(libtocheck,'eml_lib',7)

        helpInfo.hTag='simulink';
    elseif contains(libtocheck,'modelsimlib')||contains(libtocheck,'lfilinklib')
        helpInfo.hTag='hdlverifier';
    else

        helpInfo.hTag='hdlcoder';
    end
