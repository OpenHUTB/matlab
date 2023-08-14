function h=modelAdvisorExclusions






    h=Simulink.slx.PartHandler(i_id,'blockDiagram',[],@i_save);

end

function id=i_id
    id='ModelAdvisorExclusions';
end

function name=i_partname
    name='/advisor/exclusions.xml';
end

function p=i_advisor_partinfo
    p=Simulink.loadsave.SLXPartDefinition(i_partname,...
    '/simulink/blockdiagram.xml',...
    'application/vnd.mathworks.simulink.advisor+xml',...
    'http://schemas.mathworks.com/simulink/2015/relationships/Advisor',...
    i_id);
end

function i_save(modelHandle,saveOptions)
    if Simulink.harness.isHarnessBD(modelHandle)
        return;
    end






    newFile=slcheck.getFilterFilePath(modelHandle);
    [oldFile,bInsideModel]=slcheck.getOldExclusionFileDetails(modelHandle);



    if~isempty(newFile)&&exist(newFile,'file')
        deleteCondition=...
        ~isempty(oldFile)&&exist(oldFile,'file')&&...
        bInsideModel&&...
        ~contains(fileread(oldFile),'CloneDetection');

        if deleteCondition
            saveOptions.writerHandle.deletePart(i_advisor_partinfo);
            return;
        end
    end


    if isempty(get_param(modelHandle,'MAModelExclusionFile'))



        exclusions_file=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
        if~exist(exclusions_file,'file')
            return
        end
        saveOptions.writerHandle.writePartFromFile(i_advisor_partinfo,exclusions_file);


        cp=simulinkcoder.internal.CodePerspective.getInstance;
        if(strcmp(edittime.getAdvisorChecking(modelHandle),'on')||...
            cp.isInPerspective(modelHandle))
            edittime.setAdvisorChecking(get_param(modelHandle,'Name'),'off');
            edittime.setAdvisorChecking(get_param(modelHandle,'Name'),'on');
        end
    else
        saveOptions.writerHandle.deletePart(i_advisor_partinfo);
    end
end
