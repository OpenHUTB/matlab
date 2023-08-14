function storedValue=setOtherwiseValue(h,proposedValue)




    otherwiseEl=h.getOtherwiseElement;
    if isempty(otherwiseEl)
        error(message('rptgen:RptgenML_StylesheetHeader:nonConformingStructure'));
    end

    try
        com.mathworks.toolbox.rptgen.xml.StylesheetEditor.setParameterAsStringXML(otherwiseEl,proposedValue);
        h.ErrorMessage='';
    catch ME
        h.OtherwiseValueInvalid=proposedValue;
        errMsg=ME.message;
        crLoc=strfind(errMsg,char(10));
        if(length(crLoc)>1)

            errMsg=errMsg(crLoc(1)+1:crLoc(2)-1);
        end
        h.ErrorMessage=errMsg;
    end

    storedValue='';
