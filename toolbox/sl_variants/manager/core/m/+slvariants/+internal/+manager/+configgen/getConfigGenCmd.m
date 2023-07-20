function command=getConfigGenCmd(parsedInput)




    try
        command=getConfigGenCmdImpl(parsedInput);
    catch
        command='';
    end
end

function command=getConfigGenCmdImpl(parsedInput)
    params=fields(parsedInput);
    tab=repmat(' ',1,7);
    command=['>> [vcdOut, configsInfo] = Simulink.VariantManager.generateConfigurations(...',newline,tab];
    command=sprintf('%s',command,getCharFromVal(parsedInput.ModelName));
    for idx=1:numel(params)
        param=params{idx};
        if isequal(param,'ModelName')
            continue;
        end
        paramVal=parsedInput.(param);
        paramValueStr=getCharFromVal(paramVal);
        commandToAppend=strcat('''',param,'''',',',paramValueStr);
        command=sprintf('%s',command,', ...',newline,tab,commandToAppend);
    end
    command=sprintf('%s',command,');');
end

function valStr=getCharFromVal(val)
    valStr=val;
    switch lower(class(val))
    case 'char'
        valStr=['''',val,''''];
    case 'cell'
        if isempty(val)
            valStr='{}';
            return;
        end
        cellStrVal=val;
        for idx=1:numel(val)
            cellVal=val{idx};
            cellStrVal{idx}=getCharFromVal(cellVal);
        end
        valStr=['{',cellStrVal{1}];
        for cellId=2:numel(cellStrVal)
            valStr=strcat(valStr,', ',cellStrVal{cellId});
        end
        valStr=[valStr,'}'];
    case 'logical'
        if val
            valStr='true';
        else
            valStr='false';
        end
    case 'string'
        valStr=['''',convertStringsToChars(val),''''];
    otherwise
    end
end
