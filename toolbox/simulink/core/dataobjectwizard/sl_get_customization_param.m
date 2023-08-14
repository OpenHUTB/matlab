function value=sl_get_customization_param(hObj,propName)




    if isprop(hObj,propName)
        try
            switch propName
            case 'UserDataTypes'
                value=get_data_types(hObj);
            case 'MPFSymbolDefinition'
                value=get_symbols(hObj);
            otherwise
                value=get(hObj,propName);
            end
        catch merr
            value=[];
            MSLDiagnostic('Simulink:dow:GetCustomizationParamWarning',merr.message).reportAsWarning;
        end
    else
        errMsg=sprintf('''%s'' is a invalid property. ',propName);
        MSLDiagnostic('Simulink:dow:GetCustomizationParamWarning',errMsg).reportAsWarning;
        value=[];
    end


    function dtList=get_data_types(hObj)


        dtList={};
        for i=1:length(hObj.UserDataTypes)
            udt=hObj.UserDataTypes{i};
            if iscell(udt)

                dtList{end+1}=udt{1};%#ok
            else
                dtList{end+1}=udt;%#ok
            end
        end


        function symList=get_symbols(hObj)


            symList={};
            for i=1:length(hObj.MPFSymbolDefinition)
                symList{end+1}=hObj.MPFSymbolDefinition{i}.Name;%#ok
            end
