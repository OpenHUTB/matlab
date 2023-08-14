











function hasTunableParameters=isTunableBlockParameter(blocks,parameter)
    if nargin>0
        blocks=convertStringsToChars(blocks);
    end

    if nargin>1
        parameter=convertStringsToChars(parameter);
    end

    if ischar(blocks)
        blocks={blocks};
    end

    hasTunableParameters=false(size(blocks));

    for n=1:length(blocks)
        [~,usage]=Advisor.Utils.Simulink.getTunableParameters(blocks{n},true);

        if~isempty(usage)
            parameterValue=get_param(blocks{n},parameter);

            for ni=1:length(usage)
                if~isempty(strfind(parameterValue,usage(ni).Name))
                    hasTunableParameters(n)=true;
                    break;
                end
            end
        end
    end
end