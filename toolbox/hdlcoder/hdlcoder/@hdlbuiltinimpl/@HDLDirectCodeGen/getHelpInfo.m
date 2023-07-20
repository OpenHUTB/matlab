function[helpInfo]=getHelpInfo(~,blkPath)

    if contains(blkPath,'.')

        [libname,~]=split(blkPath,'.');
    else
        [libname,~]=split(blkPath,'/');
    end

    libtocheck=libname{1};
    helpInfo.hTargets=true;

    if strncmpi(libtocheck,'dsphdl',6)

        helpInfo.hTag='dsphdl';
        helpInfo.hTargets=false;
    elseif strncmpi(libtocheck,'dsp',3)
        helpInfo.hTag='dsp';
        helpInfo.hTargets=false;
    elseif contains(libtocheck,'commhdl')||strncmpi(libtocheck,'whdl',4)

        helpInfo.hTag='wireless-hdl';
        helpInfo.hTargets=false;
    elseif strncmpi(libtocheck,'built-in',8)||contains(libtocheck,'simulink')||strncmpi(libtocheck,'eml_lib',7)
        helpInfo.hTag='simulink';
    elseif strncmpi(libtocheck,'embmatrixops',3)
        helpInfo.hTag='fixedpoint';
        helpInfo.hTargets=false;
    else
        helpInfo.hTag='hdlcoder';
    end
