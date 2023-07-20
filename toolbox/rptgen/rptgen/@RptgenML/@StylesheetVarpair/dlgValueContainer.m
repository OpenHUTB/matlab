function dlgStruct=dlgValueContainer(this,varargin)




    if isLibrary(this)

        globalEnable=0;
    else

        globalEnable=1;
    end

    pValue='Varvalue';
    optBoolean={
'#t'
'#f'
    };
    if any(strcmp(optBoolean,this.(pValue)))
        pValue=struct(findprop(this,pValue));
        pValue.DataType=[optBoolean,{
        getString(message('rptgen:RptgenML_StylesheetVarpair:trueLabel'))
        getString(message('rptgen:RptgenML_StylesheetVarpair:falseLabel'))
        }];
    end

    idStr=[this.Varname,' - ',this.DescriptionShort];

    dlgStruct=this.dlgContainer({
    this.dlgText(idStr,...
    'WordWrap',1,...
    'ColSpan',[1,2],...
    'RowSpan',[1,1])
    this.dlgWidget('Varname',...
    'Visible',false,...
    'ColSpan',[1,2],...
    'RowSpan',[2,2],...
    'Enabled',globalEnable)
    this.dlgWidget(pValue,...
    'ColSpan',[1,2],...
    'RowSpan',[3,3],...
    'DialogRefresh',1,...
    'Enabled',globalEnable)
    },getString(message('rptgen:RptgenML_StylesheetVarpair:valueLabel')),...
    'LayoutGrid',[4,2],'RowStretch',[0,0,0,1],'ColStretch',[1,0],...
    varargin{:});

