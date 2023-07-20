function resp=freqRespShared(freq,m,n,a,c,d,e,delay)
    s=2j*pi*freq.';
    if isempty(a)
        x=repmat(d.',size(s));
    else
        y=1./(s-a);
        x=d.'+c.'*y;
    end
    if any(e~=0)
        x=e.'*s+x;
    end
    if any(delay~=0)
        x=exp(-delay.'*s).*x;
    end
    resp=reshape(x,m,n,[]);
end