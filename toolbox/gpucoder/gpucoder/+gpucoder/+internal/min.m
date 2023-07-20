

function B=min(A,nanflag)%#codegen



















    narginchk(1,2);
    if nargin==2
        nanflagInp=nanflag;
    else
        nanflagInp='omitnan';
    end

    coder.allowpcode('plain');
    if coder.target('MATLAB')
        B=min(A(:),[],nanflagInp);
    else
        if strcmp(nanflagInp,'includenan')
            B=gpucoder.reduce(A(:),@minFuncIncNan);
        else
            B=gpucoder.reduce(A(:),@minFuncOmitNan);
        end
    end
end

function out=minFuncOmitNan(a,b)




    if~isnan(a)&&~isnan(b)
        if a>=b
            out=b;
        else
            out=a;
        end
    elseif isnan(a)
        out=b;
    else
        out=a;
    end
end

function out=minFuncIncNan(a,b)



    if isnan(a)||isnan(b)
        out=cast(NaN,'like',a);
    else
        if a>=b
            out=b;
        else
            out=a;
        end
    end
end