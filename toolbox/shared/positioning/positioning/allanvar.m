function[y,tau]=allanvar(omega,m,Fs)












































    try
        [omega,N]=parseomega(omega);

        if(nargin<2)

            m=2.^(0:floor(log2(N/2)));
        else
            m=parsem(m,N);
        end

        if(nargin<3)
            Fs=1;
        else
            Fs=parseFs(Fs);
        end

        if isa(omega,'double')
            m=double(m(:));
            Fs=double(Fs);
        else
            m=single(m(:));
            Fs=single(Fs);
        end

        y=builtin('_computeAllanVariance',omega,m);

        tau=m/Fs;

    catch ME
        throwAsCaller(ME);
    end

end

function[omega,N]=parseomega(omega)

    if~((isa(omega,'double')||isa(omega,'single'))...
        &&isreal(omega)&&ismatrix(omega)&&~issparse(omega)...
        &&all(isfinite(omega(:)))&&~isempty(omega))
        error(message('shared_positioning:allanvar:invalidOmega','omega'));
    end
    if isvector(omega)
        omega=omega(:);
    end
    N=size(omega,1);
    if~(N>1)
        error(message('shared_positioning:allanvar:invalidNumel','omega'));
    end
end

function m=parsem(m,N)

    if((ischar(m)&&isrow(m))...
        ||(isStringScalar(m)&&strlength(m)>0))
        m=parseMStr(m,N);
    else
        m=parseMArr(m,N);
    end
end

function m=parseMStr(m,N)

    mStrings=["octave","decade"];
    mStr=startsWith(mStrings,m,'IgnoreCase',true);
    if mStr(1)

        m=2.^(0:floor(log2(N/2)));
    elseif mStr(2)

        m=10.^(0:floor(log10(N/2)));
    else
        error(message('shared_positioning:allanvar:invalidPtStr',m,...
        mStrings(1),mStrings(2)));
    end
end

function m=parseMArr(m,N)

    if~(isnumeric(m)&&isvector(m)&&isreal(m)...
        &&all(fix(m(:))==m(:))&&issorted(m,'strictascend'))
        error(message('shared_positioning:allanvar:invalidM','m'));
    end
    if~((m(1)>0)&&(m(end)<=N/2))
        error(message('shared_positioning:allanvar:invalidRange','m','omega'));
    end
end

function Fs=parseFs(Fs)

    if~(isnumeric(Fs)&&isreal(Fs)&&isscalar(Fs)...
        &&isfinite(Fs)&&(Fs>0))
        error(message('shared_positioning:allanvar:invalidFs','Fs'));
    end
end
