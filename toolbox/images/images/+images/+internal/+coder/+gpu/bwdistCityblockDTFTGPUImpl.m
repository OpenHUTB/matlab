function[distMat,idxMat]=bwdistCityblockDTFTGPUImpl(img)%#codegen








    coder.allowpcode('plain');
    coder.gpu.internal.kernelfunImpl(false);
    if(numel(img)==0)
        distMat=[];
        idxMat=[];
        return;
    end


    h=size(img,1);
    w=size(img,2);
    ch=size(img,3);




    numEle=w*h*ch;


    tempDist_2D=ones(size(img),'single')*Inf;


    distMat=ones(size(img),'single')*Inf;
    distMat_2D=distMat;


    colRepeatVal=single(16);
    rowRepeatVal=single(1);


    threads=256;


    tmpIdx=single(-1);

    if(numel(img)<2^32)
        isMatrixShort=true;
        idxMat_2D=ones(size(img),'uint32');
        idxMat=ones(size(img),'uint32');
    else
        isMatrixShort=false;
        idxMat_2D=ones(size(img),'uint64');
        idxMat=ones(size(img),'uint64');
    end


    for channel=1:ch


        if(isMatrixShort)
            tempIdxMat=zeros([size(img,1),size(img,2)],'uint32');
        else
            tempIdxMat=zeros([size(img,1),size(img,2)],'uint64');
        end





















        threadsPerBlockX=1;
        threadsPerBlockY=threads;
        BlockDimX=floor((w+colRepeatVal-1)/colRepeatVal);
        BlockDimY=floor((h+threadsPerBlockY-1)/threadsPerBlockY);

        numblocks=[BlockDimX,BlockDimY,1];
        threadsPerBlock=[threadsPerBlockX,threadsPerBlockY,1];

        coder.gpu.internal.kernelImpl(false,numblocks,threadsPerBlock,1,'X_kernel');
        for r=1:h
            for c=1:colRepeatVal:w





                if(r>h||c>w)
                    continue;
                end

                tmpIdx=single(-1);



                maxDist=single(Inf);





                direction=single(0);


                for i=0:colRepeatVal-1



                    rowVal=r;
                    colVal=c+i;
                    maxDist=maxDist-direction;

                    if((i==0||direction~=0)&&(maxDist~=0))







                        maxLookDist=max(w-colVal+1,colVal);
                        maxLookDist=min(maxLookDist,maxDist);






                        for k=0:maxLookDist-1
                            leftPixColIdx=colVal-k;
                            rightPixColIdx=colVal+k;





                            if((direction~=-1)&&(leftPixColIdx>0)&&(img(rowVal,leftPixColIdx,channel)~=0))
                                maxDist=k;
                                direction=single(-1);
                                tmpIdx=(leftPixColIdx-1)*h+(rowVal-1)+(w*h*(channel-1));
                                break;
                            end





                            if((direction~=1)&&(rightPixColIdx<=w)&&(img(rowVal,rightPixColIdx,channel)~=0))
                                maxDist=k;
                                direction=single(1);
                                tmpIdx=(rightPixColIdx-1)*h+(rowVal-1)+(w*h*(channel-1));
                                break;
                            end
                        end
                    end




                    if(maxDist==0)
                        direction=single(-1);
                    end


                    if(tmpIdx~=-1&&rowVal<=h&&colVal<=w&&rowVal>0&&colVal>0)
                        if(isMatrixShort)
                            tempIdxMat(rowVal,colVal)=uint32(tmpIdx+1);
                        else
                            tempIdxMat(rowVal,colVal)=uint64(tmpIdx+1);
                        end
                        tempDist_2D(rowVal,colVal,channel)=(direction*maxDist);
                    end

                end


            end
        end






        BlockDimX=ceil(numEle/threads);
        BlockDimY=1;

        numblocks=[BlockDimX,BlockDimY,1];
        threadsPerBlock=[threads,1,1];
        coder.gpu.internal.kernelImpl(false,numblocks,threadsPerBlock,1,'Y_kernel');
        for c=1:w
            for r=1:rowRepeatVal:h


                colVal=c;
                rowVal=r;


                if(rowVal>h||colVal>w)
                    continue;
                end

                tmpIdx=single(tempIdxMat(rowVal,colVal));




                minDist=abs(tempDist_2D(rowVal,colVal,channel));
                minDist2=minDist;







                maxLookDist=max(h-rowVal,rowVal);
                maxLookDist=min(maxLookDist,minDist);


                for k=1:maxLookDist
                    topPixRowIdx=rowVal-k;
                    bottomPixRowIdx=rowVal+k;



                    if(topPixRowIdx>0)
                        tDist=tempDist_2D(topPixRowIdx,colVal,channel);
                        chkIdx=(colVal-1+tDist)*h+topPixRowIdx+(w*h*(channel-1));


                        currDist=(abs(topPixRowIdx-r)+abs(tDist));


                        if(currDist<minDist2)
                            tmpIdx=chkIdx;
                            minDist2=currDist;

                        elseif(currDist==minDist2&&chkIdx<=tmpIdx)
                            tmpIdx=chkIdx;
                        end
                    end



                    if(bottomPixRowIdx<=h)
                        tDist=tempDist_2D(bottomPixRowIdx,colVal,channel);
                        chkIdx=(colVal-1+tDist)*h+bottomPixRowIdx+(w*h*(channel-1));


                        currDist=(abs(bottomPixRowIdx-r)+abs(tDist));


                        if(currDist<minDist2)
                            tmpIdx=chkIdx;
                            minDist2=currDist;

                        elseif(currDist==minDist2&&chkIdx<=tmpIdx)
                            tmpIdx=chkIdx;
                        end
                    end
                end

                if(tmpIdx~=-1&&isMatrixShort)
                    idxMat_2D(rowVal,colVal,channel)=uint32(tmpIdx);
                elseif(tmpIdx~=-1)
                    idxMat_2D(rowVal,colVal,channel)=uint64(tmpIdx);
                end


                if(rowVal<=h&&colVal<=w&&rowVal>0&&colVal>0)
                    distMat_2D(rowVal,colVal,channel)=(minDist2);
                end


            end
        end


    end


    if(ch==1)

        distMat=distMat_2D;
        idxMat=idxMat_2D;
        return;
    end






    coder.gpu.internal.kernelImpl(false,-1,-1,1,'Z_kernel');
    for j=1:w
        for i=1:h
            for k1=1:ch
                minVal=distMat_2D(i,j,k1);
                minIdx=single(idxMat_2D(i,j,k1));
                for k2=1:ch


                    val=distMat_2D(i,j,k2)+abs(k1-k2);

                    if(val<minVal)
                        minVal=val;
                        minIdx=single(idxMat_2D(i,j,k2));

                    elseif(val==minVal&&single(idxMat_2D(i,j,k2))<minIdx)
                        minIdx=single(idxMat_2D(i,j,k2));
                    end
                end


                if(i<=h&&j<=w&&i>0&&j>0&&k1<=ch&&k1>0)
                    distMat(i,j,k1)=(minVal);
                end

                if(minIdx~=-1&&isMatrixShort)
                    idxMat(i,j,k1)=uint32(minIdx);
                elseif(minIdx~=-1)
                    idxMat(i,j,k1)=uint64(minIdx);
                end
            end
        end
    end

end
