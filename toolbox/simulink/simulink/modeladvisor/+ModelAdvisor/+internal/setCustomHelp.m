function success=setCustomHelp(instance,varargin)




    success=false;

    if~(isa(instance,'ModelAdvisor.Node')||isa(instance,'ModelAdvisor.Check'))
        return;
    end

    if(nargin>1)
        [varargin{:}]=convertStringsToChars(varargin{:});
        inputParamParser=inputParser;
        addParameter(inputParamParser,'path','',@(x)ischar(x));
        addParameter(inputParamParser,'format','webpapge',@(x)ischar((validatestring(x,{'webpage','pdf'}))));
        parse(inputParamParser,varargin{:});
        nameValPair=inputParamParser.Results;

        if strcmpi(nameValPair.format,'webpage')
            instance.CSHParameters.webpage=nameValPair.path;
            success=true;
        else
            instance.CSHParameters.file=nameValPair.path;
            success=true;
        end
    end
end



