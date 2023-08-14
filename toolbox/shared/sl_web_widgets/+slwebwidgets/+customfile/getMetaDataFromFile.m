function[jsonStruct,warnStr,datasourceMetrics]=getMetaDataFromFile(aFile)




    try
        warnStr='';
        datasourceMetrics=[];
        variableMetaData=whos(aFile);

        jsonStruct=cell(1,length(variableMetaData));
        indexToRemove=[];
        for k=1:length(variableMetaData)

            if~isfield(variableMetaData(k),'type')||...
                isempty(variableMetaData(k).type)
                variableMetaData(k).type=Simulink.io.FileType.getVariableTypeFromVariable(inVar);
            end


            jsonStruct{k}.ID=num2str(k);
            jsonStruct{k}.Name=variableMetaData(k).name;
            jsonStruct{k}.ParentName=[];
            jsonStruct{k}.ParentID='input';

            [~,justFileName,ext]=fileparts(aFile.FileName);

            jsonStruct{k}.DataSource=[justFileName,ext];
            jsonStruct{k}.FullDataSource=aFile.FileName;

            switch(lower(variableMetaData(k).type))
            case 'dataset'
                jsonStruct{k}.Icon='variable_object.png';
                jsonStruct{k}.Type='DataSet';
            case 'signal'
                jsonStruct{k}.Icon='signal.png';
                jsonStruct{k}.Type='Signal';
            case 'bus'
                jsonStruct{k}.Icon='bus.png';
                jsonStruct{k}.Type='Bus';
            case 'functioncall'
                jsonStruct{k}.Icon='variable_function_call.png';
                jsonStruct{k}.Type='FunctionCall';
            case 'ground'
                jsonStruct{k}.Icon='ground_16.png';
                jsonStruct{k}.Type='GroundOrPartialSpecification';
            case 'savetoworkspaceformatstruct'
                jsonStruct{k}.Icon='variable_object.png';
                jsonStruct{k}.Type=message('sl_web_widgets:customfiles:simStruct').getString;
            otherwise

                if isempty(indexToRemove)
                    indexToRemove(1)=k;
                else
                    indexToRemove(end+1)=k;
                end
            end
            jsonStruct{k}.isEnum=false;
            jsonStruct{k}.isString=false;
            jsonStruct{k}.TreeOrder=k;
        end


        if~isempty(indexToRemove)
            jsonStruct(indexToRemove)=[];
        end
    catch ME
        throw(ME);
    end

end
