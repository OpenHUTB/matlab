function replacefunctionviewgroup=getReplacementFunctionDialogSchema(this)





    ResourcePath=fullfile(fileparts(mfilename('fullpath')),'..','resources');


    implname=this.getDialogWidget('Tfldesigner_Implementationname');
    implname.RowSpan=[1,1];
    implname.ColSpan=[1,1];
    implname.MaximumSize=[125,50];
    implname.Alignment=5;


    namespace=this.getDialogWidget('Tfldesigner_namespace');
    namespace.RowSpan=[1,1];
    namespace.ColSpan=[2,2];
    namespace.MaximumSize=[125,50];
    namespace.Alignment=5;


    functionreturnvoid=this.getDialogWidget('Tfldesigner_functionreturnvoid');
    functionreturnvoid.RowSpan=[2,2];
    functionreturnvoid.ColSpan=[1,1];


    blaslevel=this.getDialogWidget('Tfldesigner_blaslevel');
    blaslevel.RowSpan=[2,2];
    blaslevel.ColSpan=[2,2];
    blaslevel.MaximumSize=[150,50];
    blaslevel.Alignment=5;
    blaslevel.Mode=1;


    implarglist=this.getDialogWidget('Tfldesigner_ImplfuncArglist');
    implarglist.Graphical=true;
    implarglist.RowSpan=[1,4];
    implarglist.ColSpan=[1,5];

    upargbutton=this.getDialogWidget('Tfldesigner_UpArgbutton');
    upargbutton.MaximumSize=[20,20];
    upargbutton.RowSpan=[2,2];
    upargbutton.ColSpan=[6,6];
    upargbutton.FilePath=fullfile(ResourcePath,'up.png');

    downargbutton=this.getDialogWidget('Tfldesigner_DownArgbutton');
    downargbutton.RowSpan=[3,3];
    downargbutton.ColSpan=[6,6];
    downargbutton.MaximumSize=[20,20];
    downargbutton.FilePath=fullfile(ResourcePath,'down.png');

    impladdargpushbutton=this.getDialogWidget('Tfldesigner_AddargpushbuttonImpl');
    impladdargpushbutton.RowSpan=[1,1];
    impladdargpushbutton.ColSpan=[2,2];
    impladdargpushbutton.MaximumSize=[45,45];
    impladdargpushbutton.Alignment=5;

    implremoveargpushbutton=this.getDialogWidget('Tfldesigner_RemoveargpushbuttonImpl');
    implremoveargpushbutton.RowSpan=[1,1];
    implremoveargpushbutton.ColSpan=[1,1];

    implremoveargpushbutton.MaximumSize=[45,30];

    implremoveargpushbutton.FilePath=fullfile(ResourcePath,'delete.png');


    implarglistpanel.Type='panel';
    implarglistpanel.Name='Implementation Arglist panel';
    implarglistpanel.LayoutGrid=[4,6];
    implarglistpanel.RowSpan=[3,6];
    implarglistpanel.ColSpan=[1,1];
    implarglistpanel.Items={implarglist,upargbutton,downargbutton};


    buttonpanel.Type='panel';
    buttonpanel.Name='Arg button panel';
    buttonpanel.LayoutGrid=[1,2];
    buttonpanel.RowSpan=[7,7];
    buttonpanel.ColSpan=[1,1];
    buttonpanel.Items={impladdargpushbutton,implremoveargpushbutton};




    impldtype=this.getDialogWidget('Tfldesigner_ImplDatatype');
    impldtype.MaximumSize=[90,23];
    impldtype.Alignment=5;
    impldtype.RowSpan=[1,1];
    impldtype.ColSpan=[1,1];


    iotypedesc=this.getDialogWidget('Tfldesigner_ImplIOType');
    iotypedesc.RowSpan=[1,1];
    iotypedesc.ColSpan=[2,2];
    iotypedesc.MaximumSize=[90,23];
    iotypedesc.Alignment=5;



    readonlydesc=this.getDialogWidget('Tfldesigner_Readonly');
    readonlydesc.RowSpan=[2,2];
    readonlydesc.ColSpan=[1,1];
    readonlydesc.Alignment=5;
    readonlydesc.ToolTip=DAStudio.message('RTW:tfldesigner:ReadOnlyArgTooltip');

    pointerdesc=this.getDialogWidget('Tfldesigner_ispointer');
    pointerdesc.RowSpan=[2,2];
    pointerdesc.ColSpan=[1,1];
    pointerdesc.Alignment=7;

    pointerpointerdesc=this.getDialogWidget('Tfldesigner_ispointerpointer');
    pointerpointerdesc.RowSpan=[2,2];
    pointerpointerdesc.ColSpan=[2,2];
    pointerpointerdesc.Alignment=6;

    complexdesc=this.getDialogWidget('Tfldesigner_isargcomplex');
    complexdesc.RowSpan=[2,2];
    complexdesc.ColSpan=[2,2];
    complexdesc.Alignment=6;

    dataalign=this.getDialogWidget('Tfldesigner_DataAlignment');
    dataalign.MaximumSize=[65,50];
    dataalign.Alignment=5;
    dataalign.RowSpan=[3,3];
    dataalign.ColSpan=[1,2];


    inplacelist=this.getDialogWidget('Tfldesigner_InPlaceArg');
    inplacelist.RowSpan=[1,1];
    inplacelist.ColSpan=[1,2];


    makeconstant=this.getDialogWidget('Tfldesigner_makeconstant');
    makeconstant.RowSpan=[5,5];
    makeconstant.ColSpan=[1,1];

    initialval=this.getDialogWidget('Tfldesigner_Initialvalue');
    initialval.MaximumSize=[65,50];
    initialval.Alignment=5;
    initialval.RowSpan=[1,1];
    initialval.ColSpan=[1,2];









    if this.isStructSpecEnabled
        isArgStruct=this.isDataTypeStruct(this.iargdtypeunapplied);
        structname=this.getDialogWidget('Tfldesigner_ImplStructName');
        structname.RowSpan=[1,1];
        structname.ColSpan=[1,1];

        implarg=hGetActiveImplArg(this);
        if~isempty(implarg)
            if isa(implarg,'RTW.TflArgPointer')
                structname.Value=implarg.Type.BaseType.Identifier;
            else
                structname.Value=implarg.Type.Identifier;
            end
        end

        structelements=this.getDialogWidget('Tfldesigner_ImplStructElements');
        structelements.ColHeader={'Field name','Field type'};
        structelements.Editable=true;
        structelements.RowSpan=[2,3];
        structelements.ColSpan=[1,2];
        structelements.Size=[2,2];
        structelements=this.populateImplStructTable(structelements);
        structelements.ValueChangedCallback=@implStructTableCallback;

        structarggroup.Name='';
        structarggroup.Type='group';
        structarggroup.Tag='Tfldesigner_ImplStructArgGroup';
        structarggroup.LayoutGrid=[3,2];
        structarggroup.RowSpan=[4,4];
        structarggroup.ColSpan=[1,2];
        structarggroup.Visible=false;
        structarggroup.Items={structname,structelements};



        if isArgStruct&&~isStructFieldMap(this)
            structarggroup.Visible=true;





            complexdesc.Enabled=false;
            matrixpointerdesc.Visible=false;
            dataalign.Enabled=false;
            dataalign.Visible=false;
            inplacelist.Enabled=false;
            inplacelist.Visible=false;
            makeconstant.Value=false;
            makeconstant.Enabled=false;
            makeconstant.Visible=false;
        end
    end



    inplacearggroup.Name='In-place argument mapping';
    inplacearggroup.Type='group';
    inplacearggroup.Tag='Tfldesigner_inplacearggroup';
    inplacearggroup.LayoutGrid=[1,2];
    inplacearggroup.RowSpan=[4,4];
    inplacearggroup.ColSpan=[1,2];
    inplacearggroup.Items={inplacelist};
    inplacearggroup.ColStretch=[0,0,1];
    inplacearggroup.Visible=false;

    passbytype=this.getDialogWidget('Tfldesigner_Passbytype');
    passbytype.RowSpan=[1,1];
    passbytype.ColSpan=[3,4];
    passbytype.MaximumSize=[90,50];
    passbytype.Alignment=5;


    paramsettingsgroup.Name=DAStudio.message('RTW:tfldesigner:ConstantParamSettingText');
    paramsettingsgroup.Type='group';
    paramsettingsgroup.LayoutGrid=[1,2];
    paramsettingsgroup.RowSpan=[6,6];
    paramsettingsgroup.ColSpan=[1,2];
    paramsettingsgroup.Items={initialval,passbytype};
    paramsettingsgroup.Visible=false;
    paramsettingsgroup.ColStretch=[0,0];
    paramsettingsgroup.Alignment=5;

    if this.makeimplargconstant&&makeconstant.Visible
        paramsettingsgroup.Visible=true;
        this.makeimplargconstant=false;
    end
    inplacearggroup.Visible=dataalign.Visible&&inplacelist.Visible;


    implargpropgroup.Name=DAStudio.message('RTW:tfldesigner:ArgumentPropertyText');
    implargpropgroup.Type='group';
    implargpropgroup.Tag='Tfldesigner_Implargpropgroup';
    implargpropgroup.LayoutGrid=[4,3];
    implargpropgroup.RowSpan=[3,6];
    implargpropgroup.ColSpan=[2,2];
    implargpropgroup.Items={impldtype,iotypedesc,readonlydesc,...
    pointerdesc,pointerpointerdesc,complexdesc,dataalign,makeconstant,...
    paramsettingsgroup,inplacearggroup};
    if this.isStructSpecEnabled
        implargpropgroup.Items=[implargpropgroup.Items,structarggroup];
    end
    implargpropgroup.ColStretch=[0,0,1];

    activearg=[];
    if this.activeimplarg==0&&~isempty(this.object.Implementation.Return)
        activearg=this.object.Implementation.Return;
    elseif this.activeimplarg~=0&&~isempty(this.object.Implementation.Arguments)
        activearg=this.object.Implementation.Arguments(this.activeimplarg);
    end

    if isempty(activearg)||(this.copyconcepargsettings==1)
        implargpropgroup.Enabled=false;
    end

    if this.copyconcepargsettings==1


        this.copyconcepargsettings=2;
    end



    implfuncsigpreview=this.getDialogWidget('Tfldesigner_ImplFcnPreview');
    implfuncsigpreview.RowSpan=[7,7];
    implfuncsigpreview.ColSpan=[2,2];

    signaturegroup.Name=DAStudio.message('RTW:tfldesigner:SignatureTooltip');
    signaturegroup.Type='group';
    signaturegroup.LayoutGrid=[3,1];
    signaturegroup.RowSpan=[8,8];
    signaturegroup.ColSpan=[1,2];
    signaturegroup.Items={implfuncsigpreview};

    satmoddescLbl.Name=DAStudio.message('RTW:tfldesigner:SaturationModeText');
    satmoddescLbl.Type='text';
    satmoddescLbl.RowSpan=[1,1];
    satmoddescLbl.ColSpan=[1,1];
    satmoddescLbl.Tag='Tfldesigner_SaturationModeLbl';

    satmoddesc=this.getDialogWidget('Tfldesigner_SaturationMode');
    satmoddescLbl.Buddy=satmoddesc.Tag;
    satmoddesc.RowSpan=[1,1];
    satmoddesc.ColSpan=[2,2];


    roundmoddescLbl.Name=DAStudio.message('RTW:tfldesigner:RoundingModeText');
    roundmoddescLbl.Type='text';
    roundmoddescLbl.RowSpan=[2,2];
    roundmoddescLbl.ColSpan=[1,1];

    roundmoddesc=this.getDialogWidget('Tfldesigner_RoundingMode');
    roundmoddescLbl.Buddy=roundmoddesc.Tag;
    roundmoddesc.RowSpan=[2,3];
    roundmoddesc.ColSpan=[2,2];



    modessettinggroup.Name=DAStudio.message('RTW:tfldesigner:ModesSettings');
    modessettinggroup.Type='panel';
    modessettinggroup.LayoutGrid=[2,3];
    modessettinggroup.RowSpan=[1,2];
    modessettinggroup.ColSpan=[1,2];
    modessettinggroup.Items={satmoddescLbl,satmoddesc,...
    roundmoddescLbl,roundmoddesc};
    modessettinggroup.ColStretch=[0,1];
    modessettinggroup.RowStretch=[1,1,1];

    exprinput=this.getDialogWidget('Tfldesigner_ExprInput');
    exprinput.RowSpan=[3,3];
    exprinput.ColSpan=[1,4];

    returnvoid=this.getDialogWidget('Tfldesigner_SideEffects');
    returnvoid.RowSpan=[4,4];
    returnvoid.ColSpan=[1,4];



    fractionlengthdesc=this.getDialogWidget('Tfldesigner_FLmustbesame');
    fractionlengthdesc.RowSpan=[1,1];
    fractionlengthdesc.ColSpan=[1,2];
    fractionlengthdesc.Alignment=7;

    fxpspacer.Type='panel';
    fxpspacer.RowSpan=[2,2];
    fxpspacer.ColSpan=[1,2];

    netslopefacdescLbl.Name=DAStudio.message('RTW:tfldesigner:NetSlopeAdjText');
    netslopefacdescLbl.Type='text';
    netslopefacdescLbl.RowSpan=[1,1];
    netslopefacdescLbl.ColSpan=[1,1];
    netslopefacdescLbl.Visible=false;

    netslopefacdesc=this.getDialogWidget('Tfldesigner_Netslopeadjustfac');
    netslopefacdescLbl.Buddy=netslopefacdesc.Tag;
    netslopefacdescLbl.Visible=netslopefacdesc.Visible;
    netslopefacdesc.RowSpan=[1,1];
    netslopefacdesc.ColSpan=[2,2];
    netslopefacdesc.MaximumSize=[45,30];


    netfxexpdescLbl.Name=DAStudio.message('RTW:tfldesigner:NetFixedExpText');
    netfxexpdescLbl.Type='text';
    netfxexpdescLbl.RowSpan=[2,2];
    netfxexpdescLbl.ColSpan=[1,1];
    netfxexpdescLbl.Visible=false;

    netfxexpdesc=this.getDialogWidget('Tfldesigner_Netfixedexponent');
    netfxexpdescLbl.Buddy=netfxexpdesc.Tag;
    netfxexpdescLbl.Visible=netfxexpdesc.Visible;
    netfxexpdesc.MaximumSize=[45,30];
    netfxexpdesc.RowSpan=[2,2];
    netfxexpdesc.ColSpan=[2,2];

    dtype=this.getDialogWidget('Tfldesigner_DataType');
    keydesc=this.getDialogWidget('Tfldesigner_Key');

    if isa(this.object,'RTW.TflCOperationEntryGenerator_NetSlope')||...
        isa(this.object,'RTW.TflCOperationEntryGenerator')
        fxpType=~strcmp(dtype.Value,'double')&&...
        ~strcmp(dtype.Value,'single');
        types={'double','single','boolean','logical','void'};
        for idx=1:length(this.object.ConceptualArgs)
            fxpType=fxpType||...
            isempty(strfind(types,this.object.ConceptualArgs(idx).toString));
        end

        setSlopeBiasCheckOff=false;

        if isa(this.object,'RTW.TflCOperationEntryGenerator')&&fxpType
            fixptsettinggroup.Visible=true;
            setSlopeBiasCheckOff=true;
        elseif fxpType
            switch(keydesc.Value)
            case{'Addition','Minus'}
                fixptsettinggroup.Visible=true;
                setSlopeBiasCheckOff=true;
            case{'Multiply','Divide','Cast','Shift left',...
                'Element-wise Matrix Multiply',...
                'Shift Right Arithmetic','Shift Right Logical',...
                'Hermitian Multiplication','Transpose Multiplication'}
                fixptsettinggroup.Visible=true;
                fxpspacer.Visible=false;
                setSlopeBiasCheckOff=true;
            otherwise
                fixptsettinggroup.Visible=false;
            end
        end
        if~setSlopeBiasCheckOff
            fixptsettinggroup.Visible=false;
        end
    else
        fixptsettinggroup.Visible=false;
    end


    sameslopedescLbl.Name=DAStudio.message('RTW:tfldesigner:SlopesSameText');
    sameslopedescLbl.Type='text';
    sameslopedescLbl.RowSpan=[1,1];
    sameslopedescLbl.ColSpan=[2,2];
    sameslopedescLbl.Visible=false;

    sameslopedesc=this.getDialogWidget('Tfldesigner_SameSlopeFunction');
    sameslopedescLbl.Buddy=sameslopedesc.Tag;
    sameslopedescLbl.Visible=sameslopedesc.Visible;
    sameslopedesc.RowSpan=[1,1];
    sameslopedesc.ColSpan=[1,1];

    samebiasdescLbl.Name=DAStudio.message('RTW:tfldesigner:BiasSameText');
    samebiasdescLbl.Type='text';
    samebiasdescLbl.RowSpan=[2,2];
    samebiasdescLbl.ColSpan=[2,2];
    samebiasdescLbl.Visible=false;
    samebiasdescLbl.Alignment=4;

    samebiasdesc=this.getDialogWidget('Tfldesigner_SameBiasFunction');
    samebiasdescLbl.Buddy=samebiasdesc.Tag;
    samebiasdescLbl.Visible=samebiasdesc.Visible;
    samebiasdesc.RowSpan=[2,2];
    samebiasdesc.ColSpan=[1,1];
    samebiasdesc.Alignment=4;


    if isa(this.object,'RTW.TflCFunctionEntry')
        fxpType=~strcmp(dtype.Value,'double')&&...
        ~strcmp(dtype.Value,'single');
        types={'double','single','boolean','logical','void'};
        for idx=1:length(this.object.ConceptualArgs)
            fxpType=fxpType||...
            isempty(strfind(types,this.object.ConceptualArgs(idx).toString));
        end
        if fxpType
            switch(keydesc.Value)
            case{'abs','min','max','sign','sqrt'}
                fixptsettinggroup.Visible=true;
            end
        end
    end

    fixptsettinggroup.Name=DAStudio.message('RTW:tfldesigner:FixedPointSettings');
    fixptsettinggroup.Type='panel';
    fixptsettinggroup.LayoutGrid=[2,2];
    fixptsettinggroup.RowSpan=[1,2];
    fixptsettinggroup.ColSpan=[3,4];
    fixptsettinggroup.Items={fractionlengthdesc,netslopefacdescLbl,netslopefacdesc,...
    netfxexpdescLbl,netfxexpdesc,fxpspacer,sameslopedesc,...
    sameslopedescLbl,samebiasdesc,samebiasdescLbl};
    fixptsettinggroup.ColStretch=[1,1];
    fixptsettinggroup.RowStretch=[1,1];











    implattribgroup.Name=DAStudio.message('RTW:tfldesigner:ImplementationAttribs');
    implattribgroup.Type='group';
    implattribgroup.LayoutGrid=[4,4];
    implattribgroup.RowSpan=[4,7];
    implattribgroup.ColSpan=[1,4];
    implattribgroup.RowStretch=zeros(1,4);
    implattribgroup.ColStretch=[1,0,0,0];


    implattribgroup.Items={modessettinggroup,exprinput,...
    returnvoid,fixptsettinggroup};

    buildInfohyperlinkdesc=this.getDialogWidget('Tfldesigner_buildinfoHyperlink');
    buildInfohyperlinkdesc.RowSpan=[8,8];
    buildInfohyperlinkdesc.ColSpan=[1,2];
    buildInfohyperlinkdesc.Mode=1;



    implpanel.Type='panel';
    implpanel.LayoutGrid=[7,3];
    implpanel.RowSpan=[8,12];
    implpanel.ColSpan=[1,2];
    implpanel.RowStretch=zeros(1,6);
    implpanel.ColStretch=[0,1,1];
    implpanel.Items={implattribgroup,buildInfohyperlinkdesc};


    implspacer.Type='panel';
    implspacer.RowSpan=[4,4];



    functionprototypegroup.Name=DAStudio.message('RTW:tfldesigner:FunctionPrototypeGroup');
    functionprototypegroup.Type='group';
    functionprototypegroup.LayoutGrid=[7,2];
    functionprototypegroup.RowSpan=[1,7];
    functionprototypegroup.ColSpan=[1,2];
    functionprototypegroup.RowStretch=ones(1,7);
    functionprototypegroup.ColStretch=[0,1];
    functionprototypegroup.Items={implname,namespace,functionreturnvoid,...
    blaslevel,implarglistpanel,buttonpanel,implargpropgroup,signaturegroup};



    replacefunctionviewgroup.Name=DAStudio.message('RTW:tfldesigner:ReplacementFunction');
    replacefunctionviewgroup.Type='group';
    replacefunctionviewgroup.LayoutGrid=[11,2];
    replacefunctionviewgroup.Items={functionprototypegroup,...
    implpanel,implspacer};


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


        function ret=isStructFieldMap(this)
            ret=false;
            implarg=hGetActiveImplArg(this);
            if~isempty(this.object.Implementation)&&...
                ~isempty(this.object.Implementation.StructFieldMap)
                mappedName=this.object.Implementation.StructFieldMap{1};
                if strcmp(mappedName,implarg.Name)
                    ret=true;
                end
            end


            function implStructTableCallback(dlg,row,col,value)
                source=dlg.getDialogSource;
                dtypeentries=source.getentries('Tfldesigner_ImplStructDatatype');
                if col==0
                    source.iargstructfields{row+1,col+1}=value;
                elseif col==1
                    source.iargstructfields{row+1,col+1}=dtypeentries{value+1};
                end