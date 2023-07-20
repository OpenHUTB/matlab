function DF=residuematrix(poles,s,TendsToZero)




%#codegen

    np=numel(poles);
    DF=complex(zeros(numel(s),np+1-TendsToZero));
    k=1;
    while k<=np
        if imag(poles(k))==0
            DF(:,k)=1./(s-poles(k));
            k=k+1;
        else
            common=1./((s-poles(k)).*(s-poles(k+1)));
            DF(:,k)=(2*s-(poles(k)+poles(k+1))).*common;
            DF(:,k+1)=(1j*(poles(k)-poles(k+1)))*common;
            k=k+2;
        end
    end
    if~TendsToZero
        DF(:,np+1)=1;
    end
end
