function tList=getTemplateList(o,propName)













    if nargin<2


        propName=o.getStylesheetProperty;
    end

    if~strncmp(propName,'-',1)

        if strcmpi(propName(1:8),'Template')
            propName=propName(9:end);
        else
            ME=MException('rptgen:invalidPropName',...
            getString(message('rptgen:rptgen:invalidTemplatePropName',propName)));
            throw(ME);
        end
    end

    tList=getTemplateList(RptgenML.DB2DOMTemplateBrowser,propName);
