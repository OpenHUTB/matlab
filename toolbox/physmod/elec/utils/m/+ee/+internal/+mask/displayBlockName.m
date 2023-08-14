function displayBlockName(blockName)

    if ishandle(blockName)
        name=get_param(blockName,'Name');
        parent=get_param(blockName,'Parent');
        blockName=[parent,'/',name];
    end

    fprintf(['\n',getString(message('physmod:ee:library:comments:utils:mask:displayBlockName:sprintf_BlockName')),':\n    ''%s''\n'],pmsl_sanitizename(blockName));

end