function[result,ResultDescription]=modelAdvisorCheck_ifBlock(system,xlateTagPrefix)




    ResultDescription={};
    result=true;




    ifBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','If');
    blkHandlesWithFloatingPtCmp={};

    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setSubBar(false);
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    if isempty(ifBlocks)
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'IfBlocksNoneFound']));
        ResultDescription{end+1}=ft;
        return;
    end


    for i=1:length(ifBlocks)
        isFloatingPtEquality=checkIfBlock(ifBlocks{i});
        if isFloatingPtEquality
            blkHandlesWithFloatingPtCmp{end+1}=ifBlocks{i};%#ok<AGROW>
        end
    end


    blkHandlesWithFloatingPtCmp=mdladvObj.filterResultWithExclusion(blkHandlesWithFloatingPtCmp);

    if~isempty(blkHandlesWithFloatingPtCmp)
        ft.setSubResultStatus('Warn');
        ft.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'IfBlockWarningFloatingPoint']));
        ft.setRecAction(DAStudio.message([xlateTagPrefix,'IfBlockRecActionFloatingPoint']));
        ft.setListObj(blkHandlesWithFloatingPtCmp);
        result=false;
    end

    ft1=ModelAdvisor.FormatTemplate('ListTemplate');
    ft1.setSubBar(false)



    hasElseIf=~strcmp('',deblank(get_param(ifBlocks,'ElseIfExpressions')));
    doesNotHaveElse=strcmp('off',get_param(ifBlocks,'ShowElse'));
    badCon=hasElseIf&doesNotHaveElse;
    badConBlocks={};
    if(any(badCon))
        badConBlocks=ifBlocks(find(badCon));%#ok<FNDSB>
        badConBlocks=mdladvObj.filterResultWithExclusion(badConBlocks);
    end

    if~isempty(badConBlocks)

        ft1.setSubResultStatus('warn');
        ft1.setListObj(badConBlocks);
        ft1.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'hisl_0010_Fail_1']));
        ft1.setRecAction(DAStudio.message([xlateTagPrefix,'hisl_0010_RecAct_1']));
        result=false;
    end








    portCons=get_param(ifBlocks,'PortConnectivity');
    numIns=get_param(ifBlocks,'numInputs');
    noConSub=zeros(length(ifBlocks),1);
    for inx=1:length(ifBlocks)
        for jnx=(str2double(numIns{inx})+1):length(portCons{inx})
            if isempty(portCons{inx}(jnx).DstBlock)
                noConSub(inx)=1;
            else

                dstBlock=get_param(portCons{inx}(jnx).DstBlock,'BlockType');
                if(strcmp(dstBlock,'Terminator'))
                    noConSub(inx)=1;
                end
            end
        end
    end

    ft2=ModelAdvisor.FormatTemplate('ListTemplate');
    ft2.setSubBar(false);
    noCondBlocks={};
    if(any(noConSub))
        noCondBlocks=ifBlocks(find(noConSub));%#ok<FNDSB>
        noCondBlocks=mdladvObj.filterResultWithExclusion(noCondBlocks);
    end

    if~isempty(noCondBlocks)

        ft2.setSubResultStatus('warn');
        ft2.setListObj(noCondBlocks);
        ft2.setSubResultStatusText(DAStudio.message([xlateTagPrefix,'hisl_0010_Fail_2']));
        ft2.setRecAction(DAStudio.message([xlateTagPrefix,'hisl_0010_RecAct_2']));
        result=false;
    end

    if result
        ft.setSubResultStatus('Pass');
        ft.setSubResultStatusText([DAStudio.message([xlateTagPrefix,'IfBlockPass1']),'<br/>',DAStudio.message([xlateTagPrefix,'IfBlockPass2'])]);
        ResultDescription{end+1}=ft;
    else
        if~isempty(blkHandlesWithFloatingPtCmp)
            ResultDescription{end+1}=ft;
        end
        if~isempty(badConBlocks)
            ResultDescription{end+1}=ft1;
        end
        if~isempty(noCondBlocks)
            ResultDescription{end+1}=ft2;
        end
    end
end

function isFloatingPtEquality=checkIfBlock(ifBlock)
    pHandles=get_param(ifBlock,'PortHandles');
    ipHandles=pHandles.Inport;
    ipPorts=length(ipHandles);
    isFloatingPtEquality=false;




    dtFloating=false;
    for i=1:length(ipHandles)
        if strcmp(get_param(ipHandles(i),'CompiledPortDataType'),'double')||...
            strcmp(get_param(ipHandles(i),'CompiledPortDataType'),'single')
            dtFloating=true;
            break;
        end
    end

    if dtFloating
        ifExp=get_param(ifBlock,'IfExpression');
        isFloatingPtEqualityIfExp=checkExp(ifExp,ipPorts);
        elseifExp=get_param(ifBlock,'elseIfExpressions');
        idx=strfind(elseifExp,',');
        elseifExpList={};
        if isempty(idx)
            elseifExpList{end+1}=elseifExp;
        else
            elseifExpList{end+1}=elseifExp(1:idx(1));
            for i=1:length(idx)-1
                elseifExpList{end+1}=elseifExp(idx(i)+1:idx(i+1)-1);%#ok<AGROW>
            end
            elseifExpList{end+1}=elseifExp(idx(end)+1:end);
        end
        isFloatingPtEqualityElseIfExp=false;
        for i=1:length(elseifExpList)
            isFloatingPtEqualityElseIfExp=checkExp(elseifExpList{i},ipPorts);
            if isFloatingPtEqualityElseIfExp
                break;
            end
        end
        isFloatingPtEquality=isFloatingPtEqualityElseIfExp||isFloatingPtEqualityIfExp;
    end
end

function isFloatingPtEquality=checkExp(Exp,ipPorts)
    if isempty(Exp)
        isFloatingPtEquality=false;
        return;
    end





    allOperators={'LT','GT','LE','GE','EQ','NE','AND','OR','NOT'};
    isFloatingPtEquality=false;
    operators={'EQ','NE','AND','OR','NOT'};

    T=mtree(strrep(Exp,' ',''));


    expressionHasNoOperators=true;

    for i=1:length(allOperators)
        opNodes=mtfind(T,'Kind',allOperators{i});
        if opNodes.count~=0
            expressionHasNoOperators=false;



            if any(strcmp(operators,allOperators{i}))


                isFloatingPtEquality=checkTree(opNodes,ipPorts,allOperators{i});

                if isFloatingPtEquality


                    break;
                end
            end
        end
    end

    if expressionHasNoOperators
        isFloatingPtEquality=true;
    end
end


function isFloatingPtEquality=checkTree(opNodes,ipPorts,operator)
    isFloatingPtEquality=false;


    numNodes=opNodes.count;
    nodeIndices=opNodes.indices;

    for N=1:numNodes
        opNode=opNodes.select(nodeIndices(N));

        if strcmp(operator,'NOT')
            if~isempty(opNode)
                while(strcmp(opNode.Arg.kind,'PARENS'))
                    opNode=opNode.Arg;
                end
                notArg=mtfind(opNode.Arg,'Kind','CALL');

                for k=1:length(notArg.Left.strings)
                    for j=1:ipPorts
                        if strcmp(notArg.Left.strings{k},['u',num2str(j)])
                            isFloatingPtEquality=true;
                            break;
                        end
                    end
                end
            end
            if isFloatingPtEquality
                break;
            end
        end

        if~isempty(opNode)
            LeftNode=opNode.Left;
            RightNode=opNode.Right;
            while LeftNode.count==1&&(strcmp(LeftNode.kind,'PARENS')||strcmp(LeftNode.kind,'UMINUS')...
                ||strcmp(LeftNode.kind,'UPLUS'))
                LeftNode=LeftNode.Arg;
            end
            while RightNode.count==1&&(strcmp(RightNode.kind,'PARENS')||strcmp(RightNode.kind,'UMINUS')...
                ||strcmp(RightNode.kind,'UPLUS'))
                RightNode=RightNode.Arg;
            end
            leftNode=mtfind(LeftNode,'Kind','CALL');
            rightNode=mtfind(RightNode,'Kind','CALL');
            if~isempty(leftNode)
                for k=1:length(leftNode.Left.strings)
                    for j=1:ipPorts
                        if strcmp(leftNode.Left.strings{k},['u',num2str(j)])
                            isFloatingPtEquality=true;
                            break;
                        end
                    end
                end
            end
            if~isFloatingPtEquality
                if~isempty(rightNode)
                    for k=1:length(rightNode.Left.strings)
                        for j=1:ipPorts
                            if strcmp(rightNode.Left.strings{k},['u',num2str(j)])
                                isFloatingPtEquality=true;
                                break;
                            end
                        end
                    end
                end
            end
        end

        if isFloatingPtEquality
            break;
        end
    end
end

