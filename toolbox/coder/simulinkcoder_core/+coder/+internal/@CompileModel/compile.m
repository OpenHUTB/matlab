function compile(hSrc,hModel)








    if isempty(hSrc.savedEngineInterface)
        hSrc.savedEngineInterface=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.embeddedCoder);
    end
    hSrc.bdObject=get_param(hModel,'Object');
    hSrc.bdObject.init('COMMAND_LINE','UpdateBDOnly','on');
    hSrc.modelNeedsTerm=true;
