function[data_new,u1,u2,gain1,gain2,bias1,bias2,diffu1,diffu2,intSpace1,intSpace2]=autooptimizeLUTforHDL2D(intPrec,data,u1_original,u2_original,u1max,u2max,u1min,u2min,n1,n2,preExtrapFlag)


    intSpace1=intPrec-n1;
    intSpace2=intPrec-n2;

    num1=2^n1;
    num2=2^n2;

    if~preExtrapFlag
        u1min=min(u1_original);
        u1max=max(u2_original);
        u2min=min(u1_original);
        u2max=max(u2_original);
    end

    [u1,gain1,bias1]=DistributeEvenly(u1min,u1max,intPrec,intSpace1);
    [u2,gain2,bias2]=DistributeEvenly(u2min,u2max,intPrec,intSpace2);

    [u2grid_orig,u1grid_orig]=meshgrid(u2_original,u1_original);
    [u2grid,u1grid]=meshgrid(u2,u1);

    InterpolatorF=griddedInterpolant(u1grid_orig,u2grid_orig,data);
    data_new=single(InterpolatorF(u1grid,u2grid));
    diffu1=diff(data_new,1,1);
    diffu1(num1,:)=zeros(1,num2);
    diffu2=diff(data_new,1,2);
    diffu2(:,num2)=zeros(num1,1);

end

function[outVector,gain,bias]=DistributeEvenly(minVal,maxVal,intPrec,intSpace)


    n=2^(intPrec-intSpace);

    maxVal=1.001*maxVal;
    minVal=1.001*minVal;
    dif=(maxVal-minVal);

    bin=2^intPrec-2^(intSpace);

    gain=bin/dif;
    bias=-minVal*bin/dif;
    outVector=((0:n-1)*2^(intSpace)-bias)/gain;

end



