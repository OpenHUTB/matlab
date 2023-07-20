








function[bResultStatus,ResultDescription]=modelAdvisorCheck_SFBlocks(system,xlateTagPrefix)











    ResultDescription={};

    Advisor.Utils.LoadLinkCharts(system);

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    ft=ModelAdvisor.FormatTemplate('TableTemplate');
    ft.setInformation(DAStudio.message([xlateTagPrefix,'SFEntryFormattingCheckText']));

    ft.setColTitles({DAStudio.message([xlateTagPrefix,'SFEntryFormattingColTitle1']),DAStudio.message([xlateTagPrefix,'SFEntryFormattingColTitle2'])});
    ft.setSubBar(0);
    if strcmp(xlateTagPrefix,'ModelAdvisor:iec61508:')
        ft.setSubTitle(DAStudio.message([xlateTagPrefix,'SFBlocksTitle']));
    end
    info={};tableInfo={};%#ok<NASGU>
    bResultStatus=false;%#ok<NASGU>
    ObjsTobeHighlited={};
    nl=newline;
    m=get_param(system,'Object');
    if~isempty(m)
        chartArray=m.find('-isa','Stateflow.Chart');

        linkCharts=ModelAdvisor.Common.find_LinkChart(m);
        chartArray=[chartArray(:);linkCharts(:)];
    end

    chartArray=mdladvObj.filterResultWithExclusion(chartArray);

    for ii=1:length(chartArray)
        chartObj=chartArray(ii);
        isCActionLanguage=Advisor.Utils.Stateflow.isActionLanguageC(chartObj);

        States=chartObj.find('-isa','Stateflow.State');
        for jj=1:length(States)
            obj=States(jj);
            uStr=updateStr(obj.LabelString);

            asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
            if isempty(asts)
                continue;
            end
            info={};

            indices=[];


            sections=asts.sections;














            firstCommandCharacterPattern='[^\s%/]{1}';


            sectionDefinitionPattern='(entry|during|exit|en|du|ex){1}';

            pattern=['\n(?:\s*',sectionDefinitionPattern,'\s*,)*',...
            '(?:\s*',sectionDefinitionPattern,')\s*:(\s*)',...
            firstCommandCharacterPattern];

            [startIdx,endIdx,match]=...
            regexpi(uStr,pattern,...
            'start','end','tokens');

            for ni=1:length(startIdx)
                if isempty(strfind(match{ni}{1},nl))





                    indices=[indices;startIdx(ni)+1,endIdx(ni)-1];%#ok<AGROW>
                end
            end


            for i=1:length(sections)
                roots=sections{i}.roots;



                if isCActionLanguage
                    indices=[indices;verifyEntryFormattingC(roots,obj)];%#ok<AGROW>
                else
                    indices=[indices;verifyEntryFormattingM(roots,obj)];%#ok<AGROW>
                end

            end
            for i=1:size(indices,1)
                linkStr=ModelAdvisor.Text([obj.Path,'/',obj.Name]);
                objID=Simulink.ID.getSID(obj);
                linkStr.setHyperlink(['matlab: Simulink.ID.hilite(''',objID,''')']);
                info=[info;{Advisor.Utils.Stateflow.highlightSFLabelByIndex(obj.LabelString,indices(i,:)),linkStr}];%#ok<AGROW>            
                ObjsTobeHighlited{end+1}=obj;%#ok<AGROW>
            end
            tableInfo=[tableInfo;info];%#ok<AGROW>
        end
    end
    if isempty(tableInfo)
        ft.setSubResultStatus('pass');
        bResultStatus=true;
        if isempty(chartArray)
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'NoChartsFound']));
        else
            ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SFEntryFormattingPassMsg']));
        end
    else
        ft.setSubResultStatus('warn');
        bResultStatus=false;
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'SFEntryFormattingFailMsg']));
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'SFEntryFormattingRecAction']));
        ft.setTableInfo(tableInfo);
        mdladvObj.setCheckResultMap(ObjsTobeHighlited);
    end
    ResultDescription{1}=ft;
end

function indices=verifyEntryFormattingC(roots,obj)
    indices=zeros(0,2);


    isComment=false(size(roots));
    for n=1:length(roots)
        if isa(roots{n},'Stateflow.Ast.Comment')
            isComment(n)=true;
        end
    end
    roots(isComment)=[];

    for j=1:length(roots)-1
        if~contains(obj.LabelString(roots{j}.treeStart:roots{j+1}.treeStart),newline)
            indices=[indices;[roots{j}.treeStart,roots{j}.treeEnd]];%#ok<AGROW>
        end
    end
end

function indices=verifyEntryFormattingM(roots,obj)
    indices=zeros(0,2);


    for n=1:length(roots)

        codeFragment=roots{n}.sourceSnippet;

        if isempty(codeFragment)
            continue;
        end
        tempIndex=strfind(obj.LabelString,codeFragment);

        if isempty(tempIndex)
            continue;
        end
        startIndexSection=tempIndex(1);

        mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(codeFragment);


        if~mtreeObject.isempty
            currentNode=mtreeObject.root;
            while~isempty(currentNode.Next)
                leftIndex=currentNode.lefttreepos;
                rightIndex=currentNode.Next.righttreepos;
                expressionPair=codeFragment(leftIndex:rightIndex);
                if isempty(regexp(expressionPair,'\n','once'))
                    startIndex=startIndexSection-1+currentNode.lefttreepos;
                    stopIndex=startIndexSection-1+currentNode.righttreepos;
                    indices=[indices;[startIndex,stopIndex]];%#ok<AGROW>
                end
                currentNode=currentNode.Next;
            end
        end
    end
end

function uStr=updateStr(str)
    cr=newline;
    uStr=[];
    lns=regexp(str,cr,'split');
    for i=1:length(lns)
        Line=stripline(lns{i});
        uStr=[uStr,Line,newline];%#ok<AGROW>
    end
end


function str=stripline(strline)

    str=strline;
    if isempty(strline)
        return;
    end

    len=length(str);
    token=strfind(str,'%');
    if~isempty(token)
        for i=token(1):len
            str(i)='%';
        end
    end

    len=length(str);
    token=strfind(str,'...');
    if~isempty(token)

        str(token(1):len)=char(repmat(37,1,len-token(1)+1));
    end


end

