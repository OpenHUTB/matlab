function headerFile=get_imported_type_header_file(enumName)



    headerFile='';

    try
        isImported=true;
        if any(ismember(methods(enumName),'getDataScope'))
            scope=eval([enumName,'.getDataScope']);
            isImported=~strcmpi(scope,'Exported');
        end

        if isImported&&any(ismember(methods(enumName),'getHeaderFile'))
            headerFile=eval([enumName,'.getHeaderFile']);
        end

    catch ME %#ok<NASGU>

        headerFile='';

    end
