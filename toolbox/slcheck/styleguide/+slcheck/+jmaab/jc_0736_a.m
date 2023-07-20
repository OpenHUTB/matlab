classdef jc_0736_a<slcheck.subcheck




    methods
        function obj=jc_0736_a()
            obj.CompileMode='None';
            obj.Licenses={''};
            obj.ID='jc_0736_a';
        end

        function result=run(this)

            result=false;





            noSingleByteSpace=this.getInputParamByName(...
            DAStudio.message(...
            'ModelAdvisor:jmaab:jc_0736_InputMessage'));

            noSingleByteSpace=str2double(noSingleByteSpace);

            if isempty(noSingleByteSpace)||isnan(noSingleByteSpace)
                return;
            end

            noSingleByteSpace=round(noSingleByteSpace);


            sfObj=this.getEntity();

            if~isa(sfObj,'Stateflow.State')
                return;
            end


            if isempty(strtrim(sfObj.LabelString))
                return;
            end



            if Advisor.Utils.Stateflow.isActionLanguageC(sfObj)
                RDObj=checkCObj(sfObj,noSingleByteSpace);
            else
                RDObj=checkMObj(sfObj,noSingleByteSpace);
            end

            if isempty(RDObj)
                return;
            end

            result=this.setResult(RDObj);

        end

    end
end





function RDObj=checkCObj(sfObj,spaceLimit)




    RDObj=[];

    labelStringEdit=sfObj.LabelString;

    labelString=sfObj.LabelString;

    offset=0;


    [asts,~]=Advisor.Utils.Stateflow...
    .getAbstractSyntaxTree(sfObj);

    if isempty(asts)
        return;
    end

    sections=asts.sections;

    if isempty(sections)
        return;
    end






    notEmptyFlag=cellfun(@(x)~isempty(x.roots),sections);
    sections=sections(notEmptyFlag);

    [~,index,~]=unique(cellfun(@(x)x.roots{1}.treeStart,sections));

    sections=sections(index);

    for i=1:numel(sections)

        sec=sections{i};

        if isempty(sec)
            continue;
        end

        for j=1:numel(sec.roots)

            root=sec.roots{j};

            if isempty(root.sourceSnippet)
                continue;
            end







            startIndex=root.treeStart-spaceLimit-1;
            stopIndex=root.treeStart-1;






            indent=labelString(startIndex:stopIndex);

            if isempty(indent)
                continue;
            end

            noByteSpace=getByteSpaceCount(indent);




            if noByteSpace==spaceLimit
                continue;
            end

            LSLength=length(labelStringEdit);


            labelStringEdit=Advisor.Utils.Naming.formatFlaggedName(...
            labelStringEdit,false,...
            [root.treeStart+offset-1,...
            root.treeStart+offset],'');

            offset=offset+length(labelStringEdit)-LSLength;


        end
    end


    [labelStringEdit,actionTypeoffset]=checkActionType(labelStringEdit);

    if 0==offset&&0==actionTypeoffset
        return;
    end

    RDObj=createRDObj(sfObj,labelStringEdit,spaceLimit);


end

function rootCount=countASTRoots(AST)





    sections=[AST.sections,AST.duringSection,AST.entrySection];
    rootCount=sum(cellfun(@(x)numel(x.roots),sections));

end


function RDObj=checkMObj(sfObj,spaceLimit)




    RDObj=[];





    [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow...
    .getAbstractSyntaxTree(sfObj);

    if isempty(asts)
        return;
    end

    rootCount=countASTRoots(asts);

    if rootCount==0
        return;
    end

    nodesRoots=cell(2,rootCount);

    nIx=1;
    nodeIndexCount=0;







    for i=1:numel(asts.sections)

        sec=asts.sections{i};

        if isempty(sec)
            continue;
        end

        for j=1:numel(sec.roots)

            root=sec.roots{j};

            if isempty(root.sourceSnippet)
                continue;
            end



            mt=Advisor.Utils.Stateflow...
            .createMtreeObject(root.sourceSnippet,resolvedSymbolIds);


            if nIx>rootCount
                break;
            end




            if isempty(mt)
                continue;
            end






            condNodes=mt.root.mtfind('Kind',{'IF','SWITCH','FOR','WHILE','TRY'});
            if~isempty(condNodes)
                nodes=condNodes;
            else
                nodes=mt.mtfind('Kind',{'EQUALS','PRINT','CALL'});
            end
            if isempty(nodes)
                continue;
            end
            nodesRoots{1,nIx}=nodes;
            nodesRoots{2,nIx}=root;
            nIx=nIx+1;



            nodeIndexCount=nodeIndexCount+numel(nodes.indices);

        end
    end



    if isempty(nodesRoots)
        return;
    end








    nodeIndex=zeros(1,nodeIndexCount);
    nIIdx=1;

    for nIx=1:size(nodesRoots,2)

        node=nodesRoots{1,nIx};
        root=nodesRoots{2,nIx};

        if isempty(node)
            continue;
        end

        for idx=node.indices


            thisNode=node.select(idx);

            if isempty(thisNode)
                continue;
            end



            if nIIdx>nodeIndexCount
                break;
            end






            nodeIndex(nIIdx)=root.treeStart+thisNode.lefttreepos-1;

            nIIdx=nIIdx+1;

        end
    end



    if isempty(nodeIndex)
        return;
    end

    nodeIndex=unique(sort(nodeIndex));








    labelStringEdit=sfObj.LabelString;
    labelString=sfObj.LabelString;
    offset=0;


    for nIIdx=1:numel(nodeIndex)


        lSStartIndex=nodeIndex(nIIdx);

        if lSStartIndex==0
            continue;
        end


        if lSStartIndex<spaceLimit
            continue;
        end





        startIndex=lSStartIndex-spaceLimit-1;
        stopIndex=lSStartIndex-1;




        indent=labelString(startIndex:stopIndex);

        if isempty(indent)
            continue;
        end



        noByteSpace=getByteSpaceCount(indent);




        if noByteSpace~=spaceLimit

            LSLength=length(labelStringEdit);


            labelStringEdit=Advisor.Utils.Naming.formatFlaggedName(...
            labelStringEdit,false,...
            [lSStartIndex+offset-1,lSStartIndex+offset],'');

            offset=offset+length(labelStringEdit)-LSLength;

        end

    end



    [labelStringEdit,actionTypeoffset]=checkActionType(labelStringEdit);

    if 0==offset&&0==actionTypeoffset
        return;
    end


    RDObj=createRDObj(sfObj,labelStringEdit,spaceLimit);


end

function[labelStringEdit,offset]=checkActionType(labelString)


    labelStringEdit=labelString;


    labelStr=ModelAdvisor.internal.removeCommentsInLabelString(labelString,true);
    offset=0;

    index=regexp(labelStr,'((en|ex|du)[a-zA-Z, ]*:)');

    if isempty(index)
        return;
    end

    for countID=1:length(index)
        indent=labelStr(index(countID)-1);

        if getByteSpaceCount(indent)==0
            continue;
        end

        LSLength=length(labelStringEdit);


        labelStringEdit=Advisor.Utils.Naming.formatFlaggedName(...
        labelStringEdit,false,...
        [index(countID)+offset-1,index(countID)+offset],'');

        offset=offset+length(labelStringEdit)-LSLength;

    end

end


function noByteSpace=getByteSpaceCount(indent)




    newlineIndex=regexp(indent,'\n');

    if~isempty(newlineIndex)
        if max(newlineIndex)==length(indent)
            noByteSpace=0;
            return;
        end
    end


    spaceIndex=regexp(indent,'[ \b\f]');
    tabIndex=regexp(indent,'\t');

    whiteSpace=numel(spaceIndex);
    tabSpace=numel(tabIndex);


    noByteSpace=whiteSpace+4*tabSpace;
end

function RDObj=createRDObj(sfObj,higlightedText,inputParam)

    MAText=ModelAdvisor.Text(higlightedText);
    MAText.RetainReturn=true;
    MAText.RetainSpaceReturn=true;
    RDObj=ModelAdvisor.ResultDetail;
    ModelAdvisor.ResultDetail.setData(RDObj,'SID',sfObj,'Expression',MAText.emitHTML);
    RDObj.RecAction=DAStudio.message('ModelAdvisor:jmaab:jc_0736_a_rec_action',inputParam);

end


