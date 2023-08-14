function styleguide_jm_0011()




    rec=ModelAdvisor.Check('mathworks.maab.jm_0011');



    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jm0011Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jm0011Tip');
    rec.setCallbackFcn(@jm_0011_StyleOneCallback,'None','StyleOne');
    rec.Value=true;
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jm_0011';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end

function ResultDescription=jm_0011_StyleOneCallback(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');







    ft.setInformation(ModelAdvisor.Common.getStrings(...
    'CheckNotAppliesToMatlabActionLanguage'));

    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': jm_0011'];
    ft.setCheckText(DAStudio.message('ModelAdvisor:styleguide:jm0011CheckText'))
    ft.setSubBar(0);
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:jm0011ColTitle1'),DAStudio.message('ModelAdvisor:styleguide:jm0011ColTitle1')});
    m=get_param(system,'Object');
    chartArray=m.find('-isa','Stateflow.Chart');


    ResultDescription={};
    info={};tableInfo={};%#ok<NASGU>
    for ii=1:length(chartArray)
        chartObj=chartArray(ii);


        if Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
            continue;
        end

        StatesTransitions=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');
        for jj=1:length(StatesTransitions)
            obj=StatesTransitions(jj);

            asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
            if isempty(asts)
                continue;
            end
            indices=[];
            info={};

            sections=asts.sections;
            for i=1:length(sections)
                roots=sections{i}.roots;
                for j=1:length(roots)
                    indices=[indices;iVerifyNoPtr(roots{j})];%#ok<AGROW>
                end
            end
            for i=1:size(indices,1)

                obj=mdladvObj.filterResultWithExclusion(obj);
                if isempty(obj)
                    continue;
                end
                if isa(obj,'Stateflow.State')
                    linkStr=ModelAdvisor.Text([obj.Path,'/',obj.Name]);
                else
                    linkStr=ModelAdvisor.Text(obj.Path);
                end
                objID=Simulink.ID.getSID(obj);
                linkStr.setHyperlink(['matlab: Simulink.ID.hilite(''',objID,''')']);
                info=[info;{Advisor.Utils.Stateflow.highlightSFLabelByIndex(obj.LabelString,indices(i,:)),linkStr}];%#ok<AGROW>            
            end
            tableInfo=[tableInfo;info];%#ok<AGROW>
        end
    end
    if isempty(tableInfo)
        mdladvObj.setCheckResultStatus(true);
        ft.setSubResultStatus('pass');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:jm0011PassMsg'));
    else
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:jm0011FailMsg'));
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:jm0011RecAction'));
        ft.setTableInfo(tableInfo);
    end
    ResultDescription{1}=ft;
end

function indices=iVerifyNoPtr(ast)

    indices=[];
    if(isa(ast,'Stateflow.Ast.Pointer')||isa(ast,'Stateflow.Ast.ContentOf')||isa(ast,'Stateflow.Ast.AddressOf'))
        indices=[indices;[ast.treeStart,ast.treeEnd]];
    end

    children=ast.children;
    for i=1:length(children)
        indices=[indices;iVerifyNoPtr(children{i})];%#ok<AGROW>
    end
end

