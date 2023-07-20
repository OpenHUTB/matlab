function[numBlocks,numColumnPerBlock,numColumnPerBlockVec]=computeGemmConvBlockSizes(maxNumElements,...
    imageMatrixHeight,imageMatrixWidth)






%#codegen


    coder.allowpcode('plain')

    numElemsImageMatrix=imageMatrixHeight*imageMatrixWidth;

    if maxNumElements>=numElemsImageMatrix

        numBlocks=1;
        numColumnPerBlock=imageMatrixWidth;
        numColumnPerBlockVec=numColumnPerBlock;
    elseif maxNumElements<=imageMatrixHeight



        numBlocks=imageMatrixWidth;
        numColumnPerBlock=1;
        numColumnPerBlockVec=ones([numBlocks,1]);
    else


        numColumnPerBlock=floor(maxNumElements/imageMatrixHeight);
        lastBlockSize=mod(imageMatrixWidth,numColumnPerBlock);
        numBlocks=floor(imageMatrixWidth/numColumnPerBlock);

        if lastBlockSize>0
            numColumnPerBlockVec=[repmat(numColumnPerBlock,[numBlocks,1]);lastBlockSize];
            numBlocks=numBlocks+1;
        else
            numColumnPerBlockVec=repmat(numColumnPerBlock,[numBlocks,1]);
        end
    end

end