

function success=saveMask(aDialog)
    success=true;
    hOpenedDoc=[];
    blockHandle=aDialog.m_MEData.context.blockHandle;
    try
        if(aDialog.m_MEData.context.maskOnSysObject)
            [success,hOpenedDoc,bDialogCustomizationPresent]=...
            maskeditor.internal.loadsave.SubsystemOrCoreBlock.saveMaskHelperForSysObject.getUserResponseToRemoveDialogCustomizations(blockHandle);
        end
        if success
            ApplyMaskData(aDialog);
            if(aDialog.m_MEData.context.maskOnSysObject&&bDialogCustomizationPresent)
                maskeditor.internal.loadsave.SubsystemOrCoreBlock.saveMaskHelperForSysObject.removeDialogCustomizationsFromSysObjectFile(blockHandle);
            end
        end
    catch exp
        msg=slprivate('getExceptionMsgReport',exp);
        showDialog(msg,false);
        success=false;
    end
    if~isempty(hOpenedDoc)
        hOpenedDoc.closeNoPrompt();


        aDialog.show();
    end
end

function ApplyMaskData(aDialog)
    bDataSavedToSysObjectAuxryXml=false;
    aInterceptor=Simulink.output.StorageInterceptorCb();

    scope_definer=Simulink.output.registerProcessor(aInterceptor);%#ok<NASGU>

    MEData=aDialog.m_MEData;
    isMaskOnMask=MEData.context.maskOnMask;
    widgets=MEData.widgets;
    H=MEData.context.blockHandle;


    if~strcmp(get_param(bdroot(H),'SimulationStatus'),'stopped')
        error(message('Simulink:Masking:Simulate'));
    end

    [aMaskObj,bCanCreateNewMask]=Simulink.Mask.get(H);
    isMaskPresent=~(isempty(aMaskObj)||(isMaskOnMask&&bCanCreateNewMask));

    if(~isMaskPresent)
        aMaskObj=Simulink.Mask.create(H);

        if(isempty(aMaskObj))
            msg=DAStudio.message('Simulink:Masking:BlockNotMasked',getfullname(H));
            showDialog(msg,false);
            return;
        end
    end


    aOldMaskObj=createStandalone(aMaskObj);

    aMaskDialogRefreshHandler=Simulink.MaskDialogRefreshHandler(aMaskObj);%#ok<NASGU>

    try
        if(aDialog.m_MEData.context.maskOnSysObject)
            doDialogCallBackParams=aMaskObj.getParameterNamesWithAttribute('do-dialog-callback','on');
            mxArrayParams=aMaskObj.getParameterNamesWithAttribute('mxarray','on');
            mxNumStructParams=aMaskObj.getParameterNamesWithAttribute('mxnumstruct','on');
        end
        aMaskObj.removeAllDialogControls;
        aMaskObj.removeAllParameters


        environment='MASKEDITOR';
        [~]=constraint_manager.SaveConstraints(aDialog,environment);

        addWidgetsOnMask(aMaskObj,widgets,MEData);

        MaskType=MEData.documentation.type;
        MaskDescription=MEData.documentation.description;
        MaskHelp=MEData.documentation.help;

        MaskInitString=MEData.initialization;
        if MEData.selfModifiable
            MaskSelfModifiable='on';
        else
            MaskSelfModifiable='off';
        end

        MaskDisplay=MEData.icon.display;
        MaskIconRotate=MEData.iconProperties.iconRotate;
        MaskIconFrame=MEData.iconProperties.iconFrame;
        MaskIconOpaque=MEData.iconProperties.iconOpaque;
        MaskIconUnits=MEData.iconProperties.iconUnits;
        MaskPortRotate=MEData.iconProperties.portRotate;
        MaskRunInit=MEData.iconProperties.runInitForIconRedraw;

        aMaskObj.set(...
        'Type',MaskType,...
        'Description',MaskDescription,...
        'Help',MaskHelp,...
        'Initialization',MaskInitString,...
        'SelfModifiable',MaskSelfModifiable,...
        'IconRotate',MaskIconRotate,...
        'IconFrame',MaskIconFrame,...
        'IconOpaque',MaskIconOpaque,...
        'IconUnits',MaskIconUnits,...
        'PortRotate',MaskPortRotate,...
        'RunInitForIconRedraw',MaskRunInit,...
        'Display',MaskDisplay...
        );

        if(aDialog.m_MEData.context.maskOnSysObject)
            maskeditor.internal.loadsave.SubsystemOrCoreBlock.saveMaskHelperForSysObject.updateAdvacedAttribsOfMaskParams(aMaskObj,...
            doDialogCallBackParams,...
            mxArrayParams,...
            mxNumStructParams);
            aMaskObj.saveSystemObjectMask();
            bDataSavedToSysObjectAuxryXml=true;
        end

        aScopedGLIMMessageBlocker=SLM3I.ScopedGLIMMessageBlocker;
        if~MEData.context.maskOnModel
            Simulink.Block.eval(H);
        end
        delete(aScopedGLIMMessageBlocker);


        newMLWarnings=aInterceptor.lastInterceptedMsg();
        clear scope_definer;

        if(~isempty(newMLWarnings)&&~isWarningFiltered(newMLWarnings.MessageId))
            showDialog(newMLWarnings.Message,true);
        end
    catch exp
        constraint_manager.ConstraintUtils.SaveOldConstraintsToMaskObj(aMaskObj,aOldMaskObj);

        aMaskObj.set(...
        'Type',aOldMaskObj.Type,...
        'Description',aOldMaskObj.Description,...
        'Help',aOldMaskObj.Help,...
        'Display',aOldMaskObj.Display,...
        'IconRotate',aOldMaskObj.IconRotate,...
        'IconFrame',aOldMaskObj.IconFrame,...
        'IconOpaque',aOldMaskObj.IconOpaque,...
        'IconUnits',aOldMaskObj.IconUnits,...
        'PortRotate',aOldMaskObj.PortRotate,...
        'Initialization',aOldMaskObj.Initialization,...
        'SelfModifiable',aOldMaskObj.SelfModifiable,...
        'Parameters',aOldMaskObj.Parameters,...
        'RunInitForIconRedraw',aOldMaskObj.RunInitForIconRedraw...
        );

        if(isa(aOldMaskObj.DialogControls,'Simulink.dialog.Control'))
            aMaskObj.setDialogControls(aOldMaskObj.DialogControls);
        end
        if(aDialog.m_MEData.context.maskOnSysObject)
            maskeditor.internal.loadsave.SubsystemOrCoreBlock.saveMaskHelperForSysObject.updateAdvacedAttribsOfMaskParams(aMaskObj,...
            doDialogCallBackParams,...
            mxArrayParams,...
            mxNumStructParams);
            if(bDataSavedToSysObjectAuxryXml)
                aMaskObj.saveSystemObjectMask();
            end
        end

        rethrow(exp);
    end

end

function addWidgetsOnMask(aMaskObj,widgets,MEData)

    parameterWidgets=getParameterWidgets(widgets);
    numParams=length(parameterWidgets);
    aMaskParameters=Simulink.MaskParameter.createStandalone(numParams);

    for i=1:numParams

        widget=parameterWidgets{i};
        aMaskParameter=aMaskParameters(i);

        properties=widget.properties;
        widgetType=widget.getPropertyByKey("Type").value;

        resolvedWidgetType=widgetType;
        if~isempty(widget.getPropertyByKey('PromotedParametersList'))
            resolvedWidgetType='promote';
        elseif strcmpi(widgetType,'datatypestr')
            resolvedWidgetType=getDataTypeStrTypeString(widget.getPropertyByKey('TypeOptions').value,widgets,widget);
        end

        if MEData.context.maskOnSysObject&&(strcmpi(resolvedWidgetType,'popup')...
            ||(strcmpi(resolvedWidgetType,'radiobutton')))
            paramType=widget.getPropertyByKey("Type").value;
            paramName=getPropertyFromPropertyMap('Name',widget,paramType);
            typeOpts=getPropertyFromPropertyMap('TypeOptions',widget,paramType);
            matlab.system.ui.ImplementSystemObjectUsingMask.validateTypeOptionsForParamInSysObject(MEData.context.blockHandle,paramName,typeOpts);
        end

        alreadyApplied=["Type","Name","TypeOptions","Evaluate","Tunable","Prompt","Value",...
        "Enabled","Visible","Callback","Alias","ReadOnly","NeverSave","ConstraintName",...
        "Range","StepSize","Minimum","Maximum","PromotedParametersList"];

        aMaskParameter.set(...
        'Type',resolvedWidgetType,...
        'Name',getPropertyFromPropertyMap('Name',widget,resolvedWidgetType),...
        'TypeOptions',getPropertyFromPropertyMap('TypeOptions',widget,resolvedWidgetType),...
        'Evaluate',getPropertyFromPropertyMap('Evaluate',widget,resolvedWidgetType),...
        'Tunable',getPropertyFromPropertyMap('Tunable',widget,resolvedWidgetType),...
        'Prompt',getPropertyFromPropertyMap('Prompt',widget,resolvedWidgetType),...
        'Value',getPropertyFromPropertyMap('Value',widget,resolvedWidgetType),...
        'Enabled',getPropertyFromPropertyMap('Enabled',widget,resolvedWidgetType),...
        'Visible',getPropertyFromPropertyMap('Visible',widget,resolvedWidgetType),...
        'Callback',getPropertyFromPropertyMap('Callback',widget,resolvedWidgetType),...
        'Alias',getPropertyFromPropertyMap('Alias',widget,resolvedWidgetType),...
        'ReadOnly',getPropertyFromPropertyMap('ReadOnly',widget,resolvedWidgetType),...
        'NeverSave',getPropertyFromPropertyMap('NeverSave',widget,resolvedWidgetType),...
        'Range',getPropertyFromPropertyMap('Range',widget,resolvedWidgetType),...
        'StepSize',getPropertyFromPropertyMap('StepSize',widget,resolvedWidgetType),...
        'ConstraintName',getPropertyFromPropertyMap('ConstraintName',widget,widgetType,MEData)...
        );

        for propIdx=1:length(properties)
            propertyId=properties(propIdx).id;

            if isDialogControlProperty(propertyId)
                continue;
            elseif~alreadyApplied.contains(propertyId)
                setWidgetProperty(aMaskParameter,propertyId,widget,widgetType);
            end
        end

    end

    aMaskObj.set('Parameters',aMaskParameters);

    parentChildrenMap=getParentChildrenMap(widgets);

    if parentChildrenMap.isKey('null')
        rootWidgetIndices=parentChildrenMap('null');
        for i=1:length(rootWidgetIndices)
            addDialogControlsReccursive(rootWidgetIndices(i),aMaskObj,aMaskObj,parentChildrenMap,widgets);
        end
    end

end

function addDialogControlsReccursive(idx,aMaskObj,parent,parentChildMap,widgets)

    h=addDialogControl(aMaskObj,parent,widgets,idx);
    widgetId=widgets(idx).id;
    if(parentChildMap.isKey(widgetId))
        children=parentChildMap(widgetId);
        for i=1:length(children)
            addDialogControlsReccursive(children(i),aMaskObj,h,parentChildMap,widgets);
        end
    end

end

function dlgControl=addDialogControl(aMaskObj,parent,widgets,idx)

    widget=widgets(idx);
    properties=widgets(idx).properties;
    widgetType=widgets(idx).getPropertyByKey('Type').value;
    controlName=getPropertyFromPropertyMap('Name',widget,widgetType);
    updatedMaskStyle=updateWidgetType(widgetType);



    if(strcmpi(getWidgetCategory(widgetType),"Container"))

        dlgControl=parent.addDialogControl('Type',updatedMaskStyle,'Name',controlName);
        alreadyApplied=["Type","Name"];
        for i=1:length(properties)
            propertyId=properties(i).id;
            if~alreadyApplied.contains(propertyId)
                setWidgetProperty(dlgControl,propertyId,widget,widgetType);
            end
        end


    elseif(strcmpi(getWidgetCategory(widgetType),"Control"))

        dlgControl=parent.addDialogControl('Type',updatedMaskStyle,'Name',controlName);
        alreadyApplied=["Type","Name"];
        for i=1:length(properties)
            propertyId=properties(i).id;
            if~alreadyApplied.contains(propertyId)
                setWidgetProperty(dlgControl,propertyId,widget,widgetType);
            end
        end


    else
        paramName=controlName;

        dlgControl=aMaskObj.getDialogControl(paramName);
        for propIdx=1:length(properties)
            propertyId=properties(propIdx).id;

            if isDialogControlProperty(propertyId)
                setWidgetProperty(dlgControl,propertyId,widget,widgetType);
            end
        end
        dlgControl.moveTo(parent);
    end

end





function updatedType=updateWidgetType(type)
    updatedType=type;
    if(strcmpi(type,'button'))
        updatedType='pushbutton';
    end
end

function[aStandaloneMaskObject]=createStandalone(aMaskObj)


    aStandaloneMaskObject=struct();
    aMaskObjProperties=properties(aMaskObj);
    aMaskParameters=aMaskObj.Parameters;
    iNumParameters=length(aMaskObj.Parameters);

    for i=1:length(aMaskObjProperties)
        aMaskObjPropertyValue=aMaskObj.(aMaskObjProperties{i});

        if isa(aMaskObjPropertyValue,'Simulink.MaskParameter')
            aStandaloneMaskObject.Parameters=Simulink.MaskParameter.createStandalone(iNumParameters);
            for j=1:iNumParameters
                aStandaloneMaskObject.Parameters(j).copy(aMaskParameters(j));
                aStandaloneMaskObject.Parameters(j).Container='';
            end
        elseif isa(aMaskObjPropertyValue,'Simulink.Mask.CrossParameterConstraints')
            aStandaloneMaskObject=constraint_manager.ConstraintUtils.addCrossParameterConstraintsToStandaloneMask(aMaskObj,aStandaloneMaskObject);
        elseif isa(aMaskObjPropertyValue,'Simulink.Mask.Constraints')
            aStandaloneMaskObject=constraint_manager.ConstraintUtils.addParameterConstraintsToStandaloneMask(aMaskObj,aStandaloneMaskObject);
        elseif isa(aMaskObjPropertyValue,'Simulink.Mask.PortConstraint')
            aStandaloneMaskObject=constraint_manager.ConstraintUtils.addPortConstraintsToStandaloneMask(aMaskObj,aStandaloneMaskObject);
            aStandaloneMaskObject=constraint_manager.ConstraintUtils.addPortConstraintAssociationsToStandaloneMask(aMaskObj,aStandaloneMaskObject);
        elseif isa(aMaskObjPropertyValue,'Simulink.Mask.PortIdentifier')
            aStandaloneMaskObject=constraint_manager.ConstraintUtils.addPortIdentifiersToStandaloneMask(aMaskObj,aStandaloneMaskObject);
        else
            aStandaloneMaskObject.(aMaskObjProperties{i})=aMaskObjPropertyValue;
        end
    end

    aStandaloneMaskObject.DialogControls=aMaskObj.cloneDialogControls();
end

function map=getParentChildrenMap(widgets)
    map=containers.Map('KeyType','char','ValueType','any');
    for i=1:widgets.Size
        parent=widgets(i).parent;
        if map.isKey(parent)
            map(parent)=[map(parent),i];
        else
            map(parent)=i;
        end
    end
end

function parameterWidgets=getParameterWidgets(widgets)
    parameterWidgets={};
    for i=1:widgets.Size
        widgetType=widgets(i).getPropertyByKey('Type').value;
        if strcmpi(getWidgetCategory(widgetType),"Parameter")
            parameterWidgets{end+1}=widgets(i);%#ok<AGROW>
        end
    end
end

function val=getPropertyFromPropertyMap(propName,widget,widgetType,varargin)

    if strcmpi(propName,"TypeOptions")
        val=getTypeOptions(widget,widgetType);
        return;
    end

    if strcmpi(widgetType,"lookuptablecontrol")&&strcmpi(propName,"Table")

        val=widget.getPropertyByKey(propName).value;
        val=jsondecode(val);

        if(~isempty(val.paramName))
            table=Simulink.dialog.LookupTableControl.Table;
            table.Name=val.paramName;
            table.Unit=val.unit;
            table.FieldName=val.displayName;
            val=table;
        else
            val='';
        end

        return;
    end

    if strcmpi(widgetType,"lookuptablecontrol")&&strcmpi(propName,"Breakpoints")

        breakpoints=widget.getPropertyByKey(propName).value;
        numBP=0;

        if~isempty(breakpoints)
            breakpoints=jsondecode(breakpoints);
            numBP=length(breakpoints);
        end

        if(numBP==0)
            val=Simulink.dialog.LookupTableControl.Breakpoint.empty(1,0);
        end

        for i=1:numBP
            bp=Simulink.dialog.LookupTableControl.Breakpoint;
            val(i)=bp;
            bp.Name=breakpoints(i).paramName;
            bp.Unit=breakpoints(i).unit;
            bp.FieldName=breakpoints(i).displayName;
        end

        return;
    end

    if strcmpi(propName,"TreeItems")
        val=getTreeItems(widget);
        return;
    end

    if strcmpi(propName,"Range")
        try
            min=getPropertyFromPropertyMap("Minimum",widget,widgetType);
            max=getPropertyFromPropertyMap("Maximum",widget,widgetType);
            range=[str2double(min),str2double(max)];
            val=range;
        catch
            val=[0,100];
        end

        return;
    end

    if(strcmpi(propName,"StepSize"))
        try
            val=str2double(widget.getPropertyByKey(propName).value);
        catch
            val=1;
        end

        return;
    end

    if strcmp(propName,'ConstraintName')
        if strcmpi(widgetType,'edit')||strcmpi(widgetType,'combobox')
            MEData=varargin{1};
            val=getConstraintNameFromId(MEData,widget.getPropertyByKey('ConstraintName').value);
        else
            val='';
        end
        return;
    end


    val=widget.getPropertyByKey(propName).value;

    if strcmpi(propName,"Value")&&strcmpi(widgetType,'textarea')
        valueObj=jsondecode(val);
        val='';
        if~isempty(valueObj)
            val=valueObj.value;
        end
    end

    if strcmpi(propName,"Value")&&strcmpi(widgetType,'listbox')
        selected=jsondecode(val);
        if(isempty(selected))
            val="{''}";
            return;
        end
        valStr="{";
        for i=1:length(selected)
            if(i~=1)
                valStr=valStr.append(', ');
            end
            valStr=valStr.append("'",selected{i},"'");
        end
        valStr=valStr.append('}');
        val=valStr;
        return;
    end

    if strcmpi(propName,"Value")&&strcmpi(widgetType,'customtable')
        valStr=widget.getPropertyByKey('Value').value;
        if(~isempty(valStr))
            rows=jsondecode(valStr).values;
            valStr=buildCustomTableValueStr(rows);
        end
        val=valStr;

        return;
    end

    switch(lower(propName))
    case 'prompt'
        val=jsondecode(val).textId;
    case 'tooltip'
        val=jsondecode(val).textId;
    otherwise
    end

    val=convertLabelToValue(val);
end

function constraintName=getConstraintNameFromId(MEData,constraintId)
    constraintName='';
    constraintManagerModel=MEData.constraintManagerTopObject;
    if isempty(constraintManagerModel)
        return;
    end
    constraintName=constraint_manager.ModelUtils.getConstraintNameFromId(constraintManagerModel,constraintId);
end


function setWidgetProperty(h,propName,widget,widgetType)
    if(strcmpi(widgetType,'customtable')&&strcmpi(propName,'Columns'))
        setCustomTableColumnsProperty(h,widget);
    else
        value=getPropertyFromPropertyMap(propName,widget,widgetType);
        if~isempty(value)
            h.(propName)=value;
        end
    end
end


function setCustomTableColumnsProperty(tableControl,widget)
    colStr=widget.getPropertyByKey('Columns').value;
    if(~isempty(colStr))
        cols=jsondecode(colStr);
        for i=1:length(cols)

            if(cols(i).Enabled)
                enabled='on';
            else
                enabled='off';
            end

            if(cols(i).Visible)
                visible='on';
            else
                visible='off';
            end

            if(cols(i).Evaluate)
                evaluate='on';
            else
                evaluate='off';
            end


            if(strcmpi(cols(i).Type,'popup'))&&~isempty(cols(i).TypeOptions)
                tableControl.addColumn('Name',cols(i).Name,'Type',cols(i).Type,...
                'Enabled',enabled,'TypeOptions',cols(i).TypeOptions,'Visible',visible,...
                'Width',cols(i).Width,'Evaluate',evaluate);
            else
                tableControl.addColumn('Name',cols(i).Name,'Type',cols(i).Type,...
                'Enabled',enabled,'Visible',visible,'Width',cols(i).Width,'Evaluate',evaluate);
            end

        end
    end
end
function resultStr=buildCustomTableValueStr(rows)

    resultStr='{';
    for i=1:length(rows)
        if(i~=1)
            resultStr=strcat(resultStr,';');
        end

        for j=1:length(rows{i})
            if(isstruct(rows{i}{j}))
                checked='off';
                if(rows{i}{j}.checked)
                    checked='on';
                end
                rows{i}{j}=checked;
            else
                rows{i}{j}=strrep(rows{i}{j},"'","''");
            end
            if(j~=1)
                resultStr=strcat(resultStr,",");
            end
            resultStr=strcat(resultStr,"'",rows{i}{j},"'");
        end
    end
    resultStr=strcat(resultStr,"}");

end


function typeOptions=getTypeOptions(widget,widgetType)
    if(strcmpi(widgetType,"promote"))
        typeOptionsStr=widget.getPropertyByKey('PromotedParametersList').value;
        typeOptions=jsondecode(typeOptionsStr);
    elseif(strcmpi(widgetType,'combobox')||strcmpi(widgetType,'listboxcontrol')||...
        strcmpi(widgetType,'radiobutton')||strcmpi(widgetType,'listbox'))
        typeOptions=widget.getPropertyByKey('TypeOptions').value;
        if~isempty(typeOptions)
            typeOptions=jsondecode(typeOptions);
        end
    elseif strcmpi(widgetType,'popup')
        val=jsondecode(widget.getPropertyByKey('TypeOptions').value);
        if strcmpi(val.selectedRadio,'list')
            typeOptions=val.value;
        else
            type='ExternalEnumerationClass';
            typeOptions=Simulink.Mask.EnumerationTypeOptions(type,val.value);
        end
    else
        typeOptions='';
    end
end


function treeItems=getTreeItems(widget)
    treeItems=widget.getPropertyByKey('TreeItems').value;
    if isempty(treeItems)
        treeItems={};
        return;
    end

    treeItems=jsondecode(treeItems);

    if isempty(treeItems)
        treeItems={};
        return;
    end

    childrenMap=containers.Map('KeyType','char','ValueType','any');
    for i=1:length(treeItems)
        parent=treeItems(i).parent;
        if childrenMap.isKey(parent)
            childrenMap(parent)=[childrenMap(parent),treeItems(i)];
        else
            childrenMap(parent)=treeItems(i);
        end
    end

    nullParent.id='null';
    treeItems=buildTreeItemsReccursive(childrenMap,nullParent);
    treeItems=treeItems{1};
end

function treeItems=buildTreeItemsReccursive(treeItemsChildrenMap,parent)

    treeItems={};
    if~strcmpi(parent.id,"null")
        treeItems={parent.label};
    end

    if(treeItemsChildrenMap.isKey(parent.id))
        children=treeItemsChildrenMap(parent.id);
        childItems={};
        for i=1:length(children)
            childItems=[childItems,buildTreeItemsReccursive(treeItemsChildrenMap,children(i))];%#ok<AGROW>
        end
        treeItems{end+1}=childItems;
    end
end



function ret=getDataTypeStrTypeString(typeOptionsStr,widgets,widget)

    typeOptionsObj=jsondecode(typeOptionsStr);
    if(~isempty(typeOptionsObj.a))
        dtsParamIdx=getParameterIndexFromId(...
        typeOptionsObj.a.DTSParamId,widgets);
        minParamIdx=getParameterIndexFromId(...
        typeOptionsObj.a.MinWidget,widgets);
        maxParamIdx=getParameterIndexFromId(...
        typeOptionsObj.a.MaxWidget,widgets);
        editParamIdx=getParameterIndexFromId(...
        typeOptionsObj.a.EditWidget,widgets);

    else
        dtsParamIdx=getParameterIndexFromId(...
        widget.id,widgets);

        minParamIdx='';
        maxParamIdx='';
        editParamIdx='';
    end
    assocSubStr=[num2str(dtsParamIdx),'|',num2str(minParamIdx),'|',...
    num2str(maxParamIdx),'|',num2str(editParamIdx)];


    aMapperSubstr=getCapString('a',assocSubStr);

    aInheritSubstr=getCapString('i',typeOptionsObj.i);
    aBuiltinSubstr=getCapString('b',typeOptionsObj.b);
    aScModeSubstr=getCapString('s',typeOptionsObj.s);
    aSignModeSubstr=getCapString('g',typeOptionsObj.g);
    aUserSubstr=getCapString('u',typeOptionsObj.u);

    ret=[...
    'unidt',...
    '(',...
    aMapperSubstr,...
    aInheritSubstr,...
    aBuiltinSubstr,...
    aScModeSubstr,...
    aSignModeSubstr,...
    aUserSubstr,...
')'
    ];


end
function capString=getCapString(capType,options)

    if isempty(options)
        capString='';
    elseif(iscell(options))
        str=options{1};
        for i=2:length(options)
            str=strcat(str,'|',options{i});
        end
        capString=['{',capType,'=',str,'}'];
    else
        capString=['{',capType,'=',options,'}'];
    end
end
function ret=getParameterIndexFromId(paramId,widgets)
    ret='';
    paramIdx=0;
    for widgetsIdx=1:widgets.Size
        widgets(widgetsIdx).getPropertyByKey('Name');

        widgetType=widgets(widgetsIdx).getPropertyByKey('Type').value;
        widgetCategory=getWidgetCategory(widgetType);
        if(strcmpi(widgetCategory,'Parameter'))
            paramIdx=paramIdx+1;
        end

        if(strcmpi(widgets(widgetsIdx).id,paramId))
            ret=paramIdx;
        end
    end
end

function ret=convertLabelToValue(label)
    ret=label;

    if~ischar(label)
        return;
    end

    if(strcmpi(ret,'false'))
        ret='off';
    elseif(strcmpi(ret,'true'))
        ret='on';
    elseif(strcmpi(ret,'DataTypeStrDefaultValue'))
        ret='Inherit:';
    end
end

function widgetType=getWidgetCategory(type)

    containerArray=["group","tab","tabcontainer","table","collapsiblepanel","panel"];
    controlArray=["text","image","listboxcontrol","treecontrol","hyperlink","button","lookuptablecontrol"];

    if(any(strcmpi(containerArray,type)))
        widgetType="Container";
    elseif(any(strcmpi(controlArray,type)))
        widgetType="Control";
    else
        widgetType="Parameter";
    end
end

function flag=isDialogControlProperty(property)

    dialogControlProperties=["HorizontalStretch","Tooltip","PromptLocation","Orientation","Scale",...
    "TextType","MultiSelect","ShowFilter","Sortable","Row","Columns"];

    flag=any(strcmpi(dialogControlProperties,property));

end


function isFiltered=isWarningFiltered(~)
    isFiltered=false;
end

function showDialog(msg,isWarning)
    msg=slprivate('removeHyperLinksFromMessage',msg);
    if isWarning
        warndlg(msg);
    else
        errordlg(msg);
    end
end