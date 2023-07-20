function elementWrapper=createStylesheetElement(parentObj,ssElement,varargin)










    if isa(ssElement,'RptgenML.StylesheetElement')
        ssElementType=ssElement.JavaHandle;
    else
        if rptgen.use_java
            typeName='com.mathworks.toolbox.rptgen.xml.StylesheetCustomizationParser';
        else
            typeName='mlreportgen.re.internal.ui.StylesheetCustomizationParser';
        end
        if isa(ssElement,typeName)
            ssElementType=ssElement.getParamStylesheetElement;
        else
            ssElementType=ssElement;
        end
    end

    if isempty(ssElementType)
        elementWrapper=[];
        return;

    elseif~(rptgen.use_java&&isa(ssElementType,'org.w3c.dom.Element')||...
        isa(ssElementType,'matlab.io.xml.dom.Element'))
        error(message('rptgen:RptgenML:unknownStylesheetElement'));
    end

    if rptgen.use_java
        wrapperType=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.findMatlabWrapperType(ssElementType));
    else
        wrapperType=mlreportgen.re.internal.ui.StylesheetEditor.findMatlabWrapperType(ssElementType);
    end

    elementWrapper=feval(wrapperType,parentObj,ssElement,varargin{:});

