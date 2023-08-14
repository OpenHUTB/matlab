function command=getReducerCommand(inpParser)





    try


        cmdArgs=inpParser.Results;
        params=setdiff(fields(cmdArgs),{'FrameHandle','CalledFromUI'});

        command=['>> Simulink.VariantManager.reduceModel(...',newline,repmat(' ',1,7)];
        command=sprintf('%s',command,'''',cmdArgs.ModelName,'''');

        for paramId=1:numel(params)

            param=params{paramId};

            if strcmp(param,'ModelName')
                continue;
            end

            if shouldAppendParamToCommand(cmdArgs.(param))
                paramValueStr=i_getCharFromVal(cmdArgs.(param));
                commandToAppend=strcat('''',param,'''',',',paramValueStr);
                command=sprintf('%s',command,', ...',newline,repmat(' ',1,7),commandToAppend);
            end
        end
        command=sprintf('%s',command,');');
    catch
        command='';
    end
end

function append=shouldAppendParamToCommand(paramVal)
    append=~isempty(paramVal);

    if isstruct(paramVal)&&isfield(paramVal,'VariantControls')


        append=~isempty([paramVal.VariantControls]);
    end
end

function paramValStr=i_getCharFromVal(paramVal)

    paramValStr='';
    if isempty(paramVal)
        return;
    end

    switch lower(class(paramVal))
    case 'char'
        paramValStr=['''',paramVal,''''];
    case 'cell'
        cellStrVal=cellfun(@(x)i_getCharFromVal(x),paramVal,'UniformOutput',false);
        paramValStr=['{',cellStrVal{1}];
        for cellId=2:numel(cellStrVal)
            paramValStr=strcat(paramValStr,', ',cellStrVal{cellId});
        end
        paramValStr=[paramValStr,'}'];
    case 'logical'
        if paramVal
            paramValStr='true';
        else
            paramValStr='false';
        end
    case 'struct'
        paramValStr=i_handleStructString(paramVal);
    case 'string'
        paramValStr=['''',convertStringsToChars(paramVal),''''];
    otherwise
        if isnumeric(paramVal)||isa(paramVal,'Simulink.Parameter')||isa(paramVal,'Simulink.VariantControl')


            if isscalar(paramVal)
                paramValStr=strcat(Simulink.variant.reducer.utils.convertCVV2String(paramVal));
            else
                paramValStr=strcat('[',Simulink.variant.reducer.utils.convertCVV2String(paramVal),']');
            end
        end
    end
end

function structString=i_handleStructString(arg)


    [isVarGroupNameSyntax,arg]=Simulink.variant.reducer.utils.isVarGroupNameSyntaxStructValid(arg);
    if isVarGroupNameSyntax

        fieldNamesArg=fieldnames(arg);
        structString='';
        for j=1:numel(arg)
            thisStruct=arg(j);
            thisStructString=['struct(''',fieldNamesArg{1},''', ''',...
            (thisStruct.(fieldNamesArg{1})),''', ''',fieldNamesArg{2},''', {',...
            i_getCharFromVal(thisStruct.(fieldNamesArg{2})),'})'];
            if j>1
                thisStructString=[repmat(' ',1,25),thisStructString];
            end
            structString=[structString,thisStructString,', ...',newline];
        end
        structString(end-5:end)=[];
        if numel(arg)>1
            structString=['[',structString,']'];
        end
    else
        structString='struct(';
        controlVariableNames=fieldnames(arg);
        for j=1:numel(controlVariableNames)
            structString=[structString,'''',controlVariableNames{j},''', '];%#ok<*AGROW>
            cvv=arg.(controlVariableNames{j});

            switch numel(cvv)
            case 0



                structString=[structString,''''''];
            case 1
                structString=[structString,Simulink.variant.reducer.utils.convertCVV2String(cvv)];
            otherwise
                structString=[structString,'[',Simulink.variant.reducer.utils.convertCVV2String(cvv),']'];
            end

            if j~=numel(controlVariableNames)
                structString=[structString,', ...',newline,repmat(' ',1,34)];
            end
        end
        structString=[structString,')'];

    end
end


