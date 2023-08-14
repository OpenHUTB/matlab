function constructMdlHier(obj)





    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>

    obj.MdlSettingsMap=...
    containers.Map('KeyType','char','ValueType','any');



    mdlHCompGraphMap=containers.Map('KeyType','double','ValueType','any');

    mdlHSSNodeMap=containers.Map('KeyType','double','ValueType','any');


    changeMdlSettingsToGetCoverage(obj.ModelH,obj.MdlSettingsMap);


    obj.compileModel('compileForCoverage');



    [treeNodeTop,subsystemHNodeMap]=...
    obj.constructCompGraph(obj.ModelH);


    mdlHSSNodeMap(obj.ModelH)=subsystemHNodeMap;


    obj.CompGraph=treeNodeTop;


    modelQueue={};
    modelQueue{end+1}=treeNodeTop;

    startNodeIdx=1;
    while startNodeIdx<=length(modelQueue)
        startNode=modelQueue{startNodeIdx};

        if~isempty(startNode.Up)
            startNodeRefMdlH=obj.deriveReferencedModelH(startNode.BlockH);
        else
            startNodeRefMdlH=obj.ModelH;
        end

        startNodeRefMdlOriginallyPaused=...
        Sldv.xform.MdlInfo.isMdlCompiled(startNodeRefMdlH);
        startNodeRefMdlPaused=startNodeRefMdlOriginallyPaused;



        if~isempty(startNode.Up)&&mdlHCompGraphMap.isKey(startNodeRefMdlH)
            mdlTop=mdlHCompGraphMap(startNodeRefMdlH);
            startNode.CompGraph=mdlTop;

            mdlTop.ReferencedMdlBlocks{end+1}=startNode;
        end



        if~isempty(startNode.Up)&&~mdlHCompGraphMap.isKey(startNodeRefMdlH)
            changeMdlSettingsToGetCoverage(startNodeRefMdlH,obj.MdlSettingsMap);

            Sldv.xform.MdlInfo.compileBlkDiagram(startNodeRefMdlH,...
            startNodeRefMdlPaused,'compileForCoverage');
            startNodeRefMdlPaused=true;
            [mdlTop,subsystemHNodeMap]=obj.constructCompGraph(startNodeRefMdlH);

            mdlHCompGraphMap(startNodeRefMdlH)=mdlTop;
            mdlHSSNodeMap(startNodeRefMdlH)=subsystemHNodeMap;
            startNode.CompGraph=mdlTop;

            mdlTop.ReferencedMdlBlocks{end+1}=startNode;


            modelRefNodes=exploreModelReferences(mdlHSSNodeMap,startNodeRefMdlH);
            modelQueue=[modelQueue,modelRefNodes];%#ok<AGROW>
        end


        if isempty(startNode.Up)


            modelRefNodes=exploreModelReferences(mdlHSSNodeMap,startNodeRefMdlH);
            modelQueue=[modelQueue,modelRefNodes];%#ok<AGROW>
        end



        if~isempty(startNode.Up)&&...
            startNodeRefMdlPaused&&...
            ~startNodeRefMdlOriginallyPaused
            Sldv.xform.MdlInfo.termBlkDiagram(startNodeRefMdlH,startNodeRefMdlPaused);
        elseif isempty(startNode.Up)
            obj.termModel;
        end

        startNodeIdx=startNodeIdx+1;
    end

    keys=mdlHSSNodeMap.keys;
    obj.MdlObjectToComponentMap=mdlHSSNodeMap(obj.ModelH);



    for i=1:length(keys)
        obj.MdlObjectToComponentMap=[obj.MdlObjectToComponentMap;mdlHSSNodeMap(keys{i})];
    end


    function mdlRefBlkNodes=exploreModelReferences(mdlHSSNodeMap,startNodeRefMdlH)



        mdlRefBlkNodes={};
        subsysHNodeMap=mdlHSSNodeMap(startNodeRefMdlH);

        topModelName=get_param(startNodeRefMdlH,'Name');
        mdlBlks=Sldv.utils.findModelBlocks(topModelName,true);


        for idx=1:length(mdlBlks)
            blockH=get_param(mdlBlks{idx},'Handle');


            obj.deriveReferencedModelH(blockH);


            parentH=get_param(get_param(blockH,'Parent'),'Handle');
            assert(subsysHNodeMap.isKey(parentH),...
            getString(message('Sldv:xform:MdlHierInfo:MdlHierInfo:ParentMustInMap')));


            nodeToBind=subsysHNodeMap(parentH);


            mdlRefBlkTreeNode=obj.constructMdlRefBlkTreeNode(blockH,nodeToBind);
            mdlRefBlkNodes{end+1}=mdlRefBlkTreeNode;%#ok<AGROW>
        end
    end
end

function changeMdlSettingsToGetCoverage(modelH,mdlSettingsMap)
    model=get_param(modelH,'Name');
    if~mdlSettingsMap.isKey(model)
        origDirty=get_param(modelH,'Dirty');

        mdlInfo.RecordCoverage=get_param(modelH,'RecordCoverage');

        mdlInfo.OldConfigSet=getActiveConfigSet(modelH);

        mdlSettingsMap(model)=mdlInfo;%#ok<NASGU>


        Sldv.utils.replaceConfigSetRefWithCopy(modelH);
        set_param(modelH,'SimulationMode','normal');
        set_param(modelH,'RecordCoverage','on');

        set_param(modelH,'Dirty',origDirty);
    end
end

