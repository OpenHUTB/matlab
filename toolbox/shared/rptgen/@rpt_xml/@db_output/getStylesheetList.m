function sList=getStylesheetList(o,propName)












    if nargin<2


        propName=o.getStylesheetProperty;
    end

    if~strncmp(propName,'-',1)

        if strcmpi(propName(1:10),'Stylesheet')
            propName=propName(11:end);
        else
            ME=MException('rptgen:invalidPropName',...
            getString(message('rptgen:rptgen:invalidStylesheetPropName',propName)));
            throw(ME);
        end
    end


    sList=getStylesheetList(RptgenML.StylesheetRoot,propName);
