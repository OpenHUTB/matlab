function iseq=isequaln_impl(u,v,varargin)%#codegen



















    coder.allowpcode('plain');

    if nargin==1
        iseq=true;
        return;
    end

    if~isequal(size(u),size(v))
        iseq=false;
        return;
    end

    if~((isnumeric(u)||isfi(u))&&(isnumeric(v)||isfi(v)))



        if islogical(u)||islogical(v)
            iseq=isequal(u,v);
        else
            iseq=false;
        end
        return
    end

    nanIdxU=isnan(u);
    nanIdxV=isnan(v);
    anyNanU=any(nanIdxU,'all');
    anyNanV=any(nanIdxV,'all');

    if anyNanU&&anyNanV&&all(nanIdxU==nanIdxV)
        iseq=isequalnLocal(u,v,~nanIdxU,~nanIdxV,varargin{:});
    elseif anyNanU||anyNanV
        iseq=false;
    else
        iseq=isequal(u,v)&&fixed.internal.isequaln_impl(v,varargin{:});
    end

end

function iseq=isequalnLocal(u,v,uNonNanIdx,vNonNanIdx,varargin)


    if nargin==1

        iseq=true;
    elseif(isequal(u(uNonNanIdx),v(vNonNanIdx)))

        iseq=fixed.internal.isequaln_impl(v,varargin{:});
    end

end
