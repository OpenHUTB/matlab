function setPropValue(h,propName,propValue)




    if isequal(h.getPropValue(propName),propValue)
        return;
    end

    switch propName

    case 'Tfldesigner_Name'

        for idx=1:length(h.getRoot.children)
            nameexists=strcmpi(propValue,h.getRoot.children(idx).Name);
            if nameexists
                break;
            end
        end

        if~isvarname(propValue)||nameexists
            if~isvarname(propValue)
                errorstr=DAStudio.message('RTW:tfldesigner:InvalidTableName',propValue);
            elseif nameexists
                errorstr=DAStudio.message('RTW:tfldesigner:TableNameExists',propValue);
            end

            dlghandle=TflDesigner.getdialoghandle;
            if~isempty(dlghandle)
                dlghandle.setFocus('Tfldesigner_Name');
            end
            dp=DAStudio.DialogProvider;
            dp.errordlg(errorstr,DAStudio.message('RTW:tfldesigner:ErrorText'),true);
            h.getRoot.setproperror=errorstr;
            return;
        end

        h.Name=propValue;
        dlghandle=TflDesigner.getdialoghandle;
        if~isempty(dlghandle)
            dlghandle.refresh;
        end
        h.firepropertychanged;

    otherwise

        dlghandle=TflDesigner.getdialoghandle;
        if~isempty(dlghandle)
            dlghandle.refresh;
        end;
    end
