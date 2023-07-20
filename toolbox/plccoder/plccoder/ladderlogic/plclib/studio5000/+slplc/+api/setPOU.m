function setPOU(block,varargin)



    if isempty(varargin)||mod(numel(varargin),2)==1
        error('slplc:invalidArgumentNumber',...
        'Wrong number (%d) of input arguments detected. At least 3 arguments are needed for slplc.api.setPOU. The number of arguments should be an odd value.',...
        numel(varargin)+1);
    end

    paramPairs=varargin;

    [isVarListSpecified,varListIdx]=ismember(lower('variablelist'),lower(paramPairs(1:2:end)));
    if isVarListSpecified
        varlistValueIdx=2*varListIdx(end);
        try
            slplc.utils.setVariableList(block,paramPairs{varlistValueIdx});
        catch ME
            error('slplc:invalidPOUToSetVarList',...
            'Invalid PLC block %s to set variable list on it.\nThe block should be Function, Function Block, Program, and PLC Controller. \n\nError Message:\n',...
            getfullname(block),...
            ME.message)
        end
        paramPairs(varlistValueIdx)=[];
        paramPairs(varlistValueIdx-1)=[];
    end

    if~isempty(paramPairs)
        set_param(block,paramPairs{:});
    end

end