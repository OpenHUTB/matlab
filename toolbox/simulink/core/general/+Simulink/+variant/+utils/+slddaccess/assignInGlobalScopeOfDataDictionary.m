function isValueOverwritten=assignInGlobalScopeOfDataDictionary(varName,value,ddSpec)








    isValueOverwritten=false;
    varName=convertStringsToChars(varName);

    if strcmp(ddSpec,'<active>')
        ddSpec='';
    end
    isSame=false;
    varExistsInGlobalScope=Simulink.variant.utils.slddaccess.existsInGlobalScopeOfDataDictionary(varName,ddSpec);
    if varExistsInGlobalScope
        try %#ok<TRYNC>






            oldValue=Simulink.variant.utils.slddaccess.evalInGlobalScopeOfDataDictionary(varName,ddSpec);
            isSame=strcmp(class(oldValue),class(value))&&isequal(oldValue,value);
        end
    end

    if isSame
        return;
    end

    isValueOverwritten=varExistsInGlobalScope;



    if isempty(ddSpec)


        if isvarname(varName)
            assignin('base',varName,value);
        else
            i_getEvalableCharValue();
            if ischar(value)
                evalin('base',[varName,'= [',value,'];']);
            end
        end
    else
        ddConn=Simulink.dd.open(ddSpec);

        if~ddConn.isOpen
            return;
        end

        if isvarname(varName)
            ddConn.assignin(varName,value,'Global');
        else


            i_getEvalableCharValue();
            if ischar(value)
                ddConn.evalin([varName,'=[',value,'];'],'Global');
            end
        end
    end

    function i_getEvalableCharValue()
        if isnumeric(value)||islogical(value)
            value=[class(value),'([',num2str(value),'])'];
        elseif isa(value,'Simulink.Parameter')

            tempVal='';
            for ii=1:numel(value)
                dataType=value(ii).DataType;
                if strcmp('auto',dataType)
                    dataType='double';
                end
                tempVal=[tempVal,' ',class(value),'(',dataType,'([',num2str(value(ii).Value),'])) '];%#ok<AGROW>
            end
            value=['[',tempVal,']'];
        elseif isa(value,'string')
            tempVal='';
            for ii=1:numel(value)
                tempVal=[tempVal,' string','(''',convertStringsToChars(value(ii)),''') '];%#ok<AGROW>
            end
            value=['[',tempVal,']'];
        elseif isa(value,'char')
            value=['char(''',value,''')'];
        end
    end
end
