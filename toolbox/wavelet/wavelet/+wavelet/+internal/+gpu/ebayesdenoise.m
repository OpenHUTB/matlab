function[xden,denoisedCfs,cfs]=...
    ebayesdenoise(x,Lo_D,Hi_D,Lo_R,Hi_R,level,noiseestimate,threshold)




%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    coder.inline('never');
    coder.allowpcode('plain');





    [cd,ca]=wavelet.internal.gpu.mdwtdecWdenoise(x,level,Lo_D,Hi_D);



    cfs=coder.nullcopy(cell(1,level+1));
    for j=1:level
        cfs{j}=cd{j};
    end
    cfs{level+1}=ca;



    isLevDep=false;



    normfac=coder.const(1/(-sqrt(2)*erfcinv(2*0.75)));


    vscale=coder.nullcopy(zeros(1,size(x,2)));
    if strcmpi(noiseestimate,'levelindependent')


        d1=gpucoder.sort(abs(cd{1}),1);
        [m,n]=size(cd{1});


        if mod(m,2)
            coder.gpu.kernel;
            for i=1:n
                vscale(i)=d1((m+1)/2,i)*normfac;
            end
        else
            coder.gpu.kernel;
            for i=1:n
                tempMedX=d1(m/2,i)+d1((m/2)+1,i);
                vscale(i)=(tempMedX/2)*normfac;
            end
        end

    else
        isLevDep=true;
    end


    for lev=1:level

        if isLevDep
            cd{lev}=wavelet.internal.ebayesthresh(...
            cd{lev},'leveldependent',threshold,'decimated');

        else
            cd{lev}=wavelet.internal.ebayesthresh(...
            cd{lev},vscale,threshold,'decimated');
        end
    end


    denoisedCfs=coder.nullcopy(cell(1,level+1));
    for j=1:level
        denoisedCfs{j}=cd{j};
    end
    denoisedCfs{level+1}=ca;



    xden=coder.nullcopy(zeros(size(x),'like',x));
    xden=wavelet.internal.gpu.mdwtrecWdenoise(cd,ca,level,Lo_R,Hi_R,size(x));
end




