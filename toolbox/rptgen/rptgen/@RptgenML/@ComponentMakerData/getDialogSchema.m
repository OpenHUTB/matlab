function dlgStruct=getDialogSchema(this,name)





    globalEnable=~isLibrary(this);

    dtProp=struct(findprop(classhandle(this),'DataTypeString'));
    dtProp.DataType={
    'double',getString(message('rptgen:RptgenML_ComponentMakerData:doubleLabel'))
    '!ENUMERATION',getString(message('rptgen:RptgenML_ComponentMakerData:enumLabel'))
    'int32',getString(message('rptgen:RptgenML_ComponentMakerData:intLabel'))
    'string',getString(message('rptgen:RptgenML_ComponentMakerData:stringLabel'))
    'string vector',getString(message('rptgen:RptgenML_ComponentMakerData:stringVectorLabel'))
    rptgen.makeStringType,getString(message('rptgen:RptgenML_ComponentMakerData:parsedStringLabel'))
    'bool',getString(message('rptgen:RptgenML_ComponentMakerData:booleanLabel'))
    };

    fvProp='FactoryValueString';
    if strcmp(this.DataTypeString,'!ENUMERATION')
        if~isempty(this.EnumValues)
            fvProp=struct(findprop(classhandle(this),fvProp));
            fvProp.DataType=[strcat('''',this.EnumValues,''''),this.EnumValues];
        end

        [pPropertyName,wPropertyName]=locWidget(this,'PropertyName',...
        'DialogRefresh',true,...
        'RowSpan',[1,1],...
        'ColSpan',[2,3],...
        'Enabled',globalEnable);
        [pDataType,wDataType]=locWidget(this,dtProp,...
        'Editable',true,...
        'RowSpan',[2,2],...
        'ColSpan',[2,3],...
        'DialogRefresh',true,...
        'Enabled',globalEnable);
        [pFactory,wFactory]=locWidget(this,fvProp,...
        'DialogRefresh',true,...
        'RowSpan',[4,4],...
        'ColSpan',[2,3],...
        'Enabled',globalEnable);
        [pDescription,wDescription]=locWidget(this,'Description',...
        'DialogRefresh',true,...
        'RowSpan',[5,5],...
        'ColSpan',[2,3],...
        'Enabled',globalEnable);

        controls=this.dlgContainer({
pPropertyName
wPropertyName
pDataType
wDataType
        this.dlgWidget('EnumValues',...
        'DialogRefresh',true,...
        'RowSpan',[3,3],...
        'ColSpan',[2,2],...
        'Enabled',globalEnable)
        this.dlgWidget('EnumNames',...
        'DialogRefresh',true,...
        'RowSpan',[3,3],...
        'ColSpan',[3,3],...
        'Enabled',globalEnable)
pFactory
wFactory
pDescription
wDescription
        },getString(message('rptgen:RptgenML_ComponentMakerData:enumPropertiesLabel')),'LayoutGrid',[5,3]);
    else

        controls=this.dlgContainer({
        this.dlgWidget('PropertyName',...
        'DialogRefresh',true,...
        'Enabled',globalEnable)
        this.dlgWidget(dtProp,...
        'Editable',true,...
        'DialogRefresh',true,...
        'Enabled',globalEnable)
        this.dlgWidget(fvProp,...
        'DialogRefresh',true,...
        'Enabled',globalEnable)
        this.dlgWidget('Description',...
        'DialogRefresh',true,...
        'Enabled',globalEnable)
        },getString(message('rptgen:RptgenML_ComponentMakerData:propertiesLabel')));
    end

    try
        codeText=this.toString;

    catch ME
        codeText=['<< ',ME.message,' >>'];
    end

    dlgStruct=this.dlgMain(name,{
    this.dlgContainer({
    struct('Type','pushbutton',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1],...
    'ObjectMethod','exploreAction',...
    'FilePath',fullfile(matlabroot,'toolbox','rptgen','resources','ComponentMakerData.png'))
    this.dlgText(getString(message('rptgen:RptgenML_ComponentMakerData:addPropToComponentLabel')),...
    'RowSpan',[1,1],...
    'ColSpan',[2,2])
    },getString(message('rptgen:RptgenML_ComponentMakerData:addPropLabel')),...
    'LayoutGrid',[1,2],...
    'ColStretch',[0,1],...
    'RowSpan',[1,1],...
    'ColSpan',[1,1],...
    'Visible',~globalEnable)
    this.dlgSet(controls,...
    'RowSpan',[2,2],...
    'ColSpan',[1,1])
    this.dlgContainer({
    this.dlgText(codeText,...
    'FontFamily','%fixedwidth')
    },getString(message('rptgen:RptgenML_ComponentMakerData:codePreviewLabel')),...
    'RowSpan',[3,3],...
    'ColSpan',[1,1])
    },'LayoutGrid',[3,1],'RowStretch',[0,0,1]);


    dlgStruct.DialogTitle=getString(message('rptgen:RptgenML_ComponentMakerData:createPropComponentLabel'));



    function[pPrompt,pWidget]=locWidget(this,varargin)

        pWidget=this.dlgWidget(varargin{:});
        pPrompt=this.dlgText(pWidget.Name,'RowSpan',pWidget.RowSpan,'ColSpan',[1,1]);
        pWidget=rmfield(pWidget,'Name');



