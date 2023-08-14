function setParamWithDirtyOff(modelOrBlock,varargin)






    try %#ok<TRYNC>
        set_param(modelOrBlock,varargin{:});

        set_param(strtok(modelOrBlock,'/'),'Dirty','off');
    end

end
