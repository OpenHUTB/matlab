function displayField(b,fieldName,fieldUnit,fieldDescription)




    fieldValue=b.(fieldName);
    if~isempty(fieldValue)&&~isnan(fieldValue)
        switch class(fieldValue)
        case 'double'
            str1=sprintf('    %s =',fieldName);
            str2=sprintf('%g',fieldValue);
            str3=sprintf(': %s',fieldUnit);
            fprintf('%-20s%-12s%-8s%% %s\n',str1,str2,str3,fieldDescription);
        case 'ee.enum.Connection'
            str1=sprintf('    %s =',fieldName);
            fprintf(['%-20s%-20s%% ',getString(message('physmod:ee:library:comments:utils:displayField:sprintf_ConnectionConfiguration')),'\n'],str1,char(fieldValue));
        otherwise

        end
    end

end