function h=modelAdvisorFilters




    h=Simulink.slx.PartHandler(i_id,'blockDiagram',[],@i_save);

end

function id=i_id
    id='ModelAdvisorFilters';
end

function name=i_partname
    name='/advisor/filters.xml';
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

    if isempty(get_param(modelHandle,'MAModelFilterFile'))



        filters_file=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
        if~exist(filters_file,'file')
            return
        end


        cp=simulinkcoder.internal.CodePerspective.getInstance;
        if(strcmp(get_param(modelHandle,'ShowEditTimeAdvisorChecks'),'on')||...
            cp.isInPerspective(modelHandle))
            edittime.setAdvisorChecking(get_param(modelHandle,'Name'),'off');
            edittime.setAdvisorChecking(get_param(modelHandle,'Name'),'on');
        end

        saveOptions.writerHandle.writePartFromFile(i_advisor_partinfo,filters_file);
    else
        saveOptions.writerHandle.deletePart(i_advisor_partinfo);
    end
end
