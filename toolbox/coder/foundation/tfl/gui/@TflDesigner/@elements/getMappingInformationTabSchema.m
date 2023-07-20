function tabcontent=getMappingInformationTabSchema(this)




    rowvalue=1;


    keydesc=this.getDialogWidget('Tfldesigner_Key');
    keydesc.RowSpan=[rowvalue,rowvalue];
    keydesc.ColSpan=[1,1];

    custdesc=this.getDialogWidget('Tfldesigner_CustomFunc');
    custdesc.RowSpan=[rowvalue,rowvalue];
    custdesc.ColSpan=[2,2];

    rowvalue=rowvalue+1;



    entryinfoviewgroup=getEntryInfoDialogSchema(this);
    entryinfoviewgroup.RowSpan=[rowvalue,rowvalue];
    entryinfoviewgroup.ColSpan=[1,2];
    entryinfoviewgroup.RowStretch=ones(1,1);
    entryinfoviewgroup.ColStretch=ones(1,2);
    if entryinfoviewgroup.Visible
        rowvalue=rowvalue+1;
    end




    algorithmparamgroup=getAlgorithmParamsDialogSchema(this);
    algorithmparamgroup.RowSpan=[rowvalue,rowvalue];
    algorithmparamgroup.ColSpan=[1,2];
    algorithmparamgroup.RowStretch=ones(1,1);
    algorithmparamgroup.ColStretch=ones(1,2);
    if algorithmparamgroup.Visible
        rowvalue=rowvalue+1;
    end




    conceptualviewgroup=getConceptualViewDialogSchema(this);
    conceptualviewgroup.RowSpan=[rowvalue,rowvalue+1];
    conceptualviewgroup.ColSpan=[1,2];
    conceptualviewgroup.RowStretch=zeros(1,2);
    conceptualviewgroup.ColStretch=[0,1];

    rowvalue=rowvalue+2;





    matrixentrypropertygroup=getMatrixEntryPropertyDialogSchema(this);
    matrixentrypropertygroup.RowSpan=[rowvalue,rowvalue+1];
    matrixentrypropertygroup.ColSpan=[1,2];
    matrixentrypropertygroup.RowStretch=ones(1,1);
    matrixentrypropertygroup.ColStretch=ones(1,2);
    if matrixentrypropertygroup.Visible
        rowvalue=rowvalue+2;
    end






    if isa(this.object,'RTW.TflCSemaphoreEntry')

        dworkgroup=getDWorkArgsDialogSchema(this);
        dworkgroup.RowSpan=[rowvalue,rowvalue+1];
        dworkgroup.ColSpan=[1,2];
        dworkgroup.RowStretch=zeros(1,2);
        dworkgroup.ColStretch=[0,0];

        rowvalue=rowvalue+2;
    end





    if~isa((this.object),'RTW.TflCustomization')

        replacefunctionviewgroup=getReplacementFunctionDialogSchema(this);
        replacefunctionviewgroup.RowSpan=[rowvalue,rowvalue+3];
        replacefunctionviewgroup.ColSpan=[1,2];
        replacefunctionviewgroup.RowStretch=ones(1,11);
        replacefunctionviewgroup.ColStretch=[0,1];

        rowvalue=rowvalue+4;
    else

        customizationgroup=getCustomizationEntryDialogSchema(this);
        customizationgroup.RowSpan=[rowvalue,rowvalue+1];
        customizationgroup.ColSpan=[1,2];

        rowvalue=rowvalue+2;
    end





    validationgroup=getValidationViewDialogSchema(this);
    validationgroup.RowSpan=[rowvalue,rowvalue+1];
    validationgroup.ColSpan=[1,2];
    validationgroup.RowStretch=ones(1,1);
    validationgroup.ColStretch=zeros(1,2);


    if isempty(keydesc.Value)
        entryinfoviewgroup.Enabled=false;
        conceptualviewgroup.Enabled=false;
        dworkgroup.Enabled=false;
        replacefunctionviewgroup.Enabled=false;
        validationgroup.Enabled=false;
        buildInfohyperlinkdesc.Enabled=false;
        customizationgroup.Enabled=false;
    end

    tabcontent.Type='panel';
    tabcontent.Name=DAStudio.message('RTW:tfldesigner:PropertiesText');
    tabcontent.LayoutGrid=[15,2];
    tabcontent.RowStretch=ones(1,15);
    tabcontent.ColStretch=[1,1];

    if~isa(this.object,'RTW.TflCustomization')
        if isa(this.object,'RTW.TflCSemaphoreEntry')
            tabcontent.Items={keydesc,custdesc,entryinfoviewgroup,...
            algorithmparamgroup,matrixentrypropertygroup,conceptualviewgroup,...
            dworkgroup,replacefunctionviewgroup,validationgroup};
        else
            tabcontent.Items={keydesc,custdesc,entryinfoviewgroup,...
            algorithmparamgroup,matrixentrypropertygroup,conceptualviewgroup,...
            replacefunctionviewgroup,validationgroup};
        end
    else
        tabcontent.Items={keydesc,custdesc,entryinfoviewgroup,...
        algorithmparamgroup,matrixentrypropertygroup,conceptualviewgroup,...
        customizationgroup,validationgroup};
    end

end












