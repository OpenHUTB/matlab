






classdef Stateflow

    methods(Static=true)



        [linkStatus,emCharts,modelPath]=findAllEmCharts(system);





        msg=highlightSFLabelByIndex(line,ind);




        tableInfo=AddIndiceHyperLinkToTable(indices,sfObj,sourceSnippet);






        FailingExpressions=GetFailingExpressions(system,mdladvObj,CVerifyHandle,MVerifyHandle);


    end

    methods(Static=true,Hidden=true)




        [astContainer,resolvedSymbolIds]=getAbstractSyntaxTree(stateflowObject);




        booleanResult=isActionLanguageC(stateflowObject);




        booleanResult=isActionLanguageM(stateflowObject);




        mtreeObject=createMtreeObject(codeFragment,resolvedSymbolIds);




        filteredSymbolIds=filterSymbolIds(symbolIds,symbolType);




        [dataType,bIsConstant]=getDataTypeFromTreeNode(system,treeNode,resolvedSymbolIds);




        [dataType,bIsConstant]=getAstDataType(system,ast,chartObj);




        booleanResult=IsAComparison(ast);




        booleanResult=IsAssignment(ast);





        dataType=getDataTypeFromDataDict(system,idName);




        dataType=getBuiltInDataType(system,className);


        dataBitWidth=getDataBitwidth(dataType);

        [sfObjs,SFCharts]=sfFindSys(system,FollowLinks,LookUnderMasks,sfFindArgs,filterCommented);

        loops=getLoopsInChart(chartObj);


        sfDataObj=getDataDefinedInHierarchy(sfObj,scopeType);


        [targetVariable]=getLoopCountersInTransitions(gPath,sfJunctionMap);

        sfData=getDataUsedInSFObj(sfObj);


        bFlag=isDefaultTransition(sfObj);
        bFlag=isSuperTransition(sfObj);
        bFlag=isSuperTransitionToDest(sfObj);
        bFlag=isSuperTransitionFromSource(sfObj);
        bFlag=isSelfTransition(sfObj);
        bFlag=isInnerTransition(sfObj);
        bFlag=isTransitionHorizontal(sfObj);
        bFlag=isTransitionStraight(sfObj);
        bFlag=isTransitionVertical(sfObj);
        bFlag=isUnnecessaryJunction(sfObj);
        bFlag=doTransitionsOverlap(sfObj1,sfObj2);
        bFlag=doSegmentsIntersect(sfObj1,sfObj2);
        bFlag=doSplineBoundingBoxesOverlap(sfObj1,sfObj2);
        bFlag=doTransitionBoxOverlap(sfObj1,sfObj2);
        bFlag=doTransitionJunctionOverlap(sfTran,sfJunc);
        bFlag=isStateflowObject(sid);
    end

end


