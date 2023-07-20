function[out,av]=getDisplayedValues(obj,varargin)




    if nargin==1
        av=obj.AvailableValues;
    else
        cs=varargin{1};
        av=obj.AvailableValues(cs);
    end

    n=length(av);
    out=cell(1,n);
    for i=1:n
        a=av(i);
        if isnumeric(a)
            out{i}=num2str(a);
        elseif isfield(a,'key')&&~isempty(a.key)
            out{i}=configset.internal.getMessage(a.key);
        elseif isfield(a,'disp')
            out{i}=a.disp;
        else
            out{i}=a.str;
        end
    end

