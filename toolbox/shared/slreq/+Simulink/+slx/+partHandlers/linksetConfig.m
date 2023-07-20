function h=linksetConfig






    h=Simulink.slx.PartHandler(i_id(),'blockDiagram',@i_load,@i_save);

end

function id=i_id
    id='SlreqLinkset';
end

function name=i_partname
    [~,name]=slreq.utils.getEmbeddedLinksetName;
end

function p=i_partinfo
    p=Simulink.loadsave.SLXPartDefinition(i_partname,...
    '/simulink/blockdiagram.xml',...
    'application/vnd.mathworks.simulink.linkset+binary',...
    'http://schemas.mathworks.com/simulink/2016/relationships/SlreqLinkset',...
    i_id);
end

function i_load(modelHandle,loadOptions)

    if~loadOptions.readerHandle.hasPart(i_partname)

        return;
    end
    partName=i_partname;
    fileName=Simulink.slx.getUnpackedFileNameForPart(modelHandle,partName);
    loadOptions.readerHandle.readPartToFile(partName,fileName);
end

function i_save(modelHandle,saveOptions)
    if Simulink.harness.isHarnessBD(modelHandle)
        return;
    end

    linkSetFile=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
    if~exist(linkSetFile,'file')
        saveOptions.writerHandle.deletePart(i_partinfo);
        return;
    end

    if saveOptions.isExportingToReleaseOrOlder('R2016b')


        if exist(linkSetFile,'file')
            delete(linkSetFile);
        end
        saveOptions.writerHandle.deletePart(i_partinfo);
        return;
    end


    modelPath=get_param(modelHandle,'FileName');
    linkSet=slreq.data.ReqData.getInstance.getLinkSet(modelPath);

    if isempty(linkSet)



        saveOptions.writerHandle.deletePart(i_partinfo);
        return;

    elseif linkSet.dirty
        linkSet.save();
    end


    saveOptions.writerHandle.writePartFromFile(i_partinfo,linkSetFile);

end

