function objGetParam(obj,varargin)


    in=varargin{1};


    OldParamNames=fieldnames(obj.OldParam);
    nOldParam=numel(OldParamNames);
    for paramIdx=1:nOldParam
        thisParamName=OldParamNames{paramIdx};
        thisParamValue=getValue(in,thisParamName);
        if isempty(str2num(thisParamValue))

            obj.OldParam.(thisParamName)=strtrim(thisParamValue);
        else
            obj.OldParam.(thisParamName)=str2num(thisParamValue);
        end
    end
end

