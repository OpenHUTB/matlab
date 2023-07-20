function ResultDescription=modelAdvisorCheck_na_0001(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);
    bResult=true;
    ResultDescription={};

    ftPre=ModelAdvisor.FormatTemplate('TableTemplate');

    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': na_0001'];

    ftPre.setCheckText(DAStudio.message('ModelAdvisor:styleguide:na0001CheckText'));

    ftPre.setInformation(ModelAdvisor.Common.getStrings(...
    'CheckNotAppliesToMatlabActionLanguage'));

    ResultDescription{end+1}=ftPre;

    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setSubTitle(DAStudio.message('ModelAdvisor:styleguide:na0001SubTitle1'));
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:na0001ColTitle1'),...
    DAStudio.message('ModelAdvisor:styleguide:na0001ColTitle2')});
    ft.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0001SubCheckInfo1'));

    ft1=ModelAdvisor.FormatTemplate('TableTemplate');
    ft1.setSubTitle(DAStudio.message('ModelAdvisor:styleguide:na0001SubTitle2'));
    ft1.setInformation(DAStudio.message('ModelAdvisor:styleguide:na0001SubCheckInfo2'));
    ft1.setSubBar(0);
    ft1.setColTitles({DAStudio.message('ModelAdvisor:styleguide:na0001ColTitle1'),...
    DAStudio.message('ModelAdvisor:styleguide:na0001ColTitle2')});

    enabledTableInfo={};enabledTableInfoUnknown={};disabledTableInfo={};

    chartsWithEnabledBitOps=ModelAdvisor.Paragraph();
    chartsWithEnabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:na0001ListTitle1')));
    chartsWithDisabledBitOps=ModelAdvisor.Paragraph();
    chartsWithDisabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:na0001ListTitle2')));

    m=get_param(system,'Object');
    chartArray=m.find('-isa','Stateflow.Chart');

    for ii=1:length(chartArray)
        chartObj=chartArray(ii);

        if Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
            continue;
        end

        chartInfo=ModelAdvisor.Text(chartObj.Path);
        objID=Simulink.ID.getSID(chartObj.Path);
        chartInfo.setHyperlink(['matlab: Simulink.ID.hilite(''',objID,''')']);
        if chartObj.EnableBitOps
            chartsWithEnabledBitOps.addItem(ModelAdvisor.LineBreak);
            chartsWithEnabledBitOps.addItem(chartInfo);
            enFlag=1;
        else
            chartsWithDisabledBitOps.addItem(ModelAdvisor.LineBreak);
            chartsWithDisabledBitOps.addItem(chartInfo);
            enFlag=0;
        end
        StatesTransitions=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');
        for jj=1:length(StatesTransitions)
            obj=StatesTransitions(jj);

            asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
            if isempty(asts)
                continue;
            end
            info={};infoUnknown={};

            indices=[];
            indicesUnknown=[];

            sections=asts.sections;
            for i=1:length(sections)
                roots=sections{i}.roots;
                for j=1:length(roots)
                    [indicesTemp,indicesUnknownTemp]=iVerifyBitwiseOps(system,obj,roots{j},chartObj);
                    indices=[indices;indicesTemp];%#ok<AGROW>
                    indicesUnknown=[indicesUnknown;indicesUnknownTemp];%#ok<AGROW>
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
            if enFlag
                enabledTableInfo=[enabledTableInfo;info];%#ok<AGROW>
            else
                disabledTableInfo=[disabledTableInfo;info];%#ok<AGROW>            
            end

            for i=1:size(indicesUnknown,1)

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
                infoUnknown=[infoUnknown;{Advisor.Utils.Stateflow.highlightSFLabelByIndex(obj.LabelString,indicesUnknown(i,:)),linkStr}];%#ok<AGROW>
            end
            enabledTableInfoUnknown=[enabledTableInfoUnknown;infoUnknown];%#ok<AGROW>
        end
    end

    if length(chartsWithEnabledBitOps.Items)==1
        chartsWithEnabledBitOps.addItem(ModelAdvisor.LineBreak);
        chartsWithEnabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:NoChartsBitOpsFound')));
    end
    if length(chartsWithDisabledBitOps.Items)==1
        chartsWithDisabledBitOps.addItem(ModelAdvisor.LineBreak);
        chartsWithDisabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:NoChartsBitOpsFound')));
    end
    chartsWithEnabledBitOps.addItem(ModelAdvisor.LineBreak);
    chartsWithEnabledBitOps.addItem(ModelAdvisor.LineBreak);
    if isempty(enabledTableInfo)
        chartsWithEnabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:NoBitwiseOpsBooleanFound')));

        ft.setSubResultStatus('pass');
        if~isempty(enabledTableInfoUnknown)
            chartsWithEnabledBitOps.addItem(ModelAdvisor.LineBreak);
            chartsWithEnabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:NoteMessage'),{'bold'}));
            chartsWithEnabledBitOps.addItem(ModelAdvisor.LineBreak);
            chartsWithEnabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:NoteInconclusiveBitwiseOps')));
            chartsWithEnabledBitOps.addItem(ModelAdvisor.LineBreak);
            chartsWithEnabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:InconclusiveBitwiseOpsRecAction')));
            ft.setTableInfo(enabledTableInfoUnknown);
        end
    else
        bResult=false;
        chartsWithEnabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:BitwiseOpsBooleanFound')));
        ft.setSubResultStatus('warn');
        ft.setTableInfo(enabledTableInfo);
        ft.setRecAction(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:BitwiseOpsBooleanRecAction')));
    end
    enabledBitOpsSubResultText={};
    for i=1:length(chartsWithEnabledBitOps.Items)
        enabledBitOpsSubResultText{end+1}=chartsWithEnabledBitOps.Items(i);%#ok<AGROW>
    end


    ft.setSubResultStatusText(enabledBitOpsSubResultText);
    ResultDescription{end+1}=ft;
    chartsWithDisabledBitOps.addItem(ModelAdvisor.LineBreak);
    chartsWithDisabledBitOps.addItem(ModelAdvisor.LineBreak);
    if isempty(disabledTableInfo)
        ft1.setSubResultStatus('pass');
        chartsWithDisabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:NoBitwiseOpsFound')));
    else
        bResult=false;
        ft1.setTableInfo(disabledTableInfo);
        ft1.setSubResultStatus('warn');
        chartsWithDisabledBitOps.addItem(ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:BitwiseOpsFound')));
        ft1.setRecAction(DAStudio.message('ModelAdvisor:styleguide:BitwiseOpsFoundRecAction'));
    end
    disabledBitOpsSubResultText={};
    for i=1:length(chartsWithDisabledBitOps.Items)
        disabledBitOpsSubResultText{end+1}=chartsWithDisabledBitOps.Items(i);%#ok<AGROW>
    end
    ft1.setSubResultStatusText(disabledBitOpsSubResultText);
    ResultDescription{end+1}=ft1;
    mdladvObj.setCheckResultStatus(bResult);
end

function[indices,indicesUnknown]=iVerifyBitwiseOps(system,obj,ast,chartObj)



    indices=[];indicesUnknown=[];

    if(isa(ast,'Stateflow.Ast.LogicalAnd')||isa(ast,'Stateflow.Ast.LogicalOr')...
        ||isa(ast,'Stateflow.Ast.BitAnd')||isa(ast,'Stateflow.Ast.BitOr'))
        left=ast.lhs;
        right=ast.rhs;

        src=obj.LabelString(left.treeStart:right.treeEnd);
        if~(isa(left,'Stateflow.Ast.Trigger')||isa(right,'Stateflow.Ast.Trigger'))
            if(isaBitOp(src,left,right,'&')||isaBitOp(src,left,right,'|'))
                if(~obj.Chart.EnableBitOps||isaBool(system,left,right,ast,chartObj))

                    indices=[indices;[left.treeStart,right.treeEnd]];
                elseif(strcmp(Advisor.Utils.Stateflow.getAstDataType(system,left,chartObj),'unknown')||strcmp(Advisor.Utils.Stateflow.getAstDataType(system,right,chartObj),'unknown'))
                    indicesUnknown=[indicesUnknown;[left.treeStart,right.treeEnd]];
                end
            end
        end
    end


    children=ast.children;
    for i=1:length(children)
        [indicesTemp,indicesUnknownTemp]=iVerifyBitwiseOps(system,obj,children{i},chartObj);
        indices=[indices;indicesTemp];%#ok<AGROW>
        indicesUnknown=[indicesUnknown;indicesUnknownTemp];%#ok<AGROW>
    end
end

function chk=isaBitOp(src,left,right,op)


    src=strrep(src,left.sourceSnippet,'');
    src=strrep(src,right.sourceSnippet,'');
    chk=false;

    ind=strfind(src,op);


    if(isempty(ind))
        return;
    elseif(length(ind)==1)
        chk=true;
    elseif(ind(1)+1~=ind(2))
        chk=true;
    end
end

function chk=isaBool(system,left,right,ast,chartObj)
    chk=false;
    if~(isa(ast,'Stateflow.Ast.BitAnd')||isa(ast,'Stateflow.Ast.BitOr'))
        return
    end
    if strcmp(Advisor.Utils.Stateflow.getAstDataType(system,left,chartObj),'boolean')||...
        strcmp(Advisor.Utils.Stateflow.getAstDataType(system,right,chartObj),'boolean')
        chk=true;
    else
        chk=false;
    end
end

