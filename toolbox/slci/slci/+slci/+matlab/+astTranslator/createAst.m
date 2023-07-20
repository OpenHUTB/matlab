





function[astNeeded,cObj]=createAst(thisNode,astObj)




    if any(strcmpi(thisNode.kind,{'GLOBAL','COMMENT','BLKCOM','PERSISTENT'}))
        astNeeded=false;
        cObj=[];
        return;
    else
        astNeeded=true;
    end

    cObj=[];%#ok
    switch(thisNode.kind)

    case{'CALL','LP'}






        if isa(astObj.ParentBlock(),'slci.simulink.IfBlock')
            [resolved,cObj]=slci.matlab.astTranslator.resolveToConst(thisNode,astObj);
        else

            [resolved,cObj]=slci.matlab.astTranslator.getMatlabDirective(thisNode,...
            astObj);
        end

        if~resolved
            [astNeeded,cObj]=slci.matlab.astTranslator.resolveCALLNode(thisNode,astObj);
        end

    case 'PARENS'


        [successflag,ch]=slci.mlutil.getMtreeChildren(thisNode);
        assert(successflag,...
        DAStudio.message('Slci:slci:unsupportedNodeMtree','PARENS'));
        [astNeeded,cObj]=slci.matlab.astTranslator.createAst(ch{1},astObj);

    case 'EXPR'

        [successflag,ch]=slci.mlutil.getMtreeChildren(thisNode);
        assert(successflag,...
        DAStudio.message('Slci:slci:unsupportedNodeMtree','EXPR'));
        [astNeeded,cObj]=slci.matlab.astTranslator.createAst(ch{1},astObj);

    case 'PRINT'

        [successflag,ch]=slci.mlutil.getMtreeChildren(thisNode);
        assert(successflag,...
        DAStudio.message('Slci:slci:unsupportedNodeMtree','PRINT'));
        [astNeeded,cObj]=slci.matlab.astTranslator.createAst(ch{1},astObj);

    case 'ID'

        if isa(astObj.ParentBlock(),'slci.simulink.IfBlock')
            [resolved,cObj]=slci.matlab.astTranslator.resolveToConst(thisNode,astObj);
        else
            resolved=false;
            cObj=[];
        end


        if~resolved

            cObj=createNode('ID',thisNode,astObj);
        end

    case 'NOT'

        [successflag,ch]=slci.mlutil.getMtreeChildren(thisNode);
        assert(successflag);
        if isempty(ch)

            cObj=createNode('TILDE',thisNode,astObj);
        else

            cObj=createNode('NOT',thisNode,astObj);
        end

    case 'ERR'

        DAStudio.error('Slci:slci:unsupportedNodeMtree',thisNode.kind);

    case{'SUBSCR','LP','DOT'}

        [isSLFcn,fcnHdl]=slci.matlab.astTranslator.isMTreeNodeSimulinkFunctionCall(...
        thisNode,astObj);
        if isSLFcn
            cObj=slci.ast.SFAstSimulinkFunctionCall(thisNode,astObj,fcnHdl);
            return;
        end

        [flag,directive]=slci.matlab.astTranslator.getMatlabDirective(thisNode,...
        astObj);
        if flag
            assert(~isempty(directive));
            cObj=directive;
        else
            cObj=createNode(thisNode.kind,thisNode,astObj);
        end


    case{'LB'}

        cObj=createNode('CONCATENATELB',thisNode,astObj);

    otherwise

        cObj=createNode(thisNode.kind,thisNode,astObj);

    end

end


function astClassName=resolveAstClassName(kind,mNode,astObj)
    astClassName=['slci.ast.'...
    ,slci.matlab.astTranslator.getAstClassForMNode(kind)];
    if strcmp(astClassName,'slci.ast.SFAstIdentifier')...
        &&isa(mNode,'mtree')
        if isa(astObj,'slci.ast.SFAst')
            owner=astObj.getRootAstOwner;
            if isa(owner,'slci.stateflow.Transition')...
                ||isa(owner,'slci.stateflow.SFState')
                chart=owner.ParentChart;
                assert(isa(chart,'slci.stateflow.Chart'));
                if chart.isEvent(mNode.string)
                    astClassName='slci.ast.SFAstExplicitEvent';
                end
            end
        end
    end
end


function cObj=createNode(kind,mNode,astObj)

    cObj=[];
    if strcmpi(kind,'SUBSCR')...
        &&isempty(mNode.Right)

        cmd='cObj = slci.ast.SFAstUnsupported(mNode, astObj);';
    elseif strcmpi(kind,'ID')&&ismember(lower(mNode.string),{'inf','nan'})

        cmd='cObj = slci.ast.SFAstUnsupported(mNode, astObj);';
    else
        astClassName=resolveAstClassName(kind,mNode,astObj);
        cmd=['cObj = ',astClassName,' (mNode, astObj);'];
    end
    eval(cmd);

end
