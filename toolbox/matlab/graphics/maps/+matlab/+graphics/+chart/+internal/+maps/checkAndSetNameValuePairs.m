function obj=checkAndSetNameValuePairs(obj,varargin)




















    if~isempty(obj)&&~isempty(varargin)
        try
            p=properties(obj);
        catch
            p={};
        end

        if~isempty(p)
            try
                checkNameValuePairs(varargin{:});
                names=varargin(1:2:end);
                values=varargin(2:2:end);
                S=struct;
                for k=1:length(names)
                    name=names{k};
                    name=validatestring(name,p);
                    S.(name)=values{k};
                end
                obj=setProperties(obj,S);
            catch e
                throwAsCaller(e);
            end
        end
    end
end



function checkNameValuePairs(varargin)







    if~isempty(varargin)
        if rem(length(varargin),2)
            error('MATLAB:maps:NameValuePairs',...
            'Incorrect number of input arguments. Name-value arguments must occur in pairs.')
        end

        params=varargin(1:2:end);
        for k=1:length(params)
            if isstring(params{k})
                validateattributes(params{k},{'string'},{'scalar'},mfilename,'Name')
                params{k}=char(params{k});
            else
                validateattributes(params{k},{'char'},{'row','nonempty'},mfilename,'Name')
            end
        end
    end
end



function obj=setProperties(obj,options)



















    if isobject(obj)&&~isempty(obj)&&isstruct(options)&&isscalar(options)
        names=fieldnames(options);
        for k=1:length(names)
            if isprop(obj,names{k})
                obj.(names{k})=options.(names{k});
            end
        end
    end
end
