function OnEditChange(hThis,hDlgSrc,widgetVal,widgetTag)








    errFound=false;

    tmpNumVal=str2double(widgetVal);
    if isnan(tmpNumVal)
        beep();
        msgbox('Input value must be an integer.',...
        'Invalid Input Type','error');
        errFound=true;
    end

    tmpNumVal=int8(tmpNumVal);

    if~errFound&&~isinteger(tmpNumVal)
        beep();
        msgbox('Input value must be an integer.',...
        'Invalid Input Type','error');
        errFound=true;
    end

    if~errFound&&tmpNumVal<0
        beep();
        msgbox('Input value must be an integer.',...
        'Invalid Input Type','error')
        errFound=true;
    end

    if(errFound)

        hDlgSrc.setWidgetValue(widgetTag,hThis.ValueTxt);
    else
        hThis.Value=tmpNumVal;
    end

    hThis.ValueTxt=num2str(hThis.Value);


    hThis.notifyListeners(hDlgSrc,widgetVal,widgetTag);

end
