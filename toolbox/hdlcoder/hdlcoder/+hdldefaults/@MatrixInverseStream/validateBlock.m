function v=validateBlock(this,hC)


    v=hdlvalidatestruct;
    blockInfo=this.getBlockInfo(hC);
















    fc=hdlgetparameter('FloatingPointTargetConfiguration');

    if~isempty(fc)


        if strcmpi(fc.Library,'ALTERAFPFUNCTIONS')
            hdlLatencyStrategy=[];
        else
            hdlLatencyStrategy=fc.LibrarySettings.LatencyStrategy;
        end
    else
        hdlLatencyStrategy=[];
    end



    isNFP=targetcodegen.targetCodeGenerationUtils.isNFPMode();
    if isNFP&&(~(strcmpi(hdlLatencyStrategy,blockInfo.latencyStrategy)))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:LatencyStrategyMismatch',blockInfo.latencyStrategy,hdlLatencyStrategy));
    end


    if hC.Owner.hasResettableInstances
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:streammatinvcannotbereset'));
    end

end


