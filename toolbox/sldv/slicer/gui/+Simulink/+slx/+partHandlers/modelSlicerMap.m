function h=modelSlicerMap






    if~exist('modelslicerprivate','file')

        return;
    end
    h=Simulink.slx.PartHandler(i_id,'blockDiagram',@i_load,@i_save);

end

function id=i_id
    id='ModelSlicerMap';
end

function name=i_partname
    name='/modelslicer/mapping.mat';
end

function p=get_modelslicer_partinfo
    p=Simulink.loadsave.SLXPartDefinition(i_partname,...
    '/simulink/blockdiagram.xml',...
    'application/vnd.mathworks.matlab.mat+binary',...
    'http://schemas.mathworks.com/simulink/2014/relationships/ModelSlicerMap',...
    i_id);
end

function i_load(modelHandle,loadOptions)
    if Simulink.harness.isHarnessBD(modelHandle)

        return;
    end
    if~loadOptions.readerHandle.hasPart(i_partname)

        return;
    end

    filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
    loadOptions.readerHandle.readPartToFile(i_partname,filename);
    assert(exist(filename,'file')~=0,'Extracted part not present');

    data=load(filename);

    if~isempty(data.slicerMap)

        slicerMap=Transform.SliceMapper.loadobj(data.slicerMap);
        modelslicerprivate('sliceMdlMapperObj','set',get_param(modelHandle,'Handle'),...
        slicerMap);
        if~isempty(slicerMap.origMdlName)&&bdIsLoaded(slicerMap.origMdlName)
            slicerMap.setAsActiveSlice();
        end
    end
end

function i_save(modelHandle,saveOptions)

    filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);


    slicerMap=[];
    if exist('modelslicerprivate','file')
        try
            slicerMap=modelslicerprivate('sliceMdlMapperObj','get',get_param(modelHandle,'Handle'));
        catch Mex %#ok<NASGU>
        end
    end

    part=get_modelslicer_partinfo;

    if isempty(slicerMap)||~shouldSaveMap(modelHandle,slicerMap)
        if exist(filename,'file')

            delete(filename);
        end


        if isOwnerModel(modelHandle)
            saveOptions.writerHandle.deletePart(part);
        end
        return;
    end

    if saveOptions.isExportingToReleaseOrOlder('R2014a')


        if exist(filename,'file')
            delete(filename);
        end
        saveOptions.writerHandle.deletePart(part);
        return;
    end

    slicerMap=slicerMap.saveobj();
    save(filename,'slicerMap');
    saveOptions.writerHandle.writePartFromFile(part,filename);
end

function yesno=shouldSaveMap(modelHandle,slicerMap)
    model_to_save=modelHandle;
    orig_modelH=slicerMap.origMdlH;
    yesno=...
    (isHarnessModel(model_to_save)==isHarnessModel(orig_modelH));
end

function yesno=isOwnerModel(modelHandle)
    if isHarnessModel(modelHandle)
        harness_model_name=get_param(modelHandle,'name');
        owner_modelH=Simulink.harness.internal.getHarnessOwnerBD(modelHandle);
        owner_model_name=get_param(owner_modelH,'name');
        yesno=strcmp(harness_model_name,owner_model_name);
    else
        yesno=true;
    end
end

function yesno=isHarnessModel(modelHandle)
    yesno=...
    ~isempty(modelHandle)&&ishandle(modelHandle)&&strcmp(get_param(modelHandle,'isHarness'),'on');
end

