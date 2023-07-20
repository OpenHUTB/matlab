function ResultDescription=checkFcnCallUsage(system,checklist)



    model=bdroot(system);
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ResultDescription={{''};{''}};





    ftList=...
    locComposeFcnCallUsageResultString(model,checklist,ResultDescription);


    [ResultStatus,ftList]=...
    locCheckFcnCallConfigSetParams(model,checklist,ftList);


    if min(ResultStatus)==true
        mdladvObj.setCheckResultStatus(true);
        mdladvObj.setActionEnable(false);
    elseif isa(getActiveConfigSet(model),'Simulink.ConfigSetRef')
        mdladvObj.setActionEnable(false);
    else
        mdladvObj.setActionEnable(true);
    end

    ftList{end}.setSubBar(0);
    ResultDescription=ftList;




    function ftList=locComposeFcnCallUsageResultString(model,checklist,resultDesc)


        encodedModelName=modeladvisorprivate('HTMLjsencode',get_param(model,'Name'),'encode');
        encodedModelName=[encodedModelName{:}];


        cs=getActiveConfigSet(bdroot(model));
        ftList={};
        for i=1:size(checklist,1)



            ft=ModelAdvisor.FormatTemplate('ListTemplate');

            paramStr='';
            if~isempty(cs)
                propcfg=slCfgPrmDlg(model,'Param2UI',checklist{i,1});
                if isfield(propcfg,'Type')&&strcmp(propcfg.Type,'NonUI')
                    paramStr='';
                else
                    paramStr=checklist{i,1};
                end
            end
            xlateTag1=['Simulink:tools:FcnCallUsageHyperLink',num2str(i)];
            xlateTag='Simulink:tools:FcnCallUsageRecAction';


            encodedURL=Advisor.Utils.getHyperlinkToConfigSetParameter(encodedModelName,paramStr);
            encodedURL=char(encodedURL.Hyperlink);

            msgStr=DAStudio.message(...
            xlateTag,...
            ['<a href = "',encodedURL,'">',DAStudio.message(xlateTag1),'</a>']);
            ft.setRecAction(ModelAdvisor.Text(msgStr));

            xlateTag=['Simulink:tools:FcnCallUsageSubTitle',num2str(i)];
            msgStr=ModelAdvisor.Text(DAStudio.message(xlateTag),{'bold'});
            ft.setSubTitle(msgStr);
            xlateTag=['Simulink:tools:FcnCallUsageInfo',num2str(i)];
            msgStr=ModelAdvisor.Text(DAStudio.message(xlateTag));
            ft.setInformation(msgStr);
            refLinks=cell(1,size(resultDesc{i},1));
            for j=1:size(resultDesc{i},1)
                refLinks{j}={ModelAdvisor.Text(resultDesc{i}{j})};
            end
            ft.setRefLink(refLinks);
            ftList{i}=ft;%#ok<*AGROW>
        end




        function[fcncallParamStr]=locGetFcnCallConfigSetParamStr(model,paramName)
            if strcmp(paramName,'FcnCallInpInsideContextMsg')
                fcncallParamStr=DAStudio.message(...
                ['ModelAdvisor:engine:',get_param(model,paramName)]);
            else
                fcncallParamStr=get_param(model,paramName);
            end




            function[status,ftList]=locCheckFcnCallConfigSetParams(model,checklist,ftList)


                status(1:size(checklist,1))=false;

                for i=1:size(checklist,1)
                    ftList{i}.setSubResultStatus('Warn');
                    ftList{i}.setSubResultStatusText(...
                    DAStudio.message(...
                    ['Simulink:tools:FcnCallUsageFailMsg',num2str(i)],...
                    locGetFcnCallConfigSetParamStr(model,checklist{i,1})));

                    if strcmpi(get_param(model,checklist{i,1}),checklist{i,2});
                        status(i)=true;
                        ftList{i}.RecAction='';
                        ftList{i}.setSubResultStatus('Pass');
                        ftList{i}.setSubResultStatusText(...
                        DAStudio.message(...
                        ['Simulink:tools:FcnCallUsagePassMsg',num2str(i)]));
                    end
                end

