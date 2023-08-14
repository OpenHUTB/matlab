function pMap=getLegacyConfigParams(model)




    if strcmp(get_param(model,'SystemTargetFile'),'slrt.tlc')
        pMap=containers.Map;
        pMap('RL32ModeModifier')=get_param(model,'RL32ModeModifier');
        pMap('RL32IRQSourceModifier')=get_param(model,'RL32IRQSourceModifier');
        pMap('xPCIRQSourceBoard')=get_param(model,'xPCIRQSourceBoard');
        pMap('xPCIOIRQSlot')=get_param(model,'xPCIOIRQSlot');
        pMap('RL32LogTETModifier')=get_param(model,'RL32LogTETModifier');
        pMap('xPCLoadParamSetFile')=get_param(model,'xPCLoadParamSetFile');
    else
        pMap=[];
    end

end

