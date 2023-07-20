function output=houghpeaksGPUImpl(Hin,numPeaks,threshold,nhoodSize,isThetaAntisymmetric)%#codegen




    coder.allowpcode('plain');


    coder.gpu.internal.kernelfunImpl(false);


    H=cast(Hin,'uint32');




    [H_sorted,H_idxArray]=gpucoder.sort(H(:),'descend');


    output=coder.nullcopy(zeros(numPeaks,2));


    numRowH=(size(H,1));
    numColH=(size(H,2));


    nhoodCenter_i=((nhoodSize(1)-1)/2);
    nhoodCenter_j=((nhoodSize(2)-1)/2);






    if H_sorted(1)<threshold

        output_empty=[];
        output=output_empty;
        return;
    else

        [yVal,xVal]=ind2sub(size(H),H_idxArray(1));
        output(1,1)=yVal;
        output(1,2)=xVal;
    end


    nonZeroElements=sum(H(:)~=0);
    numOfElements=numel(H);


    numPeaksCounter=1;
    iter=2;

    while(numPeaksCounter<numPeaks)

        if(iter<numOfElements&&iter<=nonZeroElements)


            if(H_sorted(iter)<threshold)
                break;
            else


                [yVal,xVal]=ind2sub(size(H),H_idxArray(iter));
                i=1;

                while(i<=numPeaksCounter)



                    rhoMin=output(i,1)-nhoodCenter_i;
                    rhoMax=output(i,1)+nhoodCenter_i;




                    thetaMin=output(i,2)-nhoodCenter_j;
                    thetaMax=output(i,2)+nhoodCenter_j;




                    if isThetaAntisymmetric



                        if((rhoMin<=yVal)&&(yVal<=rhoMax)&&(thetaMin<=xVal)&&(xVal<=thetaMax))
                            break;
                        end



                        if(thetaMax>numColH)

                            rhoMinimum=numRowH-rhoMax+1;
                            rhoMaximum=numRowH-rhoMin+1;
                            thetaMaximum=thetaMax-numColH;

                            if((rhoMinimum<=yVal)&&(yVal<=rhoMaximum)&&(1<=xVal)&&(xVal<=thetaMaximum))
                                break;
                            end
                        elseif(thetaMin<1)

                            rhoMinimum=numRowH-rhoMax+1;
                            rhoMaximum=numRowH-rhoMin+1;
                            thetaMinimum=thetaMin+numColH;

                            if((rhoMinimum<=yVal)&&(yVal<=rhoMaximum)&&(thetaMinimum<=xVal)&&(xVal<=numColH))
                                break;
                            end
                        end

                    else





                        if((rhoMin<=yVal)&&(yVal<=rhoMax)&&(thetaMin<=xVal)&&(xVal<=thetaMax))
                            break;
                        end
                    end
                    i=i+1;
                end


                if(i==numPeaksCounter+1)
                    numPeaksCounter=numPeaksCounter+1;
                    output(numPeaksCounter,1)=yVal;
                    output(numPeaksCounter,2)=xVal;
                end
            end
            iter=iter+1;
        else
            if(threshold==0)


                numPeaksCounter=numPeaksCounter+1;
                output(numPeaksCounter,1)=1;
                output(numPeaksCounter,2)=1;
            else
                break;
            end
        end
    end



    output=output(1:numPeaksCounter,:);
end
