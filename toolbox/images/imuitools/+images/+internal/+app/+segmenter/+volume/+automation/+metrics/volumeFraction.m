function VF=volumeFraction(info)




    n=numel(info.Mask);

    VF=nnz(info.Mask)/n;

end