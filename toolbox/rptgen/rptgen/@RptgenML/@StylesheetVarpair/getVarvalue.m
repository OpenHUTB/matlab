function returnedValue=getVarvalue(h,~)




    if isempty(h.JavaHandle)
        returnedValue=['[[',getString(message('rptgen:RptgenML_StylesheetVarpair:noValueLabel')),']]'];
    else
        try
            if rptgen.use_java
                returnedValue=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.getVarpairValue(h.JavaHandle));
            else
                returnedValue=mlreportgen.re.internal.ui.StylesheetEditor.getVarpairValue(h.JavaHandle);
            end
        catch
            returnedValue=['[[',getString(message('rptgen:RptgenML_StylesheetVarpair:errorLabel')),']]'];
        end
    end
