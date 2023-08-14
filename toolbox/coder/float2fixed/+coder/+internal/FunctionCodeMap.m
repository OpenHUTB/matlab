classdef FunctionCodeMap<handle
    properties
OrigFcnNode
FixPtFcnNode

OrigToFixPt
FixPtToOrig

fLevel
Debug
fOrigToFixPtLookup
fFixPtToOrigLookup
    end

    properties(SetAccess=private)
OrigInferenceID
    end

    methods(Static)
        function[fcnMaps,classMaps]=buildCodeMaps(origfcnInfoRegistry,fixptDNames,config,mcosFiles)
            outDir=config.OutputFilesDirectory;
            fixptSuffix=config.FixPtFileNameSuffix;

            fixPtFcnNodes=containers.Map();
            for ii=1:numel(fixptDNames)
                addFunctionNodes(fixPtFcnNodes,fullfile(outDir,[fixptDNames{ii},'.m']));
            end
            fixPtClasses=containers.Map();
            for ii=1:numel(mcosFiles)
                [~,fixPtClass]=fileparts(mcosFiles{ii});
                methodMap=containers.Map();
                fixPtClasses(fixPtClass)=methodMap;
                addFunctionNodes(methodMap,mcosFiles{ii});
            end

            fcnMaps=containers.Map();
            classMaps=containers.Map();
            try
                origFcnInfos=origfcnInfoRegistry.getAllFunctionTypeInfos();
                for ii=1:numel(origFcnInfos)
                    origFcnInfo=origFcnInfos{ii};
                    if origFcnInfo.isDesign
                        fixPtName=[origFcnInfo.functionName,fixptSuffix];
                    else
                        fixPtName=origFcnInfo.specializationName;
                    end
                    if~isempty(origFcnInfo.classSpecializationName)
                        fixPtClass=[origFcnInfo.classSpecializationName,fixptSuffix];
                    else
                        fixPtClass=[];
                    end
                    if isempty(fixPtClass)&&fixPtFcnNodes.isKey(fixPtName)
                        addFunctionCodeMap(fcnMaps,fixPtFcnNodes,origFcnInfo,fixPtName);
                    elseif~isempty(fixPtClass)&&fixPtClasses.isKey(fixPtClass)
                        if classMaps.isKey(fixPtClass)
                            methodMap=classMaps(fixPtClass);
                        else
                            methodMap=containers.Map();
                            classMaps(fixPtClass)=methodMap;
                        end
                        classNodeMap=fixPtClasses(fixPtClass);
                        if classNodeMap.isKey(fixPtName)
                            addFunctionCodeMap(methodMap,classNodeMap,origFcnInfo,fixPtName);
                        end
                    end
                end
            catch
            end

            function addFunctionNodes(destMap,fixPtFile)




                tr=coder.internal.translator.F2FMTree(strrep(fileread(fixPtFile),char(13),''),'-comments');
                fcnNodes=mtfind(wholetree(tr),'Kind','FUNCTION');
                idx=indices(fcnNodes);
                for jj=1:numel(idx)
                    fcnNode=fcnNodes.select(idx(jj));
                    fcnName=string(fcnNode.Fname);
                    destMap(fcnName)=fcnNode;
                end
            end

            function addFunctionCodeMap(destMap,nodeMap,origFcnInfo,fixPtName)
                origFcnNode=origFcnInfo.tree;
                fixPtFcnNode=nodeMap(fixPtName);
                debug=0;
                codeMap=coder.internal.FunctionCodeMap(origFcnNode,fixPtFcnNode,debug);
                codeMap.OrigInferenceID=origFcnInfo.inferenceId;
                destMap(fixPtName)=codeMap;%#ok<NASGU>
            end
        end

        function data=toTraceabilityData(functionCodeMaps,methodCodeMaps)
            keys=functionCodeMaps.keys();
            functionTraces=cell(numel(keys),3);
            for i=1:numel(keys)
                codeMap=functionCodeMaps(keys{i});
                functionTraces(i,:)={keys{i},codeMap.OrigInferenceID,codeMap.getTraces()};
            end
            keys=methodCodeMaps.keys();
            classTraces=cell(numel(keys),2);
            for i=1:numel(keys)
                classMethodMap=methodCodeMaps(keys{i});
                methodNames=classMethodMap.keys();
                methodTraces=cell(numel(methodNames),3);
                for j=1:numel(methodNames)
                    codeMap=classMethodMap(methodNames{j});
                    methodTraces(j,:)={methodNames{j},codeMap.OrigInferenceID,codeMap.getTraces()};
                end
                classTraces(i,:)={keys{i},methodTraces};
            end

            if~isempty(functionTraces)||~isempty(classTraces)
                data.functionTraces=functionTraces;
                data.classTraces=classTraces;
            else
                data=[];
            end
        end
    end

    methods
        function this=FunctionCodeMap(origFcnNode,fixptFcnNode,debug)
            this.OrigFcnNode=origFcnNode;
            this.FixPtFcnNode=fixptFcnNode;
            this.fLevel=0;

            this.OrigToFixPt={};
            this.FixPtToOrig={};

            if nargin==3
                this.Debug=debug;
            else
                this.Debug=0;
            end
            this.doIt();
        end

        function fixPtCode=testLookupFixPtCode(this,origCode)
            if isempty(this.fOrigToFixPtLookup)
                this.fOrigToFixPtLookup=this.testCreateTextualLookupMap(this.OrigFcnNode,this.OrigToFixPt);
            end

            if this.fOrigToFixPtLookup.isKey(origCode)
                fixPtCode=this.fOrigToFixPtLookup(origCode).tree2str(0,1);
            else
                fixPtCode='';
            end
        end
    end


    methods
        function doIt(this)
            mOrig=this.classifyAnchorNodes(this.OrigFcnNode);
            mFixPt=this.classifyAnchorNodes(this.FixPtFcnNode);

            this.mapAnchorFunctionSignature();

            this.mapAnchorEXPRNodes(mOrig,mFixPt);
            this.mapAnchorIFNodes(mOrig,mFixPt);
            this.mapAnchorELSEIFNodes(mOrig,mFixPt);
            this.mapAnchorFORNodes(mOrig,mFixPt);
            this.mapAnchorWHILENodes(mOrig,mFixPt);
            this.mapAnchorSWITCHNodes(mOrig,mFixPt);
            this.mapAnchorCASENodes(mOrig,mFixPt);

            this.mapAnchorMultiOutputNodes(mOrig,mFixPt);
            this.mapAnchorSingleAssignmentNodes(mOrig,mFixPt);
        end


        function mapAnchorFunctionSignature(this)
            this.mapNodeListRecursive(this.OrigFcnNode.Outs,this.FixPtFcnNode.Outs);
            this.mapNodeListRecursive(this.OrigFcnNode.Fname,this.FixPtFcnNode.Fname);
            this.mapNodeListRecursive(this.OrigFcnNode.Ins,this.FixPtFcnNode.Ins);
        end

        function mapParentNodes(this,oNode,fNode,kinds)
            oParent=oNode.Parent;
            fParent=fNode.Parent;
            if~isempty(oParent)&&any(strcmp(oParent.kind,kinds))
                this.mapNodesRaw(oParent,fParent);
            end
        end

        function mapAnchorEXPRNodes(this,mOrig,mFixPt)
            nodesOrig=mOrig('EXPR');
            nodesFixPt=mFixPt('EXPR');


            assert(numel(nodesOrig)==numel(nodesFixPt));
            for ii=1:numel(nodesOrig)
                this.mapNodesRecursive(nodesOrig{ii},nodesFixPt{ii});
                this.mapParentNodes(nodesOrig{ii},nodesFixPt{ii},'PRINT');
            end
        end

        function mapAnchorIFNodes(this,mOrig,mFixPt)
            nodesOrig=mOrig('IF');
            nodesFixPt=mFixPt('IF');


            assert(numel(nodesOrig)==numel(nodesFixPt));
            for ii=1:numel(nodesOrig)
                oIfHead=nodesOrig{ii}.Arg;
                fIfHead=nodesFixPt{ii}.Arg;
                this.mapNodesRecursive(oIfHead.Left,fIfHead.Left);
            end
        end

        function mapAnchorELSEIFNodes(this,mOrig,mFixPt)
            nodesOrig=mOrig('ELSEIF');
            nodesFixPt=mFixPt('ELSEIF');


            assert(numel(nodesOrig)==numel(nodesFixPt));
            for ii=1:numel(nodesOrig)
                oCond=nodesOrig{ii}.Left;
                fCond=nodesFixPt{ii}.Left;
                this.mapNodesRecursive(oCond,fCond);
            end
        end

        function mapAnchorFORNodes(this,mOrig,mFixPt)
            nodesOrig=mOrig('FOR');
            nodesFixPt=mFixPt('FOR');


            assert(numel(nodesOrig)==numel(nodesFixPt));
            for ii=1:numel(nodesOrig)
                oFor=nodesOrig{ii};
                fFor=nodesFixPt{ii};
                this.mapNodesRaw(oFor.Index,fFor.Index);
                this.mapNodesRecursive(oFor.Vector,fFor.Vector);
            end
        end

        function mapAnchorWHILENodes(this,mOrig,mFixPt)
            nodesOrig=mOrig('WHILE');
            nodesFixPt=mFixPt('WHILE');


            assert(numel(nodesOrig)==numel(nodesFixPt));
            for ii=1:numel(nodesOrig)
                oWhileCond=nodesOrig{ii}.Left;
                fWhileCond=nodesFixPt{ii}.Left;
                this.mapNodesRecursive(oWhileCond,fWhileCond);
            end
        end

        function mapAnchorSWITCHNodes(this,mOrig,mFixPt)
            nodesOrig=mOrig('SWITCH');
            nodesFixPt=mFixPt('SWITCH');


            assert(numel(nodesOrig)==numel(nodesFixPt));
            for ii=1:numel(nodesOrig)
                oSwitchCond=nodesOrig{ii}.Left;
                fSwitchCond=nodesFixPt{ii}.Left;
                this.mapNodesRecursive(oSwitchCond,fSwitchCond);
            end
        end

        function mapAnchorCASENodes(this,mOrig,mFixPt)
            nodesOrig=mOrig('CASE');
            nodesFixPt=mFixPt('CASE');


            assert(numel(nodesOrig)==numel(nodesFixPt));
            for ii=1:numel(nodesOrig)
                oCaseCond=nodesOrig{ii}.Left;
                fCaseCond=nodesFixPt{ii}.Left;
                this.mapNodesRecursive(oCaseCond,fCaseCond);
            end
        end

        function mapNodesRecursive(this,oNode,fNode)
            if isempty(oNode)||isempty(fNode)
                return;
            end

            this.fLevel=this.fLevel+1;
            oKind=oNode.kind;
            fKind=fNode.kind;

            if strcmp(oKind,fKind)


                switch oKind
                case{'EXPR','PARENS'}
                    this.mapNodesRaw(oNode,fNode);
                    this.mapNodesRecursive(oNode.Arg,fNode.Arg);

                case{'SUBSCR','DOT','DOTLP'}
                    this.mapNodesRaw(oNode,fNode);
                    this.mapNodesRecursive(oNode.Left,fNode.Left);
                    this.mapNodeListRecursive(oNode.Right,fNode.Right);

                case{'ID','FIELD','CHARVECTOR'}
                    this.mapNodesRaw(oNode,fNode);

                case{'NOT','TRANS','UPLUS','UMINUS'}
                    this.mapNodesRaw(oNode,fNode);
                    this.mapNodesRecursive(oNode.Arg,fNode.Arg);

                case{'PLUS','MINUS','MUL','DIV','DOTMUL','DOTDIV',...
                    'EXP','DOTEXP',...
                    'OR','AND','OROR','ANDAND',...
                    'EQ','NE',...
                    'GT','GE','LT','LE',...
                    'COLON'}
                    this.mapNodesRaw(oNode,fNode);
                    this.mapNodesRecursive(oNode.Left,fNode.Left);
                    this.mapNodesRecursive(oNode.Right,fNode.Right);

                case{'LC','LB','ROW'}
                    this.mapNodesRaw(oNode,fNode);
                    this.mapNodeListRecursive(oNode.Arg,fNode.Arg);

                case{'CALL'}
                    oFcn=string(oNode.Left);
                    fFcn=string(fNode.Left);
                    if~strcmp(oFcn,fFcn)
                        if strcmp(fFcn,'fi')



                            this.mapNodesRecursive(oNode,fNode.Right);





                            this.mapNodesRaw(oNode,fNode);
                        else

                            this.mapNodesRaw(oNode,fNode);
                            this.mapNodeListRecursive(oNode.Right,fNode.Right);
                        end
                    else


                        this.mapNodesRaw(oNode,fNode);
                        this.mapNodeListRecursive(oNode.Right,fNode.Right);
                    end
                end
            else

                switch fKind
                case 'SUBSCR'
                    if strcmp(strtrim(fNode.Right.tree2str(0,1)),':')



                        this.mapNodesRecursive(oNode,fNode.Left);


                        this.mapNodesRaw(oNode,fNode);
                    end
                case 'CALL'
                    switch string(fNode.Left)
                    case{'fi','fi_toint','fi_signed'}


                        this.mapNodesRecursive(oNode,fNode.Right);


                        this.mapNodesRaw(oNode,fNode);

                    case{'fi_div','fi_div_by_shift'}

                        this.mapNodesRaw(oNode,fNode);
                        this.mapNodesRecursive(oNode.Left,fNode.Right);
                        this.mapNodesRecursive(oNode.Right,fNode.Right.Next);

                    case{'fi_uminus'}

                        this.mapNodesRaw(oNode,fNode);
                        this.mapNodesRecursive(oNode.Arg,fNode.Right);

                    otherwise


                    end
                end
            end
            this.fLevel=this.fLevel-1;
        end

        function mapNodeListRecursive(this,oNode,fNode)
            while~isempty(oNode)&&~isempty(fNode)
                this.mapNodesRecursive(oNode,fNode);
                oNode=oNode.Next;
                fNode=fNode.Next;
            end
        end

        function mapNodesRaw(this,oNode,fNode)
            oIdx=indices(oNode);
            fIdx=indices(fNode);
            this.OrigToFixPt{oIdx}=fNode;
            this.FixPtToOrig{fIdx}=oNode;

            if this.Debug
                fprintf('%sMapping ''%s'' to ''%s''\n',repmat('   ',1,this.fLevel),oNode.tree2str(0,1),fNode.tree2str(0,1));
            end
        end

        function m=classifyAnchorNodes(this,fcnNode)
            m=containers.Map();
            m('EXPR')={};
            m('EQUALS')={};
            m('FOR')={};
            m('IF')={};
            m('ELSEIF')={};
            m('SWITCH')={};
            m('CASE')={};
            m('WHILE')={};
            nodes=subtree(fcnNode);
            indexes=indices(nodes);
            for ii=1:numel(indexes)
                idx=indexes(ii);
                node=nodes.select(idx);
                kind=node.kind;

                switch node.kind
                case{'EQUALS'}

                case{'EXPR'}
                    if strcmp(node.Arg.kind,'EQUALS')


                        continue;
                    else



                    end
                case{'IF','ELSEIF','FOR','WHILE','SWITCH','CASE'}






                otherwise

                    continue;
                end

                nodeList=m(kind);

                nodeList{end+1}=node;
                m(kind)=nodeList;
            end
        end

        function multiNodes=getMultiOutputAssignments(this,assignNodes)
            multiNodes={};
            for ii=1:numel(assignNodes)
                aOrig=assignNodes{ii};
                lhs=aOrig.Left;
                if strcmp(lhs.kind,'LB')
                    multiNodes{end+1}=aOrig;
                end
            end
        end

        function mapAnchorMultiOutputNodes(this,mOrig,mFixPt)
            assignOrig=mOrig('EQUALS');
            assignFixPt=mFixPt('EQUALS');

            multiNodesOrig=this.getMultiOutputAssignments(assignOrig);
            multiNodesFixPt=this.getMultiOutputAssignments(assignFixPt);

            assert(numel(multiNodesOrig)==numel(multiNodesFixPt));
            for ii=1:numel(multiNodesOrig)
                oNode=multiNodesOrig{ii};
                fNode=multiNodesFixPt{ii};


                this.mapNodesRaw(oNode,fNode);



                this.mapNodesRecursive(oNode.Right,fNode.Right);






                this.mapNodeListRecursive(oNode.Left.Arg,fNode.Left.Arg);



                this.mapParentNodes(oNode,fNode,{'PRINT','EXPR'});
            end
        end


        function m=gatherVarAssignments(this,assignNodes)
            if~isempty(assignNodes)
                assignNodes=assignNodes('EQUALS');
            end
            m=containers.Map();
            for ii=1:numel(assignNodes)
                assignNode=assignNodes{ii};
                lhs=assignNode.Left;
                switch lhs.kind
                case 'LB'



                    lhs=lhs.Arg;
                    while~isempty(lhs)
                        addLhsNode(lhs,assignNode,m);
                        lhs=lhs.Next;
                    end
                otherwise

                    addLhsNode(lhs,assignNode,m);
                end
            end

            function addLhsNode(node,assignNode,m)
                rootVar=getLhsRootVar(node);
                if~m.isKey(rootVar)
                    varAssignNodes={};
                else
                    varAssignNodes=m(rootVar);
                end
                varAssignNodes{end+1}={node,assignNode};
                m(rootVar)=varAssignNodes;
            end

            function rootVar=getLhsRootVar(node)
                switch node.kind
                case{'SUBSCR','DOT'}
                    rootVar=getLhsRootVar(node.Left);
                case 'ID'
                    rootVar=string(node);
                case 'NOT'
                    rootVar='~';
                end
            end
        end

        function mapAnchorSingleAssignmentNodes(this,mOrig,mFixPt)
            mOrig=this.gatherVarAssignments(mOrig);
            mFixPt=this.gatherVarAssignments(mFixPt);

            mOrigRootVars=mOrig.keys();
            mFixPtRootVars=mFixPt.keys();


            for ii=1:numel(mOrigRootVars)
                rootVar=mOrigRootVars{ii};
                mOrigAssigns=mOrig(rootVar);
                mFixPtAssigns=mFixPt(rootVar);

                if numel(mOrigAssigns)~=numel(mFixPtAssigns)
                    if this.Debug
                        fprintf('Ignoring complicated root var : %s\n',rootVar);
                    end
                    continue;
                end

                for jj=1:numel(mOrigAssigns)
                    mOAssign=mOrigAssigns{jj};
                    mFAssign=mFixPtAssigns{jj};

                    if isMultiAssign(mOAssign{2})



                        if isMultiAssign(mFAssign{2})




                            if this.Debug
                                fprintf('Retained multi-output lhs\n');
                            end
                            this.mapNodesRecursive(mOAssign{1},mFAssign{1});
                        else

                            if this.Debug
                                fprintf('Rewritten multi-output lhs\n');
                            end



                            this.mapNodesRecursive(mOAssign{1},mFAssign{1});



                            this.mapNodesRaw(mOAssign{1},mFAssign{2});
                        end

                    else

                        this.mapNodesRaw(mOAssign{2},mFAssign{2});
                        this.mapNodesRecursive(mOAssign{2}.Left,mFAssign{2}.Left);
                        this.mapNodesRecursive(mOAssign{2}.Right,mFAssign{2}.Right);

                        this.mapParentNodes(mOAssign{2},mFAssign{2},{'PRINT','EXPR'});
                    end
                end

            end

            function b=isMultiAssign(node)
                b=strcmp(node.Left.kind,'LB');
            end
        end


        function textMap=testCreateTextualLookupMap(this,fcnNode,nodeMap)
            nodes=subtree(fcnNode);
            indexes=indices(nodes);
            textMap=containers.Map();
            for ii=1:numel(indexes)
                idx=indexes(ii);
                node=nodes.select(idx);

                if idx<=numel(nodeMap)&&~isempty(nodeMap{idx})
                    key=node.tree2str(0,1);
                    textMap(key)=nodeMap{idx};
                end
            end
        end

        function traces=getTraces(this)
            fcnNode=this.OrigFcnNode;
            nodeMap=this.OrigToFixPt;
            nodes=subtree(fcnNode);
            indexes=indices(nodes);

            maxPossible=numel(indexes);
            traces=cell2struct(cell(maxPossible,4),...
            {'origStart','origEnd','fixptStart','fixptEnd'},2);
            last=0;

            for ii=1:maxPossible
                idx=indexes(ii);
                srcNode=nodes.select(idx);

                if idx<=numel(nodeMap)&&~isempty(nodeMap{idx})
                    targetNode=nodeMap{idx};
                    last=last+1;
                    traces(last).origStart=position(srcNode);
                    traces(last).origEnd=endposition(srcNode);
                    traces(last).fixptStart=position(targetNode);
                    traces(last).fixptEnd=endposition(targetNode);
                end
            end
            traces=traces(1:last);
        end

    end

end
