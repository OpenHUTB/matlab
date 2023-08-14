function customizationgroup=getCustomizationEntryDialogSchema(this)





    inlinedesc=this.getDialogWidget('Tfldesigner_InlineFcn');
    inlinedesc.RowSpan=[1,1];
    inlinedesc.ColSpan=[1,8];

    precisedesc=this.getDialogWidget('Tfldesigner_Precise');
    precisedesc.RowSpan=[2,2];
    precisedesc.ColSpan=[1,8];

    snfdescLbl.Name=DAStudio.message('RTW:tfldesigner:SNFText');
    snfdescLbl.Type='text';
    snfdescLbl.RowSpan=[3,3];
    snfdescLbl.ColSpan=[1,1];
    snfdescLbl.Visible=false;

    snfdesc=this.getDialogWidget('Tfldesigner_SupportNonFinite');
    snfdescLbl.Buddy=snfdesc.Tag;
    snfdescLbl.Visible=snfdesc.Visible;
    snfdesc.RowSpan=[3,3];
    snfdesc.ColSpan=[2,8];


    emlcallbackdescLbl.Name=DAStudio.message('RTW:tfldesigner:EMLCallbackText');
    emlcallbackdescLbl.Type='text';
    emlcallbackdescLbl.RowSpan=[4,4];
    emlcallbackdescLbl.ColSpan=[1,1];
    emlcallbackdescLbl.Visible=false;

    emlcallbackdesc=this.getDialogWidget('Tfldesigner_EMLCallback');
    emlcallbackdescLbl.Buddy=emlcallbackdesc.Tag;
    emlcallbackdescLbl.Visible=emlcallbackdesc.Visible;
    emlcallbackdesc.RowSpan=[4,4];
    emlcallbackdesc.ColSpan=[2,8];

    customizationpanel.Type='panel';
    customizationpanel.LayoutGrid=[4,8];
    customizationpanel.RowSpan=[1,3];
    customizationpanel.ColSpan=[1,2];
    customizationpanel.Items={inlinedesc,snfdescLbl,snfdesc,...
    emlcallbackdesc,emlcallbackdescLbl,precisedesc};


    customizationgroup.Name=DAStudio.message('RTW:tfldesigner:CustomizationSettingsText');
    customizationgroup.Type='group';
    customizationgroup.LayoutGrid=[2,2];
    customizationgroup.Items={customizationpanel};

