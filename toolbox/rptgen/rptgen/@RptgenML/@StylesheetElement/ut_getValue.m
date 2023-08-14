function returnedValue=ut_getValue(this,storedValue)





    if~isempty(this.ValueInvalid)


        returnedValue=this.ValueInvalid;
    else
        if rptgen.use_java
            returnedValue=char(com.mathworks.toolbox.rptgencore.tools.StylesheetMaker.getParameterAsString(this.JavaHandle));
        else
            returnedValue=mlreportgen.re.internal.db.StylesheetMaker.getParameterAsString(this.JavaHandle);
        end
    end
