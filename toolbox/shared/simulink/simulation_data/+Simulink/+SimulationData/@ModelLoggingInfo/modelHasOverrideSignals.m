function bRet=modelHasOverrideSignals(this,block)










    bLookForTopMdl=nargin<2;
    len=length(this.signals_);
    for idx=1:len


        if~this.signals_(idx).loggingInfo_.dataLogging_
            continue;
        end


        bTopMdl=this.signalIsInTopMdl(idx);
        if bLookForTopMdl
            if bTopMdl
                bRet=true;
                return;
            else
                continue;
            end
        end



        if bTopMdl
            continue;
        end



        if strcmp(this.signals_(idx).blockPath_.getBlock(1),block)
            bRet=true;
            return;
        end

    end


    bRet=false;

end
