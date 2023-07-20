function dnz=datanz(data,tol)




%#codegen

    dnz=abs(data);
    dnz(dnz<tol)=tol;
end
