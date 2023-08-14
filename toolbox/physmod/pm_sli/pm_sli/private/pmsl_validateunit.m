function[status,messageString]=pmsl_validateunit(defaultUnit,inputUnit)





    status=true;
    messageString='';
    try
        if~pm_isunit(inputUnit)
            status=false;
            inputUnit=strrep(inputUnit,'<','&lt;');
            inputUnit=strrep(inputUnit,'>','&gt;');
            messageString=getString(message('physmod:pm_sli:dialog:InputUnitInvalid',...
            inputUnit,defaultUnit));
            return;
        end
        if~pm_commensurate(defaultUnit,inputUnit)
            status=false;
            messageString=getString(message('physmod:pm_sli:dialog:InputUnitIncommensurate',...
            inputUnit,defaultUnit));
            return;
        end
    catch e
        status=false;
        messageString=e.message;
    end
end
