function unusedParamVals=setTflEntryParameters(h,varargin)









































    len=length(varargin);
    if mod(len,2)~=0
        DAStudio.error('RTW:tfl:oddArguments');
    end

    unusedParamVals={};

    for idx=1:2:len
        prop=findprop(h,varargin{idx});
        if~isempty(prop)
            set(h,varargin{idx},varargin{idx+1});
        else
            unusedParamVals={unusedParamVals{:},...
            varargin{idx},...
            varargin{idx+1}};%#ok
        end
    end



