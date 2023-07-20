function[UD,saveStruct]=create_save_struct(UD)






    UD=dataSet_store(UD);



    saveStruct.gridSetting=UD.current.gridSetting;
    saveStruct.channels=rmfield(UD.channels,...
    {'lineH','leftDisp','rightDisp','axesInd'});
    if isfield(UD,'axes')&&~isempty(UD.axes)
        saveStruct.axes=rmfield(UD.axes,...
        {'handle','numChannels','lineLabels','vertProportion'});
    else
        saveStruct.axes=[];
    end
    if isfield(UD.common,'reqUIOpen')
        UD.common=rmfield(UD.common,'reqUIOpen');
    end
    saveStruct.common=rmfield(UD.common,'dirtyFlag');
    saveStruct.dataSet=UD.dataSet;
    saveStruct.dataSetIdx=UD.current.dataSetIdx;
    saveStruct.isVerificationVisible=UD.current.isVerificationVisible;



    if isfield(UD,'sbobj')
        saveStruct.sbobj=UD.sbobj;
    end
