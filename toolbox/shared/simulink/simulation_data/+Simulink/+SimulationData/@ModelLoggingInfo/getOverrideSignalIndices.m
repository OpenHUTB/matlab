function indices=getOverrideSignalIndices(this)







    indices=uint32.empty;



    if this.OverrideMode==...
        Simulink.SimulationData.LoggingOverrideMode.LogAsSpecifiedInModel
        return;
    end



    bTopMdlDefault=this.getLogAsSpecifiedInModel(this.model_);
    len=length(this.signals_);
    for idx=1:len


        pathLen=this.signals_(idx).blockPath_.getLength;
        if this.signalIsInTopMdl(idx)&&bTopMdlDefault
            continue;
        elseif pathLen>1
            mdlBlock=this.signals_(idx).blockPath_.getBlock(1);
            if this.getLogAsSpecifiedInModel(mdlBlock,false)
                continue;
            end
        end


        indices=[indices,uint32(idx)];%#ok<AGROW>
    end

end
