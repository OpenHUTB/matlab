function n=reverseCalcMemSize(paddedImgSize,dilatedOpSize,param,bcc,cc)












    convBCC=bcc.conv;
    convCC=cc.conv;


    deficit=max(dilatedOpSize-paddedImgSize);
    d1=ceil(deficit/convBCC.opW);


    threadNumLimit=convCC.threadNumLimit;

    inputMemDepthLimit=convCC.inputMemDepthLimit;
    inputMemSizeLimit=prod(inputMemDepthLimit)*threadNumLimit;

    inputFeatureNum=param.inputFeatureNum;
    inputFeatureDepth=ceil(inputFeatureNum/threadNumLimit)*threadNumLimit;

    D1=floor(sqrt(inputMemSizeLimit/inputFeatureDepth));
    d2=(d1+1)^2+2*D1*(d1+1);


    d3=d2*ceil(inputFeatureNum/threadNumLimit);



    if(convBCC.inputMemDepthLimit(1)<=convBCC.threadNumLimit/2)

        L2_squared=prod(ceil(convBCC.inputMemDepthLimit(2:3)/convBCC.opW));

        L2_=sqrt(L2_squared+2*d3);
        L2_=ceil(L2_);

        n=L2_*convBCC.opW;
    else

        K1=ceil(convBCC.inputMemDepthLimit(1)/convBCC.threadNumLimit);
        K2_squared=prod(ceil(convBCC.inputMemDepthLimit(2:3)/convBCC.opW));

        K2_=sqrt(K2_squared+d3/K1);
        K2_=ceil(K2_);

        n=K2_*convBCC.opW;
    end

end





















































































































































