function appendCallbacks(rpt)




    import mlreportgen.dom.*



    callbackMsg=message('Simulink:VariantReducer:ReducerCallbacks');
    callbackHead=Heading2(callbackMsg.getString());
    callbackHead.Style={Bold,Color('black'),BackgroundColor('white')};
    append(rpt,callbackHead);







    callbacks=rpt.RepData.Callbacks;

















    callbackAbstract=message('Simulink:VariantReducer:CallbackAbstract');
    abstract=Paragraph(callbackAbstract.getString());
    abstract.Style={Color('black'),BackgroundColor('white'),FontSize('12pt')};
    idAttr=CustomAttribute('id','abstract');
    abstract.CustomAttributes=idAttr;
    append(rpt,abstract);


    modelCallbkContainer=Container();
    mdlCallbackMsg=message('Simulink:VariantReducer:ModelCallbacks');
    mdlCallbkHeading=Heading3(mdlCallbackMsg.getString());
    mdlCallbkHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(modelCallbkContainer,mdlCallbkHeading);


    i_fillCallbacks(rpt,modelCallbkContainer,callbacks.mdlCallbacks,true,'modelcallbk');


    idAttr=CustomAttribute('id','modelCallbacks');
    modelCallbkContainer.CustomAttributes=idAttr;

    if isempty(callbacks.mdlCallbacks)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(modelCallbkContainer,par);
    end


    append(rpt,modelCallbkContainer);


    blockCallbkContainer=Container();
    blockCallbackMsg=message('Simulink:VariantReducer:BlockCallbacks');
    blockCallbkHeading=Heading3(blockCallbackMsg.getString());
    blockCallbkHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(blockCallbkContainer,blockCallbkHeading);


    i_fillCallbacks(rpt,blockCallbkContainer,callbacks.blkCallbacks,false,'blockcallbk');


    idAttr=CustomAttribute('id','blockCallbacks');
    blockCallbkContainer.CustomAttributes=idAttr;

    if isempty(callbacks.blkCallbacks)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(blockCallbkContainer,par);
    end


    append(rpt,blockCallbkContainer);


    portCallbkContainer=Container();
    portCallbackMsg=message('Simulink:VariantReducer:PortCallbacks');
    portCallbkHeading=Heading3(portCallbackMsg.getString());
    portCallbkHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(portCallbkContainer,portCallbkHeading);


    i_fillCallbacks(rpt,portCallbkContainer,callbacks.portCallbacks,false,'portcallbk');


    idAttr=CustomAttribute('id','portCallbacks');
    portCallbkContainer.CustomAttributes=idAttr;

    if isempty(callbacks.portCallbacks)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(portCallbkContainer,par);
    end


    append(rpt,portCallbkContainer);


    maskCallbkContainer=Container();
    maskCallbackMsg=message('Simulink:VariantReducer:MaskCallbacks');
    maskCallbkHeading=Heading3(maskCallbackMsg.getString());
    maskCallbkHeading.Style={Bold,Color('black'),BackgroundColor('white')};
    append(maskCallbkContainer,maskCallbkHeading);



    i_fillMaskCallbackList(rpt,maskCallbkContainer,callbacks.maskCallbacks);


    idAttr=CustomAttribute('id','maskCallbacks');
    maskCallbkContainer.CustomAttributes=idAttr;

    if isempty(callbacks.maskCallbacks)
        notapplicableMsg=message('Simulink:VariantReducer:NotApplicableFields');
        par=Paragraph(notapplicableMsg.getString());
        append(maskCallbkContainer,par);
    end


    append(rpt,maskCallbkContainer);
end

function i_fillCallbacks(rpt,callbkContainer,callbacks,isMdl,callbkId)
    if isempty(callbacks)
        return;
    end

    if isMdl
        tableHeadermsg=message('Simulink:VariantReducer:ModelTableHeading');
        tableHeader=tableHeadermsg.getString();
    else
        tableHeadermsg=message('Simulink:VariantReducer:BlockTableHeading');
        tableHeader=tableHeadermsg.getString();
    end

    import mlreportgen.dom.*


    callbkTable=Table(2);


    col1Heading=TableEntry(tableHeader);
    callbkHeadmsg=message('Simulink:VariantReducer:CallbackHeading');
    col2Heading=TableEntry(callbkHeadmsg.getString());

    tbHeaderRow=TableRow();
    append(tbHeaderRow,col1Heading);
    append(tbHeaderRow,col2Heading);

    tbHeaderRow.Style={Bold};

    idAttr=CustomAttribute('id',[callbkId,'headerrow']);
    tbHeaderRow.CustomAttributes=idAttr;

    append(callbkTable,tbHeaderRow);

    for clbkId=1:numel(callbacks)

        tableRowObj=TableRow();


        if isMdl
            col1=Text(callbacks(clbkId).ModelName);
        else


            blockHandle=get_param(callbacks(clbkId).BlkPaths,'Handle');
            blockText=Text(callbacks(clbkId).BlkPaths);
            blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');
            col1=blockLink;
        end
        col1Entry=TableEntry(col1);

        idAttr=CustomAttribute('id',[callbkId,'row',num2str(clbkId),'col1']);
        col1Entry.CustomAttributes=idAttr;


        callbackList=UnorderedList(callbacks(clbkId).Callbacks);
        col2Entry=TableEntry(callbackList);

        idAttr=CustomAttribute('id',[callbkId,'row',num2str(clbkId),'col2']);
        col2Entry.CustomAttributes=idAttr;


        append(tableRowObj,col1Entry);
        append(tableRowObj,col2Entry);


        idAttr=CustomAttribute('id',[callbkId,'row',num2str(clbkId)]);
        tableRowObj.CustomAttributes=idAttr;


        append(callbkTable,tableRowObj);
    end



    callbkTable.Border='solid';
    callbkTable.BorderWidth='2px';
    callbkTable.ColSep='solid';
    callbkTable.ColSepWidth='1';
    callbkTable.RowSep='solid';
    callbkTable.RowSepWidth='1';
    callbkTable.TableEntriesHAlign='center';
    callbkTable.TableEntriesVAlign='middle';

    append(callbkContainer,callbkTable);
end

function i_fillMaskCallbackList(rpt,maskCallbkContainer,maskCallbacks)

    if isempty(maskCallbacks),return;end
    import mlreportgen.dom.*
    maskCallbackList=OrderedList();
    for callbkId=1:numel(maskCallbacks)


        blockHandle=get_param(maskCallbacks(callbkId).BlkPaths,'Handle');
        blockText=mlreportgen.dom.Text(maskCallbacks(callbkId).BlkPaths);
        blockLink=createElementTwoWayLink(rpt,blockHandle,blockText,'model2');

        append(maskCallbackList,blockLink);
    end
    append(maskCallbkContainer,maskCallbackList);
end



