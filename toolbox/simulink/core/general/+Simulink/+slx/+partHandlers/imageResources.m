function h=imageResources




    h=Simulink.slx.PartHandler('resources','blockDiagram',[],@i_save);
end

function i_save(modelHandle,saveOptions)


    if~Simulink.slx.isPartDirty(modelHandle,'blockDiagram')&&...
        ~Simulink.slx.isPartDirty(modelHandle,'Stateflow')
        return;
    end

    writer=saveOptions.writerHandle;


    folder=[saveOptions.getPartNamePrefix,'resources'];

    if saveOptions.isExportingToReleaseOrOlder('R2013b')
        parts=writer.getMatchingPartDefinitions(folder);
        for i=1:numel(parts)
            writer.deletePart(parts(i));
        end
        return;
    end

    existing_partnames=writer.getMatchingPartNames(folder);


    required_parts=getModelResourcesFiles(modelHandle);


    to_delete=setdiff(existing_partnames,required_parts);
    for i=1:numel(to_delete)
        p=i_partinfo(to_delete{i});
        writer.deletePart(p);
    end


    to_write=setdiff(required_parts,existing_partnames);
    if~isempty(to_write)
        files=slfullfile(get_param(modelHandle,'UnpackedLocation'),to_write);
        for i=1:numel(to_write)
            p=i_partinfo(to_write{i});


            if~isempty(Simulink.loadsave.resolveFile(files{i}))
                writer.writePartFromFile(p,files{i});
            end
        end
    end



end

function part=i_partinfo(partname)


    parent='/simulink/blockdiagram.xml';

    id=matlab.lang.makeValidName(partname);
    relType='http://schemas.mathworks.com/simulinkModel/2010/relationships/resources';

    contentType=i_get_content_type(partname);
    part=Simulink.loadsave.SLXPartDefinition(partname,parent,contentType,relType,id);
end

function type=i_get_content_type(partname)

    type='image/';

    index=find(ismember(fliplr(partname),'.'),1);

    if~isempty(index)
        extension=partname(length(partname)-(index-2):length(partname));
    else
        extension='';
    end
    if~isempty(extension)
        type=strcat(type,extension);
    end
end
