function [signalPaths, blocks] = computeDependence(obj, mode, dfgIds, ...
    inactiveVId, inactiveEId, activeC)
%

%   Copyright 2013-2020 The MathWorks, Inc.
import Analysis.*;

assert(~isempty(dfgIds) && isnumeric(dfgIds));
inactive = SystemsEngineering.SLGraphInactive( obj.ir.dfg, ...
    MSUtils.graphVertices(inactiveVId), ...
    MSUtils.graphEdges(inactiveEId));

ir = obj.ir;
mdlStructureInfo = obj.mdlStructureInfo;
if ~isempty(activeC)
    [src,dst] = obj.getControlDependence(activeC);
else
    src = [];
    dst = [];
end

[iSrc, iDst] = obj.ir.getIteratorDependence;
src = [src; iSrc];
dst = [dst; iDst];

dependence = SystemsEngineering.SLGraphDependence(obj.ir.dfg, ...
    MSUtils.graphVertices(dst), MSUtils.graphVertices(src));

% Filter the inactive design interests
srcDfgIds = setdiff(dfgIds, inactiveVId);

r = SystemsEngineering.SLReachSet(ir.dfg);
switch mode
    case 'back'
        % Create an empty Map for busActions
        [vertexMaps,edgeMap] = createMap(ir);
        ir.dfg.backwardReachable(MSUtils.graphVertices(srcDfgIds), ...
            inactive, dependence, vertexMaps, edgeMap, r);
    case 'forward'
        [vertexMaps,edgeMap] = createMap(ir);
        ir.dfg.forwardReachable(MSUtils.graphVertices(srcDfgIds), ...
            inactive, dependence, vertexMaps, edgeMap, r);
    case 'either'
        [vertexMaps,edgeMap] = createMap(ir);
        ir.dfg.eitherReachable(MSUtils.graphVertices(srcDfgIds), ...
            inactive, dependence, vertexMaps, edgeMap, r);        
    otherwise
        error('ModelSlicer:Dependence:UnknownMode', ...
            getString(message('Sldv:ModelSlicer:ModelSlicer:UnknownDependenceModeSpecified')));
end

procIds = r.getProcs;
blocks = ir.getHandles(procIds);

sigPairs = r.getVarInputPairs;
srcIds = sigPairs(1:2:end);
dstIds = sigPairs(2:2:end);

if ( strcmp(mode,'back') || strcmp(mode,'either') ) && ...
    ~isempty(inactiveVId)  || ~isempty(inactiveEId)
    % In case of dynamic slicing, we need to remove inactive ports of
    % a Merge block not to highlight inactive lines. (g1245723)
    deadInpIdMerge = findDeadSegIdsForMerge();
    if ~isempty(deadInpIdMerge)
        idx = ~ismember([dstIds.vId],deadInpIdMerge);
        srcIds = srcIds(idx);
        dstIds = dstIds(idx);
    end
end

[srcIds,dstIds] = filterInactivePairs(srcIds,dstIds);    
src = ir.getPortHandles(srcIds);
dst = ir.getInportHandles(dstIds);

inputs = r.getInputInputPairs;
sI = inputs(1:2:end);
dI = inputs(2:2:end);

[sI,dI] = filterInactivePairs(sI,dI);
srcI = ir.getInportHandles(sI);
dstI = ir.getInportHandles(dI);

src = [src srcI];
dst = [dst dstI];


% Add DSM blocks
dsmIds = ir.dfgIdxToDsm.keys;
dsmIds = [dsmIds{:}];
dsmVarNodes = r.getSubset(MSUtils.graphVertices(dsmIds));
dsmBlocks = arrayfun(@(x)ir.dfgIdxToDsm(x.vId), dsmVarNodes);
dsmBlocks = reshape(dsmBlocks, numel(dsmBlocks), 1);

blocks = [blocks; dsmBlocks];

% Add signal observer only if
% user wants to retain the signal observers in backward mode and
% there exists some signal observers in model
if obj.options.SliceOptions.SignalObservers && ...
        ~isempty(mdlStructureInfo.signalObservers) && strcmpi(mode,'back')
    
    % Filter the inactive design interests from signal observers
    modelSignalObservers = setdiff(mdlStructureInfo.signalObservers,inactiveVId);
    
    tmpSrcIds = srcIds;
    % used to keep track of already seen srcIds
    srcIdsSeen = [];
    % Iterative algorithm to find signal observers until fixpoint (i.e., 
    % no new signal observers are found)
    while(~isempty(tmpSrcIds))
        newSrcIds = [];
        for i = 1:length(tmpSrcIds)
            srcDfgV = tmpSrcIds(i);
            % get successor from dfg
            srcDfgVSucc = ir.dfg.succ(srcDfgV);
            for j = 1:length(srcDfgVSucc)
                % get successor's successor and check if it is a observer sink.
                secondLevelSucc = ir.dfg.succ(srcDfgVSucc(j));
                vIds = cell2mat({secondLevelSucc.vId});
                signalObservers = intersect(double(modelSignalObservers),vIds);
                if ~isempty(signalObservers)
                    % It is a observer sink.
                    % Update src, dst and blocks to include this sink in the
                    % slice
                    signalObsererNodes = MSUtils.graphVertices(signalObservers);
                    signalObserverBlocks = arrayfun(@(x)ir.getHandles(x), ...
                        signalObsererNodes);
                    blocks = [blocks; signalObserverBlocks]; %#ok<AGROW>
                    srcPort = ir.getPortHandles(srcDfgV);
                    dstPort = ir.getInportHandles(srcDfgVSucc(j));
                    src = [src srcPort]; %#ok<AGROW>
                    dst =[dst dstPort]; %#ok<AGROW>
                    %calculate the new srcIds to include for signal observers
                    %transitively
                    for k = 1:length(signalObsererNodes)
                        sIds = ir.dfg.succ(signalObsererNodes(k));
                        newSrcIds = [newSrcIds cell2mat({sIds.vId})]; %#ok<AGROW>
                    end
                end
            end
        end
        % Filter out already seen srcIds
        newSrcIds = setdiff(newSrcIds, srcIdsSeen);
        % update seen src Ids
        srcIdsSeen = [srcIdsSeen newSrcIds]; %#ok<AGROW>
        % run the above algorithm on updated tmpSrcIds to find more signal
        % observers
        tmpSrcIds = MSUtils.graphVertices(newSrcIds);
    end
end

signalPaths = struct('src', src, 'dst', dst);

    % Internal function 
    function ids = findDeadSegIdsForMerge()
        % In case of dynamic slicing, we need to remove inacitve ports of
        % a Merge block in order not to highlight inactive lines. (g1245723)
        % This ID removal is gets called in this function because merge
        % block doesn't have coverage and Transform.RedundantMerge cannot
        % specify inactive inportH.
        ids = [];
        for n=1:length(blocks)
            if strcmp(get(blocks(n),'BlockType'),'Merge')
                mergeH = blocks(n);
                if isKey(ir.handleToDfgIdx,mergeH)
                    dfgId = ir.handleToDfgIdx(mergeH);
                    inpIds = ir.dfg.pre(MSUtils.graphVertices(dfgId));
                    for m=1:length(inpIds)
                        outpId = ir.dfg.pre(MSUtils.graphVertices(inpIds(m).vId));
                        for nOutp=1:length(outpId)
                            prevBlkId = ir.dfg.pre(MSUtils.graphVertices(outpId(nOutp).vId));
                            for nPrevBH = 1:length(prevBlkId)
                                if ir.dfgIdxToHandle.isKey(prevBlkId(nPrevBH).vId)
                                    prevBlkH = ir.dfgIdxToHandle(prevBlkId.vId);
                                    if ~ismember(prevBlkH,blocks)
                                        ids(end+1) = inpIds(m).vId; %#ok<AGROW>
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    function [src,dst] = filterInactivePairs(src,dst)
        if isempty(inactiveEId)
            return;
        end
        inIdx = [];
        for jdx = 1:length(src)
            edge = ir.dfg.getEdge(src(jdx),dst(jdx));
            if ismember(edge.eId,inactiveEId)
                inIdx(end+1) = jdx; %#ok<AGROW>
            end
        end
        src(inIdx) = [];
        dst(inIdx) = [];
    end
end
