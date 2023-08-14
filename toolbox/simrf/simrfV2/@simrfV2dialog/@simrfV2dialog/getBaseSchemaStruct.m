function dlgStruct=getBaseSchemaStruct(...
    this,parameters,maskDescription,optPane)















    if nargin<3
        maskDescription=this.Block.MaskDescription;
    end

    description.Type='text';
    description.Name=maskDescription;
    description.Tag='description';
    description.WordWrap=1;

    descriptionPane.Type='group';
    descriptionPane.Name=this.Block.MaskType;
    descriptionPane.Tag='descriptionPane';
    descriptionPane.Items={description};
    descriptionPane.RowSpan=[1,1];
    descriptionPane.ColSpan=[1,1];

    mainPane.Type='panel';
    mainPane.Name='';
    mainPane.Tag='mainPane';
    if nargin<4
        if iscell(parameters)
            mainPane.Items=cat(2,{descriptionPane},parameters);
        else
            mainPane.Items={descriptionPane,parameters};
        end
        mainPane.Tag='mainPane';

        numItems=1+length(mainPane.Items);
        mainPane.LayoutGrid=[numItems,1];
        mainPane.RowStretch=[zeros(1,numItems-1),1];
        mainPane.RowSpan=[1,1];
        mainPane.ColSpan=[1,1];
    else
        if iscell(parameters)
            mainPane.Items=cat(2,{descriptionPane},{optPane},parameters);
        else
            mainPane.Items={descriptionPane,optPane,parameters};
        end
        mainPane.Tag='mainPane';
        mainPane.LayoutGrid=[4,1];
        mainPane.RowStretch=[0,0,0,1];
        mainPane.RowSpan=[1,1];
        mainPane.ColSpan=[1,1];
    end




    title=this.Block.Name;

    title(double(title)==10)=' ';
    dlgStruct.DialogTitle=['Block Parameters: ',title];
    dlgStruct.HelpMethod='slhelp';
    dlgStruct.HelpArgs={this,this.Block.Handle};
    dlgStruct.Items={mainPane};
    dlgStruct.DialogTag=this.Block.Name;
    dlgStruct.PreApplyCallback='simrfV2DDGPreApply';
    dlgStruct.PreApplyArgs={this,'%dialog'};
    dlgStruct.PostApplyCallback='simrfV2PostApply';
    dlgStruct.PostApplyArgs={this,'%dialog'};
    dlgStruct.SmartApply=0;
    dlgStruct.CloseMethod='closeCallback';
    dlgStruct.CloseMethodArgs={'%dialog'};
    dlgStruct.CloseMethodArgsDT={'handle'};







    [isLibrary,isLocked]=this.isLibraryBlock(this.Block);
    if isLibrary&&isLocked
        dlgStruct.DisableDialog=1;

        return;
    end