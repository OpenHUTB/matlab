function this=StylesheetAttributeSet(parentObj,varargin)





    this=feval(mfilename('class'));
    this.init(parentObj,varargin{:});




    try
        if rptgen.use_java
            attElement=com.mathworks.toolbox.rptgen.xml.StylesheetCustomizationParser.findFirstAttribute(this.JavaHandle);
        else
            attElement=mlreportgen.re.internal.ui.StylesheetCustomizationParser.findFirstAttribute(this.JavaHandle);
        end
    catch ME
        warning(ME.message);
        attElement=[];
    end

    while~isempty(attElement)
        try
            RptgenML.StylesheetAttribute(this,attElement);
        catch ME
            warning(message('rptgen:RptgenML_StylesheetAttributeSet:unableToCreateAttribute',ME.message));
        end
        try
            if rptgen.use_java
                attElement=com.mathworks.toolbox.rptgen.xml.StylesheetCustomizationParser.findNextAttribute(attElement);
            else
                attElement=mlreportgen.re.internal.ui.StylesheetCustomizationParser.findNextAttribute(attElement);
            end
        catch ME %#ok
            attElement=[];
        end
    end
















