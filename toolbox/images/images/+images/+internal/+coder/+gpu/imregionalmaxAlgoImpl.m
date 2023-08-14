function BW=imregionalmaxAlgoImpl(I,connb,floatEpsilonFlag)%#codegen

















    coder.allowpcode('plain');



    BW=regionalmax2D(I,connb,floatEpsilonFlag);
end

function BW=regionalmax2D(I,connb,floatEpsilonFlag)%#codegen
    coder.inline('always')
    coder.gpu.constantMemory(connb);

    imgSz=size(I);





    Ipadded=coder.nullcopy(zeros(imgSz(1)+2,imgSz(2)+2,class(I)));

    coder.gpu.kernel;
    for row=1:size(Ipadded,2)
        coder.gpu.kernel;
        for col=1:size(Ipadded,1)
            if col==1||row==1||col==size(Ipadded,1)||row==size(Ipadded,2)
                if isfloat(I)

                    Ipadded(col,row)=-realmax(class(I));
                elseif isinteger(I)

                    Ipadded(col,row)=-intmax(class(I));
                else

                    Ipadded(col,row)=false;
                end
            else
                Ipadded(col,row)=I(col-1,row-1);
            end
        end
    end



    BW=gpucoder.stencilKernel(@localMaxima2D,Ipadded,[3,3],'valid',connb);














    dummyRepeat=2;

    dummyIncrementAfter=5;

    dummyRepeatMax=4;


    globalReiterateFlag=true;
    while(globalReiterateFlag)
        globalReiterateFlag=false;


        coder.gpu.nokernel;
        for dummy=1:floor(dummyRepeat)
            coder.gpu.kernel;
            for row=1:imgSz(2)
                coder.gpu.kernel;
                for col=1:imgSz(1)

                    if BW(col,row)
                        for rowDelta=-1:1
                            for colDelta=-1:1



                                checkFlag=updateBW2D(BW,I,col,row,colDelta,rowDelta,connb,floatEpsilonFlag);
                                if checkFlag
                                    BW(col,row)=false;
                                    globalReiterateFlag=true;
                                end
                            end
                        end
                    end
                end
            end
        end






        dummyRepeat=min(dummyRepeat+(1/dummyIncrementAfter),...
        dummyRepeatMax);
    end
end


function checkFlag=updateBW2D(BW,I,col,row,colDelta,rowDelta,connb,floatEpsilonFlag)%#codegen
    coder.inline('always')

    imgSz=size(I);

    if(col+colDelta<1)||(col+colDelta>imgSz(1))||...
        (row+rowDelta<1)||(row+rowDelta>imgSz(2))
        checkFlag=false;
    else
        neighbourValue=I(col+colDelta,row+rowDelta);
        neighbourMaxima=BW(col+colDelta,row+rowDelta);

        checkFlag=connb(colDelta+2,rowDelta+2);



        if isfloat(I)&&floatEpsilonFlag
            checkFlag=checkFlag&&(abs(neighbourValue-I(col,row))<eps);
        else
            checkFlag=checkFlag&&(neighbourValue==I(col,row));
        end

        checkFlag=checkFlag&&~neighbourMaxima;
    end
end

function retVal=localMaxima2D(inpImgPatch,connb)%#codegen



    retVal=true;
    numElems=numel(inpImgPatch);
    midIdx=int8((numElems+1)/2);
    midEle=inpImgPatch(midIdx);
    for itr=[1:midIdx-1,midIdx+1:numElems]
        if connb(itr)&&inpImgPatch(itr)>midEle
            retVal=false;
            return
        end
    end
end
