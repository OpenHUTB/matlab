function[status,desc]=pslink_VerificationSettings(cs,name)





    desc='';
    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('Polyspace');
    else
        hObj=cs;
        if~isempty(cs.getConfigSet)
            cs=cs.getConfigSet;
        end
    end

    if~isempty(hObj.PSSystemToAnalyze)
        if isa(hObj.PSSystemToAnalyze,'Simulink.BlockDiagram')
            modelName=bdroot(hObj.PSSystemToAnalyze.getFullName());
        else
            try
                modelName=bdroot(hObj.PSSystemToAnalyze);
            catch Me %#ok<NASGU>


                modelName=bdroot;
            end
        end
    else
        modelName=bdroot;
    end

    modelLang='';
    Clang=true;
    isGrtAllowed=pssharedprivate('isPslinkAvailable')&&pslinkprivate('pslinkattic','getBinMode','allowGrtTarget');
    isForEC=strcmp(get_param(cs,'IsERTTarget'),'on')||isGrtAllowed;
    if isa(cs,'Simulink.ConfigSet')||isGrtAllowed
        modelLang=get_param(cs,'TargetLang');
        Clang=strcmpi(modelLang,'C');
    end

    isForTL=~isForEC&&pssharedprivate('isTlInstalled')&&pssharedprivate('isTlTarget',modelName,true);
    if isForTL

        modelLang='C';
    end

    if Clang||isForTL
        if isempty(modelLang)
            Cstatus=configset.internal.data.ParamStatus.ReadOnly;
        else
            Cstatus=configset.internal.data.ParamStatus.Normal;
        end
        CppStatus=configset.internal.data.ParamStatus.InAccessible;
    else
        Cstatus=configset.internal.data.ParamStatus.InAccessible;
        CppStatus=configset.internal.data.ParamStatus.Normal;
    end

    if strcmp(name,'PSVerificationSettings')
        status=Cstatus;
    else
        status=CppStatus;
    end


