function widget=createDialogWidget(handle,widgetTag)







    widgetNode=TflDesigner.widgetnode;
    widgetNode.Tag=widgetTag;
    widgetNode.Source=handle;
    switch widgetTag
    case 'Tfldesigner_Key'
        if isa(handle.object,'RTW.TflCOperationEntry')
            widgetNode.Name=DAStudio.message('RTW:tfldesigner:OperationKeyText');
        else
            widgetNode.Name=DAStudio.message('RTW:tfldesigner:FunctionKeyText');
        end
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getkeyentries;
        widgetNode.Source=handle;
        widgetNode.Value=[];
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
    case 'Tfldesigner_CustomFunc'
        widgetNode.Type='edit';
        widgetNode.Source=handle;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
    case{'Tfldesigner_AlgorithmInfo',...
        'Tfldesigner_FIR2D_OutputMode'}
        widgetNode.Type='combobox';
        widgetNode.Source=handle;
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case{'Tfldesigner_AddMinusAlgorithm'}
        widgetNode.Type='combobox';
        widgetNode.Source=handle;
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case{'Tfldesigner_FIR2D_NumInRows',...
        'Tfldesigner_FIR2D_NumInCols',...
        'Tfldesigner_FIR2D_NumOutRows',...
        'Tfldesigner_FIR2D_NumOutCols',...
        'Tfldesigner_FIR2D_NumMaskRows',...
        'Tfldesigner_FIR2D_NumMaskCols',...
        'Tfldesigner_CONVCORR1D_NumIn1Rows',...
'Tfldesigner_CONVCORR1D_NumIn2Rows'...
        }
        widgetNode.Type='edit';
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_LOOKUP_SearchMethod'
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_LOOKUP_Search');
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_LOOKUP_IntrpMethod'
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_LOOKUP_Interp');
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_LOOKUP_ExtrpMethod'
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_LOOKUP_Extrp');
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_TIMER_CountDirection'
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_TIMER_CountDirection');
        widgetNode.Source=handle;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:CountDirTooltip');
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_TIMER_Ticks'
        widgetNode.Type='edit';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:TicksTooltip');
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_ActiveConceptArg'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ConceptualArgText');
        widgetNode.Type='listbox';
        widgetNode.Entries=handle.getconceptualarglist;
        widgetNode.MultiSelect=false;
        widgetNode.Source=handle;
        widgetNode.Value=handle.activeconceptarg-1;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ConceptualArglistTooltip');
    case 'Tfldesigner_Addargpushbutton'
        widgetNode.Name='+';
        widgetNode.Type='pushbutton';
        widgetNode.Tag='Tfldesigner_Addargpushbutton';
        widgetNode.Enabled=false;
        widgetNode.Visible=false;
        widgetNode.ObjectMethod='addconceptualarg';
        widgetNode.Source=handle;
        widgetNode.DialogRefresh=false;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AddConceptualArgTooltip');
    case 'Tfldesigner_Removeargpushbutton'
        widgetNode.Type='pushbutton';
        widgetNode.Enabled=false;
        widgetNode.Visible=false;
        widgetNode.ObjectMethod='removeconceptualarg';
        widgetNode.Source=handle;
        widgetNode.DialogRefresh=false;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:RemoveConceptualArgTooltip');
    case 'Tfldesigner_customclassbutton'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:EditButtonLabel');
        widgetNode.Type='pushbutton';
        widgetNode.Enabled=false;
        widgetNode.Visible=false;
        widgetNode.Source=handle;
        widgetNode.ObjectMethod='opencustomdeffile';
        widgetNode.DialogRefresh=true;
    case 'Tfldesigner_DataType'
        widgetNode=handle.createconceptualDTAwidget(widgetTag);
    case 'Tfldesigner_ConceptIOType'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:IOTypeText');
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_IOType');
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:CIOTypeTooltip');
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
    case 'Tfldesigner_Complex'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ComplexText');
        widgetNode.Type='checkbox';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ComplexSignalTooltip');
    case 'Tfldesigner_isMatrixPointer'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ArgumentTypeText');
        widgetNode.Type='combobox';
        widgetNode.Tag='Tfldesigner_isMatrixPointer';
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
        widgetNode.Value=handle.argtype;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:SignalTypeTooltip');
    case 'Tfldesigner_LowerDim'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:LowerDimRangeText');
        widgetNode.Type='edit';
        widgetNode.Visible=handle.argtype;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:LowerDimTooltip');
    case 'Tfldesigner_UpperDim'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:UpperDimRangeText');
        widgetNode.Type='edit';
        widgetNode.Visible=handle.argtype;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:UpperDimTooltip');

    case 'Tfldesigner_StructName'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:StructNameText');
        widgetNode.Type='edit';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:StructNameTooltip');
    case 'Tfldesigner_StructElements'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:StructFieldText');
        widgetNode.Type='table';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:StructFieldTooltip');

    case 'Tfldesigner_CopyConcepArgSettings'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:MakeConceptualImplArgSame');
        widgetNode.Type='checkbox';
        widgetNode.Value=handle.copyconcepargsettings>2;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:MakeConceptualImplArgSameTooltip');
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
        widgetNode.Source=handle;
    case 'Tfldesigner_DWorkAllocatorCheck'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:DWorkAllocatorText');
        widgetNode.Type='checkbox';
        widgetNode.Value=handle.allocatesdwork;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:DWorkAllocatorCheckTooltip');
    case 'Tfldesigner_DWorkEntryTag'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:DWorkEntryTag');
        widgetNode.Type='edit';
        widgetNode.Value=handle.object.EntryTag;
    case 'Tfldesigner_ActiveDWorkArg'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:DWorkArgText');
        widgetNode.Type='listbox';
        widgetNode.Entries=handle.getdworkarglist;
        widgetNode.MultiSelect=false;
        widgetNode.Source=handle;
        widgetNode.Value=handle.activedworkarg-1;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:DWorkArglistTooltip');
    case 'Tfldesigner_DWorkDataType'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:DataTypeText');
        widgetNode.Type='edit';
        widgetNode.Value='void';
        widgetNode.Enabled=false;
    case 'Tfldesigner_DWorkPointerDesc'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:PointerText');
        widgetNode.Type='checkbox';
        widgetNode.Value=true;
        widgetNode.Enabled=false;
    case 'Tfldesigner_DWorkAllocatorEntry'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:DWorkAllocatorEntry');
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getdworkallocatorentries;
        widgetNode.Source=handle;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
        widgetNode.Value=[];
    case 'Tfldesigner_Implementationname'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ImplNameText');
        widgetNode.Type='edit';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ImplFunctionNameTooltip');
        widgetNode.Source=handle;
        widgetNode.Value=handle.object.Implementation.Name;
    case 'Tfldesigner_namespace'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:CPPNamespaceText');
        widgetNode.Type='edit';
        widgetNode.Source=handle;
        widgetNode.Value='';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:NamespaceTooltip');
    case 'Tfldesigner_functionreturnvoid'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:VoidFunctionText');
        widgetNode.Type='checkbox';
        widgetNode.Value=strcmp(handle.returnargname,'unused');
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:VoidFunctionTooltip');
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
    case 'Tfldesigner_blaslevel'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:BlasLevelText');
        widgetNode.Type='combobox';
        widgetNode.Entries={'None','2 (vector)','3 (matrix)'};
        widgetNode.Source=handle;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
        widgetNode.Value=0;
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_ImplfuncArglist'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:FunctionArgListText');
        widgetNode.Type='listbox';
        widgetNode.Value=handle.activeimplarg;
        widgetNode.MultiSelect=false;
        widgetNode.Source=handle;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.DialogRefresh=true;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ImplArgListTooltip');
    case 'Tfldesigner_UpArgbutton'
        widgetNode.Type='pushbutton';
        widgetNode.Enabled=false;
        widgetNode.ObjectMethod='movearg';
        widgetNode.MethodArgs={'%dialog','Tfldesigner_UpArgbutton'};
        widgetNode.ArgDataTypes={'handle','string'};
        widgetNode.DialogRefresh=true;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ReorderupTooltip');
    case 'Tfldesigner_DownArgbutton'
        widgetNode.Type='pushbutton';
        widgetNode.Enabled=false;
        widgetNode.ObjectMethod='movearg';
        widgetNode.MethodArgs={'%dialog','Tfldesigner_DownArgbutton'};
        widgetNode.ArgDataTypes={'handle','string'};
        widgetNode.DialogRefresh=true;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ReorderdownTooltip');
    case 'Tfldesigner_AddargpushbuttonImpl'
        widgetNode.Name='+';
        widgetNode.Type='pushbutton';
        widgetNode.Enabled=false;
        widgetNode.Visible=true;
        widgetNode.ObjectMethod='addimplarg';
        widgetNode.DialogRefresh=true;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AddArgumentTooltip');
    case 'Tfldesigner_RemoveargpushbuttonImpl'
        widgetNode.Type='pushbutton';
        widgetNode.Enabled=false;
        widgetNode.Visible=true;
        widgetNode.ObjectMethod='removeimplarg';
        widgetNode.DialogRefresh=true;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:RemoveSelectedArgTooltip');
    case 'Tfldesigner_ImplDatatype'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ImplDataTypeText');
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_ImplDatatype');
        widgetNode.Source=handle;
        widgetNode.DialogRefresh=true;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:FunctionArgDatatypeTooltip');





        dtypeentries=handle.getentries('Tfldesigner_ImplDatatype');
        dlghandle=TflDesigner.getdialoghandle;
        if~isempty(dlghandle)&&dlghandle.hasUnappliedChanges
            handle.iargdtypeunapplied=...
            dtypeentries{dlghandle.getWidgetValue('Tfldesigner_ImplDatatype')+1};
        else
            implarg=hGetActiveImplArg(handle);
            if~isempty(implarg)
                handle.iargdtypeunapplied=implarg.toString(true);
            else
                handle.iargdtypeunapplied='';
            end
        end
    case 'Tfldesigner_ImplIOType'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:IOTypeText');
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_IOType');
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:IOTypeTooltip');
        widgetNode.Enabled=false;
    case 'Tfldesigner_Readonly'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ReadOnlyText');
        widgetNode.Type='checkbox';
    case 'Tfldesigner_ispointer'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:PointerText');
        widgetNode.Type='checkbox';
        widgetNode.Value=false;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:PointerArgTooltip');
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
    case 'Tfldesigner_ispointerpointer'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:PointerPointerText');
        widgetNode.Type='checkbox';
        widgetNode.Value=false;
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:PointerPointerArgTooltip');
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
    case 'Tfldesigner_isargcomplex'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ComplexText');
        widgetNode.Type='checkbox';
        widgetNode.Value=false;
        widgetNode.Visible=true;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ComplexArgTooltip');
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};

    case 'Tfldesigner_ImplStructName'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:StructNameText');
        widgetNode.Type='edit';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:StructNameTooltip');
    case 'Tfldesigner_ImplStructElements'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:StructFieldText');
        widgetNode.Type='table';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:StructFieldTooltip');

    case 'Tfldesigner_DataAlignment'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:DataAlignmentText');
        widgetNode.Type='edit';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:DataAlignTooltip');
        widgetNode.Visible=handle.showdataalign;
    case 'Tfldesigner_makeconstant'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:MakeConstantValue');
        widgetNode.Type='checkbox';
        widgetNode.Value=handle.makeimplargconstant;
        widgetNode.DialogRefresh=true;
        widgetNode.Visible=true;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:MakeConstantTooltip');
    case 'Tfldesigner_Initialvalue'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:InitialValueText');
        widgetNode.Type='edit';
        widgetNode.Value='0';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:InitialValTooltip');
    case 'Tfldesigner_Passbytype'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:PassByTypeText');
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_PassbyType');
        widgetNode.Value=0;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:PassByTypeTooltip');
    case 'Tfldesigner_ImplFcnPreview'
        widgetNode.Name='';
        widgetNode.Type='text';
        widgetNode.Tag='Tfldesigner_ImplFcnPreview';
    case 'Tfldesigner_SaturationMode'
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_SaturationMode');
        widgetNode.Value=handle.getEnumString(handle.object.SaturationMode);
        widgetNode.Source=handle;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:SaturationModeTooltip');
    case 'Tfldesigner_RoundingMode'
        widgetNode.Type='listbox';
        widgetNode.Entries=handle.getentries('Tfldesigner_RoundingMode');
        widgetNode.Value=cellindex(handle,handle.getentries('Tfldesigner_RoundingMode'),...
        handle.object.RoundingModes);
        widgetNode.MultiSelect=true;
        widgetNode.Source=handle;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:RoundingModeTooltip');
    case 'Tfldesigner_ExprInput'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:AllowExpressionInputText');
        widgetNode.Type='checkbox';
        widgetNode.Value=handle.object.AcceptExprInput;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ExprInputTooltip');
    case 'Tfldesigner_SideEffects'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:SideEffectText');
        widgetNode.Type='checkbox';
        widgetNode.Value=handle.object.SideEffects;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:SideEffectsTooltip');
    case 'Tfldesigner_FLmustbesame'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:FractionLengthSameText');
        widgetNode.Type='checkbox';
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_Netslopeadjustfac'
        widgetNode.Type='edit';
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_Netfixedexponent'
        widgetNode.Type='edit';
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_SameSlopeFunction'
        widgetNode.Type='checkbox';
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_SameBiasFunction'
        widgetNode.Type='checkbox';
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_buildinfoHyperlink'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:BuildInfoLinkText');
        widgetNode.Type='hyperlink';
        widgetNode.ToolTip='Navigate to Build Information tab';
        widgetNode.Tag='Tfldesigner_buildinfoHyperlink';
        widgetNode.DialogRefresh=1;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
    case 'Tfldesigner_InlineFcn'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:InlineFuncText');
        widgetNode.Type='checkbox';
        widgetNode.Tag='Tfldesigner_InlineFcn';
        widgetNode.Visible=false;
    case 'Tfldesigner_Precise'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:PreciseText');
        widgetNode.Type='checkbox';
        widgetNode.Visible=false;
    case 'Tfldesigner_SupportNonFinite'
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_SupportNonFinite');
        widgetNode.Visible=false;
    case 'Tfldesigner_EMLCallback'
        widgetNode.Type='edit';
        widgetNode.Visible=false;
    case 'Tfldesigner_ValidateStatus'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:StatusText');
        widgetNode.Type='text';
    case 'Tfldesigner_errorLogHyperlink'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:CheckErroLogDetailsText');
        widgetNode.Type='hyperlink';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ShowErrorTooltip');
        widgetNode.DialogRefresh=1;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
        widgetNode.Visible=false;
    case 'Tfldesigner_ValidateStatusDesc'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:NotValidText');
        widgetNode.Type='text';
        widgetNode.Visible=false;
    case 'Tfldesigner_InvalidStatusDesc'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:InvalidText');
        widgetNode.Type='text';
        widgetNode.Visible=false;
    case 'Tfldesigner_ValidStatusDesc'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ValidatedText');
        widgetNode.Type='text';
        widgetNode.Visible=false;
    case 'Tfldesigner_WarningStatusDesc'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:WarningText');
        widgetNode.Type='text';
        widgetNode.Visible=false;
    case 'Tfldesigner_Validatepushbutton'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ValidateEntryText');
        widgetNode.Type='pushbutton';
        widgetNode.Enabled=true;
        widgetNode.Visible=true;
        widgetNode.ObjectMethod='validateEntry';
        widgetNode.MethodArgs={'%dialog'};
        widgetNode.ArgDataTypes={'handle'};
        widgetNode.DialogRefresh=1;

    case 'Tfldesigner_AngleUnit_AlgoParam'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:AngleUnit');
        widgetNode.Type='edit';
        widgetNode.Enabled=false;
        widgetNode.Visible=false;


    case{'Tfldesigner_IntrpMethod_AlgoParam','Tfldesigner_ExtrpMethod_AlgoParam',...
        'Tfldesigner_IndexSearchMethod','Tfldesigner_UseLastTableValue',...
        'Tfldesigner_RemoveProtection','Tfldesigner_RemoveProtectionIndex',...
        'Tfldesigner_ValidIndexReachLast','Tfldesigner_SupportTunableTable',...
        'Tfldesigner_InputSelectObjectTable','Tfldesigner_UseLastBreakpoint',...
        'Tfldesigner_BeginIndexSearchUsingPreviousIndexResult',...
        'Tfldesigner_SatMethod','Tfldesigner_RoundMethod','Tfldesigner_UseRowMajorAlgorithm'}
        widgetNode.Type='edit';
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case{'Tfldesigner_TableDimension'}
        widgetNode.Type='edit';
        widgetNode.Visible=false;
        widgetNode.Enabled=false;
    case 'Tfldesigner_InPlaceArg'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:InplaceText');
        widgetNode.Type='combobox';
        widgetNode.Visible=false;
        widgetNode.Enable=false;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:InplaceTooltip');
        widgetNode.DialogRefresh=1;
        widgetNode.ObjectMethod='setproperties';
        widgetNode.MethodArgs={'%dialog',{widgetNode.Tag}};
        widgetNode.ArgDataTypes={'handle','mxArray'};
    case 'Tfldesigner_ArrayLayout'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:ArrayLayoutText');
        widgetNode.Type='combobox';
        widgetNode.Entries=handle.getentries('Tfldesigner_ArrayLayout');
        widgetNode.Value=handle.getEnumString(handle.object.ArrayLayout);
        widgetNode.Source=handle;
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:ArrayLayoutTooltip');
        widgetNode.Visible=false;
        widgetNode.Enable=false;
    case 'Tfldesigner_AllowShapeAgnosticMatch'
        widgetNode.Name=DAStudio.message('RTW:tfldesigner:AllowShapeAgnosticMatchText');
        widgetNode.Type='checkbox';
        widgetNode.ToolTip=DAStudio.message('RTW:tfldesigner:AllowShapeAgnosticMatchTooltip');
        widgetNode.Value=false;
        widgetNode.Visible=false;
        widgetNode.Enable=false;
    otherwise
        error(['Error creating widget: ''',widgetTag,''' widget tag not found']);
    end


    if isempty(handle.widgetStructList)
        handle.widgetStructList=widgetNode;
        handle.widgetTagList={widgetTag};
    else
        handle.widgetStructList(end+1)=widgetNode;
        handle.widgetTagList{end+1}=widgetTag;
    end
    widget=widgetNode;
end





function val=cellindex(this,cellA,cellB)
    val=[];
    for i=1:length(cellB)
        c=find(strcmp(cellA,this.getEnumString(cellB{i})),1)-1;
        val=[val,c];%#ok
    end
end


function implarg=hGetActiveImplArg(this)


    index=this.activeimplarg;
    implarg=[];

    if index==0&&~isempty(this.object.Implementation.Return)
        implarg=this.object.Implementation.Return;
    else

        if index~=0&&~isempty(this.object.Implementation.Arguments)
            implarg=this.object.Implementation.Arguments(index);
        end
    end
end

