function appendModifiedBlocks(rpt)





    import mlreportgen.dom.*

    modContainer=Container();

    modBlksMsg=message('Simulink:VariantReducer:BlocksModified');
    modBlksHeading=Heading2(modBlksMsg.getString());
    modBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(modContainer,modBlksHeading);

    modifiedBlockStructVec=rpt.RepData.BlocksModified;


    idAttr=CustomAttribute('id','modifiedBlocks');
    modContainer.CustomAttributes=idAttr;

    if all(arrayfun(@(x)isempty(x.BlockPaths),modifiedBlockStructVec))
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(modContainer,par);
        append(rpt,modContainer);
        return;
    end

    modBlkAbstract=message('Simulink:VariantReducer:BlocksModifiedAbstract');
    abstract=Paragraph(modBlkAbstract.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','modifiedabstract');
    abstract.CustomAttributes=idAttr;
    append(modContainer,abstract);

    for bdId=1:numel(modifiedBlockStructVec)
        mdlHeading=Heading3(modifiedBlockStructVec(bdId).ModelName);
        mdlHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(modContainer,mdlHeading);
        i_fillModifiedBlocksList(rpt,modContainer,modifiedBlockStructVec(bdId));
    end

    append(rpt,modContainer);
end

function i_fillModifiedBlocksList(rpt,modContainer,modifiedBlockStruct)
    import mlreportgen.dom.*

    modifiedBlocks=modifiedBlockStruct.BlockPaths;
    if~iscell(modifiedBlocks)
        modifiedBlocks={modifiedBlocks};
    end

    modList=UnorderedList();
    for blkId=1:numel(modifiedBlocks)


        if~modifiedBlockStruct.isLibrary
            blockHandle=get_param(modifiedBlocks{blkId},'Handle');
            blockText=mlreportgen.dom.Text(modifiedBlocks{blkId});
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');

            append(modList,blockLink);
        else


            append(modList,modifiedBlocks(blkId));
        end
    end


    idAttr=CustomAttribute('id',['modifiedBlocks',modifiedBlockStruct.ModelName]);
    modList.CustomAttributes=idAttr;
    append(modContainer,modList);
end


