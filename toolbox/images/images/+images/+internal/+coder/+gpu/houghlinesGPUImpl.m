function lines=houghlinesGPUImpl(BW,theta,rho,peaks,fillgap,minlength)%#codegen




    coder.allowpcode('plain');


    coder.gpu.internal.kernelfunImpl(false);


    numPeaks=size(peaks,1);
    numElements=numel(BW);


    [imgR,imgC]=size(BW);

    nonZeroPixels=sum(BW(:));


    if(nonZeroPixels==0)
        tmpStruct.point1=[0,0];
        tmpStruct.point2=[0,0];
        tmpStruct.theta=0;
        tmpStruct.rho=0;
        lines=repmat(tmpStruct,1,0);
        return;
    end



    convFactor=double(pi)/double(180);
    cost=cos(double(theta(peaks(:,2)))*convFactor);
    sint=sin(double(theta(peaks(:,2)))*convFactor);


    slope=double(length(rho)-1)/double(rho(end)-rho(1));








    peakPixelPoints=coder.nullcopy(zeros(nonZeroPixels,numPeaks));
    peakPixelCount=zeros(numPeaks,1,'single');

    coder.gpu.internal.kernelImpl(false);
    for pixelIndex=1:numElements
        coder.gpu.internal.kernelImpl(false);
        for peakIndex=1:numPeaks

            if BW(pixelIndex)



                [yCoord,xCoord]=ind2sub([imgR,imgC],pixelIndex);


                myRho=double(xCoord-1)*cost(peakIndex)+double(yCoord-1)*sint(peakIndex);

                rhoBinIdx=roundAndCastInt(slope*(myRho-rho(1)))+1;


                if(rhoBinIdx==peaks(peakIndex,1))






                    [peakPixelCount(peakIndex),oldVal]=gpucoder.atomicAdd(peakPixelCount(peakIndex),single(ones(1,1)));
                    peakPixelPoints(oldVal+1,peakIndex)=pixelIndex;
                end
            end
        end
    end



    maxNumPixels=max(peakPixelCount);
    peakPixelPoints2D=zeros([maxNumPixels,2,numPeaks],'single');
    coder.gpu.internal.kernelImpl(false);
    for i=1:maxNumPixels
        coder.gpu.internal.kernelImpl(false);
        for j=1:numPeaks
            if peakPixelPoints(i,j)
                [peakPixelPoints2D(i,1,j),peakPixelPoints2D(i,2,j)]=ind2sub([imgR,imgC],peakPixelPoints(i,j));
            end
        end
    end



    coder.gpu.internal.kernelImpl(false);
    for i=1:numPeaks

        rMin=min(peakPixelPoints2D(1:peakPixelCount(i),1,i));
        rMax=max(peakPixelPoints2D(1:peakPixelCount(i),1,i));

        cMin=min(peakPixelPoints2D(1:peakPixelCount(i),2,i));
        cMax=max(peakPixelPoints2D(1:peakPixelCount(i),2,i));

        r_range=rMax-rMin;
        c_range=cMax-cMin;

        if(r_range>c_range)

            [peakPixelPoints2D(1:peakPixelCount(i),1,i),idx]=sort(peakPixelPoints2D(1:peakPixelCount(i),1,i));


            peakPixelPoints2D(1:peakPixelCount(i),2,i)=peakPixelPoints2D(idx,2,i);




            peakPixelPoints2D=modifiedBubbleSort(peakPixelCount,peakPixelPoints2D,i,[1,2]);

        else

            [peakPixelPoints2D(1:peakPixelCount(i),2,i),idx]=sort(peakPixelPoints2D(1:peakPixelCount(i),2,i));


            peakPixelPoints2D(1:peakPixelCount(i),1,i)=peakPixelPoints2D(idx,1,i);




            peakPixelPoints2D=modifiedBubbleSort(peakPixelCount,peakPixelPoints2D,i,[2,1]);

        end
    end


    minLengthSquare=minlength^2;
    fillGapSquare=fillgap^2;










    fillgapIndices=zeros([maxNumPixels,numPeaks],'logical');
    for i=1:numPeaks
        coder.gpu.internal.kernelImpl(false);
        for j=1:peakPixelCount(i)



            distX=(peakPixelPoints2D(j+1,1,i)-peakPixelPoints2D(j,1,i))^2;
            distY=(peakPixelPoints2D(j+1,2,i)-peakPixelPoints2D(j,2,i))^2;
            squaredDistance=distX+distY;
            if(squaredDistance>fillGapSquare)
                fillgapIndices(j,i)=true;
            end
        end
        fillgapIndices(peakPixelCount(i),i)=true;
    end




    lineCoords=zeros([maxNumPixels,4,numPeaks],'single');

    coder.gpu.internal.kernelImpl(false);
    for i=1:numPeaks
        prevIdx=single([peakPixelPoints2D(1,1,i),peakPixelPoints2D(1,2,i)]);
        coder.gpu.internal.kernelImpl(false);
        for j=1:peakPixelCount(i)
            if fillgapIndices(j,i)
                newIdx=single([peakPixelPoints2D(j,1,i),peakPixelPoints2D(j,2,i)]);


                lineLenVal=((newIdx(1)-prevIdx(1))^2+(newIdx(2)-prevIdx(2))^2);
                if(lineLenVal>=minLengthSquare)
                    lineCoords(j,:,i)=[prevIdx(2),prevIdx(1),newIdx(2),newIdx(1)];
                end
                prevIdx=[peakPixelPoints2D(j+1,1,i),peakPixelPoints2D(j+1,2,i)];
            end
        end
    end



    totalLines=nnz(lineCoords)/4;
    tmpStruct.point1=[0,0];
    tmpStruct.point2=[0,0];
    tmpStruct.theta=0;
    tmpStruct.rho=0;
    lines=repmat(tmpStruct,1,totalLines);


    iter=0;
    coder.gpu.internal.kernelImpl(false);
    for i=1:numPeaks
        coder.gpu.internal.kernelImpl(false);
        for j=1:peakPixelCount(i)
            if(lineCoords(j,1,i)~=0)
                iter=iter+1;
                lines(iter).theta=theta(peaks(i,2));
                lines(iter).rho=rho(peaks(i,1));
                lines(iter).point1=double(lineCoords(j,1:2,i));
                lines(iter).point2=double(lineCoords(j,3:4,i));
            end
        end
    end

    function y=roundAndCastInt(x)
        coder.inline('always');
        coder.internal.prefer_const(x);

        y=coder.internal.indexInt(x+0.5);
    end

    function peakPixelPoints2DTemp=modifiedBubbleSort(pixelCount,peakPixelPoints2DTemp,peakIdx,sortingOrder)


        pixIdx=zeros(pixelCount(peakIdx)+1,1);
        pixIdx(1)=1;
        counter=2;
        for k=2:pixelCount(peakIdx)
            if(peakPixelPoints2DTemp(k,sortingOrder(1),peakIdx)~=peakPixelPoints2DTemp(k-1,sortingOrder(1),peakIdx))
                pixIdx(counter)=k;
                counter=counter+1;
            end
        end

        for k=1:counter-2
            len=pixIdx(k+1)-pixIdx(k);
            if(len>=2)
                for m=1:len-1
                    for l=pixIdx(k):pixIdx(k+1)-m-1
                        if peakPixelPoints2DTemp(l,sortingOrder(2),peakIdx)>peakPixelPoints2DTemp(l+1,sortingOrder(2),peakIdx)
                            temp=peakPixelPoints2DTemp(l,sortingOrder(2),peakIdx);
                            peakPixelPoints2DTemp(l,sortingOrder(2),peakIdx)=peakPixelPoints2DTemp(l+1,sortingOrder(2),peakIdx);
                            peakPixelPoints2DTemp(l+1,sortingOrder(2),peakIdx)=temp;
                        end
                    end
                end
            end
        end
    end

end
