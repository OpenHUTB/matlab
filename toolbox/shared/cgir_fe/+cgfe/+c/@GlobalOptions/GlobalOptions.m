classdef GlobalOptions<internal.cxxfe.FrontEndOptions

    methods
        function this=GlobalOptions(varargin)
            this=this@internal.cxxfe.FrontEndOptions;
            if nargin==1&&isa(varargin{1},'internal.cxxfe.FrontEndOptions')
                cgfe.c.GlobalOptions.deepCopy(varargin{1},this);
            end
        end
    end

    methods(Static)
        function dst=deepCopy(src,dst)
            clsInfo=metaclass(src);
            if nargin<2
                dst=feval(clsInfo.Name);
            end
            for ii=1:numel(clsInfo.PropertyList)
                propName=clsInfo.PropertyList(ii).Name;
                if~strcmpi(clsInfo.PropertyList(ii).GetAccess,'public')||...
                    ~strcmpi(clsInfo.PropertyList(ii).SetAccess,'public')
                    continue;
                end

                if~isobject(src.(propName))||isenum(src.(propName))
                    dst.(propName)=src.(propName);
                else
                    dst.(propName)=cgfe.c.GlobalOptions.deepCopy(src.(propName));
                end
            end
        end
    end
end


