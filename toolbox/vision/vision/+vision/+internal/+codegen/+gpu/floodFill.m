function labels=floodFill(angleMat,rangeMat,angThresh,seedThresh)














%#codegen



    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    coder.gpu.kernelfun;

    labels=computeSeeds(angleMat,rangeMat,seedThresh);

    globalContinueFlag=1;


    while globalContinueFlag

        globalContinueFlag=0;



        for i=1:10

            [labels,globalContinueFlag]=floodfillAlgo(labels,angleMat,...
            rangeMat,angThresh,globalContinueFlag);
        end
    end
end

function seedMat=computeSeeds(angleMat,rangeMat,seedThresh)



%#codegen

    coder.gpu.kernelfun;
    seedMat=zeros(size(angleMat),'logical');

    coder.gpu.kernel;
    for cIter=1:size(angleMat,2)
        rIter=size(angleMat,1);
        while(rIter)
            if isfinite(rangeMat(rIter,cIter))
                if angleMat(rIter,cIter)<=seedThresh


                    seedMat(rIter,cIter)=1;
                end


                break;
            end
            rIter=rIter-1;
        end
    end
end

function[labelMat,flagOut]=floodfillAlgo(labelMat,angleMat,rangeMat,angThresh,flagIn)




    flagOut=flagIn;
    coder.gpu.kernel;
    for cIter=1:size(rangeMat,2)
        coder.gpu.kernel;
        for rIter=size(rangeMat,1):-1:1



            checkFlag=isfinite(angleMat(rIter,cIter))&&isfinite(rangeMat(rIter,cIter));

            if checkFlag&&~labelMat(rIter,cIter)






                if rIter>1&&labelMat(rIter-1,cIter)&&...
                    abs(angleMat(rIter-1,cIter)-angleMat(rIter,cIter))<angThresh
                    labelMat(rIter,cIter)=1;


                elseif rIter<size(rangeMat,1)&&labelMat(rIter+1,cIter)&&...
                    abs(angleMat(rIter+1,cIter)-angleMat(rIter,cIter))<angThresh
                    labelMat(rIter,cIter)=1;


                elseif cIter>1&&labelMat(rIter,cIter-1)&&...
                    abs(angleMat(rIter,cIter-1)-angleMat(rIter,cIter))<angThresh
                    labelMat(rIter,cIter)=1;


                elseif cIter<size(rangeMat,2)&&labelMat(rIter,cIter+1)&&...
                    abs(angleMat(rIter,cIter+1)-angleMat(rIter,cIter))<angThresh
                    labelMat(rIter,cIter)=1;
                end



                if labelMat(rIter,cIter)
                    flagOut=1;
                end
            end
        end
    end

end
