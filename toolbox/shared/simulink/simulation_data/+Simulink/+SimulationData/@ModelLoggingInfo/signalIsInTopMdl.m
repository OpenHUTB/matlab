function bInTop=signalIsInTopMdl(this,idx)





    bInTop=false;


    sig=this.signals_(idx);
    if sig.blockPath_.getLength()==1


        mdl=...
        Simulink.SimulationData.BlockPath.getModelNameForPath(...
        sig.blockPath_.getBlock(1));
        if strcmp(mdl,this.model_)
            bInTop=true;
        end

    end

end
