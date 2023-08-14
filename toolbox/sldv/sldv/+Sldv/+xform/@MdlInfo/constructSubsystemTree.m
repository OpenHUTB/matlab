function constructSubsystemTree(obj,genSSCompiledInfo,genBuiltinBlkInfo)




    if genSSCompiledInfo||genBuiltinBlkInfo
        assert(obj.ModelWasCompiled,getString(message('Sldv:xform:MdlInfo:MdlInfo:ModelCompiled')));
    end

    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    if genBuiltinBlkInfo
        systemTable=containers.Map('KeyType','double','ValueType','any');
    else
        systemTable=[];
    end

    objModel=get_param(obj.ModelH,'object');
    graphs=getGraph(objModel);
    root=graphs(2);

    if genSSCompiledInfo
        busObjectList=get_param(obj.ModelH,'BackPropagatedBusObjects');
    else
        busObjectList=[];
    end

    obj.SubsystemTree=obj.constructSubSystemTreeNode(obj.ModelH,[],...
    genSSCompiledInfo,busObjectList);
    rootSubsystemTreeNode=obj.SubsystemTree;

    updateSystemTable(systemTable,obj.ModelH,rootSubsystemTreeNode,genBuiltinBlkInfo);

    childSubsystems=Sldv.xform.SubSystemTreeNode.findChildSubsystems(root);
    if~isempty(childSubsystems)
        subsystemQueue={};
        for i=1:length(childSubsystems)
            [subsystemH,subsystemObj]=findSubsystemH(childSubsystems{i}.FullPath);
            if~isempty(subsystemObj)&&~subsystemObj.isSynthesized&&...
                strcmp(subsystemObj.BlockType,'SubSystem')
                subsystemNode=obj.constructSubSystemTreeNode(subsystemH,...
                rootSubsystemTreeNode,genSSCompiledInfo,busObjectList);
                updateSystemTable(systemTable,subsystemH,subsystemNode,genBuiltinBlkInfo);
            else
                subsystemNode=[];
            end
            ssInfo.GraphNode=childSubsystems{i};
            ssInfo.TreeNode=subsystemNode;
            ssInfo.ParentNode=rootSubsystemTreeNode;
            subsystemQueue{end+1}=ssInfo;
        end

        startNodeIdx=1;
        while startNodeIdx<=length(subsystemQueue)
            startNode=subsystemQueue{startNodeIdx};
            childSubsystems=Sldv.xform.SubSystemTreeNode.findChildSubsystems(startNode.GraphNode);
            if isempty(childSubsystems)
                startNodeIdx=startNodeIdx+1;
                continue;
            end
            if~isempty(startNode.TreeNode)
                rootNodeToConnect=startNode.TreeNode;
            else

                rootNodeToConnect=startNode.ParentNode;
            end
            for i=1:length(childSubsystems)
                [subsystemH,subsystemObj]=findSubsystemH(childSubsystems{i}.FullPath);
                if~isempty(subsystemObj)&&~subsystemObj.isSynthesized&&...
                    strcmp(subsystemObj.BlockType,'SubSystem')
                    subsystemNode=obj.constructSubSystemTreeNode(subsystemH,...
                    rootNodeToConnect,genSSCompiledInfo,busObjectList);
                    updateSystemTable(systemTable,subsystemH,subsystemNode,genBuiltinBlkInfo);
                else
                    subsystemNode=[];
                end
                ssInfo.GraphNode=childSubsystems{i};
                ssInfo.TreeNode=subsystemNode;
                ssInfo.ParentNode=rootNodeToConnect;
                subsystemQueue{end+1}=ssInfo;
            end
            startNodeIdx=startNodeIdx+1;
        end
    end

    if genBuiltinBlkInfo


        opts={'FollowLinks','on','LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'CompiledIsActive','on'};
        allBlksH=find_system(obj.ModelH,opts{:});

        if~isempty(allBlksH)


            mdlIdx=(obj.ModelH==allBlksH);
            allBlkTypes=get_param(allBlksH,'BlockType');
            modelrefIdx=strcmp('ModelReference',allBlkTypes);
            ssIdx=strcmp('SubSystem',allBlkTypes);

            blockIgnoreIdx=mdlIdx|modelrefIdx|ssIdx;

            allBlksH=allBlksH(~blockIgnoreIdx);
            if~isempty(allBlksH)
                allBlkTypes=allBlkTypes(~blockIgnoreIdx);
                obj.constructSubsystemTreeBuiltinBlks(allBlksH,...
                allBlkTypes,systemTable,busObjectList);
            end
        end

        delete(systemTable);
    end
end

function updateSystemTable(systemTable,systemH,systemNode,genBuiltinBlkInfo)
    if genBuiltinBlkInfo
        systemTable(systemH)=systemNode;%#ok<NASGU>
    end
end

function[subsystemH,subsystemObj]=findSubsystemH(subsystemPath)
    try
        subsystemH=get_param(subsystemPath,'Handle');
        subsystemObj=get_param(subsystemH,'Object');
    catch Mex %#ok<NASGU>
        subsystemH=[];
        subsystemObj=[];
    end
end
