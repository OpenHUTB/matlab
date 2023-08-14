function appendRemovedBlocks(rpt)




    import mlreportgen.dom.*



    diffMsg=message('Simulink:VariantReducer:ReducerDifferences');
    diffHeading=Heading1(diffMsg.getString());
    diffHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(rpt,diffHeading);





    remContainer=Container();

    blkRemovedMsg=message('Simulink:VariantReducer:BlocksRemoved');
    remBlksHeading=Heading2(blkRemovedMsg.getString());
    remBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(remContainer,remBlksHeading);

    removedBlocksStructVec=rpt.RepData.BlocksRemoved;


    idAttr=CustomAttribute('id','removedBlocks');
    remContainer.CustomAttributes=idAttr;

    if all(arrayfun(@(x)isempty(x.BlockPaths),removedBlocksStructVec))
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(remContainer,par);
        append(rpt,remContainer);
        return;
    end

    blkRemovedAbstract=message('Simulink:VariantReducer:BlocksRemovedAbstract');
    abstract=Paragraph(blkRemovedAbstract.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','removedblksabstract');
    abstract.CustomAttributes=idAttr;
    append(remContainer,abstract);

    for bdId=1:numel(removedBlocksStructVec)
        if isempty(removedBlocksStructVec(bdId).BlockPaths)
            continue;
        end
        mdlHeading=Heading3(removedBlocksStructVec(bdId).ModelName);
        mdlHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(remContainer,mdlHeading);
        i_fillRemovedBlocksList(rpt,remContainer,removedBlocksStructVec(bdId));
    end

    append(rpt,remContainer);
end

function i_fillRemovedBlocksList(rpt,remContainer,removedBlockStruct)
    import mlreportgen.dom.*

    removedBlocks=removedBlockStruct.BlockPaths;
    if~iscell(removedBlocks)
        removedBlocks={removedBlocks};
    end


    remList=UnorderedList();
    for blkId=1:numel(removedBlocks)


        if~removedBlockStruct.isLibrary
            blockHandle=get_param(removedBlocks{blkId},'Handle');
            blockText=mlreportgen.dom.Text(removedBlocks{blkId});
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model1');

            append(remList,blockLink);
        else


            append(remList,removedBlocks(blkId));
        end
    end


    idAttr=CustomAttribute('id',['removedBlocks',removedBlockStruct.ModelName]);
    remList.CustomAttributes=idAttr;
    append(remContainer,remList);
end

