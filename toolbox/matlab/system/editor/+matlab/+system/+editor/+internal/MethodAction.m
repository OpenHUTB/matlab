classdef MethodAction




    methods(Static)
        function cmds=insert(mt,systemObjectMethodName,varargin)


            p=inputParser;
            p.KeepUnmatched=true;
            p.parse(varargin{:});
            results=p.Unmatched;


            classdefNode=mtfind(mt,'Kind','CLASSDEF');
            [results.Access,results.Attributes,results.Mixin]=...
            matlab.system.editor.internal.CodeTemplate.getSystemObjectMethodInfo(systemObjectMethodName);



            cmds={};
            if~isempty(results.Mixin)
                if~matlab.system.editor.internal.ParseTreeUtils.isSubclassOf(classdefNode,results.Mixin)
                    cmds=addMixin(classdefNode,results.Mixin);
                end
            end


            results.SystemName=matlab.system.editor.internal.ParseTreeUtils.getClassName(mt);


            results.InputNames={};
            results.OutputNames={};
            if ismember(systemObjectMethodName,matlab.system.editor.internal.CodeTemplate.SystemObjectMethodsWithSystemIOArguments)
                results.InputNames=matlab.system.editor.internal.IOAction.getInputNames(mt);
                results.OutputNames=matlab.system.editor.internal.IOAction.getOutputNames(mt);
            end

            results.StateNames={};
            if ismember(systemObjectMethodName,matlab.system.editor.internal.CodeTemplate.SystemObjectMethodsUsingStates)
                [~,~,stateNames]=matlab.system.editor.internal.PropertyAction.getPropertyInfo(mt);
                results.StateNames=stateNames;
            end



            methodBlocks=mtfind(mt,'Kind','METHODS');
            if isempty(methodBlocks)
                cmds=[cmds,insertMethodInClassWithNoBlocks(classdefNode,systemObjectMethodName,results)];
            else
                [methodNode,insertCmd]=getMethodNodeForInsertion(methodBlocks,systemObjectMethodName,results);

                switch(insertCmd)
                case 'replaceMethod'
                    cmds=[cmds,replaceMethod(methodNode,systemObjectMethodName,results)];
                case 'insertBeforeMethod'
                    cmds=[cmds,insertMethodBeforeMethod(methodNode,systemObjectMethodName,results)];
                case 'insertAfterMethod'
                    cmds=[cmds,insertMethodAfterMethod(methodNode,systemObjectMethodName,results)];
                case 'insertAtStartOfMethodBlock'
                    cmds=[cmds,insertMethodAtStartOfMethodBlock(methodNode,systemObjectMethodName,results)];
                case 'insertAtEndOfMethodBlock'
                    cmds=[cmds,insertMethodAtEndOfMethodBlock(methodNode,systemObjectMethodName,results)];
                case 'insertBeforeMethodBlock'
                    cmds=[cmds,insertMethodBeforeMethodBlock(methodNode,systemObjectMethodName,results)];
                case 'insertAfterMethodBlock'
                    cmds=[cmds,insertMethodAfterMethodBlock(methodNode,systemObjectMethodName,results)];
                end
            end
        end

        function methodNode=findMethodNode(mt,systemObjectMethodName)
            methodNode=[];
            methodBlocks=mtfind(mt,'Kind','METHODS');
            if~isempty(methodBlocks)
                for methodsBlockIndex=indices(methodBlocks)
                    methodBlock=select(methodBlocks,methodsBlockIndex);
                    [name,node]=matlab.system.editor.internal.ParseTreeUtils.getMethodBlockMethods(methodBlock);
                    if~isempty(name)
                        index=find(strcmp(name,systemObjectMethodName));
                        if~isempty(index)&&index<=numel(node)
                            methodNode=node{index};
                            break;
                        end
                    end
                end
            end
        end

        function cmds=remove(mt,systemObjectMethodName,varargin)
            cmds=[];
            methodNode=matlab.system.editor.internal.MethodAction.findMethodNode(mt,systemObjectMethodName);
            if(~isempty(methodNode))
                [results.Access,results.Attributes,results.Mixin]=...
                matlab.system.editor.internal.CodeTemplate.getSystemObjectMethodInfo(systemObjectMethodName);
                cmds=[replaceMethod(methodNode,'',results)];
            end
        end

        function[sysobjMethodNames,sysobjMethodNodes,customMethodNames,customMethodNodes]=getImplementedNames(mt)



            allSysobjMethodNames=matlab.system.editor.internal.CodeTemplate.SystemObjectMethodNames;
            allSysobjStaticMethodNames=matlab.system.editor.internal.CodeTemplate.SystemObjectStaticMethodNames;


            sysobjMethodNames={};
            sysobjMethodNodes={};
            customMethodNames={};
            customMethodNodes={};
            methodBlocks=mtfind(mt,'Kind','METHODS');
            for k=indices(methodBlocks)
                methodBlock=select(methodBlocks,k);
                [access,attributes]=matlab.system.editor.internal.ParseTreeUtils.getMethodBlockAttributes(methodBlock);
                [blockMethodNames,blockMethodNodes]=matlab.system.editor.internal.ParseTreeUtils.getMethodBlockMethods(methodBlock);

                if isempty(blockMethodNames)
                    continue;
                end


                if ismember('Static',attributes)
                    sysobjMethodCandidates=allSysobjStaticMethodNames;
                else
                    sysobjMethodCandidates=allSysobjMethodNames;
                end

                if strcmp(access,'protected')





                    newSysobjMethodNames={};
                    newCustomMethodNames={};
                    newSysobjMethodNodes={};
                    newCustomMethodNodes={};
                    for methodInd=1:numel(blockMethodNames)
                        methodName=blockMethodNames{methodInd};
                        methodNode=blockMethodNodes{methodInd};
                        if ismember(methodName,sysobjMethodCandidates)
                            if~ismember(methodName,newSysobjMethodNames)&&...
                                ~ismember(methodName,sysobjMethodNames)
                                newSysobjMethodNames{end+1}=methodName;
                                newSysobjMethodNodes{end+1}=methodNode;
                            end
                        elseif~ismember(methodName,newCustomMethodNames)&&...
                            ~ismember(methodName,customMethodNames)
                            newCustomMethodNames{end+1}=methodName;
                            newCustomMethodNodes{end+1}=methodNode;
                        end
                    end

                    if~isempty(newSysobjMethodNames)
                        sysobjMethodNames=[sysobjMethodNames,newSysobjMethodNames];
                        sysobjMethodNodes=[sysobjMethodNodes,newSysobjMethodNodes];
                    end

                    if~isempty(newCustomMethodNames)
                        customMethodNames=[customMethodNames,newCustomMethodNames];
                        customMethodNodes=[customMethodNodes,newCustomMethodNodes];
                    end

                elseif strcmp(access,'public')
                    newSysobjMethodNames={};
                    newCustomMethodNames={};
                    newSysobjMethodNodes={};
                    newCustomMethodNodes={};


                    className=matlab.system.editor.internal.ParseTreeUtils.getClassName(mt);
                    for methodInd=1:numel(blockMethodNames)
                        methodName=blockMethodNames{methodInd};
                        methodNode=blockMethodNodes{methodInd};
                        if strcmp(methodName,className)
                            if~ismember('System object constructor',sysobjMethodNames)
                                sysobjMethodNames=[sysobjMethodNames,{'System object constructor'}];
                                sysobjMethodNodes=[sysobjMethodNodes,{methodNode}];
                            end
                        elseif ismember(methodName,sysobjMethodCandidates)
                            if~ismember(methodName,newSysobjMethodNames)&&...
                                ~ismember(methodName,sysobjMethodNames)
                                newSysobjMethodNames{end+1}=methodName;
                                newSysobjMethodNodes{end+1}=methodNode;
                            end
                        elseif~ismember(methodName,newCustomMethodNames)&&...
                            ~ismember(methodName,customMethodNames)
                            newCustomMethodNames{end+1}=methodName;
                            newCustomMethodNodes{end+1}=methodNode;
                        end
                    end

                    if~isempty(newSysobjMethodNames)
                        sysobjMethodNames=[sysobjMethodNames,newSysobjMethodNames];
                        sysobjMethodNodes=[sysobjMethodNodes,newSysobjMethodNodes];
                    end

                    if~isempty(newCustomMethodNames)
                        customMethodNames=[customMethodNames,newCustomMethodNames];
                        customMethodNodes=[customMethodNodes,newCustomMethodNodes];
                    end
                else
                    customMethodNames=[customMethodNames,blockMethodNames];
                    customMethodNodes=[customMethodNodes,blockMethodNodes];
                end
            end


            notSetGetMask=cellfun(@(x)~contains(x,'.'),customMethodNames);
            customMethodNames=customMethodNames(notSetGetMask);
            customMethodNodes=customMethodNodes(notSetGetMask);
        end

        function[sysobjMethodInfo,customMethodInfo]=getAnalysisInfo(mt)



            [sysobjMethodNames,sysobjMethodNodes,customMethodNames,customMethodNodes]=...
            matlab.system.editor.internal.MethodAction.getImplementedNames(mt);


            sysobjMethodInfo=struct('Name',sysobjMethodNames,'Position',[]);
            for k=1:numel(sysobjMethodNames)
                node=sysobjMethodNodes{k};
                [L,C]=pos2lc(node,lefttreepos(node));
                sysobjMethodInfo(k).Position=[L,C];
            end


            customMethodInfo=struct('Name',customMethodNames,...
            'Position',[]);
            for k=1:numel(customMethodNodes)
                node=customMethodNodes{k};
                [L,C]=pos2lc(node,lefttreepos(node));
                customMethodInfo(k).Position=[L,C];
            end
        end

        function sysobjMethodInfo=addLegacyInfo(mt,sysobjMethodInfo)


            [sysobjMethodInfo(:).Legacy]=deal(false);
            import matlab.internal.lang.capability.Capability
            if Capability.isSupported(Capability.LocalClient)


                legacyMethods={...
                'isInputComplexityLockedImpl',...
                'isInputSizeLockedImpl',...
                'isOutputComplexityLockedImpl',...
                'isOutputSizeLockedImpl',...
                'processInputSizeChangeImpl'};

                mutableMethods={...
                'isInputDataTypeMutableImpl',...
                'isInputSizeMutableImpl',...
                'isInputComplexityMutableImpl',...
                'isDiscreteStateSpecificationMutableImpl',...
                'isTunablePropertyDataTypeMutableImpl',...
                };




                if matlab.system.editor.internal.ParseTreeUtils.hasStrictDefaults(mt)
                    implementedMutableMethodsIndex=...
                    arrayfun(@(x)ismember(x,{sysobjMethodInfo(:).Name}),mutableMethods);
                    mutableMethods=mutableMethods(implementedMutableMethodsIndex);
                    constantMutableMethods=mutableMethods(...
                    cellfun(@(x)matlab.system.editor.internal.ParseTreeUtils.methodWithConstantReturn(mt,x),mutableMethods));
                    if~isempty(constantMutableMethods)





                        superClassMutableMethods=...
                        matlab.system.editor.internal.MethodAction.getMutableImplFromSuperClass(mt);



                        redundantMutableMethods=...
                        constantMutableMethods(cellfun(@(x)~ismember(x,superClassMutableMethods),constantMutableMethods));
                        legacyMethods=[legacyMethods,redundantMutableMethods];
                    end
                end
                for Count=1:length(sysobjMethodInfo)
                    if ismember(sysobjMethodInfo(Count).Name,legacyMethods)
                        sysobjMethodInfo(Count).Legacy=true;
                    end
                end
            end
        end
        function[mutableImplMethod]=getMutableImplFromSuperClass(mt)
            mutableImplMethod=cell(0);
            superClassNames=...
            matlab.system.editor.internal.ParseTreeUtils.getSuperClasses(mt);
            superClassNames(ismember(superClassNames,{'matlab.System',...
            'matlab.system.SFunSystem',...
            'matlab.system.CoreBlockSystem'}))=[];

            superClassNames=...
            superClassNames(cellfun(@(x)~startsWith(x,{'matlab.system.mixin.'}),superClassNames));
            for Count=1:length(superClassNames)
                try
                    metaClassData=meta.class.fromName(superClassNames{Count});
                    if(~isempty(metaClassData))
                        MethodList=metaClassData.MethodList;
                        MutableMethodList=MethodList(arrayfun(@(x)~isempty(regexpi(x.Name,'is[a-zA-Z]*MutableImpl')),MethodList));
                        ImplMutableMethodIndex=arrayfun(@(x)isempty(regexpi(x.DefiningClass.Name,'matlab.system')),MutableMethodList);
                        ImplementedMethodName=arrayfun(@(x)x.Name,MutableMethodList(ImplMutableMethodIndex),'UniformOutput',false);
                        mutableImplMethod=[mutableImplMethod,ImplementedMethodName(:)];
                    end
                catch Excep
                end
            end
            mutableImplMethod=unique(mutableImplMethod);
        end

    end
end

function cmds=addMixin(classdefNode,mixin)


    classExprNode=classdefNode.Cexpr;
    lastSuperClassNode=classExprNode.Right;
    if isnull(lastSuperClassNode)

        [L,C]=pos2lc(classExprNode,righttreepos(classExprNode));
        code=sprintf(' < matlab.System & %s',mixin);
    else
        [L,C]=pos2lc(lastSuperClassNode,righttreepos(lastSuperClassNode));
        code=sprintf(' & %s',mixin);
    end


    cmds={struct('Action','insert',...
    'Text',code,'Line',L,'Column',C+1)};
end

function cmds=insertMethodInClassWithNoBlocks(classdefNode,methodName,args)


    defaultSpacesPerIndent=matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
    initialSpaces=defaultSpacesPerIndent+defaultSpacesPerIndent;
    methodCode=getSystemObjectMethodCode(methodName,initialSpaces,args);
    code=matlab.system.editor.internal.CodeTemplate.getNewMethodBlockCode(defaultSpacesPerIndent,methodCode,args);
    code=[newline,code];


    L=pos2lc(classdefNode,righttreepos(classdefNode));
    cmds=createCmds(code,L,L+2,initialSpaces+1);
end

function cmds=insertMethodBeforeMethod(methodNode,methodName,args)


    [L,C]=matlab.system.editor.internal.ParseTreeUtils.getCodePreInsertionPosition(methodNode);
    initialSpaces=C-1;
    code=getSystemObjectMethodCode(methodName,initialSpaces,args);
    code=[code,newline];


    cmds=createCmds(code,L,L,initialSpaces+1);
end

function cmds=insertMethodAfterMethod(methodNode,methodName,args)


    [L,C]=pos2lc(methodNode,righttreepos(methodNode));
    L=L+1;
    initialSpaces=C-3;
    code=getSystemObjectMethodCode(methodName,initialSpaces,args);
    code=[newline,code];


    cmds=createCmds(code,L,L+1,initialSpaces+1);
end

function cmds=insertMethodAtStartOfMethodBlock(methodBlock,methodName,args)

    firstMethodNode=matlab.system.editor.internal.ParseTreeUtils.getNextNonCommentNode(methodBlock.Body,methodBlock.Body);
    if isempty(firstMethodNode)

        cmds=insertMethodAtEndOfMethodBlock(methodBlock,methodName,args);
    else
        [L,C]=pos2lc(firstMethodNode,lefttreepos(firstMethodNode));
        initialSpaces=C-1;
        code=[getSystemObjectMethodCode(methodName,initialSpaces,args),newline];
        cmds=createCmds(code,L,L,initialSpaces+1);
    end
end

function cmds=insertMethodAtEndOfMethodBlock(methodBlock,methodName,args)


    lastMethodNode=methodBlock.Body;
    while~isnull(lastMethodNode.Next)
        lastMethodNode=lastMethodNode.Next;
    end

    if isnull(lastMethodNode)


        [~,C]=pos2lc(methodBlock,lefttreepos(methodBlock));
        initialSpaces=C-1+matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
        attributesNode=methodBlock.Attr;
        if isnull(attributesNode)
            L=pos2lc(methodBlock,lefttreepos(methodBlock));
        else
            L=pos2lc(attributesNode,righttreepos(attributesNode));
        end
        code='';
        L=L+1;
        Lselect=L;
    else


        [~,C]=pos2lc(lastMethodNode,lefttreepos(lastMethodNode));
        initialSpaces=C-1;
        L=pos2lc(lastMethodNode,righttreepos(lastMethodNode));
        code=newline;
        L=L+1;
        Lselect=L+1;
    end


    code=[code,getSystemObjectMethodCode(methodName,initialSpaces,args)];
    cmds=createCmds(code,L,Lselect,initialSpaces+1);
end

function cmds=insertMethodBeforeMethodBlock(methodBlock,methodName,args)


    [L,C]=pos2lc(methodBlock,lefttreepos(methodBlock));
    initialBlockSpaces=C-1;
    initialMethodSpaces=initialBlockSpaces+matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
    methodCode=getSystemObjectMethodCode(methodName,initialMethodSpaces,args);
    code=matlab.system.editor.internal.CodeTemplate.getNewMethodBlockCode(initialBlockSpaces,methodCode,args);
    code=[code,newline];


    cmds=createCmds(code,L,L+1,initialMethodSpaces+1);
end

function cmds=insertMethodAfterMethodBlock(methodBlock,methodName,args)


    [L,C]=pos2lc(methodBlock,righttreepos(methodBlock));
    initialBlockSpaces=C-3;
    initialMethodSpaces=initialBlockSpaces+matlab.system.editor.internal.CodeTemplate.getSpacesPerIndent;
    methodCode=getSystemObjectMethodCode(methodName,initialMethodSpaces,args);
    code=matlab.system.editor.internal.CodeTemplate.getNewMethodBlockCode(initialBlockSpaces,methodCode,args);
    code=[newline,code];


    L=L+1;
    cmds=createCmds(code,L,L+2,initialMethodSpaces+1);
end

function cmds=replaceMethod(methodNode,methodName,args)


    [Lstart,Cstart]=pos2lc(methodNode,lefttreepos(methodNode));
    initialMethodSpaces=Cstart-1;
    code='';
    if~isempty(methodName)
        code=getSystemObjectMethodCode(methodName,initialMethodSpaces,args);
        code=code(1:end-1);
    end

    [Lend,Cend]=pos2lc(methodNode,righttreepos(methodNode));
    replaceCmd=struct('Action','replace',...
    'Text',code,...
    'StartLine',Lstart,'StartColumn',0,...
    'EndLine',Lend,'EndColumn',Cend+1);

    Lselect=Lstart;
    Cselect=initialMethodSpaces+1;
    selectCmd=struct('Action','select',...
    'StartLine',Lselect,'StartColumn',Cselect,...
    'EndLine',Lselect,'EndColumn',Cselect);

    cmds={replaceCmd,selectCmd};
end

function cmds=createCmds(allCode,Linsert,Lselect,Cselect)

    insertCmd=struct('Action','insert',...
    'Text',allCode,'Line',Linsert,'Column',1);




    selectCmd=struct('Action','select',...
    'StartLine',Lselect,'StartColumn',Cselect,...
    'EndLine',Lselect,'EndColumn',Cselect);
    cmds={insertCmd,selectCmd};
end

function[matchingNode,insertCmd]=getMethodNodeForInsertion(methodsBlocks,methodName,args)




    matchingBlocks={};
    matchingBlockMethods={};
    matchingBlockMethodNames={};
    for methodsBlockIndex=indices(methodsBlocks)
        methodsBlock=select(methodsBlocks,methodsBlockIndex);

        [access,attributes]=matlab.system.editor.internal.ParseTreeUtils.getMethodBlockAttributes(methodsBlock);
        if strcmp(args.Access,access)&&isempty(setxor(args.Attributes,attributes))
            [names,nodes]=matlab.system.editor.internal.ParseTreeUtils.getMethodBlockMethods(methodsBlock);
            matchingBlocks{end+1}=methodsBlock;%#ok<*AGROW>
            matchingBlockMethodNames{end+1}=names;
            matchingBlockMethods{end+1}=nodes;
        end
    end



    blockMethodScores=getBlockMethodScores(matchingBlockMethodNames,methodName);
    highestScore=[];
    matchingMethod=[];

    for blockIndex=1:numel(blockMethodScores)
        methodScores=blockMethodScores{blockIndex};

        if isempty(methodScores)
            continue;
        end


        [v,i]=max(methodScores);
        if isempty(highestScore)||(v>highestScore)
            highestScore=v;
            matchingMethod=matchingBlockMethods{blockIndex}{i};
        end
    end

    if isempty(highestScore)||highestScore==-Inf

        if isempty(matchingBlocks)
            if strcmp(methodName,'System object constructor')

                methodsBlockIndex=indices(methodsBlocks);
                matchingNode=select(methodsBlocks,methodsBlockIndex(1));
                insertCmd='insertBeforeMethodBlock';
            else

                matchingNode=methodsBlock;
                insertCmd='insertAfterMethodBlock';
            end
        else
            if strcmp(methodName,'System object constructor')

                matchingNode=matchingBlocks{1};
                insertCmd='insertAtStartOfMethodBlock';
            else

                matchingNode=matchingBlocks{end};
                insertCmd='insertAtEndOfMethodBlock';
            end
        end
    else
        matchingNode=matchingMethod;
        if highestScore==Inf
            insertCmd='replaceMethod';
        elseif highestScore>0
            insertCmd='insertAfterMethod';
        else
            insertCmd='insertBeforeMethod';
        end
    end
end

function blockMethodScores=getBlockMethodScores(allMethodBlockNames,methodName)


    methodOrder=matlab.system.editor.internal.CodeTemplate.SystemObjectMethodNames;
    if~ismember(methodName,methodOrder)
        methodOrder=matlab.system.editor.internal.CodeTemplate.SystemObjectStaticMethodNames;
    end










    scoreRule=1:numel(methodOrder);
    indexOfMethod=find(strcmp(methodOrder,methodName));
    scoreRule(indexOfMethod+1:end)=-1*scoreRule(indexOfMethod+1:end);



    blockMethodScores={};
    for blockInd=1:numel(allMethodBlockNames)
        blockMethodNames=allMethodBlockNames{blockInd};

        blockScores=[];
        for methodInd=1:numel(blockMethodNames)
            blockMethodName=blockMethodNames{methodInd};
            methodScore=scoreRule(strcmp(blockMethodName,methodOrder));
            if isempty(methodScore)
                methodScore=-Inf;
            elseif strcmp(blockMethodName,methodName)
                methodScore=Inf;
            end
            blockScores(end+1)=methodScore;
        end
        blockMethodScores{end+1}=blockScores;
    end
end

function code=getSystemObjectMethodCode(methodName,initialSpaces,args)
    argArray=[fieldnames(args)';struct2cell(args)'];
    code=matlab.system.editor.internal.CodeTemplate.getSystemObjectMethodCode(methodName,initialSpaces,argArray{:});
end
