classdef TreeResult < handle
%
% Class for result data for a rooted result tree
% The root node can be node of result set, test file result, test suite result or 
% test case result and even more.

% Copyright 2014-2018 The MathWorks, Inc.
%
    
    properties
        rootID = [];
        nodeList = [];      % in DFS order.
        data = [];
        
        parentList = [];    % parenting relationship in the tree.
        errorStatus = 0;
    end
    
    properties (Access = private)
        nodeMap = [];
    end

    methods
        function getResultTree(obj)
            obj.rootID = int32(obj.rootID);
            treeNodes = obj.genDFSListOfOneTree(); % IDs of the tree
            NNodes = length(treeNodes);
            
            obj.nodeList = treeNodes;
            obj.data = [];
            
            for k = 1 : NNodes
                nodeResult = stm.internal.report.NodeResult();
                nodeResult.ID = treeNodes(k);
                nodeResult.getData();
                obj.data = [obj.data nodeResult];
            end
            
            obj.nodeMap = Simulink.sdi.Map(int32(0),int32(0));
            for nodeIdx = 1 : NNodes  
                obj.nodeMap.insert(obj.nodeList(nodeIdx),nodeIdx);
            end
            obj.setTreeInfoForNodes();
            obj.updateStatus(true); % everything is fine.
        end
        
        function subTree = getSubTree(obj,rootId)
            subTree = stm.internal.report.TreeResult();
            tmp = find(obj.nodeList == rootId);
            rootIdx = tmp(1);
            if(rootIdx == 1)
                subTree = obj;
                % input id is the root ID of this tree
            end
        end
    end
    
    methods (Access = private)
        function setTreeInfoForNodes(obj)
            obj.parentList = zeros(1,length(obj.nodeList));
            
            resultTree = stm.internal.getResultTree(obj.rootID);
            assert(length(resultTree) == 4);
            tmpNodeList = double(resultTree{1});
            tmpParentList = double(resultTree{3}) + 1;
            tmpDepthList = double(resultTree{4});
            NNodes = length(tmpNodeList);
            for nodeIdx = 1 : NNodes
                nodeID = tmpNodeList(nodeIdx);
                hasKey = obj.nodeMap.isKey(nodeID);
                assert(hasKey);
                posInDFSList = obj.nodeMap.getDataByKey(nodeID);
                obj.data(posInDFSList).depthInTree = tmpDepthList(nodeIdx);
                
                obj.parentList(posInDFSList) = 0;
                parentIndex = tmpParentList(nodeIdx);
                if(parentIndex > 0)
                    parentID = tmpNodeList(parentIndex);
                    parentInDFSList = obj.nodeMap.getDataByKey(parentID);
                    obj.parentList(posInDFSList) = parentInDFSList;
                end
            end
            for nodeIdx = 1 : NNodes
                nodeID = obj.nodeList(nodeIdx);
                x = obj.parentList(nodeIdx);
                if(x > 0)
                    obj.data(nodeIdx).parentIDInTree = obj.data(x).ID;
                    obj.data(nodeIdx).parentNameInTree = obj.data(x).metaData.name;
                end
                
                % get path from root
                tmp = find(obj.nodeList == nodeID);
                assert(~isempty(tmp));
                currIdx = tmp(1);   
                tmpList = [];
                while(currIdx > 0)
                    tmpList = [tmpList currIdx];
                    currIdx = obj.parentList(currIdx);
                end
                obj.data(nodeIdx).parentList = fliplr(tmpList);
                
                obj.data(nodeIdx).pathFromRoot = '';
                for k = 1 : length(obj.data(nodeIdx).parentList)
                    x = obj.data(nodeIdx).parentList(k);
                    
                    if(~isempty(obj.data(nodeIdx).pathFromRoot) && obj.data(nodeIdx).pathFromRoot(end) ~= '/')
                        obj.data(nodeIdx).pathFromRoot = strcat(obj.data(nodeIdx).pathFromRoot, '/', obj.data(x).metaData.name);
                    else
                        obj.data(nodeIdx).pathFromRoot = strcat(obj.data(nodeIdx).pathFromRoot, obj.data(x).metaData.name);
                    end
                    
                end
            end
        end
        
        function idList = genDFSListOfOneTree(obj)
            idList = [obj.rootID];
            tmpIDList = idList;
            while(~isempty(tmpIDList))
                nodeID = tmpIDList(1);
                tmpIDList(1) = [];
                resultType = stm.internal.getResultType(nodeID); 
                
                OK = strcmp(resultType,'ResultSet') || strcmp(resultType,'TestSuiteResult') || strcmp(resultType,'TestFileResult');
                OK = OK || strcmp(resultType,'TestCaseResult');
                
                if(OK)
                    tmpchildList = stm.internal.getResultChildrenIDList(nodeID,resultType);
                    tmpIDList = [tmpchildList{1};tmpchildList{2};tmpIDList];
                    
                    pos = find(idList == nodeID);
                    if(~isempty(pos))
                        k = pos(1);
                        if(k < length(idList))
                            idList = [idList(1:k);tmpchildList{1};tmpchildList{2};idList(k+1:end)];
                        else
                            idList = [idList;tmpchildList{1};tmpchildList{2}];
                        end
                    else
                        obj.updateStatus(false);
                        return;
                    end
                end
            end
        end

        function updateStatus(obj,isGood)
            if(isGood)
                obj.errorStatus = obj.errorStatus + 1;
            else
                obj.errorStatus = obj.errorStatus - 1;
            end
        end
    end
end
