function returnedValue=getVarname(h,~)




    if isempty(h.JavaHandle)
        returnedValue=['[[','unnamed',']]'];
    else
        try
            if rptgen.use_java
                returnedValue=char(com.mathworks.toolbox.rptgen.xml.StylesheetEditor.getVarpairID(h.JavaHandle));
            else
                returnedValue=mlreportgen.re.internal.ui.StylesheetEditor.getVarpairID(h.JavaHandle);
            end
        catch
            returnedValue=['[[',getString(message('rptgen:RptgenML_StylesheetVarpair:errorLabel')),']]'];
        end
    end
