function updateDeps=pslinkCallback(cs,msg)





    updateDeps=false;
    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('Polyspace');
    else
        hObj=cs;
        if~isempty(cs.getConfigSet)
            cs=cs.getConfigSet;
        end
    end
    dlg=msg.dialog;

    if strcmp(msg.name,'checkoptions')&&...
        isempty(hObj.PSSystemToAnalyze)
        return;
    end

    if~isempty(hObj.PSSystemToAnalyze)
        if isa(hObj.PSSystemToAnalyze,'Simulink.BlockDiagram')
            systemName=hObj.PSSystemToAnalyze.getFullName();
        else
            systemName=hObj.PSSystemToAnalyze;
        end
        modelName=bdroot(systemName);
    else
        systemName='';
        modelName=bdroot;
    end

    isForEC=false;
    isForSFcn=~isempty(systemName)&&pssharedprivate('isPslinkAvailable')&&...
    pslink.verifier.sfcn.isVerifiableSFcn(systemName);
    isGrtAllowed=pssharedprivate('isPslinkAvailable')&&...
    pslinkprivate('pslinkattic','getBinMode','allowGrtTarget');
    if isa(cs,'Simulink.ConfigSet')&&~isForSFcn&&...
        (strcmp(get_param(cs,'IsERTTarget'),'on')||isGrtAllowed)
        isForEC=true;
    end

    isForTL=~isForSFcn&&~isForEC&&pssharedprivate('isTlInstalled')&&pssharedprivate('isTlTarget',modelName,true);

    if isForTL
        coderID=pslink.verifier.tl.Coder.CODER_ID;
    elseif isForEC
        coderID=pslink.verifier.ec.Coder.CODER_ID;
    elseif isForSFcn
        coderID=pslink.verifier.sfcn.Coder.CODER_ID;
    else
        coderID=pslink.verifier.slcc.Coder.CODER_ID;
    end

    hObj.dialogCB(dlg,msg.name,coderID);




