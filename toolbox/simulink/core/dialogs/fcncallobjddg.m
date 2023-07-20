function dlgstruct=fcncallobjddg(h,name)








    rowIdx=1;

    nameObjLbl.Name=DAStudio.message('Simulink:dialog:StructelementNameLblName');
    nameObjLbl.Type='text';
    nameObjLbl.RowSpan=[rowIdx,rowIdx];
    nameObjLbl.ColSpan=[1,1];
    nameObjLbl.Tag='obj_name_lbl';

    nameObjVal.Name=nameObjLbl.Name;
    nameObjVal.HideName=1;
    nameObjVal.RowSpan=[rowIdx,rowIdx];
    nameObjVal.ColSpan=[2,4];
    nameObjVal.Type='edit';
    nameObjVal.Tag='obj_name_tag';
    nameObjVal.ObjectProperty='Name';

    rowIdx=rowIdx+1;


    descLbl.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    descLbl.Type='text';
    descLbl.RowSpan=[rowIdx,rowIdx];
    descLbl.ColSpan=[1,1];
    descLbl.Tag='obj_desc_lbl';

    rowIdx=rowIdx+1;

    descVal.Name=descLbl.Name;
    descVal.HideName=1;
    descVal.RowSpan=[rowIdx,rowIdx];
    descVal.ColSpan=[1,4];
    descVal.Type='editarea';
    descVal.Tag='obj_desc_tag';
    descVal.ObjectProperty='Description';
    descVal.Alignment=0;
    descVal.MaximumSize=[1000,50];

    rowIdx=rowIdx+1;



    cache=slInternal('FcnCallEditorCache');

    if isempty(cache)
        argHdl=[];
        inArgIdx=[];
        outArgIdx=[];
    else
        argHdl=cache.Arg;
        if strcmp(cache.ArgType,'input')
            inArgIdx=cache.ArgIdx;
            outArgIdx=[];
        else
            inArgIdx=[];
            outArgIdx=cache.ArgIdx;
        end
    end





    argSrcList=[h.Arguments];
    isCurrObj=0;

    if~isempty(argHdl)
        for cnt=1:length(argSrcList)
            if isArgEqual(argHdl,argSrcList(cnt))
                isCurrObj=1;
                break;
            end
        end
    end

    pnlEnbl=true;
    if(~isCurrObj||isempty(argHdl)||~isa(argHdl,'Simulink.FunctionArgument'))
        if~isempty(h.Arguments)
            argHdl=h.Arguments(1);
        else
            argHdl=Simulink.FunctionArgument;
            argHdl.Name='SampleArg';
            pnlEnbl=false;
        end
    end

    grpNumItems=0;
    grpArgsMain.Items={};
    grpArgsMain.LayoutGrid=[3,2];
    grpArgsMain.Name=DAStudio.message('Simulink:FcnCall:FcnCallArgument');
    grpArgsMain.Type='group';
    grpArgsMain.ColSpan=[1,4];
    grpArgsMain.Tag='grpArgsMain_tag';

    grpNumItems=grpNumItems+1;

    grpArgNumItems=0;
    grpArg.Items={};
    grpArg.LayoutGrid=[3,2];
    grpArg.Type='panel';
    grpArg.RowSpan=[1,1];
    grpArg.ColSpan=[3,6];
    grpArg.Tag='grpArg_tag';

    grpArgNumItems=grpArgNumItems+1;

    nameLbl.Name=DAStudio.message('Simulink:dialog:StructelementNameLblName');
    nameLbl.Type='text';
    nameLbl.RowSpan=[rowIdx,rowIdx];
    nameLbl.ColSpan=[2,2];
    nameLbl.Tag='NameLbl';

    grpArg.Items{grpArgNumItems}=nameLbl;
    grpArgNumItems=grpArgNumItems+1;

    nameVal.Name=nameLbl.Name;
    nameVal.HideName=1;
    nameVal.RowSpan=[rowIdx,rowIdx];
    nameVal.ColSpan=[3,5];
    nameVal.Type='edit';
    nameVal.Tag='name_tag';
    nameVal.ObjectProperty='Name';
    nameVal.Enabled=pnlEnbl;
    nameVal.Source=argHdl;

    grpArg.Items{grpArgNumItems}=nameVal;
    grpArgNumItems=grpArgNumItems+1;

    rowIdx=rowIdx+1;


    dimLbl.Name=DAStudio.message('Simulink:dialog:StructelementDimLblName');
    dimLbl.Type='text';
    dimLbl.RowSpan=[rowIdx,rowIdx];
    dimLbl.ColSpan=[2,2];
    dimLbl.Tag='DimLbl';

    grpArg.Items{grpArgNumItems}=dimLbl;
    grpArgNumItems=grpArgNumItems+1;

    dim.Name=dimLbl.Name;
    dim.HideName=1;
    dim.RowSpan=[rowIdx,rowIdx];
    dim.ColSpan=[3,3];
    dim.Type='edit';
    dim.Tag='dim_tag';
    dim.ObjectProperty='Dimensions';
    dim.Enabled=pnlEnbl;
    dim.Source=argHdl;

    grpArg.Items{grpArgNumItems}=dim;
    grpArgNumItems=grpArgNumItems+1;


    complexLbl.Name=DAStudio.message('Simulink:dialog:StructelementComplexLblName');
    complexLbl.Type='text';
    complexLbl.RowSpan=[rowIdx,rowIdx];
    complexLbl.ColSpan=[4,4];
    complexLbl.Tag='ComplexLbl';

    grpArg.Items{grpArgNumItems}=complexLbl;
    grpArgNumItems=grpArgNumItems+1;

    complex.Name=complexLbl.Name;
    complex.HideName=1;
    complex.RowSpan=[rowIdx,rowIdx];
    complex.ColSpan=[5,5];
    complex.Type='combobox';
    complex.Tag='complex_tag';
    complex.Entries={'auto';'real';'complex'};
    complex.ObjectProperty='Complexity';
    complex.Enabled=pnlEnbl;
    complex.Source=argHdl;

    grpArg.Items{grpArgNumItems}=complex;
    grpArgNumItems=grpArgNumItems+1;
    rowIdx=rowIdx+1;


    minimumLbl.Name=DAStudio.message('Simulink:dialog:DataMinimumPrompt');
    minimumLbl.Type='text';
    minimumLbl.RowSpan=[rowIdx,rowIdx];
    minimumLbl.ColSpan=[2,2];
    minimumLbl.Tag='MinimumLbl';

    grpArg.Items{grpArgNumItems}=minimumLbl;
    grpArgNumItems=grpArgNumItems+1;

    minimum.Name=minimumLbl.Name;
    minimum.HideName=1;
    minimum.RowSpan=[rowIdx,rowIdx];
    minimum.ColSpan=[3,3];
    minimum.Type='edit';
    minimum.Tag='minimum_tag';
    minimum.ObjectProperty='Min';
    minimum.Enabled=pnlEnbl;
    minimum.Source=argHdl;

    grpArg.Items{grpArgNumItems}=minimum;
    grpArgNumItems=grpArgNumItems+1;

    maximumLbl.Name=DAStudio.message('Simulink:dialog:DataMaximumPrompt');
    maximumLbl.Type='text';
    maximumLbl.RowSpan=[rowIdx,rowIdx];
    maximumLbl.ColSpan=[4,4];
    maximumLbl.Tag='MaximumLbl';

    grpArg.Items{grpArgNumItems}=maximumLbl;
    grpArgNumItems=grpArgNumItems+1;

    maximum.Name=maximumLbl.Name;
    maximum.HideName=1;
    maximum.RowSpan=[rowIdx,rowIdx];
    maximum.ColSpan=[5,5];
    maximum.Type='edit';
    maximum.Tag='maximum_tag';
    maximum.ObjectProperty='Max';
    maximum.Enabled=pnlEnbl;
    maximum.Source=argHdl;

    grpArg.Items{grpArgNumItems}=maximum;
    grpArgNumItems=grpArgNumItems+1;

    rowIdx=rowIdx+1;


    allowedVals={'double',...
    'single',...
    'int8',...
    'uint8',...
    'int16',...
    'uint16',...
    'int32',...
    'uint32',...
    'boolean'};

    dataTypeItems.scalingMinTag={minimum.Tag};
    dataTypeItems.scalingMaxTag={maximum.Tag};



    dataTypeItems.scalingModes=Simulink.DataTypePrmWidget.getScalingModeList('BPt_SB');
    dataTypeItems.signModes=Simulink.DataTypePrmWidget.getSignModeList('SignUnsign');



    for idx=length(allowedVals):-1:1
        if~isempty(strfind('fixdt',allowedVals{idx}))||...
            ~isempty(strfind(':',allowedVals{idx}))

            allowedVals(idx)=[];
        else

            break;
        end
    end
    dataTypeItems.builtinTypes=allowedVals;


    dataTypeItems.supportsEnumType=true;
    dataTypeItems.supportsBusType=true;


    dataTypeGroup=Simulink.DataTypePrmWidget.getDataTypeWidget(argHdl,...
    'DataType',...
    DAStudio.message('Simulink:dialog:StructelementDatatypeLblName'),...
    'datatypetag',...
    argHdl.DataType,...
    dataTypeItems,...
    false);

    dataTypeGroup.RowSpan=[rowIdx,rowIdx];
    dataTypeGroup.ColSpan=[2,5];
    dataTypeGroup.Enabled=pnlEnbl;
    dataTypeGroup.Source=argHdl;

    grpArg.Items{grpArgNumItems}=dataTypeGroup;
    grpArg.Flat=1;

    grpArgsMain.Items{grpNumItems}=grpArg;
    grpNumItems=grpNumItems+1;
    rowIdx=rowIdx+1;


    btnGrpMainNumItems=0;
    btnGrpMain.Items={};
    btnGrpMain.ColSpan=[1,1];
    btnGrpMain.RowSpan=[1,5];
    btnGrpMain.Alignment=0;
    btnGrpMain.Type='panel';
    btnGrpMain.Tag='btnGrpMainArgs_tag';
    btnGrpMain.Flat=1;

    btnGrpMainNumItems=btnGrpMainNumItems+1;

    argSelIn.HideName=1;
    argSelIn.RowSpan=[rowIdx,rowIdx];
    argSelIn.ColSpan=[1,1];
    argSelIn.Type='listbox';
    argSelIn.Tag='obj_in_arg_sel_tag';
    argSelIn.Entries={h.Arguments.Name};
    argSelIn.DialogRefresh=1;
    argSelIn.MatlabMethod='fcncallobj_argSel_cb';
    argSelIn.MatlabArgs={argSelIn.Tag,'%dialog','%source'};
    argSelIn.Graphical=true;
    argSelIn.Value=inArgIdx-1;

    btnGrpMain.Items{btnGrpMainNumItems}=argSelIn;
    btnGrpMainNumItems=btnGrpMainNumItems+1;%#ok<*NASGU>

    btnGrpNumItems=0;
    btnGrp.Items={};
    btnGrp.LayoutGrid=[1,4];
    btnGrp.RowSpan=[1,1];
    btnGrp.ColSpan=[2,2];
    btnGrp.Alignment=6;
    btnGrp.Type='panel';
    btnGrp.Tag='btnGrpArgs_tag';
    btnGrp.Flat=1;
    btnGrpNumItems=btnGrpNumItems+1;

    addButton.ToolTip=DAStudio.message('Simulink:busEditor:AddElementTypeText','Function-call Argument');
    addButton.Type='pushbutton';
    addButton.ColSpan=[1,1];
    addButton.RowSpan=[2,2];
    addButton.Enabled=pnlEnbl;
    addButton.MaximumSize=[25,25];
    addButton.MinimumSize=[25,25];
    addButton.FilePath=slprivate('getResourceFilePath','addinsert_buselement.png');
    addButton.Tag='addButton';
    addButton.MatlabMethod='fcncallobj_add_cb';
    addButton.MatlabArgs={'%dialog','%source'};

    btnGrp.Items{btnGrpNumItems}=addButton;
    btnGrpNumItems=btnGrpNumItems+1;

    upButton.ToolTip=DAStudio.message('Simulink:dialog:DDGSource_Bus_Up');
    upButton.Type='pushbutton';
    upButton.ColSpan=[1,1];
    upButton.RowSpan=[3,3];
    upButton.Enabled=pnlEnbl;
    upButton.MaximumSize=[25,25];
    upButton.MinimumSize=[25,25];
    upButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','move_up.gif');
    upButton.Tag='upButton';
    upButton.MatlabMethod='fcncallobj_up_cb';
    upButton.MatlabArgs={'%dialog','%source'};

    btnGrp.Items{btnGrpNumItems}=upButton;
    btnGrpNumItems=btnGrpNumItems+1;

    downButton.ToolTip=DAStudio.message('Simulink:dialog:DDGSource_Bus_Down');
    downButton.Type='pushbutton';
    downButton.ColSpan=[1,1];
    downButton.RowSpan=[4,4];
    downButton.Enabled=pnlEnbl;
    downButton.MaximumSize=[25,25];
    downButton.MinimumSize=[25,25];
    downButton.FilePath=fullfile(matlabroot,'toolbox','shared','dastudio','resources','move_down.gif');
    downButton.Tag='downButton';
    downButton.MatlabMethod='fcncallobj_down_cb';
    downButton.MatlabArgs={'%dialog','%source'};

    btnGrp.Items{btnGrpNumItems}=downButton;
    btnGrpNumItems=btnGrpNumItems+1;

    removeButton.ToolTip=DAStudio.message('Simulink:dialog:DDGSource_Bus_Remove');
    removeButton.Type='pushbutton';
    removeButton.ColSpan=[1,1];
    removeButton.RowSpan=[5,5];
    removeButton.Enabled=pnlEnbl;
    removeButton.MaximumSize=[25,25];
    removeButton.MinimumSize=[25,25];
    removeButton.FilePath=slprivate('getResourceFilePath','delete.png');
    removeButton.Tag='removeButton';
    removeButton.MatlabMethod='fcncallobj_remove_cb';
    removeButton.MatlabArgs={'%dialog','%source'};

    btnGrp.Items{btnGrpNumItems}=removeButton;




    rowIdx=rowIdx+1;

    grpArgsMain.Items{grpNumItems}=btnGrpMain;
    grpNumItems=grpNumItems+1;
    grpArgsMain.Items{grpNumItems}=btnGrp;

    grpArgsMain.RowSpan=[4,6];


    rowIdx=rowIdx+1;

    blankWidget.Name='';
    blankWidget.Type='text';
    blankWidget.RowSpan=[rowIdx,rowIdx];
    blankWidget.ColSpan=[1,4];
    blankWidget.Tag='blankWidgetTag';




    dlgstruct.DialogTitle=[class(h),': ',name];
    dlgstruct.Items={nameObjLbl,nameObjVal,descLbl,descVal,grpArgsMain};
    dlgstruct.Items{end+1}=blankWidget;
    dlgstruct.LayoutGrid=[rowIdx,4];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_functioncall_object'};
    dlgstruct.ColStretch=[0,1,0,1];
    dlgstruct.RowStretch=[zeros(1,(rowIdx-1)),1];
    dlgstruct.OpenCallback=@fcncallobj_open_cb;
    dlgstruct.CloseCallback='fcncallobj_close_cb';
    dlgstruct.CloseArgs={'%dialog'};
    dlgstruct.PostApplyCallback='fcncallobj_postapply_cb';
    dlgstruct.PostApplyArgs={'%dialog','%source'};





    function equality=isArgEqual(arg1,arg2)



        if(isequal(arg1.Name,arg2.Name)&&...
            isequal(arg1.Dimensions,arg2.Dimensions)&&...
            isequal(arg1.DataType,arg2.DataType)&&...
            isequal(arg1.Complexity,arg2.Complexity)&&...
            isequal(arg1.Min,arg2.Min)&&...
            isequal(arg1.Max,arg2.Max))
            equality=true;
        else
            equality=false;
        end


