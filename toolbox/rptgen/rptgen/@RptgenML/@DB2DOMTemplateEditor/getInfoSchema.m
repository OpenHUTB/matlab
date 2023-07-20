function optPanel=getInfoSchema(this)




    tTemplatePath=struct(...
    'Type','text',...
    'Name',getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:templatePathLabel')),...
    'RowSpan',[1,1],...
    'ColSpan',[1,1]...
    );

    if isBuiltInTemplate(this)
        templatePath=getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:builtinTemplateLabel'));
    else
        templatePath=this.TemplatePath;
    end

    wTemplatePath=struct(...
    'Type','text',...
    'Name',templatePath,...
    'RowSpan',[1,1],...
    'ColSpan',[2,3]...
    );

    optPanel=this.dlgContainer([
    {tTemplatePath;wTemplatePath}
    locWidget(this,'ID','RowSpan',[2,2],'ColSpan',[1,3],'Enabled',~isBuiltInTemplate(this))
    locWidget(this,'DisplayName','RowSpan',[3,3],'ColSpan',[1,3],'Enabled',~isBuiltInTemplate(this))
    locWidget(this,'Description','RowSpan',[4,4],'ColSpan',[1,3],'Enabled',~isBuiltInTemplate(this))
    locWidget(this,'Creator','RowSpan',[5,5],'ColSpan',[1,3],'Enabled',~isBuiltInTemplate(this))
    {
    }],getString(message('rptgen:RptgenML_DB2DOMTemplateEditor:templatePropertiesLabel')),...
    'LayoutGrid',[6,3],...
    'ColStretch',[0,0,1]);




    function w=locWidget(this,propName,varargin)

        tag=['DB2DOM_TE_',propName];
        wControl=this.dlgWidget(propName,varargin{:});
        firstCol=wControl.ColSpan(1);
        wControl.ColSpan(1)=firstCol+1;
        wControl.Tag=tag;
        wPrompt=this.dlgText(wControl.Name,...
        'Buddy',wControl.Tag,...
        'ColSpan',[firstCol,firstCol],...
        'RowSpan',wControl.RowSpan);
        wControl=rmfield(wControl,'Name');

        w={wPrompt;wControl};
