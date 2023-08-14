function valueStored=ut_setValue(this,proposedValue)






    try
        com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setParameterAsStringXML(this.JavaHandle,proposedValue);
        this.ErrorMessage='';
        this.ValueInvalid='';
    catch ME
        this.ValueInvalid=proposedValue;
        errMsg=ME.message;
        crLoc=findstr(errMsg,char(10));
        if length(crLoc)>1

            errMsg=errMsg(crLoc(1)+1:crLoc(2)-1);
        end
        this.ErrorMessage=errMsg;
    end

    valueStored='';
