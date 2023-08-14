




function stimulusStopTimeCalculation(block)
    mws=get_param(bdroot(block),'ModelWorkspace');
    requiredMWSElements=["SymbolTime"];
    if~isempty(mws)&&all(arrayfun(@(x)mws.hasVariable(x),requiredMWSElements))
        maskObj=Simulink.Mask.get(block);
        maskNames={maskObj.Parameters.Name};
        maskValues={maskObj.Parameters.Value};
        maskNamesValues=cell2struct(maskValues,maskNames,2);
        dcs=maskObj.getDialogControl('SimStopTimeText');
        maskTextSimStopTimeString='Recommended simulation stop time (s): ';
        maskNumberOfSymbols=get_param(block,'NumberOfSymbols');
        if~strcmp(maskNumberOfSymbols,'NaN')
            tempSymbolTime=mws.getVariable('SymbolTime');
            tempSymbolTimeValue=tempSymbolTime.Value;
            prbsLength=str2double(maskNumberOfSymbols);
            calculatedStopTime=tempSymbolTimeValue*prbsLength;
            dcs.Prompt=[maskTextSimStopTimeString,sprintf('%.15g',calculatedStopTime)];
        else
            dcs.Prompt=[maskTextSimStopTimeString,'NaN'];
        end
    end
end