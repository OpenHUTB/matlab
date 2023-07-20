function distMat=bwdistEuclideanGPUImpl(img)%#codegen








    coder.allowpcode('plain');
    coder.gpu.internal.kernelfunImpl(false);
    if(numel(img)==0)
        distMat=[];
        return;
    end


    h=size(img,1);
    w=size(img,2);
    ch=size(img,3);




    numEle=w*h*ch;


    tempDist_2D=ones(size(img),'single')*numEle;


    distMat_2D=ones(size(img),'single')*Inf;
    distMat=distMat_2D;


    colRepeatVal=single(16);
    rowRepeatVal=single(1);


    threads=256;


    for channel=1:ch




















        threadsPerBlockX=1;
        threadsPerBlockY=threads;
        BlockDimX=floor((w+colRepeatVal-1)/colRepeatVal);
        BlockDimY=floor((h+threadsPerBlockY-1)/threadsPerBlockY);

        numBlocks=[BlockDimX,BlockDimY,1];
        threadsPerBlock=[threadsPerBlockX,threadsPerBlockY,1];

        coder.gpu.internal.kernelImpl(false,numBlocks,threadsPerBlock,1,'X_kernel');
        for r=1:h
            for c=1:colRepeatVal:w





                if(r>h||c>w)
                    continue;
                end




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
                                break;
                            end





                            if((direction~=1)&&(rightPixColIdx<=w)&&(img(rowVal,rightPixColIdx,channel)~=0))
                                maxDist=k;
                                direction=single(1);
                                break;
                            end
                        end
                    end




                    if(maxDist==0)
                        direction=single(-1);
                    end


                    if(rowVal<=h&&colVal<=w&&rowVal>0&&colVal>0)
                        tempDist_2D(rowVal,colVal,channel)=abs(maxDist);
                    end
                end


            end
        end






        BlockDimX=ceil(numEle/threads);
        BlockDimY=1;

        numBlocks=[BlockDimX,BlockDimY,1];
        threadsPerBlock=[threads,1,1];

        coder.gpu.internal.kernelImpl(false,numBlocks,threadsPerBlock,1,'Y_kernel');
        for c=1:w
            for r=1:rowRepeatVal:h


                colVal=c;
                rowVal=r;


                if(rowVal>h||colVal>w)
                    continue;
                end




                minDist=tempDist_2D(rowVal,colVal,channel);
                minDist2=minDist*minDist;







                maxLookDist=max(h-rowVal,rowVal);
                maxLookDist=min(maxLookDist,minDist);


                for k=1:maxLookDist
                    topPixRowIdx=rowVal-k;
                    bottomPixRowIdx=rowVal+k;



                    if(topPixRowIdx>0)
                        tDist=tempDist_2D(topPixRowIdx,colVal,channel);


                        currDist=k*k+tDist*tDist;


                        if(currDist<minDist2)
                            minDist2=currDist;
                        end
                    end



                    if(bottomPixRowIdx<=h)
                        tDist=tempDist_2D(bottomPixRowIdx,colVal,channel);


                        currDist=k*k+tDist*tDist;


                        if(currDist<minDist2)
                            minDist2=currDist;
                        end
                    end
                end

                if(rowVal<=h&&colVal<=w&&rowVal>0&&colVal>0)
                    distMat_2D(rowVal,colVal,channel)=(minDist2);
                end


            end
        end

    end



    if(ch==1)


        distMat=sqrt(distMat_2D);
        return;
    end






    coder.gpu.internal.kernelImpl(false,-1,-1,1,'Z_kernel');
    for j=1:w
        for i=1:h
            for k1=1:ch
                minVal=distMat_2D(i,j,k1);
                for k2=1:ch
                    val=distMat_2D(i,j,k2)+(k1-k2)*(k1-k2);
                    minVal=single(min(val,minVal));
                end


                if(i<=h&&j<=w&&i>0&&j>0&&k1<=ch&&k1>0)
                    distMat(i,j,k1)=sqrt(minVal);
                end
            end
        end
    end

end
