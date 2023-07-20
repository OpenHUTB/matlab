function h=ipcore





    h=Simulink.slx.PartHandler('ipcore','blockDiagram',@i_load,@i_save);

end

function name=i_partname
    name='/ipcore/ipcore.xml';
end

function p=i_partinfo
    persistent part_info;
    if isempty(part_info)
        content_type='application/vnd.mathworks.simulink.mf0+xml';
        relationship_type=...
        'http://schemas.mathworks.com/simulinkModel/2016/relationships/ipcore';
        id='ipcore';
        parent='';
        part_info=Simulink.loadsave.SLXPartDefinition(i_partname,parent,content_type,relationship_type,id);
    end
    p=part_info;
end

function i_load(modelHandle,loadOptions)%#ok<INUSD> 


end

function i_save(modelHandle,saveOptions)


    if(slfeature('HDLTargetModelMapping')==0)||Simulink.harness.isHarnessBD(modelHandle)
        return;
    end

    [isMappedToHDL,modelMapping]=hdlcoder.mapping.internal.ModelUtils.isMapped(modelHandle);
    if~isMappedToHDL

        saveOptions.writerHandle.deletePart(i_partinfo);
        return;
    end

    mf0Model=modelMapping.IPCORE_MF0MODEL;
    if mf0Model.isvalid()

        fileName=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
        serializer=mf.zero.io.XmlSerializer;
        serializer.serializeToFile(mf0Model,fileName);


        saveOptions.writerHandle.writePartFromFile(i_partinfo,fileName);
    end
end


