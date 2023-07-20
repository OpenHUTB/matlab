function[A,B,C,D]=abcdPRD(nOut,a,c,d)
%#codegen



    nPoles=size(a,1);
    if nPoles>0
        [VAr,DAr]=cdf2rdfPRD(a(:,1));
        A=DAr;
        B=real(VAr\ones(nPoles,1));
        C=real(c*VAr);
    else
        A=zeros(nPoles,nPoles);
        B=zeros(nPoles,1);
        C=zeros(nOut,nPoles);
    end
    D=d;
end

function[vv,dd]=cdf2rdfPRD(ddiag)
    d=diag(ddiag);
    v=eye(size(d));
    n=numel(ddiag);
    dimag=imag(ddiag);
    ind=find(dimag);
    if isempty(ind)
        vv=v;
        dd=real(d);
    else
        index=ind(1:2:end);
        vv=complex(v);
        A=v(:,index);
        B=v(:,index+1);
        vv(:,index)=(A+B)/2;
        vv(:,index+1)=(A-B)/2j;
        dd=real(d);
        n=numel(dimag);
        dd(index*(n+1))=dimag(index);
        dd((index-1)*(n+1)+2)=dimag(index+1);
    end
end

