function h=modelWorkspace







    h=Simulink.slx.PartHandler('modelWorkspace','blockDiagram',@i_load,@i_save);

end

function id=i_relationship_id(modelHandle)
    id=Simulink.slx.getPartIDFromSuffix(modelHandle,'modelWorkspace');
end

function relationship_type=i_relationship_type
    relationship_type=['http://schemas.mathworks.com/'...
    ,'simulinkModel/2010/relationships/modelWorkspaceData'];
end

function name=i_matfile_partname(prefix)


    name=[prefix,'modelworkspace.mat'];
end

function p=i_matfile_partinfo(modelHandle,prefix)
    persistent part_info;
    if isempty(part_info)


        name=i_matfile_partname(prefix);
        id=i_relationship_id(modelHandle);
        content_type='application/vnd.mathworks.matlab.mat+binary';
        part_info=Simulink.loadsave.SLXPartDefinition(name,'',content_type,i_relationship_type,id);
    end
    if isempty(modelHandle)||~Simulink.harness.isHarnessBD(modelHandle)
        p=part_info;
    else


        p=Simulink.loadsave.SLXPartDefinition(i_matfile_partname(prefix),'',part_info.contentType,...
        part_info.relationshipType,i_relationship_id(modelHandle));
    end
end

function name=i_mxarray_partname(prefix)


    name=[prefix,'modelWorkspace.mxarray'];
end

function p=i_mxarray_partinfo(modelHandle,prefix)
    persistent part_info;
    if isempty(part_info)


        name=i_mxarray_partname(prefix);
        id=i_relationship_id(modelHandle);
        content_type='application/vnd.mathworks.matlab.mxarray+binary';
        part_info=Simulink.loadsave.SLXPartDefinition(name,'',content_type,i_relationship_type,id);
    end
    if isempty(modelHandle)||~Simulink.harness.isHarnessBD(modelHandle)
        p=part_info;
    else


        p=Simulink.loadsave.SLXPartDefinition(i_mxarray_partname(prefix),'',part_info.contentType,...
        part_info.relationshipType,i_relationship_id(modelHandle));
    end
end

function i_apply(modelHandle,data)




    names=fieldnames(data);
    values=struct2cell(data);
    data=struct('Name',names,'Value',values);
    set_param(modelHandle,'WSMdlFileData',data);
end

function i_load(modelHandle,loadOptions)



    if slfeature('SLModelOwnedDataDictionary')>0&&...
        ~isempty(get_param(modelHandle,'ModelOwnedDictionaryFile'))

        moddFilespec=get_param(modelHandle,'ModelOwnedDictionaryFile');
        filename=i_extractMODD(modelHandle,moddFilespec,'/modelOwnedDictionary/modelworkspace.mat');
        data=load(filename);
        names=fieldnames(data);
        values=struct2cell(data);
        data=struct('Name',names,'Value',values);
        set_param(modelHandle,'WSMdlFileData',data);
    else
        partName=i_matfile_partname(loadOptions.getPartNamePrefix);
        found=loadOptions.readerHandle.hasPart(partName);
        if found


            filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,partName);
            loadOptions.readerHandle.readPartToFile(partName,filename);
            data=load(filename);
            i_apply(modelHandle,data);
        else
            partName=i_mxarray_partname(loadOptions.getPartNamePrefix);
            found=loadOptions.readerHandle.hasPart(partName);
            if found


                data=loadOptions.readerHandle.readPartToVariable(partName);
                i_apply(modelHandle,data);
            end
        end
    end
end

function skip=i_skip_resave(modelHandle,saveOptions)
    skip=false;
    if saveOptions.writerHandle.hasPart(i_matfile_partname(saveOptions.getPartNamePrefix))

        return;
    end
    if Simulink.slx.isPartDirty(modelHandle,'blockDiagram')

        return;
    end

    skip=true;
end

function i_save(modelHandle,saveOptions)
    if i_skip_resave(modelHandle,saveOptions)
        return;
    end
    if~strcmp(get_param(modelHandle,'WSDataSource'),'Model File')


        i_delete_all(modelHandle,saveOptions);
        return;
    end
    ws=get_param(modelHandle,'ModelWorkspace');
    if isempty(ws)||isempty(ws.data)

        i_delete_all(modelHandle,saveOptions);
        return;
    end



    if slfeature('SLModelOwnedDataDictionary')>0&&...
        ~isempty(get_param(modelHandle,'ModelOwnedDictionaryFile'))
        moddName=get_param(modelHandle,'ModelOwnedDictionaryFile');
        ws.saveToExternalDictionary(moddName);
        i_delete_all(modelHandle,saveOptions);
        return;
    end


    if isempty(saveOptions.targetRelease)||...
        ~isR2019aOrEarlier(saveas_version(saveOptions.targetRelease))


        info=ws.data;
        varnames={info.Name};
        varvalues={info.Value};
        data=cell2struct(varvalues,varnames,2);
        pi=i_mxarray_partinfo(modelHandle,saveOptions.getPartNamePrefix);
        saveOptions.writerHandle.writePartFromVariable(pi,data);
        saveOptions.writerHandle.deletePart(i_matfile_partinfo(modelHandle,saveOptions.getPartNamePrefix));
    else

        filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_matfile_partname(saveOptions.getPartNamePrefix));
        if~strcmp(get_param(modelHandle,'Lock'),'on')
            ws.save(filename);
        end
        saveOptions.writerHandle.writePartFromFile(i_matfile_partinfo(modelHandle,saveOptions.getPartNamePrefix),filename);
        saveOptions.writerHandle.deletePart(i_mxarray_partinfo(modelHandle,saveOptions.getPartNamePrefix));
    end
end

function i_delete_all(modelHandle,saveOptions)
    saveOptions.writerHandle.deletePart(i_matfile_partinfo(modelHandle,saveOptions.getPartNamePrefix));
    saveOptions.writerHandle.deletePart(i_mxarray_partinfo(modelHandle,saveOptions.getPartNamePrefix));
end


function filename=i_extractMODD(modelHandle,moddName,partName)



    filename=Simulink.slx.getUnpackedFileNameForPart(modelHandle,partName);
    dest=get_param(modelHandle,'UnpackedLocation');
    Simulink.dd.extractFilePart(moddName,partName,dest);
end


