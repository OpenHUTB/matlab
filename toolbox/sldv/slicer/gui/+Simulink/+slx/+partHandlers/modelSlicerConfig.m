function h=modelSlicerConfig






    h=Simulink.slx.PartHandler(i_id,'blockDiagram',@i_load,@i_save);

end

function id=i_id
    id='ModelSlicerConfiguration';
end

function name=i_partname
    name='/modelslicer/configuration.mat';
end

function p=get_modelslicer_partinfo
    p=Simulink.loadsave.SLXPartDefinition(i_partname,...
    '/simulink/blockdiagram.xml',...
    'application/vnd.mathworks.matlab.mat+binary',...
    'http://schemas.mathworks.com/simulink/2014/relationships/ModelSlicerConfiguration',...
    i_id);
end

function i_load(modelHandle,loadOptions)
    if~loadOptions.readerHandle.hasPart(i_partname)

        return;
    end

    filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
    loadOptions.readerHandle.readPartToFile(i_partname,filename);
end

function i_save(modelHandle,saveOptions)
    if~exist('SlicerConfiguration','class')
        return;
    end



    sc=SlicerConfiguration.configurationMapper('get',modelHandle);

    if isempty(sc)


        slicerConfigMap=SlicerConfiguration.mdl2SCMapFile;
        if exist(slicerConfigMap,'file')
            map=load(slicerConfigMap);
            if isfield(map,'mdl2SCObj')...
                &&isa(map.mdl2SCObj,'containers.Map')...
                &&isKey(map.mdl2SCObj,modelHandle)
                sc=map.mdl2SCObj(modelHandle);
                sc.options=sc.Options;

                map.mdl2SCObj.remove(modelHandle);
                modelName=get_param(modelHandle,'FileName');
                if isKey(map.mdl2SCFile,modelName)
                    map.mdl2SCFile.remove(modelName);
                end
                mdl2SCFile=map.mdl2SCFile;
                mdl2SCObj=map.mdl2SCObj;
                save(SlicerConfiguration.mdl2SCMapFile,'mdl2SCFile','mdl2SCObj','-append');
            end
        end
    end

    configFile=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
    p=get_modelslicer_partinfo;

    if isempty(sc)&&~exist(configFile,'file')
        saveOptions.writerHandle.deletePart(p);
        return;
    end

    if saveOptions.isExportingToReleaseOrOlder('R2014a')


        if exist(configFile,'file')
            delete(configFile);
        end
        saveOptions.writerHandle.deletePart(p);
        return;
    end

    if~isempty(sc)
        if sc.options.Storage.SaveInModel

            if isa(sc,'SlicerConfiguration')
                sc.saveConfigurationToFile(configFile);
            else
                SlicerConfiguration.saveToFile(configFile,sc,modelName);
            end
            saveOptions.writerHandle.writePartFromFile(p,configFile);
        else
            if exist(configFile,'file')
                delete(configFile);
            end
            saveOptions.writerHandle.deletePart(p);
        end
    end
end

