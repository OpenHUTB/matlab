function resp=freqRespUnshared(freq,m,n,numPoles,a,c,d,e,delay)
    s=2j*pi*freq.';
    resp=zeros(m,n,length(freq));
    for i=1:m
        for j=1:n
            dij=d(i,j);
            eij=e(i,j);
            delayij=delay(i,j);
            np=numPoles(i,j);
            if np==0
                x=repmat(dij,size(s));
            else
                r=1:numPoles(i,j);
                aij=a(i,j,r);
                aij=aij(:);
                cij=c(i,j,r);
                cij=reshape(cij,1,[]);
                y=1./(s-aij);
                x=dij+cij*y;
            end
            if eij~=0
                x=eij*s+x;
            end
            if delayij~=0
                x=exp(-delayij*s).*x;
            end
            resp(i,j,:)=reshape(x,1,1,[]);
        end
    end
end
