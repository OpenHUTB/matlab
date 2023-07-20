

function result=modelAdvisormodifyConfigParams(checklist,taskobj,xlateTarget)



    result=ModelAdvisor.Paragraph();
    mdladvObj=taskobj.MAObj;


    system=bdroot(mdladvObj.System);
    status(1:size(checklist,1))=false;
    failedStr={};

    for i=1:size(checklist,1)
        try
            if(ischar(get_param(system,checklist{i,1}))&&~strcmpi(get_param(system,checklist{i,1}),checklist{i,2}))...
                ||(isnumeric(get_param(system,checklist{i,1}))&&get_param(system,checklist{i,1})~=checklist{i,2})

                set_param(system,checklist{i,1},checklist{i,2});

                status(i)=true;
            end
        catch
            msgStr=ModelAdvisor.Text(...
            DAStudio.message([xlateTarget,'MissingParameterMsg'],checklist{i,1}),...
            {'fail'});
            failedStr{end+1}=msgStr;
            failedStr{end+1}=ModelAdvisor.LineBreak;
        end
    end

    if~any(status)
        msgStr=ModelAdvisor.Text(DAStudio.message([xlateTarget,'NoneModified']),{'pass'});
        result.addItem(msgStr);
    else
        msgStr=ModelAdvisor.Text(DAStudio.message([xlateTarget,'Modified']),{'pass'});
        result.addItem(msgStr);
        msgStr=ModelAdvisor.Text([' ',num2str(length(find(status)))],{'bold'});
        result.addItem(msgStr);
        result.addItem(ModelAdvisor.LineBreak);
        result.addItem(ModelAdvisor.LineBreak);
        for i=1:size(checklist,1)
            if status(i)
                propcfg=slCfgPrmDlg(system,'Param2UI',checklist{i,1});
                if isfield(propcfg,'Type')&&strcmp(propcfg.Type,'NonUI')
                    msgStr=ModelAdvisor.Text(checklist{i,1},{'bold'});
                    result.addItem(msgStr);
                    msgStr=ModelAdvisor.Text(' parameter');
                    result.addItem(msgStr);
                else
                    msgStr=ModelAdvisor.Text([propcfg.Path,' > ',strrep(propcfg.Prompt,':','')],{'bold'});
                    result.addItem(msgStr);
                end
                msgStr=ModelAdvisor.Text(DAStudio.message([xlateTarget,'SetTo']));
                result.addItem(msgStr);
                if isnumeric(checklist{i,2})
                    checklist{i,2}=num2str(checklist{i,2});
                end
                msgStr=ModelAdvisor.Text(['<tt> ',checklist{i,2},'</tt>']);
                result.addItem(msgStr);
                result.addItem(ModelAdvisor.LineBreak);
            end
        end
        result.addItem(ModelAdvisor.LineBreak);
    end

    if~isempty(failedStr)
        msgStr=ModelAdvisor.Text(DAStudio.message([xlateTarget,'FailedToModify']),{'fail','italic'});
        result.addItem(msgStr);
        result.addItem(ModelAdvisor.LineBreak);
        result.addItem(ModelAdvisor.LineBreak);
        result.addItem(failedStr);
        result.addItem(ModelAdvisor.LineBreak);
    end
