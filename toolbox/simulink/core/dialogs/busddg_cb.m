function busddg_cb(action,varargin)








    warnState=warning('off','backtrace');
    cleanupWarning=onCleanup(@()warning(warnState));

    try
        loc_callbackSwitchYard(action,varargin{:});

    catch E


        throwAsCaller(E);
    end
end




function loc_callbackSwitchYard(action,varargin)

    dialogH=varargin{1};
    codeGenOptionValue=[];
    if nargin>2
        codeGenOptionValue=varargin{2};
    end

    elementType=[];
    if slfeature('CUSTOM_BUSES')==1
        elementType='Signal';
        if nargin>3
            elementType=varargin{3};
        end
    end

    dialogH.setUserData('MoveElementDownBtn',[]);
    switch action

    case 'addElement'
        i_doAddOrInsertNewElement(dialogH,elementType);

    case 'deleteElement'
        i_doDeleteElement(dialogH);

    case 'moveElementUp'
        i_doMoveElementUp(dialogH);

    case 'moveElementDown'
        i_doMoveElementDown(dialogH);

    case 'editDataScope'
        i_doEditDataScope(dialogH,codeGenOptionValue);

    case 'editHeaderFile'
        i_doEditHeaderFile(dialogH,codeGenOptionValue);

    case 'editAlignment'
        i_doEditAlignment(dialogH,codeGenOptionValue);

    case 'setPreserveDims'
        i_doSetPreserveDims(dialogH,codeGenOptionValue);

    case 'editDescription'
        i_doEditDescription(dialogH,codeGenOptionValue);
    end
    dialogH.enableApplyButton(true);
end





function i_doEditDataScope(dialogH,newVal)



    tempBusObject=loc_getTempBusObject(dialogH);
    switch(newVal)
    case 0
        tempBusObject.DataScope='Auto';
    case 1
        tempBusObject.DataScope='Exported';
    case 2
        tempBusObject.DataScope='Imported';
    end

    loc_storeTempBusObjectInUserData(dialogH,tempBusObject);
end





function i_doEditHeaderFile(dialogH,newVal)



    tempBusObject=loc_getTempBusObject(dialogH);
    tempBusObject.HeaderFile=newVal;

    loc_storeTempBusObjectInUserData(dialogH,tempBusObject);
end





function i_doEditAlignment(dialogH,newVal)



    tempBusObject=loc_getTempBusObject(dialogH);

    newAlignmentValue=str2double(newVal);
    if~loc_isValidAlignmentValue(newAlignmentValue)

        dialogH.setWidgetValue('busAlignment_tag',tempBusObject.Alignment);

        dp=DAStudio.DialogProvider;
        errorMessage=DAStudio.message('Simulink:busEditor:BusObjectInvalidAlignment');
        d=dp.errordlg(errorMessage,'Error',true);
        return;
    end

    tempBusObject.Alignment=newAlignmentValue;

    loc_storeTempBusObjectInUserData(dialogH,tempBusObject);
end



function isValid=loc_isValidAlignmentValue(newAlignmentValue)
    isValid=false;


    if(newAlignmentValue==-1)||(newAlignmentValue>0&&newAlignmentValue<=128&&...
        bitand(newAlignmentValue,newAlignmentValue-1)==0)
        isValid=true;
        return;
    end
end






function i_doSetPreserveDims(dialogH,newVal)



    if sl('busUtils','NDIdxBusUI')
        tempBusObject=loc_getTempBusObject(dialogH);

        tempBusObject.PreserveElementDimensions=newVal;

        loc_storeTempBusObjectInUserData(dialogH,tempBusObject);
    end
end





function i_doEditDescription(dialogH,newDesc)



    tempBusObject=loc_getTempBusObject(dialogH);
    tempBusObject.Description=newDesc;
    loc_storeTempBusObjectInUserData(dialogH,tempBusObject);
end







function i_doAddOrInsertNewElement(dialogH,elementType)

    selectedRow=[];
    selectedRowsMap=dialogH.getUserData('DeleteElementBtn');



    tempBusObject=loc_getTempBusObject(dialogH);

    numElems=numel(tempBusObject.Elements);

    if~isempty(selectedRowsMap)
        selectedRow=str2double(selectedRowsMap.keys);
    end

    if isempty(selectedRow)||selectedRow>numElems
        selectedRow=numElems;
    end

    elementNamesMap=containers.Map;
    for i=1:numElems
        elementNamesMap(tempBusObject.Elements(i).Name)=i;
    end

    dialogH.setUserData('AddElementBtn',elementNamesMap);

    if slfeature('CUSTOM_BUSES')==1
        if strcmpi(elementType,'signal')
            newElem=Simulink.BusElement;
        elseif strcmpi(elementType,'connection')
            newElem=Simulink.ConnectionElement;
        end
    else
        newElem=Simulink.BusElement;
    end
    newElem.Name=loc_get_NewElementName(dialogH);


    if numElems==0
        tempBusObject.Elements=newElem;

    elseif(selectedRow==numElems)

        tempBusObject.Elements(numElems+1)=newElem;
    else

        tempBusObject.Elements=[tempBusObject.Elements(1:selectedRow);newElem;tempBusObject.Elements(selectedRow+1:end)];
    end



    rowsToSelect=selectedRow+1;
    loc_storeRowSelectionsBeforeUpdate(dialogH,rowsToSelect);

    loc_storeTempBusObjectInUserData(dialogH,tempBusObject);

    isSpreadsheetUpdating=true;
    dialogH.setUserData('BusObjectSpreadsheet',isSpreadsheetUpdating);
    loc_updateSpreadsheetWidget(dialogH);
end






function i_doDeleteElement(dialogH)

    selectedRowsMap=dialogH.getUserData('DeleteElementBtn');

    if isempty(selectedRowsMap)
        selectedRows=1;
    else
        selectedRows=str2double(selectedRowsMap.keys);
    end

    minSelection=min(selectedRows);
    maxSelection=max(selectedRows);

    if isempty(selectedRows)
        areSelectionsConsecutive=false;
    else
        areSelectionsConsecutive=(maxSelection-minSelection)==(numel(selectedRows)-1);
    end



    tempBusObject=loc_getTempBusObject(dialogH);

    numElems=numel(tempBusObject.Elements);
    tempBusObject.Elements(selectedRows)=[];



    if numElems==1||~areSelectionsConsecutive
        rowsToSelect=[];
    elseif minSelection==1&&maxSelection==numElems

        rowsToSelect=[];
    elseif maxSelection==numElems

        rowsToSelect=minSelection-1;
    else

        rowsToSelect=minSelection;
    end
    loc_storeTempBusObjectInUserData(dialogH,tempBusObject);

    loc_storeRowSelectionsBeforeUpdate(dialogH,rowsToSelect);
    isSpreadsheetUpdating=true;
    dialogH.setUserData('BusObjectSpreadsheet',isSpreadsheetUpdating);

    loc_updateSpreadsheetWidget(dialogH);
end









function i_doMoveElementUp(dialogH)

    selectedRowsMap=dialogH.getUserData('DeleteElementBtn');
    selectedRows=str2double(selectedRowsMap.keys);

    if isempty(selectedRows)
        selectedRows=1;
    end



    tempBusObject=loc_getTempBusObject(dialogH);


    minSelection=min(selectedRows);
    maxSelection=max(selectedRows);

    if(minSelection==1)
        dialogH.setEnabled('MoveElementUpBtn',false);
        return;
    end


    currElements=tempBusObject.Elements(minSelection:maxSelection);


    if minSelection>2
        prevElements=tempBusObject.Elements(1:minSelection-2);
    else
        prevElements=[];
    end


    elementsUntilCurrent=[prevElements;currElements;tempBusObject.Elements(minSelection-1)];

    subsequentElements=tempBusObject.Elements(maxSelection+1:end);


    tempBusObject.Elements=[elementsUntilCurrent;subsequentElements];


    rowsToSelect=minSelection:maxSelection;


    rowsToSelect=rowsToSelect-1;



    loc_storeRowSelectionsBeforeUpdate(dialogH,rowsToSelect);

    loc_storeTempBusObjectInUserData(dialogH,tempBusObject);
    isSpreadsheetUpdating=true;
    dialogH.setUserData('BusObjectSpreadsheet',isSpreadsheetUpdating);

    loc_updateSpreadsheetWidget(dialogH);
end










function i_doMoveElementDown(dialogH)

    selectedRowsMap=dialogH.getUserData('DeleteElementBtn');
    selectedRows=str2double(selectedRowsMap.keys);

    if isempty(selectedRows)
        selectedRows=1;
    end

    tempBusObject=loc_getTempBusObject(dialogH);


    minSelection=min(selectedRows);
    maxSelection=max(selectedRows);

    if(maxSelection==numel(tempBusObject.Elements))
        dialogH.setEnabled('MoveElementDownBtn',false);
        return;
    end

    currElements=tempBusObject.Elements(minSelection:maxSelection);

    if minSelection==1
        tempBusObject.Elements=[tempBusObject.Elements(maxSelection+1);currElements;tempBusObject.Elements(maxSelection+2:end)];
    else
        previousElements=tempBusObject.Elements(1:minSelection-1);
        tempBusObject.Elements=[previousElements;tempBusObject.Elements(maxSelection+1);currElements;tempBusObject.Elements((maxSelection+2):end)];
    end


    rowsToSelect=minSelection:maxSelection;


    rowsToSelect=rowsToSelect+1;

    loc_storeTempBusObjectInUserData(dialogH,tempBusObject);



    loc_storeRowSelectionsBeforeUpdate(dialogH,rowsToSelect);

    isSpreadsheetUpdating=true;
    dialogH.setUserData('BusObjectSpreadsheet',isSpreadsheetUpdating);

    loc_updateSpreadsheetWidget(dialogH);
end




function newElementName=loc_get_NewElementName(dialogH)

    elementNamesMap=dialogH.getUserData('AddElementBtn');
    idx=1;

    while(true)
        if~isKey(elementNamesMap,'a')
            newElementName='a';
            return;
        end

        if~isKey(elementNamesMap,strcat('a',num2str(idx)))
            newElementName=strcat('a',num2str(idx));
            return;
        end

        idx=idx+1;
    end
end


function loc_updateSpreadsheetWidget(dialogH)
    w=dialogH.getWidgetInterface('BusObjectSpreadsheet');
    w.update();
    dialogH.setUserData('DeleteElementBtn',[]);
end


function tempBusObject=loc_getTempBusObject(dialogH)
    DialogState=dialogH.getUserData('MoveElementUpBtn');
    tempBusObject=DialogState.tempBusObject;
end


function loc_storeTempBusObjectInUserData(dialogH,tempBusObject)

    DialogState=dialogH.getUserData('MoveElementUpBtn');



    DialogState.tempBusObject=tempBusObject;
    dialogH.setUserData('MoveElementUpBtn',DialogState)
end


function loc_storeRowSelectionsBeforeUpdate(dialogH,rowsToSelect)


    selectionData.selectedRows=rowsToSelect;
    selectionData.selData=[];
    dialogH.setUserData('MoveElementDownBtn',selectionData);
end


