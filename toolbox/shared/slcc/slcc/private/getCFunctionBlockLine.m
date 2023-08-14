function[lineStr,methodStr,isConstructorArg]=getCFunctionBlockLine(blockPath,fcnNamePrm,lineNo)



    [lineStr,methodStr]=deal('');
    isConstructorArg=false;

    symbolSpec=get_param(blockPath,'SymbolSpec');
    for i=1:numel(symbolSpec.Symbols)
        symbol=symbolSpec.Symbols(i);
        if strcmp(symbol.Name,fcnNamePrm)
            isConstructorArg=true;
            return;
        end
    end

    blockStr=get_param(blockPath,fcnNamePrm);
    blockStrLines=strsplit(blockStr,'[\r\n]',...
    'CollapseDelimiters',false,...
    'DelimiterType','RegularExpression');
    lineStr=blockStrLines{lineNo};

    switch lower(fcnNamePrm)
    case 'outputcode'
        method=getString(message('Simulink:CustomCode:CFunctionBlockDialogcScriptName'));
    case 'startcode'
        method=getString(message('Simulink:CustomCode:CFunctionBlockDialogstartScriptName'));
    case 'initializeconditionscode'
        method=getString(message('Simulink:CustomCode:CFunctionBlockDialoginitScriptName'));
    case 'terminatecode'
        method=getString(message('Simulink:CustomCode:CFunctionBlockDialogtermScriptName'));
    otherwise
        error(['Unexpected method: ',fcnNamePrm]);
    end

    methodStr=sprintf('<a href="matlab:open_system(''%s'', ''parameter'');">%s</a>',blockPath,method);
end