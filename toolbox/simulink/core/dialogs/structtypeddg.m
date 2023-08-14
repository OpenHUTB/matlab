function dlgstruct=structtypeddg(h,name)









    rowIdx=0;

    DA_TABLE_SUPPORT=1;

    if(DA_TABLE_SUPPORT)






        rowIdx=rowIdx+1;
        tableData={};
        if~isempty(h.Elements)
            tableData=cell(length(h.Elements),4);
            for i=1:length(h.Elements)
                val=h.Elements(i);
                tableData{i,1}=val.Name;
                tableData{i,2}=num2str(val.Dimensions);
                tableData{i,3}=val.DataType;
                tableData{i,4}=val.Complexity;
            end
        end

        structtable.Type='table';
        structtable.Tag='StructElements';
        structtable.Size=[length(h.Elements),4];
        structtable.Grid=1;
        structtable.HeaderVisibility=[0,1];
        structtable.ColHeader={DAStudio.message('Simulink:dialog:StructtypeStructtableColHeaderName'),...
        DAStudio.message('Simulink:dialog:StructtypeStructtableColHeaderDimension'),...
        DAStudio.message('Simulink:dialog:StructtypeStructtableColHeaderDataBusType'),...
        DAStudio.message('Simulink:dialog:StructtypeStructtableColHeaderComplexity')};
        structtable.Enabled=0;
        structtable.Data=tableData;

        elementsgrp.Name=DAStudio.message('Simulink:dialog:StructtypeElementsgrpName');
        elementsgrp.RowSpan=[rowIdx,rowIdx];
        elementsgrp.ColSpan=[1,2];
        elementsgrp.Type='group';
        elementsgrp.Flat=1;
        elementsgrp.Items={structtable};
        elementsgrp.Tag='Elementsgrp';

    else





        rowIdx=rowIdx+1;
        elementsLbl.Name=DAStudio.message('Simulink:dialog:StructtypeElementsLblName');
        elementsLbl.RowSpan=[rowIdx,rowIdx];
        elementsLbl.ColSpan=[1,1];
        elementsLbl.Type='text';
        elementsLbl.Tag='ElementsLbl';

        elementsVal.RowSpan=[1,1];
        elementsVal.ColSpan=[2,2];
        elementsVal.Type='text';
        elementsVal.Tag='ElementsVal';

        if~isempty(h.Elements)
            val='';
            for i=1:length(h.Elements)
                val=[val,h.Elements(i).Name,' '];
            end;
            elementsVal.Name=val;
        else
            elementsVal.Name=DAStudio.message('Simulink:dialog:StructtypeElementsValNameEmpty');
            elementsVal.Italic=1;
        end

    end





    grpNumItems=0;
    grpCodeGen.Items={};





    grpNumItems=grpNumItems+1;
    dataScope.Name=DAStudio.message('Simulink:dialog:StructtypeDataScopeLblName');
    dataScope.RowSpan=[1,1];
    dataScope.ColSpan=[1,2];
    dataScope.Type='combobox';
    dataScope.Entries=h.getPropAllowedValues('DataScope')';
    dataScope.Tag='codeLocation_tag';
    dataScope.ObjectProperty='DataScope';
    grpCodeGen.Items{grpNumItems}=dataScope;





    grpNumItems=grpNumItems+1;
    headerFile.Name=DAStudio.message('Simulink:dialog:StructtypeHeaderFileLblName');
    headerFile.RowSpan=[2,2];
    headerFile.ColSpan=[1,2];
    headerFile.Type='edit';
    headerFile.Tag='headerFile_tag';
    headerFile.ObjectProperty='HeaderFile';
    grpCodeGen.Items{grpNumItems}=headerFile;





    grpNumItems=grpNumItems+1;
    alignment.Name=DAStudio.message('Simulink:dialog:StructtypeAlignmentLblName');
    alignment.RowSpan=[3,3];
    alignment.ColSpan=[1,2];
    alignment.Type='edit';
    alignment.Tag='structAlignment_tag';
    alignment.ObjectProperty='Alignment';
    grpCodeGen.Items{grpNumItems}=alignment;




    rowIdx=rowIdx+1;
    grpCodeGen.Items=align_names(grpCodeGen.Items);
    grpCodeGen.LayoutGrid=[2,2];
    grpCodeGen.Name=DAStudio.message('Simulink:dialog:DataCodeGenOptionsPrompt');
    grpCodeGen.Type='group';
    grpCodeGen.RowSpan=[rowIdx,rowIdx];
    grpCodeGen.ColSpan=[1,2];
    grpCodeGen.Tag='grpCodeGen_tag';





    rowIdx=rowIdx+1;
    description.Name=DAStudio.message('Simulink:dialog:ObjectDescriptionPrompt');
    description.Type='editarea';
    description.RowSpan=[rowIdx,rowIdx];
    description.ColSpan=[1,2];
    description.Tag='description_tag';
    description.ObjectProperty='Description';
    description.ListenToProperties='Elements';




    dlgstruct.DialogTitle=[class(h),': ',name];

    if(DA_TABLE_SUPPORT)
        dlgstruct.Items={elementsgrp,grpCodeGen,description};
    else
        dlgstruct.Items={elementsLbl,elementsVal,grpCodeGen,description};
    end

    dlgstruct.LayoutGrid=[rowIdx,2];
    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={[docroot,'/mapfiles/simulink.map'],'simulink_struct_type'};
    dlgstruct.RowStretch=[0,0,1];
    dlgstruct.ColStretch=[0,1];


