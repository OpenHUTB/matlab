function outProps=getWaveformProperties(inStruct)




    outProps=struct;

    try
        if~isfield(inStruct,'modelName')||isempty(inStruct.modelName)
            [timeToUse,dataToUse]=Simulink.sta.editor.getTimeAndDataFromExpression(inStruct.timeString,inStruct.dataString);
        else
            [timeToUse,dataToUse]=Simulink.sta.editor.getTimeAndDataFromExpression(inStruct.timeString,inStruct.dataString,inStruct.modelName);
        end

        outProps.dataType=class(dataToUse);
        outProps.isValid=true;
    catch

        outProps.isValid=false;
    end
