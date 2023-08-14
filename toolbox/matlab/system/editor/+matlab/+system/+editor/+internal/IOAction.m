classdef IOAction




    methods(Static)




        function cmds=insertInput(mt,classCode)
            cmds=insertInputImpl(mt,classCode,false);
        end

        function cmds=insertOptionalInputs(mt,classCode)

            cmds=insertInputImpl(mt,classCode,true);
        end






        function cmds=insertOutput(mt,classCode)
            cmds=insertOutputImpl(mt,classCode,false);
        end

        function cmds=insertOptionalOutputs(mt,classCode)

            cmds=insertOutputImpl(mt,classCode,true);
        end

        function names=getInputNames(mt)



            classdefNode=mtfind(mt,'Kind','CLASSDEF');



            isNondirect=matlab.system.editor.internal.ParseTreeUtils.hasNonDirectAuthoringMethods(classdefNode);
            if isNondirect
                systemInputMethod='updateImpl';
            else
                systemInputMethod='stepImpl';
            end
            systemInputMethodNode=matlab.system.editor.internal.ParseTreeUtils.getMethodNode(classdefNode,systemInputMethod);


            if isempty(systemInputMethodNode)
                names={};
            else
                names=matlab.system.editor.internal.ParseTreeUtils.getMethodInputNames(systemInputMethodNode);
            end
        end

        function names=getOutputNames(mt)





            classdefNode=mtfind(mt,'Kind','CLASSDEF');



            isNondirect=matlab.system.editor.internal.ParseTreeUtils.hasNonDirectAuthoringMethods(classdefNode);
            if isNondirect
                systemOutputMethod='outputImpl';
            else
                systemOutputMethod='stepImpl';
            end
            systemOutputMethodNode=matlab.system.editor.internal.ParseTreeUtils.getMethodNode(classdefNode,systemOutputMethod);


            if isempty(systemOutputMethodNode)
                names={};
            else
                names=matlab.system.editor.internal.ParseTreeUtils.getMethodOutputNames(systemOutputMethodNode);
            end
        end

        function[inputsInfo,outputsInfo]=getAnalysisInfo(mt)



            classdefNode=mtfind(mt,'Kind','CLASSDEF');



            isNondirect=matlab.system.editor.internal.ParseTreeUtils.hasNonDirectAuthoringMethods(classdefNode);
            if isNondirect
                inputMethodNode=matlab.system.editor.internal.ParseTreeUtils.getMethodNode(classdefNode,'updateImpl');
                outputMethodNode=matlab.system.editor.internal.ParseTreeUtils.getMethodNode(classdefNode,'outputImpl');
            else
                inputMethodNode=matlab.system.editor.internal.ParseTreeUtils.getMethodNode(classdefNode,'stepImpl');
                outputMethodNode=inputMethodNode;
            end


            if isempty(inputMethodNode)
                inputNames={};
                inputNodes={};
            else
                [inputNames,inputNodes]=...
                matlab.system.editor.internal.ParseTreeUtils.getMethodInputNames(inputMethodNode);
            end
            if isempty(outputMethodNode)
                outputNames={};
                outputNodes={};
            else
                [outputNames,outputNodes]=...
                matlab.system.editor.internal.ParseTreeUtils.getMethodOutputNames(outputMethodNode);
            end


            inputsInfo=struct('Name',inputNames,'Position',[]);
            numInputs=numel(inputNodes);
            for inputInd=1:numInputs
                node=inputNodes{inputInd};


                [L,C]=pos2lc(node,lefttreepos(node));
                inputsInfo(inputInd).Position=[L,C];

            end


            outputsInfo=struct('Name',outputNames,'Position',[]);
            numOutputs=numel(outputNodes);
            for outputInd=1:numOutputs
                node=outputNodes{outputInd};


                [L,C]=pos2lc(node,lefttreepos(node));
                outputsInfo(outputInd).Position=[L,C];
            end
        end
    end
end

function cmds=insertInputImpl(mt,classCode,isOptional)

    classdefNode=mtfind(mt,'Kind','CLASSDEF');





    isNondirect=matlab.system.editor.internal.ParseTreeUtils.hasNonDirectAuthoringMethods(classdefNode);
    if isNondirect
        processMethod='updateImpl';
        methodsWithSysInputs={'validateInputsImpl','isInputDirectFeedthroughImpl','outputImpl'};
    else
        processMethod='stepImpl';
        methodsWithSysInputs={'validateInputsImpl'};
    end



    [methodNames,methodNodes]=matlab.system.editor.internal.MethodAction.getImplementedNames(mt);
    isProcessMethodNode=ismember(methodNames,processMethod);
    if isempty(methodNodes)||~any(isProcessMethodNode)
        processCmds=matlab.system.editor.internal.MethodAction.insert(mt,processMethod,...
        'UseOptionalInputs',isOptional);


        if~isOptional
            textLine=getFunctionSignatureLine(processCmds{1}.Text);
            if~isempty(textLine)
                processCmds{2}.StartColumn=strfind(textLine,'u)');
                processCmds{2}.EndColumn=processCmds{2}.StartColumn+1;
            end
        end
    else

        processCmds=addInput(methodNodes{isProcessMethodNode},...
        true,isOptional);
    end


    methodNodesWithSysInputs={};
    if~isempty(methodNodes)
        methodNodesWithSysInputs=methodNodes(ismember(methodNames,methodsWithSysInputs));

        isSetup=ismember(methodNames,'setupImpl');
        if any(isSetup)
            setupNode=methodNodes{isSetup};
            if~isnull(setupNode.Ins)&&~isnull(setupNode.Ins.Next)
                methodNodesWithSysInputs{end+1}=setupNode;
            end
        end
    end


    cmds={};
    if~isempty(methodNodes)
        getInputNamesImplNode=methodNodes(strcmp(methodNames,'getInputNamesImpl'));
        if~isempty(getInputNamesImplNode)
            cmds=[cmds,addOutput(getInputNamesImplNode{1},classCode,...
            false,isOptional,'name')];
        end
    end


    for k=1:numel(methodNodesWithSysInputs)
        cmds=[cmds,addInput(methodNodesWithSysInputs{k},...
        false,isOptional)];%#ok<*AGROW>
    end



    cmds=[cmds,processCmds];
end

function cmds=insertOutputImpl(mt,classCode,isOptional)

    classdefNode=mtfind(mt,'Kind','CLASSDEF');





    isNondirect=matlab.system.editor.internal.ParseTreeUtils.hasNonDirectAuthoringMethods(classdefNode);
    if isNondirect
        processMethod='outputImpl';
    else
        processMethod='stepImpl';
    end



    [methodNames,methodNodes]=matlab.system.editor.internal.MethodAction.getImplementedNames(mt);
    isProcessMethodNode=ismember(methodNames,processMethod);
    if isempty(methodNodes)||~any(isProcessMethodNode)
        processCmds=matlab.system.editor.internal.MethodAction.insert(mt,processMethod,...
        'UseOptionalOutputs',isOptional);


        if~isOptional
            textLine=getFunctionSignatureLine(processCmds{1}.Text);
            if~isempty(textLine)
                processCmds{2}.StartColumn=strfind(textLine,'y');
                processCmds{2}.EndColumn=processCmds{2}.StartColumn+1;
            end
        end
    else

        processCmds=addOutput(methodNodes{isProcessMethodNode},classCode,...
        true,isOptional,'y');
    end


    methodNodesWithNamedOutputs={};
    if~isempty(methodNodes)
        methodsWithNamedOutputsMask=ismember(methodNames,...
        {'getOutputNamesImpl','getOutputSizeImpl','getOutputDataTypeImpl','isOutputComplexImpl','isOutputFixedSizeImpl'});
        methodNamesWithNamedOutputs=methodNames(methodsWithNamedOutputsMask);
        methodNodesWithNamedOutputs=methodNodes(methodsWithNamedOutputsMask);
    end


    cmds={};
    for k=1:numel(methodNodesWithNamedOutputs)
        if strcmp(methodNamesWithNamedOutputs{k},'getOutputNamesImpl')
            baseName='name';
        else
            baseName='out';
        end
        cmds=[cmds,addOutput(methodNodesWithNamedOutputs{k},classCode,...
        false,isOptional,baseName)];%#ok<*AGROW>
    end



    cmds=[cmds,processCmds];
end

function cmds=addInput(functionNode,selectInEditor,isOptional)


    inputNode=functionNode.Ins;
    isVarargin=@(node)~isnull(node)&&iskind(node,'ID')&&strcmp('varargin',string(node));
    if isnull(inputNode)||isVarargin(inputNode)
        error(message('MATLAB:system:Editor:CodeMissingMethodInput',string(functionNode.Fname)));
    end


    numInputs=0;
    while~isnull(inputNode.Next)&&~isVarargin(inputNode.Next)
        numInputs=numInputs+1;
        inputNode=inputNode.Next;
    end


    if isOptional&&isVarargin(inputNode.Next)
        if selectInEditor
            [L,C]=pos2lc(inputNode.Next,righttreepos(inputNode.Next));
            cmds={struct('Action','select',...
            'StartLine',L,'StartColumn',C+1,...
            'EndLine',L,'EndColumn',C+1)};
        else
            cmds={};
        end
        return;
    end


    if isOptional
        name='varargin';
    elseif numInputs==0
        name='u';
    else
        name=sprintf('u%u',numInputs+1);
    end


    [L,C]=pos2lc(inputNode,righttreepos(inputNode));
    code=sprintf(',%s',name);
    cmds={struct('Action','insert',...
    'Text',code,'Line',L,'Column',C+1)};

    if selectInEditor&&~isOptional
        selectCmd=struct('Action','select',...
        'StartLine',L,'StartColumn',C+2,...
        'EndLine',L,'EndColumn',C+1+numel(code));
        cmds{end+1}=selectCmd;
    end
end

function cmds=addOutput(functionNode,classCode,selectInEditor,isOptional,baseName)

    outputNode=functionNode.Outs;
    if isnull(outputNode)
        cmds=addOutputToFunctionWithNoArguments(functionNode,selectInEditor,isOptional,baseName);
        return;
    end


    isVarargout=@(node)~isnull(node)&&iskind(node,'ID')&&strcmp('varargout',string(node));
    numOutputs=1;
    while~isnull(outputNode.Next)&&~isVarargout(outputNode.Next)
        numOutputs=numOutputs+1;
        outputNode=outputNode.Next;
    end


    isVarargoutOutput=(numOutputs==1)&&isVarargout(outputNode);
    if isOptional&&(isVarargoutOutput||isVarargout(outputNode.Next))
        if selectInEditor
            if isVarargoutOutput
                varargoutNode=outputNode;
            else
                varargoutNode=outputNode.Next;
            end
            [L,C]=pos2lc(varargoutNode,righttreepos(varargoutNode));
            cmds={struct('Action','select',...
            'StartLine',L,'StartColumn',C+1,...
            'EndLine',L,'EndColumn',C+1)};
        else
            cmds={};
        end
        return;
    end


    if isOptional
        name='varargout';
    elseif isVarargoutOutput
        name=baseName;
    else
        name=sprintf('%s%u',baseName,numOutputs+1);
    end


    if numOutputs==1

        argPos=righttreepos(outputNode);
        currentChar=classCode(argPos);
        while~strcmp(currentChar,'=')&&~strcmp(currentChar,']')
            argPos=argPos+1;
            currentChar=classCode(argPos);
        end


        firstName=string(outputNode);
        if strcmp(currentChar,'=')

            cmds=addOutputToFunctionWithOneNonBracketedArgument(outputNode,firstName,selectInEditor,isOptional,baseName);
            return;
        elseif strcmp(firstName,'varargout')

            code=sprintf('%s,%s',name,firstName);
            [L,C]=pos2lc(outputNode,righttreepos(outputNode));
            cmds={struct('Action','replace',...
            'Text',code,'StartLine',L,'StartColumn',C+1-numel(firstName),...
            'EndLine',L,'EndColumn',C+1)};

            if selectInEditor&&~isOptional
                selectCmd=struct('Action','select',...
                'StartLine',L,'StartColumn',C+1-numel(firstName),...
                'EndLine',L,'EndColumn',C+1-numel(firstName)+numel(name));
                cmds{end+1}=selectCmd;
            end
            return;

        end
    end


    [L,C]=pos2lc(outputNode,righttreepos(outputNode));
    code=sprintf(',%s',name);
    cmds={struct('Action','insert',...
    'Text',code,'Line',L,'Column',C+1)};

    if selectInEditor&&~isOptional
        selectCmd=struct('Action','select',...
        'StartLine',L,'StartColumn',C+2,...
        'EndLine',L,'EndColumn',C+2+numel(name));
        cmds{end+1}=selectCmd;
    end
end

function cmds=addOutputToFunctionWithNoArguments(functionNode,selectInEditor,isOptional,baseName)


    if isOptional
        name='varargout';
    else
        name=baseName;
    end


    code=sprintf('%s = ',name);

    [L,C]=pos2lc(functionNode.Fname,lefttreepos(functionNode.Fname));
    cmds={struct('Action','insert',...
    'Text',code,'Line',L,'Column',C)};

    if selectInEditor&&~isOptional
        selectCmd=struct('Action','select',...
        'StartLine',L,'StartColumn',C,...
        'EndLine',L,'EndColumn',C+numel(name));
        cmds{end+1}=selectCmd;
    end
end

function cmds=addOutputToFunctionWithOneNonBracketedArgument(outputNode,firstName,selectInEditor,isOptional,baseName)



    if strcmp(firstName,'varargout')
        name=baseName;
        code=sprintf('[%s,%s]',name,firstName);
    else
        if isOptional
            name='varargout';
        else
            name=sprintf('%s2',baseName);
        end
        code=sprintf('[%s,%s]',firstName,name);
    end
    [L,C]=pos2lc(outputNode,righttreepos(outputNode));
    cmds={struct('Action','replace',...
    'Text',code,'StartLine',L,'StartColumn',C+1-numel(firstName),...
    'EndLine',L,'EndColumn',C+1)};

    if selectInEditor&&~isOptional
        if strcmp(firstName,'varargout')
            selectCmd=struct('Action','select',...
            'StartLine',L,'StartColumn',C+2-numel(firstName),...
            'EndLine',L,'EndColumn',C+2-numel(firstName)+numel(name));
            cmds{end+1}=selectCmd;
        else
            selectCmd=struct('Action','select',...
            'StartLine',L,'StartColumn',C+3,...
            'EndLine',L,'EndColumn',C+3+numel(name));
            cmds{end+1}=selectCmd;
        end
    end
end

function textLine=getFunctionSignatureLine(text)


    textLine=regexp(text,'^[^\n]*function[^\n]*$','match','lineanchors','once');
end
