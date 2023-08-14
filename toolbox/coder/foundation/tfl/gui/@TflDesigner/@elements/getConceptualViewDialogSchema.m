function conceptualviewgroup=getConceptualViewDialogSchema(this)




    ResourcePath=fullfile(fileparts(mfilename('fullpath')),'..','resources');

    textLbl.Name=DAStudio.message('RTW:tfldesigner:ConceptualViewText');
    textLbl.Type='text';
    textLbl.Italic=1;
    textLbl.RowSpan=[2,2];
    textLbl.ColSpan=[1,3];
    textLbl.Tag='Tfldesigner_TextLbl';

    arglist=this.getDialogWidget('Tfldesigner_ActiveConceptArg');
    arglist.RowSpan=[3,3];
    arglist.ColSpan=[1,1];


    addargpushbutton=this.getDialogWidget('Tfldesigner_Addargpushbutton');
    addargpushbutton.Alignment=5;
    addargpushbutton.MaximumSize=[45,45];
    addargpushbutton.RowSpan=[4,4];
    addargpushbutton.ColSpan=[1,1];

    removeargpushbutton=this.getDialogWidget('Tfldesigner_Removeargpushbutton');
    removeargpushbutton.MaximumSize=[45,45];
    removeargpushbutton.Alignment=6;
    removeargpushbutton.RowSpan=[4,4];
    removeargpushbutton.ColSpan=[1,1];
    removeargpushbutton.FilePath=fullfile(ResourcePath,'delete.png');

    customclasslabel.Name=DAStudio.message('RTW:tfldesigner:CustomClassEditLabel');
    customclasslabel.Type='text';
    customclasslabel.RowSpan=[5,5];
    customclasslabel.ColSpan=[1,2];
    customclasslabel.Tag='Tfldesigner_CustomClassTag';
    customclasslabel.Visible=false;

    customclassbutton=this.getDialogWidget('Tfldesigner_customclassbutton');
    customclassbutton.ToolTip=DAStudio.message('RTW:tfldesigner:EditMATLABFileTooltip');
    customclassbutton.RowSpan=[5,5];
    customclassbutton.ColSpan=[2,2];
    customclassbutton.Alignment=7;
    customclasslabel.Visible=customclassbutton.Visible;


    dtype=this.getDialogWidget('Tfldesigner_DataType');
    dtype.RowSpan=[1,1];
    dtype.ColSpan=[1,1];


    ciotypedesc=this.getDialogWidget('Tfldesigner_ConceptIOType');
    ciotypedesc.MaximumSize=[90,23];
    ciotypedesc.Alignment=5;
    ciotypedesc.RowSpan=[1,1];
    ciotypedesc.ColSpan=[2,2];

    complexdesc=this.getDialogWidget('Tfldesigner_Complex');
    complexdesc.RowSpan=[2,2];
    complexdesc.ColSpan=[1,1];

    matrixpointerdesc=this.getDialogWidget('Tfldesigner_isMatrixPointer');
    matrixpointerdesc.OrientHorizontal=true;
    matrixpointerdesc.RowSpan=[3,3];
    matrixpointerdesc.ColSpan=[1,2];
    matrixpointerdesc.MaximumSize=[170,100];
    matrixpointerdesc.Alignment=5;

    lowerdim=this.getDialogWidget('Tfldesigner_LowerDim');
    lowerdim.MaximumSize=[65,45];
    lowerdim.RowSpan=[4,4];
    lowerdim.ColSpan=[1,1];

    upperdim=this.getDialogWidget('Tfldesigner_UpperDim');
    upperdim.RowSpan=[4,4];
    upperdim.ColSpan=[2,2];
    upperdim.MaximumSize=[65,45];

    argdimgroup.Visible=this.argtype==1;
    if~isempty(this.object.ConceptualArgs)&&this.argtyp==-1
        if isa(this.object.ConceptualArgs(this.activeconceptarg),'RTW.TflArgMatrix')
            argdimgroup.Visible=true;
            if this.argtype==-1
                this.argtype=1;
            end
        end
    end


    argdimgroup.Name=DAStudio.message('RTW:tfldesigner:RangeDimension');
    argdimgroup.Type='group';
    argdimgroup.LayoutGrid=[1,2];
    argdimgroup.RowSpan=[4,4];
    argdimgroup.ColSpan=[1,2];
    argdimgroup.Alignment=5;
    argdimgroup.Tag='Tfldesigner_ArgDimGroup';
    argdimgroup.Items={lowerdim,upperdim};
    argdimgroup.ToolTip=DAStudio.message('RTW:tfldesigner:DimGroupTooltip');










    if this.isStructSpecEnabled
        isArgStruct=this.isDataTypeStruct(this.cargdtypeunapplied);
        structname=this.getDialogWidget('Tfldesigner_StructName');
        structname.RowSpan=[1,1];
        structname.ColSpan=[1,1];

        if~isempty(this.object.ConceptualArgs)
            structname.Value=this.object.ConceptualArgs(this.activeconceptarg).Type.Identifier;
        end

        structelements=this.getDialogWidget('Tfldesigner_StructElements');
        structelements.ColHeader={'Field name','Field type'};
        structelements.Editable=true;
        structelements.RowSpan=[2,3];
        structelements.ColSpan=[1,2];
        structelements.Size=[2,2];
        structelements=this.populateConceptualStructTable(structelements);
        structelements.ColumnCharacterWidth=[10,20];
        structelements.LastColumnStretchable=true;
        structelements.ValueChangedCallback=@conceptualStructTableCallback;

        structarggroup.Name='';
        structarggroup.Type='group';
        structarggroup.Tag='Tfldesigner_ConceptualStructArgGroup';
        structarggroup.LayoutGrid=[3,2];
        structarggroup.RowSpan=[4,4];
        structarggroup.ColSpan=[1,2];
        structarggroup.Visible=false;
        structarggroup.Items={structname,structelements};

        if~isempty(this.object.ConceptualArgs)&&isArgStruct
            structarggroup.Visible=true;


            complexdesc.Visible=false;
            matrixpointerdesc.Visible=false;
            argdimgroup.Visible=false;
        end
    end




    argpropgroup.Name=DAStudio.message('RTW:tfldesigner:ArgumentPropertyText');
    argpropgroup.Type='group';
    argpropgroup.Tag='Tfldesigner_ArgPropGroup';
    argpropgroup.LayoutGrid=[1,3];
    argpropgroup.RowSpan=[3,3];
    argpropgroup.ColSpan=[2,2];
    argpropgroup.Items={dtype,ciotypedesc,complexdesc,matrixpointerdesc,...
    argdimgroup};

    if this.isStructSpecEnabled
        argpropgroup.Items=[argpropgroup.Items,structarggroup];
    end

    copyconcepsettings=this.getDialogWidget('Tfldesigner_CopyConcepArgSettings');
    copyconcepsettings.RowSpan=[7,7];
    copyconcepsettings.ColSpan=[1,2];


    if isempty(this.object.ConceptualArgs)||(this.copyconcepargsettings==1)
        argpropgroup.Enabled=false;
    end


    if isa(this.object,'RTW.TflCOperationEntry')
        conceptualviewgroup.Name=DAStudio.message('RTW:tfldesigner:ConceptualOp');
    else
        conceptualviewgroup.Name=DAStudio.message('RTW:tfldesigner:ConceptualFunction');
    end
    conceptualviewgroup.Type='group';
    conceptualviewgroup.LayoutGrid=[2,2];
    conceptualviewgroup.Items={textLbl,arglist,addargpushbutton,...
    removeargpushbutton,customclasslabel,...
    customclassbutton,argpropgroup,...
    copyconcepsettings};


    function conceptualStructTableCallback(dlg,row,col,value)
        source=dlg.getDialogSource;
        if col==1
            value=source.formatNumericTypeString(value);
        end
        source.cargstructfields{row+1,col+1}=value;
