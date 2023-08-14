function valueStored=ut_setValue(this,proposedValue)




    try
        if rptgen.use_java
            com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setParameterAsString(this.JavaHandle,proposedValue);
        else
            mlreportgen.re.internal.ui.StylesheetEditor.setParameterAsString(this.JavaHandle,proposedValue);
        end
        this.ErrorMessage='';
        this.ValueInvalid='';
    catch ME
        this.ValueInvalid=proposedValue;
        errMsg=ME.message;
        crLoc=strfind(errMsg,newline);
        if length(crLoc)>1

            errMsg=errMsg(crLoc(1)+1:crLoc(2)-1);
        end
        this.ErrorMessage=errMsg;
    end

    valueStored='';
