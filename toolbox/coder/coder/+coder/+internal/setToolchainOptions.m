function aTC=setToolchainOptions(aValue)




    success=true;

    try
        tcNames=coder.make.internal.guicallback.getToolchains();
    catch
        success=false;
    end


    if~success||isempty(tcNames)
        error(message('Coder:configSet:NoToolchains'));
    end


    matchingTCs={};
    for i=1:numel(tcNames)
        if contains(tcNames{i},aValue,'IgnoreCase',true)
            matchingTCs{end+1}=tcNames{i};%#ok<AGROW>
        end
    end


    if isempty(matchingTCs)
        [aliasName,~]=coder.make.internal.getToolchainNameFromRegistry(aValue);
        if~isempty(aliasName)
            matchingTCs={aliasName};
        else
            error(message('Coder:configSet:Invalid_ToolchainName',aValue,strjoin(tcNames,'\n')));
        end
    elseif numel(matchingTCs)>1


        for i=1:numel(matchingTCs)
            if strcmp(aValue,matchingTCs{i})
                matchingTCs={matchingTCs{i}};%#ok<CCAT1>
                break;
            end
        end

        if numel(matchingTCs)>1
            error(message('Coder:configSet:MultipleMatchingToolchainName',aValue,strjoin(matchingTCs,'\n')));
        end
    end

    aTC=matchingTCs{1};


