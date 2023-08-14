function dlgstruct=structelementddg(h,name,isBus)











    if(nargin==2)
        isBus=false;
    end

    rowIdx=1;
    nameWidget.Name=DAStudio.message('Simulink:dialog:StructelementNameLblName');
    nameWidget.Type='edit';
    nameWidget.RowSpan=[rowIdx,rowIdx];
    nameWidget.ColSpan=[1,4];
    nameWidget.Tag='name_tag';
    nameWidget.ObjectProperty='Name';

    openDialogs=DAStudio.ToolRoot.getOpenDialogs;
    thisDialog=[];
    dlgTitle=[class(h),': ',name];
    for i=1:numel(openDialogs)
        if strcmp(openDialogs(i).getTitle,dlgTitle)
            thisDialog=openDialogs(i);
            break;
        end
    end


    rowIdx=rowIdx+2;


    dimLbl.Name=DAStudio.message('dastudio:ddg:WSODimensions');
    dimLbl.Type='text';
    dimLbl.RowSpan=[rowIdx,rowIdx];
    dimLbl.ColSpan=[1,1];
    dimLbl.Tag='DimLbl';

    dim.Name=dimLbl.Name;
    dim.HideName=1;
    dim.RowSpan=[rowIdx,rowIdx];
    dim.ColSpan=[2,2];
    dim.Type='edit';
    dim.Tag='dim_tag';
    dim.ObjectProperty='Dimensions';


    complexLbl.Name=DAStudio.message('Simulink:dialog:StructelementComplexLblName');
    complexLbl.Type='text';
    complexLbl.RowSpan=[rowIdx,rowIdx];
    complexLbl.ColSpan=[3,3];
    complexLbl.Tag='ComplexLbl';

    complex.Name=complexLbl.Name;
    complex.HideName=1;
    complex.RowSpan=[rowIdx,rowIdx];
    complex.ColSpan=[4,4];
    complex.Type='combobox';
    complex.Tag='complex_tag';
    complex.Entries=getPropAllowedValues(h,'Complexity')';
    complex.ObjectProperty='Complexity';
    complex.Mode=1;
    complex.DialogRefresh=1;

    rowIdx=rowIdx+1;


    if(isBus)

        [extraBusWidgets,rowIdx]=buselementwidgets(h,rowIdx);


        minimum=extraBusWidgets{2};
        maximum=extraBusWidgets{4};
        dataTypeItems.scalingMinTag={minimum.Tag};
        dataTypeItems.scalingMaxTag={maximum.Tag};
    end



    dtaOn=false;
    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');
    dataTypeItems.builtinTypes=Simulink.DataTypePrmWidget.getBuiltinListForDataObjects('StructElement');


    dataTypeItems.supportsEnumType=true;
    dataTypeItems.supportsBusType=true;
    dataTypeItems.supportsStringType=true;
    if slfeature('SLValueType')==1
        dataTypeItems.supportsValueTypeType=true;
    end


    dataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(h,...
    'DataType',...
    DAStudio.message('Simulink:dialog:StructelementDatatypeLblName'),...
    'datatypetag',...
    h.DataType,...
    dataTypeItems,...
    dtaOn);
    dataTypeGroup.RowSpan=[2,2];
    dataTypeGroup.ColSpan=[1,4];
    dataTypeGroup.Items{2}.DialogRefresh=true;

    blankWidget.Name='';
    blankWidget.Type='text';
    blankWidget.RowSpan=[rowIdx,rowIdx];
    blankWidget.ColSpan=[1,4];
    blankWidget.Tag='blankWidgetTag';

















    tab1.Name=DAStudio.message('Simulink:dialog:DataTab1Prompt');
    tab1.LayoutGrid=[rowIdx,4];
    tab1.RowStretch=[zeros(1,rowIdx-1),1];
    tab1.ColStretch=[0,1,0,1];
    tab1.Items={nameWidget};
    tab1.Items{end+1}=dataTypeGroup;
    tab1.Items=[tab1.Items,{dimLbl,dim,complexLbl,complex}];

    if isBus
        tab1.Items=[tab1.Items,extraBusWidgets];
    end
    tab1.Items{end+1}=blankWidget;
    tab1.Tag='TabOne';










    if isBus
        [grpAdditional,tab2]=get_additional_prop_grp(h,'BusElement','TabTwo');
    end




    dlgstruct.DialogTitle=dlgTitle;



    if isBus&&~isempty(grpAdditional.Items)
        tabcont.Type='tab';
        tabcont.Tabs={tab1,tab2};
        tabcont.Tag='TabWhole';
        dlgstruct.Items={tabcont};
    else

        dlgstruct.Items=tab1.Items;
        dlgstruct.LayoutGrid=tab1.LayoutGrid;
        dlgstruct.RowStretch=tab1.RowStretch;
        dlgstruct.ColStretch=tab1.ColStretch;
    end


    dlgstruct.Items=remove_duplicate_widget_tags(dlgstruct.Items);

    dlgstruct.HelpMethod='helpview';
    if isBus
        dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_bus_element'};
    else
        dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_struct_element'};
    end








    if(isBus)
        dlgstruct.PostApplyCallback='warnAboutBusElementMinMaxValidity';
        dlgstruct.PostApplyArgs={'%source','%dialog'};
    end
end



function[extraBusWidget,rowIdx]=buselementwidgets(h,rowIdx)


    colDiff=0;


    minimumLbl.Name=DAStudio.message('Simulink:dialog:DataMinimumPrompt');
    minimumLbl.Type='text';
    minimumLbl.RowSpan=[rowIdx,rowIdx];
    minimumLbl.ColSpan=[1,1];
    minimumLbl.Tag='MinimumLbl';

    minimum.Name=minimumLbl.Name;
    minimum.HideName=1;
    minimum.RowSpan=[rowIdx,rowIdx];
    minimum.ColSpan=[2,2];
    minimum.Type='edit';
    minimum.Tag='minimum_tag';
    minimum.ObjectProperty='Min';

    maximumLbl.Name=DAStudio.message('Simulink:dialog:DataMaximumPrompt');
    maximumLbl.Type='text';
    maximumLbl.RowSpan=[rowIdx,rowIdx];
    maximumLbl.ColSpan=[3,3];
    maximumLbl.Tag='MaximumLbl';

    maximum.Name=maximumLbl.Name;
    maximum.HideName=1;
    maximum.RowSpan=[rowIdx,rowIdx];
    maximum.ColSpan=[4,4];
    maximum.Type='edit';
    maximum.Tag='maximum_tag';
    maximum.ObjectProperty='Max';

    rowIdx=rowIdx+1;

    samptimeLbl.Name=DAStudio.message('Simulink:dialog:BuselementSamptimeLblName');
    samptimeLbl.Type='text';
    samptimeLbl.RowSpan=[rowIdx,rowIdx];
    samptimeLbl.ColSpan=[1,1];
    samptimeLbl.Tag='SamptimeLbl';

    samptime.Name=samptimeLbl.Name;
    samptime.HideName=1;
    samptime.RowSpan=[rowIdx,rowIdx];
    samptime.ColSpan=[2,2];
    samptime.Type='edit';
    samptime.Tag='samptime_tag';
    samptime.ObjectProperty='SampleTime';


    if(sl('busUtils','BusElementSampleTime')==1)
        colDiff=2;
    end

    sampmodeLbl.Name=DAStudio.message('Simulink:dialog:BuselementSampmodeLblName');
    sampmodeLbl.Type='text';
    sampmodeLbl.RowSpan=[rowIdx,rowIdx];
    sampmodeLbl.ColSpan=[3-colDiff,3-colDiff];
    sampmodeLbl.Tag='SampmodeLbl';

    sampmode.Name=sampmodeLbl.Name;
    sampmode.HideName=1;
    sampmode.RowSpan=[rowIdx,rowIdx];
    sampmode.ColSpan=[4-colDiff,4-colDiff];
    sampmode.Type='combobox';
    sampmode.Tag='sampmode_tag';
    sampmode.Entries=getPropAllowedValues(h,'SamplingMode')';
    sampmode.ObjectProperty='SamplingMode';
    sampmode.Mode=1;
    sampmode.DialogRefresh=1;

    if(sl('busUtils','BusElementSampleTime')==0)
        rowIdx=rowIdx+1;
    end



    samptimeWidget=[];
    if(sl('busUtils','BusElementSampleTime')==0)
        samptimeWidget={samptimeLbl,samptime};
    end
    extraBusWidget=[{minimumLbl,minimum,maximumLbl,maximum},samptimeWidget,...
    {sampmodeLbl,sampmode}];


    dimsmodeLbl.Name=DAStudio.message('Simulink:dialog:BuselementDimsmodeLblName');
    dimsmodeLbl.Type='text';
    dimsmodeLbl.RowSpan=[rowIdx,rowIdx];
    dimsmodeLbl.ColSpan=[1+colDiff,1+colDiff];
    dimsmodeLbl.Tag='DimsmodeLbl';

    dimsmode.Name='';
    dimsmode.RowSpan=[rowIdx,rowIdx];
    dimsmode.ColSpan=[2+colDiff,2+colDiff];
    dimsmode.Type='combobox';
    dimsmode.Tag='dimsmode_tag';
    dimsmode.Entries=getPropAllowedValues(h,'DimensionsMode')';
    dimsmode.ObjectProperty='DimensionsMode';
    dimsmode.Mode=1;
    dimsmode.DialogRefresh=1;

    if(sl('busUtils','BusElementSampleTime')==1)
        rowIdx=rowIdx+1;
    end

    extraBusWidget={extraBusWidget{:},dimsmodeLbl,dimsmode};%#ok


    unitLbl.Name=DAStudio.message('Simulink:dialog:DataUnitPrompt');
    unitLbl.Type='text';
    unitLbl.RowSpan=[rowIdx,rowIdx];
    unitLbl.ColSpan=[3-colDiff,3-colDiff];
    unitLbl.Tag='UnitsLbl';

    unitVal.Name=unitLbl.Name;
    unitVal.HideName=1;
    unitVal.RowSpan=[rowIdx,rowIdx];
    unitVal.ColSpan=[4-colDiff,4-colDiff];
    unitVal.Type='edit';
    unitVal.ToolTip=DAStudio.message('Simulink:dialog:DataUnitToolTip');
    unitVal.Value=h.getPropValue('Unit');
    unitVal.Tag='Unit';
    unitVal.AutoCompleteType='Custom';
    symbolPromptStr=[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnSymbolPrompt'),'                 '];
    namePromptStr=[DAStudio.message('Simulink:dialog:UnitsAutoCompleteViewColumnNamePrompt'),'              '];
    unitVal.AutoCompleteViewColumn={' ',symbolPromptStr,namePromptStr};
    unitVal.AutoCompleteCompletionMode='UnfilteredPopupCompletion';


    isBusType=regexpi(h.DataType,'^Bus:','match');
    if(~isempty(isBusType))
        unitVal.Enabled=false;
    else
        unitVal.Enabled=true;
    end

    rowIdx=rowIdx+1;


    descVal.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    descVal.Type='editarea';
    descVal.RowSpan=[rowIdx,rowIdx];
    descVal.ColSpan=[1,4];
    descVal.Tag='description_tag';
    descVal.ObjectProperty='Description';

    extraBusWidget={extraBusWidget{:},...
    unitLbl,unitVal,descVal};%#ok

    rowIdx=rowIdx+1;
end


