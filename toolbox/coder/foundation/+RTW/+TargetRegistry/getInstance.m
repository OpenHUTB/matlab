function tr=getInstance(mode)








    tr=[];
    if nargin<1
        mode='normal';
    end

    switch mode
    case 'normal'


        if~coder.targetreg.internal.TargetRegistry.initializedAndCached()&&i_isSimulinkInstalled()
            load_simulink;
        end
        tr=RTW.TargetRegistry.get();
    case 'simulinkstart'


        tr=coder.targetreg.internal.TargetRegistry.getWithoutDataLoad();
        setIncludesSlCustomizerRegistrations(tr);
    case 'reset'

        RTW.TargetRegistry.reset();
    otherwise


        tr=RTW.TargetRegistry.get();
    end



    function value=i_isSimulinkInstalled()
        persistent installed;

        if isempty(installed)
            installed=license('test','SIMULINK')&&exist('sl_refresh_customizations','file');
        end

        value=installed;


