




classdef AnalysisIR<handle
    properties
tree
dfg

treeIdxToHandle
handleToTreeIdx


dfgIdxToHandle
handleToDfgIdx


portHandleToDfgVarIdx
dfgVarIdxToPortHandle


dfgInputIdxToInportH
dfgInportHToInputIdx


dfgIdxToDsm
dsmToDfgVarIdx


dfgIdxToGlobalDsmName
globalDsmNameToDfgIdx















outputPortToInputPortEdges













dataDependenceBetweenInputAndVar


allNonSynthesizedBlocks

synBlkHToOrigBlkHMap

origBlkHToSynBlkHMap

    end
    methods

        function str=dfgNodeNames(obj)
            str='';
            keys=obj.dfgIdxToHandle.keys;
            for i=1:length(keys)
                h=obj.dfgIdxToHandle(keys{i});
                str=[str,sprintf('\n %d -> %s',keys{i},get(h,'Name'))];
            end
            keys=obj.dfgVarIdxToPortHandle.keys;
            for i=1:length(keys)
                h=obj.dfgVarIdxToPortHandle(keys{i});
                str=[str,sprintf('\n %d -> %s',keys{i},get(h,'Parent'))];
            end
            keys=obj.dfgInputIdxToInportH.keys;
            for i=1:length(keys)
                h=obj.dfgInputIdxToInportH(keys{i});
                str=[str,sprintf('\n %d -> %s',keys{i},get(h,'Parent'))];
            end
        end

        function obj=AnalysisIR(tree,dfg,maps)
            obj.tree=tree;
            obj.dfg=dfg;

            obj.handleToTreeIdx=maps.tree;
            obj.treeIdxToHandle=containers.Map(maps.tree.values,...
            maps.tree.keys);

            obj.handleToDfgIdx=maps.dfg;
            obj.dfgIdxToHandle=containers.Map(maps.dfg.values,...
            maps.dfg.keys);

            obj.portHandleToDfgVarIdx=maps.dfgVar;
            obj.dfgVarIdxToPortHandle=containers.Map(maps.dfgVar.values,...
            maps.dfgVar.keys);

            obj.dfgInputIdxToInportH=maps.inputIdToInportH;
            obj.dfgInportHToInputIdx=maps.inportHToInputId;

            obj.dsmToDfgVarIdx=maps.localDsmToId;
            if~isempty(maps.localDsmToId)
                obj.dfgIdxToDsm=containers.Map(maps.localDsmToId.values,...
                maps.localDsmToId.keys);
            else
                obj.dfgIdxToDsm=containers.Map;
            end
            obj.globalDsmNameToDfgIdx=maps.globalDsmNameToDfgIdx;
            obj.dfgIdxToGlobalDsmName=maps.dfgIdxToGlobalDsmName;

            obj.origBlkHToSynBlkHMap=maps.origBlkHToSynBlkHMap;
            obj.synBlkHToOrigBlkHMap=maps.synBlkHToOrigBlkHMap;

            obj.outputPortToInputPortEdges=maps.outputPortToInputPortEdges;

            obj.dataDependenceBetweenInputAndVar=maps.dataDependenceBetweenInputAndVar;
            obj.allNonSynthesizedBlocks=maps.allNonSynthesizedBlocks;
        end



        function h=getHandles(obj,dfgV)


            assert(size(dfgV,1)==1);
            h=zeros(length(dfgV),1);
            for i=1:length(dfgV)
                h(i)=obj.dfgIdxToHandle(dfgV(i).vId);
            end
        end


        function dfgIDs=getDfgIDs(obj,handles)
            c=num2cell(handles);
            filt=obj.handleToDfgIdx.isKey(c);
            filtered=c(filt);
            dfgIDs=cell2mat(obj.handleToDfgIdx.values(filtered));
            dfgIDs=reshape(dfgIDs,numel(dfgIDs),1);
        end

        function h=getPortHandles(obj,dfgV)
            assert(size(dfgV,1)==1);


            dfgId={dfgV.vId};
            isVar=obj.dfgVarIdxToPortHandle.isKey(dfgId);
            varId=dfgId(isVar);
            h=cell2mat(obj.dfgVarIdxToPortHandle.values(varId));
        end

        function h=getInportHandles(obj,dfgV)
            assert(size(dfgV,1)==1);
            hc=obj.dfgInputIdxToInportH.values({dfgV.vId});
            h=cell2mat(hc);
        end



        function s=dfgDotString(obj)

            s=sprintf('digraph G {\n');
            s=[s,sprintf('rankdir=LR;\n')];
            procIds=obj.dfgIdxToHandle.keys;
            handles=obj.dfgIdxToHandle.values;
            for i=1:length(procIds)
                blkName=trimstr(get(handles{i},'Name'));
                try
                    if strcmp(get(handles{i},'LinkStatus'),'none')

                        url=rmiut.cmdToUrl(rmi('navCmd',handles{i}),false);
                    else
                        url='';
                    end
                catch
                    url='';
                end
                s=[s,sprintf('%d[shape="box" label="%d-%s" tooltip="%s" URL="%s"]\n',...
                procIds{i},procIds{i},trimstr(blkName),trimstr(getfullname(handles{i})),url)];%#ok<AGROW> 
            end

            varIds=obj.dfgVarIdxToPortHandle.keys;
            portHandles=obj.dfgVarIdxToPortHandle.values;
            for i=1:length(varIds)
                portNumber=get(portHandles{i},'PortNumber');
                s=[s,sprintf('%d[shape="ellipse" label="%d-%s-%d" tooltip="%s"]\n',...
                varIds{i},varIds{i},get(portHandles{i},'Name'),portNumber,trimstr(getfullname(portHandles{i})))];%#ok<AGROW> %
            end

            inIds=obj.dfgInputIdxToInportH.keys;
            portHandles=obj.dfgInputIdxToInportH.values;
            for i=1:length(inIds)
                portNumber=get(portHandles{i},'PortNumber');
                s=[s,sprintf('%d[shape="diamond" label="%d-%s-%d" tooltip="%s"]\n',...
                inIds{i},inIds{i},get(portHandles{i},'Name'),portNumber,trimstr(getfullname(portHandles{i})))];%#ok<AGROW> %
            end

            dsmIds=obj.dsmToDfgVarIdx.values;
            dsmHdls=obj.dsmToDfgVarIdx.keys;
            for i=1:length(dsmIds)
                name=get(dsmHdls{i},'DataStoreName');
                s=[s,sprintf('%d[shape="ellipse"][label="%d-%s"]\n',...
                dsmIds{i},dsmIds{i},name)];%#ok<AGROW> %                
            end

            globalDsmIds=obj.globalDsmNameToDfgIdx.values;
            globalDsmNames=obj.globalDsmNameToDfgIdx.keys;
            for i=1:length(globalDsmNames)
                s=[s,sprintf('%d[shape="ellipse"][label="%d-GLOBAL:%s"]\n',...
                globalDsmIds{i},globalDsmIds{i},globalDsmNames{i})];
            end

            allIds=[procIds{:},varIds{:},inIds{:},dsmIds{:},globalDsmIds{:}]';
            for i=1:length(allIds)
                succ=obj.dfg.succ(MSUtils.graphVertices(allIds(i)));
                for j=1:length(succ)
                    s=[s,sprintf('%d -> %d\n',allIds(i),succ(j).vId)];
                end
            end
            s=[s,sprintf('}')];
        end
        function s=treeDotString(obj)

            s=sprintf('graph G {\n');
            procIds=obj.treeIdxToHandle.keys;
            handles=obj.treeIdxToHandle.values;
            for i=1:length(procIds)
                blkName=trimstr(get(handles{i},'Name'));
                try
                    if strcmp(get(handles{i},'LinkStatus'),'none')

                        url=rmiut.cmdToUrl(rmi('navCmd',handles{i}),false);
                    else
                        url='';
                    end
                catch
                    url='';
                end
                s=[s,sprintf('%d[shape="box" label="%d-%s" tooltip="%s" URL="%s"]\n',...
                procIds{i},procIds{i},blkName,getfullname(handles{i}),url)];%#ok<AGROW>

            end

            allIds=[procIds{:}]';
            for i=1:length(allIds)
                node=MSUtils.treeNodes(allIds(i));
                children=obj.tree.children(node);
                for j=1:length(children)
                    s=[s,sprintf('%d -- %d\n',allIds(i),children(j).Id)];
                end
            end
            s=[s,sprintf('}')];
        end






        function[srcDfgId,dstDfgId]=getIteratorDependence(ir)
            srcDfgId=[];
            dstDfgId=[];
            root=ir.tree.getRoot;
            nonleafNodes=ir.tree.nonleafDescendants(root);
            nonleafIds=[nonleafNodes.Id];


            if nonleafIds(1)==root.Id
                nonleafIds=nonleafIds(2:end);
            end
            nonleafH=cell2mat(ir.treeIdxToHandle.values(num2cell(nonleafIds)));
            for i=1:length(nonleafH)
                sysH=nonleafH(i);
                sysId=ir.handleToTreeIdx(sysH);
                sysTreeNode=MSUtils.treeNodes(sysId);
                descendantNodes=ir.tree.children(sysTreeNode);
                descendantIds=[descendantNodes.Id];
                descendants=ir.treeIdxToHandle.values(num2cell(descendantIds));

                [iteratorBlk,idxIterBlk]=findControlBlocks(descendants);
                if~isempty(iteratorBlk)
                    assert(ir.handleToDfgIdx.isKey(iteratorBlk));
                    otherBlks=descendants([1:idxIterBlk-1,idxIterBlk+1:end]);
                    n=numel(otherBlks);
                    iteratorBlkId=ir.handleToDfgIdx(iteratorBlk);
                    otherBlkId=cell2mat(ir.handleToDfgIdx.values(otherBlks));
                    srcDfgId=[srcDfgId;repmat(iteratorBlkId,n,1)];
                    dstDfgId=[dstDfgId;reshape(otherBlkId,n,1)];
                end
            end

            function[hdl,idx]=findControlBlocks(handles)



                hdl=[];
                idx=[];
                for ii=1:length(handles)
                    bt=get(handles{ii},'BlockType');
                    if strcmp(bt,'ForIterator')||strcmp(bt,'WhileIterator')
                        hdl=handles{ii};
                        idx=ii;
                        break
                    end
                end
            end
        end

        function[srcDfgId,dstDfgId]=getControlDependence(ir,activeC)
            srcDfgId=[];
            dstDfgId=[];

            for i=1:length(activeC)
                sysH=activeC(i);
                sysId=ir.handleToTreeIdx(sysH);
                sysTreeNode=MSUtils.treeNodes(sysId);
                descendants=ir.tree.children(sysTreeNode);
                if ir.handleToDfgIdx.isKey(sysH)

                    sysDfgId=ir.handleToDfgIdx(sysH);

                    for descendant=descendants
                        desId=descendant.Id;
                        desH=ir.treeIdxToHandle(desId);
                        if ir.handleToDfgIdx.isKey(desH)
                            desDfgId=ir.handleToDfgIdx(desH);
                            srcDfgId=[srcDfgId;sysDfgId];%#ok<AGROW>
                            dstDfgId=[dstDfgId;desDfgId];%#ok<AGROW>
                        end
                    end







                end
            end
        end

        function h=getNonRootContexts(this)
            root=this.tree.getRoot;
            nonleafNodes=this.tree.nonleafDescendants(root);
            nonleafIds=[nonleafNodes.Id];
            filt=nonleafIds~=root.Id;
            nonleafC=nonleafNodes(filt);
            nonleafH=cell2mat(this.treeIdxToHandle.values({nonleafC.Id}));



            h=reshape(nonleafH,numel(nonleafH),1);
        end

        function parentH=getAncestoresInTree(obj,bh)
            parentH=[];
            if isKey(obj.handleToTreeIdx,bh)
                thisId=obj.handleToTreeIdx(bh);
                parentIds=obj.tree.ancestors(MSUtils.treeNodes(thisId));
                if~isempty(parentIds)
                    parentH=cell2mat(obj.treeIdxToHandle.values({parentIds.Id}));
                end
            end
        end
    end

end

function t=trimstr(s)

    t=strrep(s,sprintf('\n'),'\\n');


end

