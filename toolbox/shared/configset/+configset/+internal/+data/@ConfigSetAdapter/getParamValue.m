function value=getParamValue(obj,name,varargin)





    if nargin>=3
        shortName=varargin{1};
    else
        shortName=configset.internal.util.toShortName(name);
    end

    value='';
    if nargin>=4
        src=varargin{2};
    else
        src=obj.Source;
        if~isempty(src.getConfigSet)
            src=src.getConfigSet;
        end
    end

    try
        value=src.get_param(shortName);
    catch
        if nargin>=5&&~isempty(varargin{3})
            cc=varargin{3};
        else
            cc=obj.getParamOwner(name,src,shortName);
        end

        if~isempty(cc)
            if isa(cc,'hdlcoderui.hdlcc')
                value=cc.get_param(shortName);
            else
                value=cc.getProp(shortName);
            end
        end
    end
end
