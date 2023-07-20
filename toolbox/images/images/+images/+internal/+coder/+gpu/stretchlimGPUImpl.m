function lowhigh=stretchlimGPUImpl(img,nbins,dim,tol_low,tol_high)%#codegen






    coder.allowpcode('plain');
    lowhigh=coder.nullcopy(zeros(2,dim));

    for i=1:dim

        inpChannel=img(:,:,i);



        histMat=imhist(inpChannel,nbins);


        sumVal=uint32(0);
        counter=0;
        while(sumVal<=tol_low*numel(inpChannel))
            counter=counter+1;
            sumVal=sumVal+histMat(counter);
        end
        lowVal=counter-1;


        sumVal=uint32(0);
        counter=length(histMat)+1;















        if isa(tol_high,'double')
            factor_high=(1-tol_high)+eps('double');
        else
            factor_high=1-tol_high;
        end

        while(sumVal<=factor_high*numel(inpChannel))
            counter=counter-1;
            sumVal=sumVal+histMat(counter);
        end
        highVal=counter-1;


        if lowVal==highVal
            lowVal=0;
            highVal=nbins-1;
        end



        lowhigh(:,i)=[lowVal/(nbins-1),highVal/(nbins-1)];
    end
