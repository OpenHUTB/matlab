








function dlgstruct=valueTypeGetDialogSchema(obj,name,varargin)
    narginchk(2,3);
    slimModeForContainer=~isempty(varargin);

    rowIdx=3;

    isBusType=false;

    if slfeature('SLValueTypeBusSupport')==1
        isBusType=~isempty(regexpi(obj.DataType,'^Bus:','match'));
    end



    dimensionsLbl.Name=DAStudio.message('dastudio:ddg:WSODimensions');
    dimensionsLbl.Type='text';
    dimensionsLbl.ColSpan=[1,1];
    dimensionsLbl.Tag='DimensionsLbl';
    dimensionsLbl.RowSpan=[rowIdx,rowIdx];
    dimensionsLbl.ColSpan=[1,1];

    dimensions.Name=dimensionsLbl.Name;
    dimensions.HideName=1;
    dimensions.Type='edit';
    dimensions.Tag='Dimensions';




    dimensions.ObjectProperty='Dimensions';
    dimensions.ToolTip=DAStudio.message('Simulink:dialog:DataDimensionsToolTip1');
    dimensions.RowSpan=[rowIdx,rowIdx];
    dimensions.ColSpan=[2,2];


    complexityLbl.Name=DAStudio.message('Simulink:dialog:DataComplexityPrompt');
    complexityLbl.Type='text';
    complexityLbl.Tag='ComplexityLbl';
    complexityLbl.RowSpan=[rowIdx,rowIdx];
    complexityLbl.ColSpan=[3,3];

    complexity.Name=complexityLbl.Name;
    complexity.HideName=1;
    complexity.Tag='Complexity';
    complexity.ToolTip=DAStudio.message('Simulink:dialog:DataComplexityToolTip1');
    complexity.RowSpan=[rowIdx,rowIdx];
    complexity.ColSpan=[4,4];
    complexity.Type='combobox';
    complexity.Entries=l_translate(getPropAllowedValues(obj,'Complexity'));

    complexity.ObjectProperty='Complexity';
    complexity.Enabled=~isBusType;


    rowIdx=rowIdx+1;
    minimumLbl.Name=DAStudio.message('Simulink:dialog:DataMinimumPrompt');
    minimumLbl.Type='text';
    minimumLbl.RowSpan=[rowIdx,rowIdx];
    minimumLbl.ColSpan=[1,1];

    minimum.Name=minimumLbl.Name;
    minimum.HideName=1;
    minimum.Type='edit';

    minimum.ObjectProperty='Min';
    minimum.Tag='Minimum';
    minimum.ToolTip=DAStudio.message('Simulink:dialog:DataMinimumToolTip');

    minimum.RowSpan=[rowIdx,rowIdx];
    minimum.ColSpan=[2,2];
    minimum.Enabled=~isBusType;

    maximumLbl.Name=DAStudio.message('Simulink:dialog:DataMaximumPrompt');
    maximumLbl.Type='text';
    maximumLbl.RowSpan=[rowIdx,rowIdx];
    maximumLbl.ColSpan=[3,3];

    maximum.Name=maximumLbl.Name;
    maximum.HideName=1;
    maximum.Type='edit';

    maximum.ObjectProperty='Max';
    maximum.Tag='Maximum';
    maximum.ToolTip=DAStudio.message('Simulink:dialog:DataMaximumToolTip');

    maximum.RowSpan=[rowIdx,rowIdx];
    maximum.ColSpan=[4,4];
    maximum.Enabled=~isBusType;



    dataTypeItems.scalingMinTag={minimum.Tag};
    dataTypeItems.scalingMaxTag={maximum.Tag};


    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('StructElement');


    dataTypeItems.supportsEnumType=true;


    if slfeature('SLValueTypeBusSupport')==0
        dataTypeItems.supportsBusType=false;
    else
        dataTypeItems.supportsBusType=true;
    end


    if slimModeForContainer
        sourceObjForDTA=varargin{1};
    else
        sourceObjForDTA=obj;
    end
    datatype=Simulink.DataTypePrmWidget.getDataTypeWidget(sourceObjForDTA,'DataType',...
    DAStudio.message('Simulink:dialog:DataDataTypePrompt'),...
    'DataType',sourceObjForDTA.DataType,dataTypeItems,false);
    assert(isequal(datatype.Items{2}.Tag,'DataType'));


    datatype.RowSpan=[2,2];
    datatype.ColSpan=[1,4];







    rowIdx=rowIdx+1;
    unitsLbl.Name=DAStudio.message('Simulink:dialog:DataUnitPrompt');
    unitsLbl.Type='text';
    unitsLbl.Tag='UnitLbl';
    unitsLbl.RowSpan=[rowIdx,rowIdx];
    unitsLbl.ColSpan=[1,1];

    units.Name=unitsLbl.Name;
    units.HideName=1;
    units.Type='edit';

    units.ToolTip=DAStudio.message('Simulink:dialog:DataUnitToolTip');

    units.Value=obj.getPropValue('Unit');
    units.ObjectProperty='Unit';
    units.Tag='Unit';
    units.AutoCompleteType='Custom';
    units.ObjectMethod='getAutoCompleteData';
    units.MethodArgs={'%value','%value','%dialog'};
    units.ArgDataTypes={'mxArray','mxArray','handle'};
    symbolPrompt=[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnSymbolPrompt'),...
    '                         '];
    namePrompt=[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnNamePrompt'),...
    '                                         '];
    units.AutoCompleteViewColumn={' ',symbolPrompt,namePrompt};
    units.AutoCompleteCompletionMode='UnfilteredPopupCompletion';
    units.RowSpan=[rowIdx,rowIdx];
    units.ColSpan=[2,2];


    units.Enabled=obj.isValidProperty(units.ObjectProperty);
    if~units.Enabled
        units.ObjectProperty='';
        units.Value='';
    end

    if units.Enabled
        units.Enabled=~isBusType;
    end


    dimensionsModeLbl.Name=DAStudio.message('Simulink:dialog:DataDimensionsModePrompt');
    dimensionsModeLbl.Type='text';
    dimensionsModeLbl.RowSpan=[rowIdx,rowIdx];
    dimensionsModeLbl.ColSpan=[3,3];
    dimensionsModeLbl.Tag='DimensionsModeLbl';

    dimensionsmode.Name=dimensionsModeLbl.Name;
    dimensionsmode.HideName=1;
    dimensionsmode.Type='combobox';
    dimensionsmode.Entries=l_translate(getPropAllowedValues(obj,'DimensionsMode'));

    dimensionsmode.ObjectProperty='DimensionsMode';
    dimensionsmode.RowSpan=[rowIdx,rowIdx];
    dimensionsmode.ColSpan=[4,4];
    dimensionsmode.Tag='DimensionsMode';
    dimensionsmode.ToolTip=DAStudio.message('Simulink:dialog:DataDimensionsModeToolTip');
    dimensionsmode.Enabled=~isBusType;


    rowIdx=rowIdx+1;
    description.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    description.Type='editarea';
    description.RowSpan=[rowIdx,rowIdx];
    description.ColSpan=[1,4];

    description.ObjectProperty='Description';
    description.Tag='Description';


    attribTab.Name=DAStudio.message('Simulink:dialog:SignalAttributes');
    attribTab.LayoutGrid=[rowIdx,4];
    attribTab.RowStretch=[zeros(1,rowIdx-1),1];
    attribTab.ColStretch=[0,1,0,1];
    attribTab.Items={datatype,dimensionsLbl,dimensions,complexityLbl,complexity,minimumLbl,minimum,...
    maximumLbl,maximum,unitsLbl,units,dimensionsModeLbl,dimensionsmode,...
    description};


    if slimModeForContainer
        dlgstruct.DialogMode='Slim';
        propPanel.Name=DAStudio.message('Simulink:busEditor:DDGProperties');
        propPanel.Type='togglepanel';
        propPanel.Expand=true;
        propPanel.LayoutGrid=attribTab.LayoutGrid;
        propPanel.RowStretch=attribTab.RowStretch;
        propPanel.ColStretch=attribTab.ColStretch;
        propPanel.Items=attribTab.Items;

        outerPanel.Type='panel';
        outerPanel.Items={propPanel};
        dlgstruct.Items={outerPanel};
    else
        dlgstruct.Items=attribTab.Items;
        dlgstruct.LayoutGrid=attribTab.LayoutGrid;
        dlgstruct.RowStretch=attribTab.RowStretch;
        dlgstruct.ColStretch=attribTab.ColStretch;
    end
    dlgstruct.DialogTag='ValueTypeDialog';
    dlgTitle=[class(obj),': ',name];
    dlgstruct.DialogTitle=dlgTitle;
end



function str=l_translate(str)

    if iscell(str)
        for idx=1:length(str)
            str{idx}=l_translate(str{idx});
        end
    else
        switch str
        case 'auto'
            str=DAStudio.message('Simulink:dialog:auto_CB');
        case 'real'
            str=DAStudio.message('Simulink:dialog:real_CB');
        case 'complex'
            str=DAStudio.message('Simulink:dialog:complex_CB');
        case 'N/A'
            str=DAStudio.message('Simulink:dialog:NA_CB');
        case 'Fixed'
            str=DAStudio.message('Simulink:dialog:Fixed_CB');
        case 'Variable'
            str=DAStudio.message('Simulink:dialog:Variable_CB');
        case 'Frame based'
            str=DAStudio.message('Simulink:dialog:Frame_based_CB');
        case 'Sample based'
            str=DAStudio.message('Simulink:dialog:Sample_based_CB');
        otherwise
            assert(false,'Unexpected string for translation');
        end
    end
end

