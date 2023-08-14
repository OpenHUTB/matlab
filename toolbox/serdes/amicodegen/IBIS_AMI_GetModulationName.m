

function name=IBIS_AMI_GetModulationName
    mws=get_param(bdroot,'ModelWorkspace');
    if contains(get_param(bdroot,'Name'),'Tx')&&mws.hasVariable('TxTree')
        tree=mws.getVariable('TxTree');
    elseif contains(get_param(bdroot,'Name'),'Rx')&&mws.hasVariable('RxTree')
        tree=mws.getVariable('RxTree');
    else
        error(message('serdes:rtwserdes:ModelMustBeTxRx'));
    end
    modulation=tree.getReservedParameter('Modulation');
    modulationLevels=tree.getReservedParameter('Modulation_Levels');
    if~isempty(modulation)
        name='Modulation';
    elseif~isempty(modulationLevels)
        name='Modulation_Levels';
    else
        error(message('serdes:rtwserdes:NoModulation'))
    end
end