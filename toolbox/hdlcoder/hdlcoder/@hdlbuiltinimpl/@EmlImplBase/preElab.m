function hNewC=preElab(this,hN,hC)



    hNewC=elabBasic(this,hN,hC);





    if hNewC.elaborationHelper
        stateInfo=getStateInfo(this,hNewC);
        hNewC.setHasState(stateInfo.HasState);
        hNewC.setHasFeedback(stateInfo.HasFeedback);
        hNewC.setMaxOversampling(getMaxOversampling(this,hNewC));
        hNewC.setAllowDistributedPipelining(allowDistributedPipelining(this,hNewC));
    end


    slbh=hNewC.SimulinkHandle;
    if slbh>0
        maskObj=get_param(slbh,'MaskObject');
        if~isempty(maskObj)
            if isempty(maskObj.BaseMask)
                maskDispStr=get_param(slbh,'MaskDisplay');
            else
                maskDispStr=maskObj.BaseMask.Display;
            end



            expr='Latency\s*=\s*(\d+)';
            latValCell=regexp(maskDispStr,expr,'tokens');
            if~isempty(latValCell)&&~isempty(latValCell{1})
                latVal=str2double(latValCell{1}{1});
                hNewC.setLatencyValue(latVal);
            end
        end
    end
end
