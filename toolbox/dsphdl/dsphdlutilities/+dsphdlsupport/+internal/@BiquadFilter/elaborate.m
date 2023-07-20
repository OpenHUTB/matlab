function nComp=elaborate(this,hN,hC)





    blockInfo=getBlockInfo(this,hC);

    [blockInfo.gainOptimMode,blockInfo.gainMode]=getHDLGainSetting(this);
    blockInfo.inRate=hC.PirInputSignals(1).SimulinkRate;


    topNet=this.elaborateTopLevel(hN,hC,blockInfo);
    topNet.addComment('Biquad Filter');


    nComp=pirelab.instantiateNetwork(hN,topNet,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);

end

function[gainOptimMode,gainMode]=getHDLGainSetting(this)



    gainMode=3;


    gainParam=getImplParams(this,'ConstMultiplierOptimization');
    gainOptimMode=0;
    if~isempty(gainParam)
        if strcmpi(gainParam,'none')
            gainOptimMode=0;
        elseif strcmpi(gainParam,'csd')
            gainOptimMode=1;
        elseif strcmpi(gainParam,'fcsd')
            gainOptimMode=2;
        elseif strcmpi(gainParam,'auto')
            gainOptimMode=3;
        end
    end
end
