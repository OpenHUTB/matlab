function styleguide_jc_0451()






    rec=ModelAdvisor.Check('mathworks.maab.jc_0451');



    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc0451Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc0451Tip');
    rec.setCallbackFcn(@jc_0451_StyleOneCallback,'PostCompile','StyleOne');
    rec.Value=false;
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc_0451';
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
    rec.SupportExclusion=true;
end

function ResultDescription=jc_0451_StyleOneCallback(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ResultDescription={};
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:jc0451ColTitle1'),DAStudio.message('ModelAdvisor:styleguide:jc0451ColTitle2')});
    ft.setCheckText(DAStudio.message('ModelAdvisor:styleguide:jc0451CheckText'))



    ft.setSubBar(0);

    tableInfo={};tableInfoUnknown={};
    m=get_param(system,'Object');
    chartArray=m.find('-isa','Stateflow.Chart');

    for ii=1:length(chartArray)
        chartObj=chartArray(ii);
        StatesTransitions=chartObj.find('-isa','Stateflow.State','-or','-isa','Stateflow.Transition');
        for jj=1:length(StatesTransitions)
            obj=StatesTransitions(jj);

            [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
            if isempty(asts)
                continue;
            end
            info={};infoUnknown={};

            indices=[];indicesUnknown=[];


            sections=asts.sections;
            for i=1:length(sections)
                roots=sections{i}.roots;
                for j=1:length(roots)

                    if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                        [indicesTemp,indicesUnknownTemp]=iVerifyUnaryOpsC(system,roots{j},chartObj,obj);
                        indices=[indices;indicesTemp];%#ok<AGROW>
                        indicesUnknown=[indicesUnknown;indicesUnknownTemp];%#ok<AGROW>
                    elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                        [indicesTemp,indicesUnknownTemp]=iVerifyUnaryOpsM(system,roots{j},resolvedSymbolIds);
                        indices=[indices;indicesTemp];%#ok<AGROW>
                        indicesUnknown=[indicesUnknown;indicesUnknownTemp];%#ok<AGROW>
                    end

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
            tableInfoUnknown=[tableInfoUnknown;infoUnknown];%#ok<AGROW>
        end
    end
    if isempty(tableInfo)
        mdladvObj.setCheckResultStatus(true);
        ft.setSubResultStatus('pass');
        if~isempty(tableInfoUnknown)
            inconclusiveMsg=[ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:jc0451PassMsg'))...
            ,ModelAdvisor.LineBreak...
            ,ModelAdvisor.LineBreak...
            ,ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:NoteMessage'),{'bold'})...
            ,ModelAdvisor.LineBreak...
            ,ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:jc0451InconclusiveMsg1'))...
            ,ModelAdvisor.LineBreak...
            ,ModelAdvisor.Text(DAStudio.message('ModelAdvisor:styleguide:jc0451InconclusiveMsg2'))];
            ft.setSubResultStatusText(inconclusiveMsg);
            ft.setTableInfo(tableInfoUnknown);
        else
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:jc0451PassMsg'));
        end
    else
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:jc0451FailMsg'));
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:jc0451RecAction'));
        ft.setTableInfo(tableInfo);
    end
    ft.setSubBar(0);
    ResultDescription{1}=ft;
end

function[indices,indicesUnknown]=iVerifyUnaryOpsC(system,ast,chartObject,stateflowObject)



    indices=[];
    indicesUnknown=[];

    if(isa(ast,'Stateflow.Ast.Uminus'))
        if isUnsignedInteger(Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObject))
            indices=[indices;[ast.children{1}.treeStart-1,ast.children{1}.treeEnd]];
        elseif strcmp(Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObject),'unknown')
            indicesUnknown=[indicesUnknown;[ast.children{1}.treeStart-2,ast.children{1}.treeEnd]];
        end
    end
    children=ast.children;
    for i=1:length(children)
        [indicesTemp,indicesUnknownTemp]=iVerifyUnaryOpsC(system,children{i},chartObject,stateflowObject);
        indices=[indices;indicesTemp];%#ok<AGROW>
        indicesUnknown=[indicesUnknown;indicesUnknownTemp];%#ok<AGROW>
    end

end

function[indices,indicesUnknown]=iVerifyUnaryOpsM(system,ast,resolvedSymbolIds)

    indices=[];
    indicesUnknown=[];

    if~isempty(ast.sourceSnippet)
        codeFragment=ast.sourceSnippet;
        mtreeObject=...
        Advisor.Utils.Stateflow.createMtreeObject(codeFragment,resolvedSymbolIds);
        uminusNodes=mtreeObject.mtfind('Kind','UMINUS');

        for index=uminusNodes.indices
            thisNode=uminusNodes.select(index);
            uminusArg=thisNode.Arg;
            dataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,...
            uminusArg,resolvedSymbolIds);
            if isUnsignedInteger(dataType)
                leftIndex=ast.treeStart+thisNode.lefttreepos-1;
                rightIndex=ast.treeStart+thisNode.righttreepos-1;
                indices=[indices;[leftIndex,rightIndex]];%#ok<AGROW>
            elseif strcmp(dataType,'unknown')==1
                leftIndex=ast.treeStart+thisNode.lefttreepos-1;
                rightIndex=ast.treeStart+thisNode.righttreepos-1;
                indicesUnknown=[indicesUnknown;[leftIndex,rightIndex]];%#ok<AGROW>
            end
        end

    end

end

function result=isUnsignedInteger(dataType)
    switch dataType
    case 'uint8',result=true;
    case 'uint16',result=true;
    case 'uint32',result=true;
    case 'boolean',result=true;
    otherwise,result=false;
    end
end

