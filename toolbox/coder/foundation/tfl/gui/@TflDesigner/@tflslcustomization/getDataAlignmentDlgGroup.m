function dataalignspecgroup=getDataAlignmentDlgGroup(this,count)






    aligntypeLbl.Name=DAStudio.message('RTW:tfldesigner:AlignmentType');
    aligntypeLbl.Type='text';
    aligntypeLbl.RowSpan=[1,1];
    aligntypeLbl.ColSpan=[1,1];
    aligntypeLbl.ToolTip=DAStudio.message('RTW:tfldesigner:AlignmentTypeTooltip');

    aligntype.Type='listbox';
    aligntype.Entries={'DATA_ALIGNMENT_LOCAL_VAR',...
    'DATA_ALIGNMENT_STRUCT_FIELD',...
    'DATA_ALIGNMENT_WHOLE_STRUCT',...
    'DATA_ALIGNMENT_GLOBAL_VAR'};
    aligntype.RowSpan=[1,2];
    aligntype.ColSpan=[2,12];
    aligntype.Tag=['Tfldesigner_AlignmentType_',num2str(count)];
    aligntype.MultiSelect=true;
    aligntype.ToolTip=DAStudio.message('RTW:tfldesigner:AlignmentTypeTooltip');
    aligntypeLbl.Buddy=aligntype.Tag;


    alignpositionLbl.Name=DAStudio.message('RTW:tfldesigner:AlignmentPosition');
    alignpositionLbl.Type='text';
    alignpositionLbl.RowSpan=[3,3];
    alignpositionLbl.ColSpan=[1,1];
    alignpositionLbl.ToolTip=DAStudio.message('RTW:tfldesigner:AlignmentPositionTooltip');

    alignposition.Type='combobox';
    alignposition.Entries={'DATA_ALIGNMENT_PREDIRECTIVE',...
    'DATA_ALIGNMENT_POSTDIRECTIVE',...
    'DATA_ALIGNMENT_PRECEDING_STATEMENT',...
    'DATA_ALIGNMENT_FOLLOWING_STATEMENT'};
    alignposition.RowSpan=[3,4];
    alignposition.ColSpan=[2,12];
    alignposition.Tag=['Tfldesigner_AlignmentPosition_',num2str(count)];
    alignposition.ToolTip=DAStudio.message('RTW:tfldesigner:AlignmentPositionTooltip');
    alignpositionLbl.Buddy=alignposition.Tag;


    alignsyntaxLbl.Name=DAStudio.message('RTW:tfldesigner:AlignmentSyntax');
    alignsyntaxLbl.Type='text';
    alignsyntaxLbl.RowSpan=[5,5];
    alignsyntaxLbl.ColSpan=[1,1];
    alignsyntaxLbl.ToolTip=DAStudio.message('RTW:tfldesigner:AlignmentSyntaxTooltip');

    alignsyntax.Type='edit';
    alignsyntax.RowSpan=[5,5];
    alignsyntax.ColSpan=[2,12];
    alignsyntax.Tag=['Tfldesigner_AlignmentSyntax_',num2str(count)];
    alignsyntax.ToolTip=DAStudio.message('RTW:tfldesigner:AlignmentSyntaxTooltip');
    alignsyntaxLbl.Buddy=alignsyntax.Tag;


    supportlangLbl.Name=DAStudio.message('RTW:tfldesigner:SupportLang');
    supportlangLbl.Type='text';
    supportlangLbl.RowSpan=[6,6];
    supportlangLbl.ColSpan=[1,1];
    supportlangLbl.ToolTip=DAStudio.message('RTW:tfldesigner:SupportLangTooltip');

    supportlang.Type='edit';
    supportlang.RowSpan=[6,6];
    supportlang.ColSpan=[2,12];
    supportlang.Tag=['Tfldesigner_SupportLanguages_',num2str(count)];
    supportlang.ToolTip=DAStudio.message('RTW:tfldesigner:SupportLangTooltip');
    supportlangLbl.Buddy=supportlang.Tag;


    s=this.object(count);
    val=cellindex(aligntype.Entries,s.AlignmentType);
    aligntype.Value=val;

    alignposition.Value=s.AlignmentPosition;

    alignsyntax.Value=s.AlignmentSyntaxTemplate;

    supportlangLbl.Value=s.SupportedLanguages;


    dataalignspecpanel.Type='panel';
    dataalignspecpanel.LayoutGrid=[6,12];
    dataalignspecpanel.RowStretch=ones(1,6);
    dataalignspecpanel.ColStretch=ones(1,12);
    dataalignspecpanel.Items={aligntypeLbl,aligntype,alignsyntaxLbl,...
    alignsyntax,alignpositionLbl,alignposition,supportlangLbl,supportlang};


    dataalignspecgroup.Name=[DAStudio.message('RTW:tfldesigner:AlignmentSpecification')...
    ,' ',num2str(count)];
    dataalignspecgroup.Type='group';
    dataalignspecgroup.LayoutGrid=[1,1];
    dataalignspecgroup.RowStretch=ones(1,1);
    dataalignspecgroup.ColStretch=ones(1,1);
    dataalignspecgroup.Items={dataalignspecpanel};



    function val=cellindex(cellA,cellB)
        val=[0,0,0,0];
        if isempty(cellB)
            return;
        end
        for i=1:length(cellB)
            c=strfind(cellA,cellB{i});
            val=val|[c{1}==1,c{2}==1,c{3}==1,c{4}==1];
        end


