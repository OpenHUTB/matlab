function libBlock=getReferenceBlock(typeId)





    persistent TypeIdBlockInfoMap

    if isempty(TypeIdBlockInfoMap)

        libTree=simmechanics.sli.internal.getLibraryTree;

        [typeIds,libBlocks]=visit_compound_node(libTree,...
        libTree.Info.LibFileName);

        TypeIdBlockInfoMap=containers.Map(typeIds,libBlocks,...
        'uniformValues',true);
    end

    if TypeIdBlockInfoMap.isKey(typeId)
        libBlock=TypeIdBlockInfoMap(typeId);
    else
        pm_error('sm:sli:internal:NoBlockWithTypeId',typeId);
    end
    mlock;
end

function[typeIds,libBlocks]=visit_compound_node(aCompoundNode,path)

    typeIds={};
    libBlocks={};
    children=aCompoundNode.getChildren;
    for idx=1:length(children)
        if isa(children{idx},'pm.util.SimpleNode')
            cnIdx=strcmp({children{idx}.Info.MaskParameters.VarName},...
            'ClassName');
            typeIds{end+1}=children{idx}.Info.MaskParameters(cnIdx).Value;
            libBlocks{end+1}=[path,'/',children{idx}.Info.SLBlockProperties.Name];
        else
            [cTypeIds,cLibBlocks]=visit_compound_node(children{idx},...
            [path,'/',children{idx}.Info.SLBlockProperties.Name]);
            typeIds=[typeIds,cTypeIds];
            libBlocks=[libBlocks,cLibBlocks];
        end
    end
end

