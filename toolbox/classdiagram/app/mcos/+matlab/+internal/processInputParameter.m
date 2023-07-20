function unprocessed=processInputParameter(inputParams,inputName,varargin)
    param=inputParams.(inputName);
    inputParams.(param.name)=param.defaultValue;
    unprocessed=varargin;
    if~isempty(unprocessed)
        [ismem,idx]=ismember(param.inputString,unprocessed);
        if ismem
            inputParams.(param.name)=true;
            unprocessed(idx)=[];
        end
    end
end
