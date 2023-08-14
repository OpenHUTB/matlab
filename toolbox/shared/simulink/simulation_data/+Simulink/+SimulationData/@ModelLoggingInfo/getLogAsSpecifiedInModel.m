function bRet=getLogAsSpecifiedInModel(this,mdlOrMdlBlk,bRefreshPaths)
















    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'getLogAsSpecifiedInModel');
    end

    if nargin<2
        bMdlWide=...
        (this.overrideMode_==...
        Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel);
        bRet=bMdlWide;
        return;
    end


    if~ischar(mdlOrMdlBlk)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoInvalidGetLogAsSpecArgs');
    end
    if nargin<3
        bRefreshPaths=true;
    end


    mdlOrMdlBlk=...
    Simulink.SimulationData.BlockPath.manglePath(mdlOrMdlBlk);

    bMdlWide=...
    (this.overrideMode_~=...
    Simulink.SimulationData.LoggingOverrideMode.UseLocalSettings);
    if bMdlWide
        bRet=...
        this.overrideMode_==...
        Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel;
    else
        if bRefreshPaths&&~strcmp(mdlOrMdlBlk,this.model_)
            bRet=this.getLogAsSpecifedFast(mdlOrMdlBlk);
        else
            if~any(strcmp(this.logAsSpecifiedByModels_,mdlOrMdlBlk))
                bRet=false;
            else
                bRet=true;
            end
        end
    end

end
