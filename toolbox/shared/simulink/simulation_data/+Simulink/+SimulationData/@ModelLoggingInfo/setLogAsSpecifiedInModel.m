function this=setLogAsSpecifiedInModel(this,mdlOrMdlBlk,bVal)












    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'setLogAsSpecifiedInModel');
    end


    if nargin<3||~ischar(mdlOrMdlBlk)||~islogical(bVal)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoInvalidSetLogAsSpecArgs');
    end


    bMdlWide=...
    (this.overrideMode_~=...
    Simulink.SimulationData.LoggingOverrideMode.UseLocalSettings);
    bUsingDefault=...
    this.overrideMode_==...
    Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel;
    if bMdlWide&&(bVal==bUsingDefault)
        return;
    end


    mdlOrMdlBlk=...
    Simulink.SimulationData.BlockPath.manglePath(mdlOrMdlBlk);



    this.OverrideMode=...
    Simulink.SimulationData.LoggingOverrideMode.UseLocalSettings;

    this.assertSizeOfLogAsSpecifiedMatch();


    if bVal
        ssid=this.getSSID(mdlOrMdlBlk);
        if isempty(this.logAsSpecifiedByModels_)
            this.logAsSpecifiedByModels_={mdlOrMdlBlk};
            this.logAsSpecifiedByModelsSSIDs_={ssid};
        elseif~any(strcmp(this.logAsSpecifiedByModels_,mdlOrMdlBlk))
            this.logAsSpecifiedByModels_{end+1}=mdlOrMdlBlk;
            this.logAsSpecifiedByModelsSSIDs_{end+1}=ssid;

        end


    else
        if bMdlWide



            if strcmp(mdlOrMdlBlk,this.model_)
                this.logAsSpecifiedByModels_={};
            else
                this.logAsSpecifiedByModels_={this.model_};
            end

            blks=Simulink.SimulationData.ModelLoggingInfo.utFindBlocksInModel(...
            this.model_,...
            'AllVariants',...
            'on',...
            'on',...
            'all',...
            true,...
            'ModelReference');
            blks=...
            Simulink.SimulationData.BlockPath.manglePath(blks);

            for idx=1:length(blks)
                if~strcmp(blks{idx},mdlOrMdlBlk)
                    this.logAsSpecifiedByModels_=...
                    [this.logAsSpecifiedByModels_,blks{idx}];
                end
            end





            this=this.cacheSSIDs(...
            false,...
            false);

        else
            len=length(this.logAsSpecifiedByModels_);
            for idx=1:len
                if strcmp(this.logAsSpecifiedByModels_{idx},mdlOrMdlBlk)
                    if idx==1
                        this.logAsSpecifiedByModels_=this.logAsSpecifiedByModels_(2:end);
                        this.logAsSpecifiedByModelsSSIDs_=this.logAsSpecifiedByModelsSSIDs_(2:end);
                    elseif idx==len
                        this.logAsSpecifiedByModels_=this.logAsSpecifiedByModels_(1:end-1);
                        this.logAsSpecifiedByModelsSSIDs_=this.logAsSpecifiedByModelsSSIDs_(1:end-1);
                    else
                        this.logAsSpecifiedByModels_=...
                        [this.logAsSpecifiedByModels_(1:idx-1)...
                        ,this.logAsSpecifiedByModels_(idx+1:len)];
                        this.logAsSpecifiedByModelsSSIDs_=...
                        [this.logAsSpecifiedByModelsSSIDs_(1:idx-1)...
                        ,this.logAsSpecifiedByModelsSSIDs_(idx+1:len)];
                    end
                    break;
                end
            end
        end


        if isempty(this.logAsSpecifiedByModels_)
            this.logAsSpecifiedByModels_={};
            this.logAsSpecifiedByModelsSSIDs_={};
        end
    end

    this.assertSizeOfLogAsSpecifiedMatch();

end
