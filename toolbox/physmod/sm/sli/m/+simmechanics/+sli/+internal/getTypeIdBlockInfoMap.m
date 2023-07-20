function blkInfoMap=getTypeIdBlockInfoMap()




    persistent TypeIdBlockInfoMap

    if isempty(TypeIdBlockInfoMap)

        libTree=simmechanics.sli.internal.getLibraryTree;

        [typeIds,blockInfos]=visit_compound_node(libTree);

        TypeIdBlockInfoMap=containers.Map(typeIds,blockInfos);
    end

    blkInfoMap=TypeIdBlockInfoMap;
    mlock;
end

function[typeIds,blockInfos]=visit_compound_node(aCompoundNode)

    typeIds={};
    blockInfos={};
    children=aCompoundNode.getChildren;
    for idx=1:length(children)
        if isa(children{idx},'pm.util.SimpleNode')
            cnIdx=strcmp({children{idx}.Info.MaskParameters.VarName},...
            'ClassName');
            typeIds{end+1}=children{idx}.Info.MaskParameters(cnIdx).Value;
            blockInfos{end+1}=children{idx}.Info;
        else
            [cTypeIds,cBlockInfos]=visit_compound_node(children{idx});
            typeIds=[typeIds,cTypeIds];
            blockInfos=[blockInfos,cBlockInfos];
        end
    end
end