function validateSFChartsAreIndependent(blkHandle,bdHandle)




    if~license('test','Stateflow')
        return;
    end


    insideHarnessBlocks=find_system(blkHandle,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','off','MaskType','Stateflow');
    bdBlocks=find_system(bdHandle,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','off','MaskType','Stateflow');
    outsideHarnessBlocks=setdiff(bdBlocks,insideHarnessBlocks);

    insideHarnessCharts=arrayfun(@(h)sfprivate('block2chart',h),insideHarnessBlocks);
    outsideHarnessCharts=arrayfun(@(h)sfprivate('block2chart',h),outsideHarnessBlocks);

    try
        validateThatChartSet1DoesNOTDependOnChartSet2(insideHarnessCharts,outsideHarnessCharts);
    catch ME %#ok

    end
end

function validateThatChartSet1DoesNOTDependOnChartSet2(chartSet1,chartSet2)






    chartSet1=unique(chartSet1);
    chartSet2=unique(chartSet2);


    if isempty(chartSet1)||isempty(chartSet2)
        return;
    end

    dependencies=findUsesOfElementsFromSetAInSetB(chartSet2,chartSet1);
    if isempty(dependencies)
        return;
    else
        keys=dependencies.keys;
        for iter=1:length(keys)
            idOfWhereFunctionIsUsed=keys{iter};
            useMatrix=dependencies(idOfWhereFunctionIsUsed);
            sourceIds=useMatrix(1:end,1);
            for funcId=sourceIds(:)'
                Simulink.harness.internal.warn({'Simulink:Harness:ExportedGraphicalFunctionsFromOutsideHarnessUsed',...
                sf('GetHyperLinkedNameForObjects',funcId),...
                sf('GetHyperLinkedNameForObjects',sf('get',funcId,'.chart')),...
                sf('GetHyperLinkedNameForObjects',idOfWhereFunctionIsUsed)...
                });
            end
        end
    end
end

function usesMap=findUsesOfElementsFromSetAInSetB(setA,setB)
    usesMap=[];
    setAExportedElements=getSetOfExportedGraphicalFunctionsInCharts(setA);
    if setAExportedElements.Count>0
        setBUddHs=idToHandle(sfroot,setB);
        usesMap=Stateflow.Refactor.getUsesOfObjectsIn(setBUddHs,setAExportedElements);
    end

end


function exportedFuncIdSet=getSetOfExportedGraphicalFunctionsInCharts(chartSet)
    exportedFuncIdSet=containers.Map('KeyType','double','ValueType','double');
    chartSetWithExportedFunctions=sf('find',chartSet,'chart.exportChartFunctions',1);
    for chartId=chartSetWithExportedFunctions(:)'
        funcIds=sf('FunctionsOf',chartId);
        for fId=funcIds(:)'
            exportedFuncIdSet(fId)=1;
        end
    end
end
