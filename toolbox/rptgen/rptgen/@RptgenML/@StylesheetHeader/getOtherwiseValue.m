function returnedValue=getOtherwiseValue(h,~)




    if~isempty(h.OtherwiseValueInvalid)


        returnedValue=h.OtherwiseValueInvalid;
    else
        otherwiseEl=h.getOtherwiseElement;
        if isempty(otherwiseEl)
            returnedValue='';
        else
            if rptgen.use_java
                returnedValue=char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.getParameterAsString(otherwiseEl));
            else
                returnedValue=mlreportgen.internal.re.db.StylesheetMaker.getParameterAsString(otherwiseEl);
            end
        end
    end
