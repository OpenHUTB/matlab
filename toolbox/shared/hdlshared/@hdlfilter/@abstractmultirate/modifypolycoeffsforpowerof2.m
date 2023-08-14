function[mod_polycoeffs,power2coeffs]=modifypolycoeffsforpowerof2(this,polycoeffs)






    mod_polycoeffs=polycoeffs;
    power2coeffs=zeros(size(polycoeffs));
    for row=1:size(polycoeffs,1)
        for col=1:size(polycoeffs,2)
            if hdlispowerof2(polycoeffs(row,col))
                mod_polycoeffs(row,col)=0;
                power2coeffs(row,col)=polycoeffs(row,col);
            end
        end
    end



