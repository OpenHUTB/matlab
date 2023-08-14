function wStyle=dlgStylesheetWidget(this,varargin)




    propName=this.getStylesheetProperty;
    if isempty(propName)

        wStyle=this.dlgText('temp',varargin{:});
        wStyle.Name=getString(message('rptgen:rx_db_output:dbOutput'));
        return;
    else

        isStylesheet=strcmp(propName(1:10),'Stylesheet');
        if isStylesheet
            sList=getStylesheetList(RptgenML.StylesheetRoot,...
            propName(11:end),...
            '-asynchronous');
        else
            sList=getTemplateList(RptgenML.DB2DOMTemplateBrowser,...
            propName(9:end),...
            '-asynchronous');
        end

        tag=propName;
        propName=struct(findprop(classhandle(this),propName));
        if~isempty(sList)




            if~isStylesheet&&~ismember(this.(tag),sList)
                this.(tag)=propName.FactoryValue;
            end
            propName.DataType=sList;
        else
            propName.DataType='ustring';
            tag=[tag,'-editfield'];
        end
        wStyle=this.dlgWidget(propName,...
        'Tag',tag,...
        varargin{:});

    end

