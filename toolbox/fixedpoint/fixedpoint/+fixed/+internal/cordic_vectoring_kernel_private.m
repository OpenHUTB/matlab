function[x,y,z]=cordic_vectoring_kernel_private(x,y,z,inpLUT,niters)




%#codegen

    coder.allowpcode('plain');

    if~isempty(coder.target)
        eml_prefer_const(inpLUT,niters);
    end

    xtmp=x;
    ytmp=y;

    for idx=1:niters
        if y<0
            x(:)=x-ytmp;
            y(:)=y+xtmp;
            z(:)=z-inpLUT(idx);
        else
            x(:)=x+ytmp;
            y(:)=y-xtmp;
            z(:)=z+inpLUT(idx);
        end

        xtmp=bitsra(x,idx);
        ytmp=bitsra(y,idx);
    end
