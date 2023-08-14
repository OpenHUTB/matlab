

function B=max(A,nanflag)%#codegen


















    narginchk(1,2);
    if nargin==2
        nanflagInp=nanflag;
    else
        nanflagInp='omitnan';
    end

    coder.allowpcode('plain');
    if coder.target('MATLAB')
        B=max(A(:),[],nanflagInp);
    else
        if strcmp(nanflagInp,'includenan')
            B=gpucoder.reduce(A(:),@maxFuncIncNan);
        else
            B=gpucoder.reduce(A(:),@maxFuncOmitNan);
        end
    end
end

function out=maxFuncOmitNan(a,b)




    if~isnan(a)&&~isnan(b)
        if a>=b
            out=a;
        else
            out=b;
        end
    elseif isnan(a)
        out=b;
    else
        out=a;
    end
end

function out=maxFuncIncNan(a,b)



    if isnan(a)||isnan(b)
        out=cast(NaN,'like',a);
    else
        if a>=b
            out=a;
        else
            out=b;
        end
    end
end