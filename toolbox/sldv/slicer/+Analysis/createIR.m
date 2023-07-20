function[analysisIR,mdlStructureInfo]=createIR(mdl)





    if slfeature('GenerateSlicerIRFromSLIR')==1
        try
            [analysisIR,mdlStructureInfo]=createIRFromMDG(mdl);
            return;
        catch ex
            if strcmp(ex.identifier,'Sldv:se:ArrayOfBusesNotSupported')
                throw(ex);
            end
        end
    end

    import Analysis.*;
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    [tree,handleToTreeIdx,refMdlToMdlBlk]=createMdlStructureTree(mdl,[]);
    allHandles=handleToTreeIdx.keys;
    allHandles=[allHandles{:}];

    [allNonSynthesizedBlocks,origBlkHToSynBlkHMap,synBlkHToOrigBlkHMap]=dealSynthesizedBlocks(allHandles);

    if length(allHandles)<2

        error('ModelSlicer:EmptyModel',getString(message('Sldv:ModelSlicer:Analysis:AllElementsInModel')));
    end

    observerSink=getSignalObservers();
    [dfg,dfgMaps,modelElements]=createMdlDataflowGraph(mdl,allHandles,...
    refMdlToMdlBlk,observerSink,origBlkHToSynBlkHMap);

    maps=struct('tree',handleToTreeIdx,'dfg',dfgMaps.blockHandleToProcid,...
    'dfgVar',dfgMaps.portHandleToOid,...
    'inputIdToInportH',dfgMaps.inputIdToInportH,...
    'inportHToInputId',dfgMaps.inportHToInputId,...
    'localDsmToId',dfgMaps.localDsmToIdx,...
    'globalDsmNameToDfgIdx',dfgMaps.globalDsmNameToDfgIdx,...
    'dfgIdxToGlobalDsmName',dfgMaps.dfgIdxToGlobalDsmName,...
    'outputPortToInputPortEdges',dfgMaps.outputPortToInputPortEdges,...
    'dataDependenceBetweenInputAndVar',dfgMaps.dataDependenceBetweenInputAndVar,...
    'allNonSynthesizedBlocks',allNonSynthesizedBlocks,...
    'synBlkHToOrigBlkHMap',synBlkHToOrigBlkHMap,...
    'origBlkHToSynBlkHMap',origBlkHToSynBlkHMap);

    analysisIR=AnalysisIR(tree,dfg,maps);
    mdlH=get_param(mdl,'handle');
    mdlStructureInfo=slslicer.internal.MdlStructureInfo(mdlH,...
    refMdlToMdlBlk,modelElements);
end
