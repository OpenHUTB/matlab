function[repairRangeOut,repairAngleOut]=segmentGroundPreProcessing(rangeData,nRows,nCols,repairDepthThreshold)















%#codegen
    coder.gpu.internal.kernelfunImpl(false);
    coder.allowpcode('plain');


    repairRange=coder.nullcopy(zeros(nRows,nCols,'like',rangeData));
    repairAngle=coder.nullcopy(zeros(nRows,nCols,'like',rangeData));


    repairPitchTranspose=coder.nullcopy(zeros(nCols,nRows,'like',rangeData));




    coder.gpu.kernel;
    for rIter=1:nRows
        coder.gpu.kernel;
        for cIter=1:nCols
            repairRange(rIter,cIter)=double(rangeData(rIter,cIter,1));
            repairPitchTranspose(cIter,rIter)=double(rangeData(rIter,cIter,2));
            repairAngle(rIter,cIter)=double(rangeData(rIter,cIter,3));
        end
    end






    stepSize=5;
    coder.gpu.kernel;
    for col=1:nCols
        for row=1:nRows




            if~isfinite(rangeData(row,col))
                counter=zeros(1,1,'like',rangeData);
                sum=zeros(1,1,'like',rangeData);
                for i=1:stepSize
                    if row-i<1
                        continue;
                    end
                    prev=repairRange(row-i,col);
                    for j=1:stepSize
                        if row+j>=nRows+1
                            continue;
                        end

                        next=repairRange(row+j,col);

                        if~isfinite(prev)||~isfinite(next)
                            continue;
                        elseif abs(prev-next)<repairDepthThreshold
                            sum=sum+prev+next;
                            counter=counter+2;
                        end
                    end
                end
                if counter>0
                    repairRange(row,col)=sum/counter;
                end
            end
        end
    end












    [nRows_t,nCols_t]=size(repairPitchTranspose);
    coder.gpu.nokernel;
    for col=1:nCols_t
        k2=0;
        for row=1:nRows_t
            if~isfinite(repairPitchTranspose(row,col))
                if row>k2
                    for iter=row+1:nRows_t
                        if isfinite(repairPitchTranspose(iter,col))
                            k2=iter;
                            break;
                        else
                            k2=0;
                        end
                    end
                end

                if row>1
                    k1=row-1;
                else
                    k1=0;
                end

                if k1>=1&&k2>=1
                    repairPitchTranspose(row,col)=repairPitchTranspose(k1,col)*...
                    (k2-row)/(k2-k1)+repairPitchTranspose(k2,col)*...
                    (row-k1)/(k2-k1);
                elseif k1>=1&&k2<1
                    repairPitchTranspose(row,col)=repairPitchTranspose(k1,col);
                elseif k2>=1&&k1<1
                    repairPitchTranspose(row,col)=repairPitchTranspose(k2,col);
                end

            end
        end
    end


    coder.gpu.kernel;
    for row=1:nRows-1
        coder.gpu.kernel;
        for col=1:nCols
            if~isfinite(repairRange(row+1,col))||...
                ~isfinite(repairRange(row,col))||...
                ~isfinite(repairPitchTranspose(col,row))||...
                ~isfinite(repairPitchTranspose(col,row+1))
                repairAngle((col-1)*nRows+row+1)=NaN;
            else
                repairPitchVal=repairPitchTranspose(col,row);
                repairPitchValNext=repairPitchTranspose(col,row+1);

                repairRangeVal=repairRange(row,col);
                repairRangeVal_next=repairRange(row+1,col);

                deltaZ=abs(repairRangeVal_next*...
                sin(repairPitchValNext)-repairRangeVal*...
                sin(repairPitchVal));
                deltaX=abs(repairRangeVal_next*...
                cos(repairPitchValNext)-repairRangeVal*...
                cos(repairPitchVal));
                repairAngle(row+1,col)=atan2(deltaZ,deltaX);
            end
        end
    end







    if nRows>1
        coder.gpu.kernel;
        for col=1:nCols
            repairAngle(1,col)=repairAngle(2,col);
        end
    end




    repairRangeOut=cast(repairRange,class(rangeData));
    repairAngleOut=cast(repairAngle,class(rangeData));

end
