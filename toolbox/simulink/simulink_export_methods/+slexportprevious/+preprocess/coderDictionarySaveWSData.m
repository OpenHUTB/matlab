function coderDictionarySaveWSData(obj)




    modelNameNoPath=obj.modelName;
    modelNameFullPath=obj.modelFile;

    ws=get_param(modelNameNoPath,'ModelWorkspace');
    if isempty(ws)||isempty(ws.whos)

        return;
    end


    dataSource=ws.DataSource;
    if(strcmp(dataSource,'Model File')&&...
        ((isR2011bOrEarlier(obj.ver)&&l_wsContainsMCOSObjects(ws,'Simulink.Data'))||...
        (isR2012bOrEarlier(obj.ver)&&l_wsContainsMCOSObjects(ws,'Simulink.DataType'))||...
        (isR2012bOrEarlier(obj.ver)&&l_wsContainsMCOSObjects(ws,'Simulink.StructElement'))||...
        (isR2012bOrEarlier(obj.ver)&&l_wsContainsMCOSObjects(ws,'embedded.fi'))))


        fullFileName=[l_getUniqueFileName(modelNameFullPath),'.m'];
        [~,fileName,ext]=fileparts(fullFileName);
        Simulink.output.info(DAStudio.message('Simulink:ExportPrevious:SaveDataToMATLABFile',obj.ver.release,fullFileName));

        l_exportWorkspaceDataToMATLABScript(ws,fullFileName);

        ws.DataSource='MATLAB File';
        ws.FileName=[fileName,ext];
        ws.reload;
    elseif slfeature('AutoMigrationIM')>0&&isR2020aOrEarlier(obj.ver)&&...
        (l_wsContainsMCOSObjects(ws,'Simulink.Data')||...
        l_wsContainsMCOSObjects(ws,'Simulink.LookupTable')||...
        l_wsContainsMCOSObjects(ws,'Simulink.Breakpoint'))


        if~strcmp(dataSource,'Model File')

            ws.DataSource='Model File';
        end
    end
end




function filepath=l_getUniqueFileName(name)


    if isempty(name)
        filepath=tempname;
    else
        [dirName,modelName]=fileparts(name);
        filepathBase=[dirName,filesep,modelName,'_saveas'];
        filepath=filepathBase;
        count=0;
        while((exist([filepath,'.m'],'file')==2)||...
            (exist([filepath,'.mat'],'file')==2))
            count=count+1;
            filepath=[filepathBase,num2str(count)];
        end
    end
end


function hasObjects=l_wsContainsMCOSObjects(ws,className)

    hasObjects=false;

    varList=ws.whos;
    for idx=1:length(varList)
        var=ws.getVariable(varList(idx).name);
        if(isobject(var)&&isa(var,className))
            hasObjects=true;
            return;
        end
    end
end

function l_exportWorkspaceDataToMATLABScript(ws,fullFileName)

    evalin(ws,['matlab.io.saveVariablesToScript(''',fullFileName,''');']);
end


