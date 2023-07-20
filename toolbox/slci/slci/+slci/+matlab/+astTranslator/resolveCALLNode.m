






function[astNeeded,cObj]=resolveCALLNode(thisNode,astObj)

    astNeeded=false;
    cObj=[];

    assert(any(strcmp(thisNode.kind,{'CALL','LP'})),'Invalid node');


    if slci.matlab.astTranslator.isBuiltin(thisNode)...
        ||slci.matlab.astTranslator.isSFBuiltin(thisNode,astObj)

        cObj=slci.matlab.astTranslator.resolveBuiltin(thisNode,astObj);
        if isempty(cObj)
            return;
        end
        astNeeded=true;



        if isa(cObj,'slci.ast.SFAstUnsupported')
            hasArgs=~isempty(thisNode.Right);
            if~hasArgs

                leftChild=thisNode.Left;
                assert(~isempty(leftChild),'Invalid CALL node');
                if strcmp(leftChild.kind,'ID')&&ismember(leftChild.string,{'i','j'})
                    [~,cObj]=slci.matlab.astTranslator.createAst(leftChild,astObj);
                end
            end
        end
    elseif slci.matlab.astTranslator.isMatlabFunction(thisNode)

        cObj=slci.matlab.astTranslator.resolveMatlabFunction(thisNode,astObj);
        if~isempty(cObj)
            astNeeded=true;
        end
    elseif slci.matlab.astTranslator.isSFFunctionCall(thisNode,astObj)
        cObj=slci.matlab.astTranslator.createSFFunctionCall(thisNode,astObj);
        astNeeded=true;
    elseif isa(astObj.ParentChart,'slci.matlab.EMChart')...
        &&(slci.matlab.astTranslator.isFunctionCall(thisNode)...
        ||slci.matlab.astTranslator.isSubFunctionCall(thisNode)...
        ||slci.matlab.astTranslator.isInnerFunctionCall(thisNode)...
        )

        cObj=slci.matlab.astTranslator.createFunctionCall(thisNode,astObj);
        astNeeded=true;
    else
        [flag,portNum]=slci.matlab.astTranslator.isMLFunctionCallEvent(...
        thisNode,astObj);%#ok
        if flag
            astClassName='slci.ast.SFAstMLFunctionCallEvent';
            cmd=['cObj = ',astClassName,' (thisNode, astObj, portNum);'];
            eval(cmd);
            astNeeded=true;
            return;
        end

        if slci.matlab.astTranslator.isUnknownMATLABFunction(thisNode)
            astNeeded=true;
            cObj=slci.ast.SFAstUnsupported(thisNode,astObj);
            return;
        end
        [isSLFcn,fcnHdl]=slci.matlab.astTranslator.isMTreeNodeSimulinkFunctionCall(...
        thisNode,astObj);
        if isSLFcn
            cObj=slci.ast.SFAstSimulinkFunctionCall(thisNode,astObj,fcnHdl);
            astNeeded=true;
            return;
        end



        hasArgs=~isempty(thisNode.Right);
        if hasArgs

            cObj=[];
            AstClassName=['slci.ast.'...
            ,slci.matlab.astTranslator.getAstClassForMNode('SUBSCR')];
            cmd=['cObj = ',AstClassName,' (thisNode, astObj);'];
            eval(cmd);
        else

            leftChild=thisNode.Left;
            assert(~isempty(leftChild),'Invalid CALL node');
            [~,cObj]=slci.matlab.astTranslator.createAst(leftChild,astObj);
        end
        astNeeded=~isempty(cObj);
    end
end
