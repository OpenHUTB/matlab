function[defLog,sigInfo,sigIdx,bSigNameChange,this]=...
    getSettingsForSignal(this,...
    path,...
    portIdx,...
    sub_path,...
    bValidateLogging,...
    signalName,...
    useCache)





















    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'getSettingsForSignal');
    end


    if nargin<3||~isscalar(portIdx)||~isnumeric(portIdx)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoInvalidGetSettingsForSignalArgs');
    end


    if nargin<5
        bValidateLogging=true;
    end


    bpath=Simulink.BlockPath(path);
    if nargin>3
        bpath.SubPath=sub_path;
    end

    if nargin<6
        signalName='';
    end

    if nargin<7
        useCache=false;
    end


    if bpath.getLength()>1
        str=bpath.getBlock(1);
    else
        str=this.model_;
    end
    defLog=this.getLogAsSpecifiedInModel(str,false);


    sigIdx=uint32(0);
    bSigNameChange=false;






    closeMdlObj=Simulink.SimulationData.ModelCloseUtil;%#ok<NASGU>


    sigInfo=[];
    if~defLog

        if~useCache
            [sigInfo,sigIdx,bSigNameChange,this]=...
            getSettingsForSignalUncached(...
            this,...
            sigInfo,...
            sigIdx,...
            bSigNameChange,...
            bpath,...
            portIdx,...
            signalName);
        else



            if isempty(this.finalBpCache)
                this=this.setFinalBpCache(this.signals_);
            end
            subSigs=find(strcmp(this.finalBpCache,bpath.getLastPath()));
            assert(isequal(length(this.finalBpCache),length(this.signals_)))
            for idx=1:length(subSigs)
                if this.signals_(subSigs(idx)).matchesSignal(bpath,portIdx)
                    sigInfo=this.signals_(subSigs(idx));
                    sigIdx=uint32(subSigs(idx));



                    if nargin>5&&ischar(sigInfo.signalName_)
                        if~strcmp(signalName,sigInfo.signalName_)


                            bSigNameChange=true;
                            old_name=this.signals_(subSigs(idx)).signalName_;
                            this.signals_(subSigs(idx)).signalName_=signalName;



                            if~this.signalIsInTopMdl(subSigs(idx))
                                this.warnForRefSignalNameChange(...
                                subSigs(idx),old_name);
                            end

                        end
                    end

                    break;
                end
            end
        end
    end



    if~isempty(sigInfo)&&bValidateLogging&&~defLog

        try
            sigInfo.validate(...
            this.model_,...
            0,...
            false,...
            true,...
            this.supportsTestPointSignals());
        catch me %#ok<NASGU>
            sigInfo=[];
            defLog=false;
        end
    end

end
