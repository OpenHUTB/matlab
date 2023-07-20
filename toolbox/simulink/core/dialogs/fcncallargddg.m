function dlgstruct=fcncallargddg(h,name,rowIdx)










    if nargin<3
        rowIdx=1;
    end

    nameLbl.Name=DAStudio.message('Simulink:dialog:StructelementNameLblName');
    nameLbl.Type='text';
    nameLbl.RowSpan=[rowIdx,rowIdx];
    nameLbl.ColSpan=[1,1];
    nameLbl.Tag='NameLbl';

    nameVal.Name=nameLbl.Name;
    nameVal.HideName=1;
    nameVal.RowSpan=[rowIdx,rowIdx];
    nameVal.ColSpan=[2,4];
    nameVal.Type='edit';
    nameVal.Tag='name_tag';
    nameVal.ObjectProperty='Name';


    rowIdx=rowIdx+2;


    dimLbl.Name=DAStudio.message('Simulink:dialog:StructelementDimLblName');
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
    complex.Entries={'auto';'real';'complex'};
    complex.ObjectProperty='Complexity';
    complex.DialogRefresh=1;

    rowIdx=rowIdx+1;


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


    allowedVals={'double',...
    'single',...
    'int8',...
    'uint8',...
    'int16',...
    'uint16',...
    'int32',...
    'uint32',...
    'boolean',...
    'fixdt(1,16,0)',...
    'fixdt(1,16,2^0,0)',...
    'Enum: <class name>',...
    'Bus: <object name>'};

    dataTypeItems.scalingMinTag={minimum.Tag};
    dataTypeItems.scalingMaxTag={maximum.Tag};



    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');



    for idx=length(allowedVals):-1:1
        if~isempty(findstr('fixdt',allowedVals{idx}))||...
            ~isempty(findstr(':',allowedVals{idx}))

            allowedVals(idx)=[];
        else

            break;
        end
    end
    dataTypeItems.builtinTypes=allowedVals;


    dataTypeItems.supportsEnumType=true;
    dataTypeItems.supportsBusType=true;


    dataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(h,...
    'DataType',...
    DAStudio.message('Simulink:dialog:StructelementDatatypeLblName'),...
    'datatypetag',...
    h.DataType,...
    dataTypeItems,...
    false);

    dataTypeGroup.RowSpan=[2,2];
    dataTypeGroup.ColSpan=[1,4];
    blankWidget.Name='';
    blankWidget.Type='text';
    blankWidget.RowSpan=[rowIdx,rowIdx];
    blankWidget.ColSpan=[1,4];
    blankWidget.Tag='blankWidgetTag';




    dlgstruct.DialogTitle=[class(h),': ',name];

    dlgstruct.Items={nameLbl,nameVal};

    dlgstruct.Items{end+1}=dataTypeGroup;

    dlgstruct.Items=[dlgstruct.Items,{dimLbl,dim,complexLbl,complex,minimumLbl,minimum,maximumLbl,maximum}];

    dlgstruct.Items{end+1}=blankWidget;

    dlgstruct.LayoutGrid=[rowIdx,4];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_functioncall_argument'};
    dlgstruct.ColStretch=[0,1,0,1];
    dlgstruct.RowStretch=[zeros(1,(rowIdx-1)),1];
    dlgstruct.PostApplyCallback='fcncallarg_postapply_cb';
    dlgstruct.PostApplyArgs={'%dialog','%source'};
