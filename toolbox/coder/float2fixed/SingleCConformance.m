
classdef SingleCConformance<handle
%#codegen

    methods
        function this=SingleCConformance(kind,varargin)
            coder.allowpcode('plain');
            coder.inline('always');
            coder.internal.prefer_const(kind,varargin);
            switch kind
            case 1,coder.internal.compileWarning(varargin{:});
            case 2,coder.internal.assert(false,varargin{:});
            end
        end
    end

    methods(Static)

        function r=checkConformance(qualifiedName)
            r=true;
            transformingLibFcs=coder.internal.f2ffeature('TransformLibraryFunctions');
            if exist(qualifiedName,'class')
                mc=meta.class.fromName(qualifiedName);
                if~isempty(mc)
                    props=mc.PropertyList;
                    for ii=1:numel(props)
                        prop=props(ii);
                        if prop.HasDefault&&isDoubleRecursive(prop.DefaultValue)
                            if transformingLibFcs

                                r=false;
                                return;
                            else
                                if~prop.Constant
                                    r=false;
                                    return;
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function r=isDoubleRecursive(val)
    if isa(val,'double')
        r=true;
    elseif iscell(val)
        for ii=1:numel(val)
            if isDoubleRecursive(val{ii})
                r=true;
                return;
            end
        end
    elseif isstruct(val)
        flds=fieldnames(val);
        for ii=1:numel(flds)
            fld=flds{ii};
            fval=val.(fld);
            if isDoubleRecursive(fval)
                r=true;
                return;
            end
        end
    else
        r=false;
    end
end


