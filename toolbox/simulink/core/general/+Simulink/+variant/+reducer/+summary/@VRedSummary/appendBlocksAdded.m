function appendBlocksAdded(rpt)





    import mlreportgen.dom.*

    addContainer=Container();
    addBlkMsg=message('Simulink:VariantReducer:BlocksInserted');
    addBlksHeading=Heading2(addBlkMsg.getString());
    addBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(addContainer,addBlksHeading);


    addedBlocks=rpt.RepData.BlocksAdded;


    idAttr=CustomAttribute('id','insertedBlocks');
    addContainer.CustomAttributes=idAttr;

    if all(structfun(@(x)isempty(x),addedBlocks))
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(addContainer,par);
        append(rpt,addContainer);
        return;
    end


    if~isempty(addedBlocks.addedBusSubsystems)
        busSubsysHeading=message('Simulink:VariantReducer:BusSubsystem');
        addBlksHeading=Heading3(busSubsysHeading.getString());
        addBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(addContainer,addBlksHeading);


        abstractMsg=message('Simulink:VariantReducer:BusSubsystemAbstract');
        abstract=Paragraph(abstractMsg.getString());
        abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','abstract');
        abstract.CustomAttributes=idAttr;
        append(addContainer,abstract);

        busSubsystemAddList=UnorderedList();
        addedBusSubsystems=addedBlocks.addedBusSubsystems;
        for blkId=1:numel(addedBusSubsystems)


            blockHandle=get_param(addedBusSubsystems(blkId).Block,'Handle');
            blockText=mlreportgen.dom.Text(addedBusSubsystems(blkId).Block);
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');


            busSubsystemContentAddList=UnorderedList();

            idAttr=CustomAttribute('id','busSubsystemContents');
            busSubsystemContentAddList.CustomAttributes=idAttr;

            constHandle=get_param(addedBusSubsystems(blkId).Constant,'Handle');
            constText=mlreportgen.dom.Text(addedBusSubsystems(blkId).Constant);
            constLink=createElementTwoWayLink(rpt,constHandle,constText,'model2');
            append(busSubsystemContentAddList,constLink);

            if~isempty(addedBusSubsystems(blkId).SignalConversion)
                sigCovHandle=get_param(addedBusSubsystems(blkId).SignalConversion,'Handle');
                sigCovText=mlreportgen.dom.Text(addedBusSubsystems(blkId).SignalConversion);
                sigCovLink=createElementTwoWayLink(rpt,sigCovHandle,sigCovText,'model2');
                append(busSubsystemContentAddList,sigCovLink);
            end

            outportHandle=get_param(addedBusSubsystems(blkId).Outport,'Handle');
            outportText=mlreportgen.dom.Text(addedBusSubsystems(blkId).Outport);
            outportLink=createElementTwoWayLink(rpt,outportHandle,outportText,'model2');
            append(busSubsystemContentAddList,outportLink);

            append(busSubsystemAddList,blockLink);
            append(busSubsystemAddList,busSubsystemContentAddList);
        end


        idAttr=CustomAttribute('id','busSubsystem');
        busSubsystemAddList.CustomAttributes=idAttr;

        append(addContainer,busSubsystemAddList);
    end


    if~isempty(addedBlocks.addedConstants)
        constantMsg=message('Simulink:VariantReducer:Constant');
        addBlksHeading=Heading3(constantMsg.getString());
        addBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(addContainer,addBlksHeading);

        constantAbstract=message('Simulink:VariantReducer:ConstantAbstract');
        abstract=Paragraph(constantAbstract.getString());
        abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','abstract');
        abstract.CustomAttributes=idAttr;
        append(addContainer,abstract);

        constantAddList=UnorderedList();
        addedConstants=addedBlocks.addedConstants;
        for blkId=1:numel(addedConstants)


            blockHandle=get_param(addedConstants{blkId},'Handle');
            blockText=mlreportgen.dom.Text(addedConstants{blkId});
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');

            append(constantAddList,blockLink);
        end


        idAttr=CustomAttribute('id','constant');
        constantAddList.CustomAttributes=idAttr;

        append(addContainer,constantAddList);
    end



    if~isempty(addedBlocks.addedLabelModeSISOVariantSources)
        varSrcMsg=message('Simulink:VariantReducer:AddedVariantSource');
        addBlksHeading=Heading3(varSrcMsg.getString());
        addBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(addContainer,addBlksHeading);

        varSrcAbstract=message('Simulink:VariantReducer:AddedVariantSourceAbstract');
        abstract=Paragraph(varSrcAbstract.getString());
        abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','abstract');
        abstract.CustomAttributes=idAttr;
        append(addContainer,abstract);

        variantSourceAddList=UnorderedList();
        addedLabelModeSISOVariantSources=addedBlocks.addedLabelModeSISOVariantSources;
        for blkId=1:numel(addedLabelModeSISOVariantSources)


            blockHandle=get_param(addedLabelModeSISOVariantSources{blkId},'Handle');
            blockText=mlreportgen.dom.Text(addedLabelModeSISOVariantSources{blkId});
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');

            append(variantSourceAddList,blockLink);
        end


        idAttr=CustomAttribute('id','labelModeSISOVariantSource');
        variantSourceAddList.CustomAttributes=idAttr;

        append(addContainer,variantSourceAddList);
    end



    if~isempty(addedBlocks.addedSS)
        sigspecMsg=message('Simulink:VariantReducer:SignalSpec');
        addBlksHeading=Heading3(sigspecMsg.getString());
        addBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(addContainer,addBlksHeading);

        sigSpecAbstract=message('Simulink:VariantReducer:SignalSpecAbstract');
        abstract=Paragraph(sigSpecAbstract.getString());
        abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','abstract');
        abstract.CustomAttributes=idAttr;
        append(addContainer,abstract);

        ssAddList=UnorderedList();
        addedSS=addedBlocks.addedSS;
        for blkId=1:numel(addedSS)


            blockHandle=get_param(addedSS{blkId},'Handle');
            blockText=mlreportgen.dom.Text(addedSS{blkId});
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');

            append(ssAddList,blockLink);
        end


        idAttr=CustomAttribute('id','sigspec');
        ssAddList.CustomAttributes=idAttr;

        append(addContainer,ssAddList);
    end


    if~isempty(addedBlocks.addedGnds)
        gndMsg=message('Simulink:VariantReducer:Ground');
        addBlksHeading=Heading3(gndMsg.getString());
        addBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(addContainer,addBlksHeading);

        gndAbstract=message('Simulink:VariantReducer:GroundAbstract');
        abstract=Paragraph(gndAbstract.getString());
        abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','abstract');
        abstract.CustomAttributes=idAttr;
        append(addContainer,abstract);

        gndAddList=UnorderedList();
        addedGnds=addedBlocks.addedGnds;
        for blkId=1:numel(addedGnds)


            blockHandle=get_param(addedGnds{blkId},'Handle');
            blockText=mlreportgen.dom.Text(addedGnds{blkId});
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');

            append(gndAddList,blockLink);
        end


        idAttr=CustomAttribute('id','ground');
        gndAddList.CustomAttributes=idAttr;

        append(addContainer,gndAddList);
    end


    if~isempty(addedBlocks.addedTerms)
        termMsg=message('Simulink:VariantReducer:Terminator');
        addBlksHeading=Heading3(termMsg.getString());
        addBlksHeading.Style={Bold,Color('black'),BackgroundColor('white')};
        append(addContainer,addBlksHeading);

        termAbstract=message('Simulink:VariantReducer:TerminatorAbstract');
        abstract=Paragraph(termAbstract.getString());
        abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
        idAttr=CustomAttribute('id','abstract');
        abstract.CustomAttributes=idAttr;
        append(addContainer,abstract);

        termAddList=UnorderedList();
        addedTerms=addedBlocks.addedTerms;
        for blkId=1:numel(addedTerms)


            blockHandle=get_param(addedTerms{blkId},'Handle');
            blockText=mlreportgen.dom.Text(addedTerms{blkId});
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');

            append(termAddList,blockLink);
        end


        idAttr=CustomAttribute('id','terminator');
        termAddList.CustomAttributes=idAttr;

        append(addContainer,termAddList);
    end



    append(rpt,addContainer);
end


