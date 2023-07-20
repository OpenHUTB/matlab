function propSet=addProperty(~,propSet,propName,varargin)




    if(propSet.isvalid&&numel(varargin)==0)
        propSet.addProperty(propName);
    elseif(propSet.isvalid&&numel(varargin)==1)
        propSet.addProperty(propName,varargin{1});
    end
end

