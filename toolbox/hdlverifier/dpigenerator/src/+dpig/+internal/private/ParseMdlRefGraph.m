function ParseMdlRefGraph(MdlRefGraph,VertexIdx,SIDPath,AssertBlkInfo,AssertBlkInstanceInfo)

    VertexInfo=MdlRefGraph.getInstanceVertex(VertexIdx);

    if VertexIdx~=MdlRefGraph.getInstanceTopVertexID()
        SIDPath=['@',l_getSIDFromVertexInfo(VertexInfo),SIDPath];
    end

    l_AddAssertionBlkInstanceInfo(AssertBlkInfo,VertexInfo,SIDPath,AssertBlkInstanceInfo);

    VertexEdges=MdlRefGraph.getInstanceEdges(VertexIdx,'outbound');

    for idx=1:length(VertexEdges)
        ParseMdlRefGraph(MdlRefGraph,VertexEdges(idx).TargetID,SIDPath,AssertBlkInfo,AssertBlkInstanceInfo);
    end
end

function str=l_getSIDFromVertexInfo(VertexInfo)


    str=Simulink.ID.getSID(VertexInfo.Data.BlockPath);
end

function l_AddAssertionBlkInstanceInfo(AssertBlkInfo,VertexInfo,SIDPath,AssertBlkInstanceInfo)
    AllAssertionBlkKeys=AssertBlkInfo.keys();
    ModelRefName=bdroot(VertexInfo.Data.Name);
    ValidKeysForReferenceModel=AllAssertionBlkKeys(cellfun(@(x)strcmp(ModelRefName,extractBefore(x,':')),AllAssertionBlkKeys));


    for ValidKeys=ValidKeysForReferenceModel
        ValidKeyStr=ValidKeys{1};
        AssertBlkInstanceInfo([ValidKeyStr,SIDPath])=AssertBlkInfo(ValidKeyStr);
    end
end