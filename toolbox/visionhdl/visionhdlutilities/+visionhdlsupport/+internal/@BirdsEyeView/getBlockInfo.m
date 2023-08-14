function blockInfo=getBlockInfo(this,hC)






    if isa(hC,'hdlcoder.sysobj_comp')

        sysObjHandle=hC.getSysObjImpl;
        blockInfo.HomographyMatrix=sysObjHandle.HomographyMatrix;
        blockInfo.MaxBufferSize=sysObjHandle.MaxBufferSize;
        blockInfo.MaxSourceLinesBuffered=sysObjHandle.MaxSourceLinesBuffered;
        blockInfo.BirdsEyeActivePixels=sysObjHandle.BirdsEyeActivePixels;
        blockInfo.BirdsEyeActiveLines=sysObjHandle.BirdsEyeActiveLines;


    else


        bfp=hC.Simulinkhandle;

        blockInfo.HomographyMatrix=this.hdlslResolve('HomographyMatrix',bfp);
        blockInfo.MaxBufferSize=this.hdlslResolve('MaxBufferSize',bfp);
        blockInfo.MaxSourceLinesBuffered=this.hdlslResolve('MaxSourceLinesBuffered',bfp);
        blockInfo.BirdsEyeActivePixels=this.hdlslResolve('BirdsEyeActivePixels',bfp);
        blockInfo.BirdsEyeActiveLines=this.hdlslResolve('BirdsEyeActiveLines',bfp);

    end


    FGrad=fimath('RoundMode','Nearest',...
    'OverflowMode','Saturate',...
    'SumMode','FullPrecision',...
    'SumWordLength',26,...
    'SumFractionLength',10,...
    'CastBeforeSum',true);

    FOffset=fimath('RoundMode','Nearest',...
    'OverflowMode','Saturate',...
    'SumMode','FullPrecision',...
    'SumWordLength',28,...
    'SumFractionLength',10,...
    'CastBeforeSum',true);

    FRow=fimath('RoundMode','Nearest',...
    'OverflowMode','Saturate',...
    'SumMode','FullPrecision',...
    'SumWordLength',26,...
    'SumFractionLength',10,...
    'CastBeforeSum',true);


    gtype=fi(0,0,26,10);
    otype=fi(0,0,28,10);
    rtype=fi(0,0,26,10);







    hMatrix=inv(blockInfo.HomographyMatrix);


    [rowMap,StartLine,EndLine,BirdsEyeDimensions,ActualSourceLines]=...
    visionhdl.BirdsEyeView.forwardRowMapping(hMatrix,blockInfo.MaxSourceLinesBuffered,...
    blockInfo.BirdsEyeActiveLines,blockInfo.BirdsEyeActivePixels);

    if ActualSourceLines>blockInfo.MaxSourceLinesBuffered
        ActualSourceLines=blockInfo.MaxSourceLinesBuffered;
    end


    blockInfo.StartLine=StartLine;
    blockInfo.EndLine=EndLine;


    [gradVal,offsetVal]=...
    visionhdl.BirdsEyeView.forwardColumnMapping(hMatrix,blockInfo.StartLine,...
    blockInfo.EndLine,rowMap,blockInfo.BirdsEyeActiveLines,blockInfo.BirdsEyeActivePixels,ActualSourceLines);
    rowMap(:)=rowMap(:)+1;
    blockInfo.rowMap=rowMap(1:end);

    blockInfo.RowMap=fi(zeros(1,ActualSourceLines),rtype.numerictype,FRow);
    blockInfo.GradientLUT=fi(zeros(1,ActualSourceLines),gtype.numerictype,FGrad);
    blockInfo.OffsetLUT=fi(zeros(1,ActualSourceLines),otype.numerictype,FOffset);
    rowMap(ActualSourceLines)=rowMap(ActualSourceLines);
    blockInfo.RowMap(:)=rowMap(1:ActualSourceLines);

    blockInfo.GradientLUT(:)=gradVal(1:ActualSourceLines);
    blockInfo.OffsetLUT(:)=offsetVal(1:ActualSourceLines);















end

