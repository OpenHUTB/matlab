function this=removeSignalsForMdlBlock(this,...
    modelBlock,...
    bInvalidOnly)











    closeMdlObj=Simulink.SimulationData.ModelCloseUtil;%#ok<NASGU>


    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'removeSignalsForMdlBlock');
    end


    if nargin<2||~ischar(modelBlock)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoInvalidRemoveInstanceArgs');
    end


    idxToRemove=[];
    len=length(this.signals_);
    for idx=len:-1:1
        if this.signals_(idx).blockPath_.getLength>1&&...
            strcmp(this.signals_(idx).blockPath_.getBlock(1),modelBlock)



            if bInvalidOnly
                try
                    this.signals_(idx).validate(...
                    this.model_,...
                    idx,...
                    false,...
                    false,...
                    false);


                    continue;
                catch me %#ok<NASGU>
                end
            end


            idxToRemove=[idxToRemove,idx];%#ok<AGROW>

        end
    end


    this=this.removeSignals_(idxToRemove);
end
