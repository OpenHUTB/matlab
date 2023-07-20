classdef(Hidden,StrictDefaults)abstractLineMemoryKernel<matlab.System





%#codegen

    properties(Access=protected,Nontunable)
        KernelMemoryKernelHeight;
        KernelMemoryKernelWidth;
        KernelMemoryPaddingMethod;
        KernelMemoryPaddingValue;
        KernelMemoryMaxLineSize=double(0);
        KernelMemoryCeilMaxLineSize=double(0);
        KernelMemoryBiasUp;
    end

    properties(Access=private)
        KernelMemoryInLine;
        KernelMemoryInFrame;
        KernelMemoryInLineInFrame;
        KernelMemoryCtrlDelay;
        KernelMemoryValidationDelay;
        KernelMemoryInLineInFrameDelay;
        KernelMemoryDataReadFSMState;
        KernelMemoryDataReadFSMInBetween;
        KernelMemoryDataReadControlREG;
        KernelMemoryLineSpaceCounter;
        KernelMemoryLineSpaceDelayLine;
        KernelMemoryLineStartV;
        KernelMemoryLineInfoStore;
        KernelMemoryRAMColumn;
        KernelMemoryPushPopReadCounterV;
        KernelMemoryPushPopWriteCounterV;
        KernelMemoryPushPopWriteCounterPrevV;
        KernelMemoryPushPopLineLengthNext;
        KernelMemoryPushPopLineLengthCurrent;
        KernelMemoryPushPopInBetween;
        KernelMemoryhEndRegV;

        KernelMemoryAllEndOfLine;
        KernelMemoryBlankingCount;
        KernelMemoryWriteCounterReg;
        KernelMemoryWriteEnableReg;
        KernelMemoryPixelInputReg;
        KernelMemoryPadREG;
        KernelMemoryControlOutputREG;
        KernelMemoryPaddingFSMState;
        KernelMemoryhStartDelayLine;
        KernelMemoryhEndDelayLine;
        KernelMemoryvStartDelayLine;
        KernelMemoryvEndDelayLine;
        KernelMemoryvalidDelayLine;
        KernelMemorydumpControlREG;
        KernelMemoryPreProcess;
        KernelMemoryHorizontalPadCount;
        KernelMemoryDataVectorREG;
        KernelMemoryPopREG;
        KernelMemoryHorizontalPaddingShiftReg;
        KernelMemoryProcessDataGatedREG;
        KernelMemoryPreProcessREG;
        KernelMemoryOnLineFlag;
        KernelMemoryRAMColumnREG;
        KernelMemoryVerticalPadCounter;
        KernelMemoryFirstLineEn;
        KernelMemoryLineLoadTo;
        KernelMemoryEvenBiasConstant;
        KernelMemoryOnLine;
        KernelMemoryTwo;
        KernelMemorySymmetricPadArray;
        KernelMemoryPixelOutputREG;
        KernelMemoryOutputCastHandle;
        KernelMemoryProcessOutREG;
        KernelMemoryCtrlInputREG;
        KernelMemoryLineSpaceAverage;
        KernelMemoryInBetween;
        KernelMemoryLineSpaceAverageSum;
        KernelMemoryLowerPaddingLUT;
        KernelMemoryUpperPaddingLUT;
        KernelMemoryProcessOnLine;
        KernelMemoryProcessPrePad;
        KernelMemoryProcessPostPad;
        KernelMemoryProcessCounter;
        KernelMemoryTwoPixelEdgeCase;
    end

    properties(Access=private,Nontunable)
        KernelMemoryKernelPHeight=5;
        KernelMemoryKernelPWidth=5;
        KernelMemoryDataMemoryHandle=@DataMemoryMultiPixels;
        KernelMemoryNumberOfPixels=1;
    end

    properties(Constant,Hidden)
        KernelMemoryPaddingMethodSet=matlab.system.StringSet({...
        'Constant',...
        'Replicate',...
        'Symmetric',...
        'Reflection',...
        'None'});
    end

    methods
        function obj=abstractLineMemoryKernel(varargin)
            coder.allowpcode('plain');
        end
    end

    methods(Access=protected)

        function validateKernelMemoryConfiguration(obj,pixelIn,kernelSize)
            pixSize=size(pixelIn);

            if pixSize(1)>1
                if~ismember(pixSize(1),[2,4,8])
                    coder.internal.error('visionhdl:LineBuffer:InputDimensions');
                end

                if(kernelSize(1)==1||kernelSize(2)==1)
                    coder.internal.error('visionhdl:LineBuffer:MultiplePixelsKernelSize');
                end

                if(strcmpi(obj.PaddingMethod,'Symmetric')||strcmpi(obj.PaddingMethod,'Reflection'))&&kernelSize(1)==2&&kernelSize(2)>4
                    coder.internal.error('visionhdl:LineBuffer:MultiplePixelsKernelSize');
                end
            end

            if pixSize(2)>1
                coder.internal.error('visionhdl:LineBuffer:InputDimensions');
            end
        end

        function setupKernelMemory(obj,pixelIn,~,~,~,~,~)
            if~coder.target('hdl')

                pixSize=size(pixelIn);

                if pixSize(2)>1
                    coder.internal.error('visionhdl:LineBuffer:InputDimensions');
                end

                if pixSize(1)>1
                    if~ismember(pixSize(1),[2,4,8])
                        coder.internal.error('visionhdl:LineBuffer:InputDimensions');
                    end
                end

                if obj.KernelMemoryKernelHeight==2||obj.KernelMemoryKernelWidth==2
                    if obj.KernelMemoryKernelHeight==2
                        obj.KernelMemoryKernelPHeight=3;
                    else
                        obj.KernelMemoryKernelPHeight=obj.KernelMemoryKernelHeight;
                    end

                    if obj.KernelMemoryKernelWidth==2
                        obj.KernelMemoryKernelPWidth=3;
                    else
                        obj.KernelMemoryKernelPWidth=obj.KernelMemoryKernelWidth;
                    end
                    obj.KernelMemoryTwo=true;
                    if obj.KernelMemoryKernelHeight==2
                        if obj.KernelMemoryBiasUp
                            obj.KernelMemoryOutputCastHandle=@OutputTwoKernelUp;
                        else
                            obj.KernelMemoryOutputCastHandle=@OutputTwoKernelDown;
                        end
                    else
                        obj.KernelMemoryOutputCastHandle=@OutputFullKernel;
                    end

                elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&mod(obj.KernelMemoryKernelHeight,2)==0&&obj.KernelMemoryKernelHeight>2
                    obj.KernelMemoryKernelPHeight=obj.KernelMemoryKernelHeight+1;
                    obj.KernelMemoryKernelPWidth=obj.KernelMemoryKernelWidth;
                    obj.KernelMemoryTwo=false;
                    if obj.KernelMemoryKernelWidth>1
                        obj.KernelMemoryOutputCastHandle=@OutputFullKernel;
                    else
                        obj.KernelMemoryOutputCastHandle=@OutputEvenColumnKernel;
                    end
                else
                    obj.KernelMemoryKernelPHeight=obj.KernelMemoryKernelHeight;
                    obj.KernelMemoryKernelPWidth=obj.KernelMemoryKernelWidth;
                    obj.KernelMemoryTwo=false;
                    obj.KernelMemoryOutputCastHandle=@OutputFullKernel;
                end

                if pixSize(1)==1
                    obj.KernelMemoryNumberOfPixels=1;
                else
                    obj.KernelMemoryNumberOfPixels=pixSize(1);
                end

                obj.KernelMemoryInLine=false;
                obj.KernelMemoryProcessOutREG=false;
                obj.KernelMemoryInFrame=false;
                obj.KernelMemoryInLineInFrame=false;
                obj.KernelMemoryInLineInFrameDelay=false;
                obj.KernelMemoryAllEndOfLine=false;
                obj.KernelMemoryCtrlDelay=...
                pixelcontrolstruct(false,false,false,false,false);
                obj.KernelMemoryDataReadControlREG=...
                pixelcontrolstruct(false,false,false,false,false);
                obj.KernelMemoryDataReadFSMState=0;
                obj.KernelMemoryDataReadFSMInBetween=false;
                obj.KernelMemoryLineStartV=false(ceil((obj.KernelMemoryKernelPHeight+1)/2),1);
                if isfloat(pixelIn)||islogical(pixelIn)
                    obj.KernelMemoryLineSpaceDelayLine=zeros(1,4);
                else
                    obj.KernelMemoryLineSpaceDelayLine=uint16(zeros(1,4));
                end
                obj.KernelMemoryCeilMaxLineSize=2^(ceil(log2(double(obj.KernelMemoryMaxLineSize))));

                if obj.KernelMemoryNumberOfPixels==1
                    obj.KernelMemoryRAMColumn=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryCeilMaxLineSize)...
                    ,'like',pixelIn);
                    obj.KernelMemoryRAMColumnREG=cast(zeros(obj.KernelMemoryKernelPHeight,1)...
                    ,'like',pixelIn);
                    obj.KernelMemoryDataMemoryHandle=@DataMemory;
                else
                    obj.KernelMemoryRAMColumn=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryCeilMaxLineSize,obj.KernelMemoryNumberOfPixels)...
                    ,'like',pixelIn);
                    obj.KernelMemoryRAMColumnREG=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels)...
                    ,'like',pixelIn);
                    obj.KernelMemoryDataMemoryHandle=@DataMemoryMultiPixels;
                end

                obj.KernelMemoryLineSpaceCounter=uint16(0);
                obj.KernelMemoryPushPopReadCounterV=uint16(ones(obj.KernelMemoryKernelPHeight,1));
                obj.KernelMemoryPushPopWriteCounterV=uint16(ones(obj.KernelMemoryKernelPHeight,1));
                obj.KernelMemoryPushPopWriteCounterPrevV=uint16(ones(obj.KernelMemoryKernelPHeight,1));
                obj.KernelMemoryPushPopLineLengthNext=uint16(ones(obj.KernelMemoryKernelPHeight,1));
                obj.KernelMemoryPushPopLineLengthCurrent=uint16(ones(obj.KernelMemoryKernelPHeight,1));
                obj.KernelMemoryPushPopInBetween=false(obj.KernelMemoryKernelPHeight,1);
                obj.KernelMemoryhEndRegV=false(obj.KernelMemoryKernelPHeight,1);
                obj.KernelMemoryBlankingCount=uint16(0);
                obj.KernelMemoryWriteCounterReg=uint16(ones(obj.KernelMemoryKernelPHeight,1));
                obj.KernelMemoryWriteEnableReg=false(obj.KernelMemoryKernelPHeight,1);

                if obj.KernelMemoryKernelWidth==1
                    obj.KernelMemoryPixelInputReg=cast(zeros(8,obj.KernelMemoryNumberOfPixels),'like',pixelIn);
                elseif~strcmpi(obj.KernelMemoryPaddingMethod,'None')
                    obj.KernelMemoryPixelInputReg=cast(zeros(9,obj.KernelMemoryNumberOfPixels),'like',pixelIn);
                else
                    obj.KernelMemoryPixelInputReg=cast(zeros(9,obj.KernelMemoryNumberOfPixels),'like',pixelIn);
                end
                obj.KernelMemoryPixelOutputREG=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryNumberOfPixels),'like',pixelIn);
                obj.KernelMemoryPadREG=...
                pixelcontrolstruct(false,false,false,false,false);
                obj.KernelMemoryControlOutputREG=false(5,6);

                if obj.KernelMemoryKernelWidth==1
                    obj.KernelMemoryCtrlInputREG=false(5,5);
                else
                    obj.KernelMemoryCtrlInputREG=false(5,6);
                end
                obj.KernelMemoryPaddingFSMState=0;


                obj.KernelMemoryTwoPixelEdgeCase=(obj.KernelMemoryNumberOfPixels==2&&mod(floor((obj.KernelMemoryKernelPWidth-1)/2),2)==1&&obj.KernelMemoryKernelPWidth>4);

                if strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels==1
                    if mod(obj.KernelMemoryKernelPWidth,2)==0
                        obj.KernelMemoryhStartDelayLine=false((obj.KernelMemoryKernelPWidth-1),1);
                        obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth+floor(obj.KernelMemoryKernelPWidth/2)-1,1);
                        obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                        obj.KernelMemoryvEndDelayLine=false(obj.KernelMemoryKernelPWidth-2,1);
                        obj.KernelMemoryvalidDelayLine=false((obj.KernelMemoryKernelPWidth)-1,1);
                    else
                        obj.KernelMemoryhStartDelayLine=false((obj.KernelMemoryKernelPWidth),1);
                        obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth+floor(obj.KernelMemoryKernelPWidth/2),1);
                        obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                        obj.KernelMemoryvEndDelayLine=false(obj.KernelMemoryKernelPWidth-1,1);
                        obj.KernelMemoryvalidDelayLine=false((obj.KernelMemoryKernelPWidth)-1,1);
                    end

                elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels==1
                    if mod(obj.KernelMemoryKernelPWidth,2)==0
                        obj.KernelMemoryhStartDelayLine=false((obj.KernelMemoryKernelPWidth),1);
                        obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth+floor(obj.KernelMemoryKernelPWidth/2),1);
                        obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+1,1);
                        obj.KernelMemoryvEndDelayLine=false(obj.KernelMemoryKernelPWidth-1,1);
                        obj.KernelMemoryvalidDelayLine=false((obj.KernelMemoryKernelPWidth),1);
                    else
                        obj.KernelMemoryhStartDelayLine=false((obj.KernelMemoryKernelPWidth)+1,1);
                        obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth+floor(obj.KernelMemoryKernelPWidth/2)+1,1);
                        obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+1,1);
                        obj.KernelMemoryvEndDelayLine=false(obj.KernelMemoryKernelPWidth,1);
                        obj.KernelMemoryvalidDelayLine=false((obj.KernelMemoryKernelPWidth),1);
                    end

                elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&obj.KernelMemoryNumberOfPixels>1
                    if obj.KernelMemoryKernelPWidth<4
                        obj.KernelMemoryhStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+2,1);
                        obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth+1,1);
                        obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+2,1);
                        obj.KernelMemoryvEndDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                        obj.KernelMemoryvalidDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    elseif mod(obj.KernelMemoryKernelPWidth,2)==0
                        obj.KernelMemoryhStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+1,1);
                        obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth+1,1);
                        obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+1,1);
                        obj.KernelMemoryvEndDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                        obj.KernelMemoryvalidDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    else
                        obj.KernelMemoryhStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+2,1);
                        obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth+2,1);
                        obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+2,1);
                        obj.KernelMemoryvEndDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+1,1);
                        obj.KernelMemoryvalidDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+1,1);
                    end

                elseif strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryTwoPixelEdgeCase
                    obj.KernelMemoryhStartDelayLine=false(ceil(obj.KernelMemoryKernelPWidth/2)+1,1);
                    obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth,1);
                    obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    if mod(obj.KernelMemoryKernelPWidth,2)==0&&(obj.KernelMemoryKernelPWidth>2)&&obj.KernelMemoryBiasUp
                        obj.KernelMemoryvEndDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)-1,1);
                        obj.KernelMemoryvalidDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)-1,1);
                    else
                        obj.KernelMemoryvEndDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                        obj.KernelMemoryvalidDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    end
                elseif mod(obj.KernelMemoryKernelPWidth,2)==0&&(obj.KernelMemoryKernelPWidth>2)&&obj.KernelMemoryBiasUp
                    obj.KernelMemoryhStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth,1);
                    obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    obj.KernelMemoryvEndDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)-1,1);
                    obj.KernelMemoryvalidDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)-1,1);
                elseif mod(obj.KernelMemoryKernelPWidth,2)==0&&~obj.KernelMemoryBiasUp
                    obj.KernelMemoryhStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)+1,1);
                    obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth,1);
                    obj.KernelMemoryvStartDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    obj.KernelMemoryvEndDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    obj.KernelMemoryvalidDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2)-1,1);
                else
                    obj.KernelMemoryhStartDelayLine=false(ceil(obj.KernelMemoryKernelPWidth/2),1);
                    obj.KernelMemoryhEndDelayLine=false(obj.KernelMemoryKernelPWidth,1);
                    obj.KernelMemoryvStartDelayLine=false(ceil(obj.KernelMemoryKernelPWidth/2),1);
                    obj.KernelMemoryvEndDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                    obj.KernelMemoryvalidDelayLine=false(floor(obj.KernelMemoryKernelPWidth/2),1);
                end

                obj.KernelMemorydumpControlREG=[false,false];
                obj.KernelMemoryPreProcess=false;
                obj.KernelMemoryHorizontalPadCount=uint16(zeros(1,2));
                obj.KernelMemoryDataVectorREG=cast(zeros(obj.KernelMemoryKernelPHeight,2,obj.KernelMemoryNumberOfPixels)...
                ,'like',pixelIn);
                obj.KernelMemoryPopREG=false;

                if strcmpi(obj.KernelMemoryPaddingMethod,'Constant')

                    if mod(obj.KernelMemoryKernelPWidth,2)==0&&obj.KernelMemoryBiasUp
                        obj.KernelMemoryHorizontalPaddingShiftReg=cast(zeros(obj.KernelMemoryKernelPHeight,floor(obj.KernelMemoryKernelPWidth/2)-1,obj.KernelMemoryNumberOfPixels)...
                        ,'like',pixelIn);
                    elseif mod(obj.KernelMemoryKernelPWidth,2)==0&&~obj.KernelMemoryBiasUp
                        obj.KernelMemoryHorizontalPaddingShiftReg=cast(zeros(obj.KernelMemoryKernelPHeight,floor(obj.KernelMemoryKernelPWidth/2),obj.KernelMemoryNumberOfPixels)...
                        ,'like',pixelIn);
                    else
                        obj.KernelMemoryHorizontalPaddingShiftReg=cast(zeros(obj.KernelMemoryKernelPHeight,ceil(obj.KernelMemoryKernelPWidth/2),obj.KernelMemoryNumberOfPixels)...
                        ,'like',pixelIn);
                    end

                elseif strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')||strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')
                    obj.KernelMemoryHorizontalPaddingShiftReg=cast(zeros(obj.KernelMemoryKernelPHeight,(obj.KernelMemoryKernelPWidth*2),obj.KernelMemoryNumberOfPixels)...
                    ,'like',pixelIn);

                elseif strcmpi(obj.KernelMemoryPaddingMethod,'None')
                    obj.KernelMemoryHorizontalPaddingShiftReg=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels)...
                    ,'like',pixelIn);

                else
                    obj.KernelMemoryHorizontalPaddingShiftReg=cast(zeros(obj.KernelMemoryKernelPHeight,(obj.KernelMemoryKernelPWidth),obj.KernelMemoryNumberOfPixels)...
                    ,'like',pixelIn);
                end

                if mod(obj.KernelMemoryKernelPHeight,2)==0&&obj.KernelMemoryBiasUp
                    obj.KernelMemoryLineLoadTo=ceil(obj.KernelMemoryKernelPHeight/2)+1;
                    obj.KernelMemoryEvenBiasConstant=1;
                elseif mod(obj.KernelMemoryKernelPHeight,2)==0&&~obj.KernelMemoryBiasUp
                    obj.KernelMemoryLineLoadTo=ceil(obj.KernelMemoryKernelPHeight/2);
                    obj.KernelMemoryEvenBiasConstant=1;
                else
                    obj.KernelMemoryLineLoadTo=ceil(obj.KernelMemoryKernelPHeight/2);
                    obj.KernelMemoryEvenBiasConstant=0;
                end

                obj.KernelMemoryProcessDataGatedREG=false;
                obj.KernelMemoryPreProcessREG=false;
                obj.KernelMemoryOnLineFlag=false;
                obj.KernelMemoryVerticalPadCounter=uint16(0);
                obj.KernelMemoryFirstLineEn=false;
                obj.KernelMemoryValidationDelay=...
                pixelcontrolstruct(false,false,false,false,false);
                obj.KernelMemoryOnLine=false;
                obj.KernelMemorySymmetricPadArray=ones(1,ceil(obj.KernelMemoryKernelPHeight/2));

                for ii=2:1:ceil(obj.KernelMemoryKernelPHeight/2)
                    obj.KernelMemorySymmetricPadArray(1,ii)=(ii*2)-1;
                end

                if isfloat(pixelIn)||islogical(pixelIn)
                    obj.KernelMemoryLineSpaceAverage=0;
                    obj.KernelMemoryLineSpaceAverageSum=0;
                else
                    obj.KernelMemoryLineSpaceAverage=uint16(0);
                    obj.KernelMemoryLineSpaceAverageSum=uint16(0);
                end
                obj.KernelMemoryInBetween=false;


                obj.KernelMemoryLowerPaddingLUT=ones(floor(obj.KernelMemoryKernelWidth/2)-1,1);

                if strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')
                    obj.KernelMemoryUpperPaddingLUT=ones(floor(obj.KernelMemoryKernelWidth/2)+1,1);
                else
                    obj.KernelMemoryUpperPaddingLUT=ones(floor(obj.KernelMemoryKernelWidth/2),1);
                end



                evenBiasConstant=double(mod(obj.KernelMemoryKernelWidth,2)==0);

                paddingCycles=ceil((floor(obj.KernelMemoryKernelWidth/2))/obj.KernelMemoryNumberOfPixels);

                if obj.KernelMemoryNumberOfPixels>1
                    lowerPaddingCycles=ceil((floor(obj.KernelMemoryKernelWidth/2)-evenBiasConstant)/obj.KernelMemoryNumberOfPixels);
                    if paddingCycles==0
                        paddingCycles=1;
                        lowerPaddingCycles=1;
                    end
                elseif paddingCycles==1
                    lowerPaddingCycles=paddingCycles;
                elseif paddingCycles==0
                    paddingCycles=1;
                    lowerPaddingCycles=1;
                else
                    lowerPaddingCycles=paddingCycles-evenBiasConstant;
                end

                if obj.KernelMemoryNumberOfPixels>1

                    for ii=1:1:floor(obj.KernelMemoryKernelWidth/2)
                        if ii<=paddingCycles
                            obj.KernelMemoryUpperPaddingLUT(ii)=floor(obj.KernelMemoryKernelWidth/2)+1+(2*(ii-1))-evenBiasConstant;
                        else
                            obj.KernelMemoryUpperPaddingLUT(ii)=floor(obj.KernelMemoryKernelWidth/2)+1-evenBiasConstant;
                        end
                    end

                    for ii=1:1:floor(obj.KernelMemoryKernelWidth/2)-1
                        if ii<=lowerPaddingCycles
                            obj.KernelMemoryLowerPaddingLUT(end-(ii-1))=floor(obj.KernelMemoryKernelWidth/2)-1-(2*(ii-1))-evenBiasConstant;
                        else
                            obj.KernelMemoryLowerPaddingLUT(end-(ii-1))=floor(obj.KernelMemoryKernelWidth/2)-1-evenBiasConstant;
                        end
                    end

                    if(floor(obj.KernelMemoryKernelWidth/2)-1)>1
                        obj.KernelMemoryLowerPaddingLUT(obj.KernelMemoryLowerPaddingLUT==0)=min(obj.KernelMemoryLowerPaddingLUT(obj.KernelMemoryLowerPaddingLUT>0));
                    end
                end

                obj.KernelMemoryProcessOnLine=false;
                obj.KernelMemoryProcessPrePad=false;
                obj.KernelMemoryProcessPostPad=false;
                obj.KernelMemoryProcessCounter=uint8(0);

            else

                obj.KernelMemoryKernelPHeight=1;
                obj.KernelMemoryKernelPWidth=1;
                obj.KernelMemoryNumberOfPixels=length(pixelIn);

                obj.KernelMemoryPixelOutputREG=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryNumberOfPixels),'like',pixelIn);
                obj.KernelMemoryDataReadFSMState=0;

                if obj.KernelMemoryNumberOfPixels==1
                    obj.KernelMemoryRAMColumn=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryCeilMaxLineSize)...
                    ,'like',pixelIn);
                    obj.KernelMemoryRAMColumnREG=cast(zeros(obj.KernelMemoryKernelPHeight,1)...
                    ,'like',pixelIn);
                    obj.KernelMemoryDataMemoryHandle=@DataMemory;
                else
                    obj.KernelMemoryRAMColumn=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryCeilMaxLineSize,obj.KernelMemoryNumberOfPixels)...
                    ,'like',pixelIn);
                    obj.KernelMemoryRAMColumnREG=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels)...
                    ,'like',pixelIn);
                    obj.KernelMemoryDataMemoryHandle=@DataMemoryMultiPixels;
                end

                if isfloat(pixelIn)||islogical(pixelIn)
                    obj.KernelMemoryLineSpaceDelayLine=zeros(1,4);
                    obj.KernelMemoryLineSpaceAverageSum=0;
                else
                    obj.KernelMemoryLineSpaceDelayLine=uint16(zeros(1,4));
                    obj.KernelMemoryLineSpaceAverageSum=uint16(0);
                end

                obj.KernelMemoryLineStartV=false(5,1);
                obj.KernelMemoryLineSpaceCounter=uint16(0);
                obj.KernelMemoryPushPopReadCounterV=uint16(ones(7,1));
                obj.KernelMemoryPushPopWriteCounterV=uint16(ones(7,1));
                obj.KernelMemoryPushPopWriteCounterPrevV=uint16(ones(7,1));
                obj.KernelMemoryPushPopLineLengthNext=uint16(ones(7,1));
                obj.KernelMemoryPushPopLineLengthCurrent=uint16(ones(7,1));
                obj.KernelMemoryPushPopInBetween=false(7,1);
                obj.KernelMemoryhEndRegV=false(7,1);
                obj.KernelMemoryBlankingCount=uint16(0);
                obj.KernelMemoryWriteCounterReg=uint16(ones(7,1));
                obj.KernelMemoryWriteEnableReg=false(7,1);
                obj.KernelMemoryPixelInputReg=cast(zeros(1,6),'like',pixelIn);
                obj.KernelMemoryPadREG=...
                pixelcontrolstruct(false,false,false,false,false);
                obj.KernelMemoryControlOutputREG=false(5,6);
                obj.KernelMemoryPaddingFSMState=0;

                obj.KernelMemoryInLine=false;
                obj.KernelMemoryProcessOutREG=false;
                obj.KernelMemoryInFrame=false;
                obj.KernelMemoryInLineInFrame=false;
                obj.KernelMemoryInLineInFrameDelay=false;
                obj.KernelMemoryAllEndOfLine=false;
                obj.KernelMemoryhStartDelayLine=false(7,1);
                obj.KernelMemoryhEndDelayLine=false(7,1);
                obj.KernelMemoryvStartDelayLine=false(7,1);
                obj.KernelMemoryvEndDelayLine=false(7,1);
                obj.KernelMemoryvalidDelayLine=false(7,1);

                obj.KernelMemorydumpControlREG=[false,false];
                obj.KernelMemoryPreProcess=false;
                obj.KernelMemoryHorizontalPadCount=uint16(zeros(1,2));
                obj.KernelMemoryDataVectorREG=cast(zeros(7,2)...
                ,'like',pixelIn);
                obj.KernelMemoryPopREG=false;

                obj.KernelMemoryHorizontalPaddingShiftReg=cast(zeros(7,(7))...
                ,'like',pixelIn);

                obj.KernelMemoryLineLoadTo=7;
                obj.KernelMemoryEvenBiasConstant=0;

                obj.KernelMemoryProcessDataGatedREG=false;
                obj.KernelMemoryPreProcessREG=false;
                obj.KernelMemoryOnLineFlag=false;
                obj.KernelMemoryVerticalPadCounter=uint16(0);
                obj.KernelMemoryFirstLineEn=false;
                obj.KernelMemoryValidationDelay=...
                pixelcontrolstruct(false,false,false,false,false);
                obj.KernelMemoryOnLine=false;
                obj.KernelMemorySymmetricPadArray=ones(1,7);
                obj.KernelMemoryLowerPaddingLUT=ones(4,1);
                obj.KernelMemoryUpperPaddingLUT=ones(5,1);
                obj.KernelMemoryProcessOnLine=false;
                obj.KernelMemoryProcessPrePad=false;
                obj.KernelMemoryProcessPostPad=false;
                obj.KernelMemoryProcessCounter=uint8(0);
            end
        end

        function[pixelOutV,hStartOut,hEndOut,vStartOut,vEndOut,validOut,processOut]=stepKernelMemory(obj,pixelIn,hStartIn,hEndIn,...
            vStartIn,vEndIn,validIn)

            if~coder.target('hdl')

                pixSize=size(pixelIn);
                if pixSize(2)>1
                    coder.internal.error('visionhdl:LineBuffer:InputDimensions');
                end

                if pixSize(1)>1
                    if~ismember(pixSize(1),[2,4,8])
                        coder.internal.error('visionhdl:LineBuffer:InputDimensions');
                    end
                end

                ctrlIn=pixelcontrolstruct(obj.KernelMemoryCtrlInputREG(1,end),obj.KernelMemoryCtrlInputREG(2,end),obj.KernelMemoryCtrlInputREG(3,end),obj.KernelMemoryCtrlInputREG(4,end),obj.KernelMemoryCtrlInputREG(5,end));


                LineSpaceAverager(obj,obj.KernelMemoryInBetween,obj.KernelMemoryCtrlInputREG(1,2));

                obj.KernelMemoryCtrlInputREG(1,1)=hStartIn;
                obj.KernelMemoryCtrlInputREG(2,1)=hEndIn;
                obj.KernelMemoryCtrlInputREG(3,1)=vStartIn;
                obj.KernelMemoryCtrlInputREG(4,1)=vEndIn;
                obj.KernelMemoryCtrlInputREG(5,1)=validIn;
                obj.KernelMemoryCtrlInputREG(:,2:end)=obj.KernelMemoryCtrlInputREG(:,1:end-1);


                [ctrlValidated,obj.KernelMemoryInBetween]=InputControlValidation(obj,ctrlIn);


                [dataReadCtrlOut,outputData,Unloading,BlankCountEn,Running]=...
                DataReadController(obj,ctrlValidated,obj.KernelMemoryLineStartV,...
                obj.KernelMemoryLineSpaceAverage,obj.KernelMemoryAllEndOfLine,obj.KernelMemoryBlankingCount,vStartIn);


                if dataReadCtrlOut.hStart
                    obj.KernelMemoryBlankingCount(:)=1;
                elseif BlankCountEn
                    obj.KernelMemoryBlankingCount(:)=obj.KernelMemoryBlankingCount(:)+1;
                end

                popEnable=obj.KernelMemoryLineStartV;


                LineInfoStore(obj,dataReadCtrlOut.hStart,Unloading,vStartIn);

                pixelMemV=obj.KernelMemoryDataMemoryHandle(obj,pixelIn);





                pushOut=false(obj.KernelMemoryKernelPHeight,1);
                popOut=false(obj.KernelMemoryKernelPHeight,1);
                EndOfLine=false(obj.KernelMemoryKernelPHeight,1);

                if obj.KernelMemoryDataReadFSMState==2
                    popEnable(:)=2^12;
                end

                for ii=1:1:obj.KernelMemoryKernelPHeight
                    if ii<=(floor(obj.KernelMemoryKernelPHeight/2)-1)
                        M=ii;
                    else
                        M=(floor(obj.KernelMemoryKernelPHeight/2));
                    end

                    if ii==1
                        [pushOut(ii),popOut(ii),EndOfLine(ii)]=PushPopCounter(obj,dataReadCtrlOut.hStart,...
                        obj.KernelMemoryDataReadControlREG.valid,popEnable,...
                        obj.KernelMemoryDataReadControlREG.hEnd,ii,M+1);
                    else
                        [pushOut(ii),popOut(ii),EndOfLine(ii)]=PushPopCounter(obj,dataReadCtrlOut.hStart,...
                        obj.KernelMemoryDataReadControlREG.valid,popEnable,...
                        obj.KernelMemoryDataReadControlREG.hEnd,ii,M+1);
                    end
                end


                obj.KernelMemoryWriteCounterReg(1:end)=obj.KernelMemoryPushPopWriteCounterV(1:end);
                obj.KernelMemoryWriteEnableReg(1:end)=pushOut(1:end);
                obj.KernelMemoryAllEndOfLine=all(EndOfLine(:));

                if obj.KernelMemoryKernelPWidth==1
                    if strcmpi(obj.KernelMemoryPaddingMethod,'None')
                        hStartOut=obj.KernelMemoryControlOutputREG(1,3);
                    else
                        hStartOut=obj.KernelMemoryControlOutputREG(1,2);
                    end
                else
                    hStartOut=obj.KernelMemoryControlOutputREG(1,3);
                end

                if obj.KernelMemoryKernelPWidth==1
                    if strcmpi(obj.KernelMemoryPaddingMethod,'None')
                        hEndOut=obj.KernelMemoryControlOutputREG(2,3);
                    else
                        hEndOut=obj.KernelMemoryControlOutputREG(2,2);
                    end
                elseif obj.KernelMemoryKernelPWidth<=4&&~strcmpi(obj.KernelMemoryPaddingMethod,'None')
                    if strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')
                        hEndOut=obj.KernelMemoryControlOutputREG(2,3);
                    else
                        hEndOut=obj.KernelMemoryControlOutputREG(2,2);
                    end
                else
                    if strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')||(strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryTwoPixelEdgeCase)
                        hEndOut=obj.KernelMemoryControlOutputREG(2,4);
                    else
                        hEndOut=obj.KernelMemoryControlOutputREG(2,3);
                    end
                end

                if obj.KernelMemoryKernelPWidth==1
                    if strcmpi(obj.KernelMemoryPaddingMethod,'None')
                        vStartOut=obj.KernelMemoryControlOutputREG(3,3);
                        vEndOut=obj.KernelMemoryControlOutputREG(4,3)&&hEndOut;
                        validOut=obj.KernelMemoryControlOutputREG(5,3)||hStartOut||hEndOut||vStartOut||vEndOut;
                    else
                        vStartOut=obj.KernelMemoryControlOutputREG(3,2);
                        vEndOut=obj.KernelMemoryControlOutputREG(4,2)&&hEndOut;
                        validOut=obj.KernelMemoryControlOutputREG(5,2)||hStartOut||hEndOut||vStartOut||vEndOut;
                    end
                elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&obj.KernelMemoryNumberOfPixels==1
                    vStartOut=obj.KernelMemoryControlOutputREG(3,3);
                    vEndOut=obj.KernelMemoryControlOutputREG(4,3)&&hEndOut;
                    validOut=obj.KernelMemoryControlOutputREG(5,3)||obj.KernelMemoryControlOutputREG(5,4)||hStartOut||hEndOut||vStartOut||vEndOut;
                elseif(strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&obj.KernelMemoryNumberOfPixels>1)||(strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryTwoPixelEdgeCase)
                    vStartOut=obj.KernelMemoryControlOutputREG(3,3);
                    vEndOut=(obj.KernelMemoryControlOutputREG(4,3)||obj.KernelMemoryControlOutputREG(4,4))&&hEndOut;
                    validOut=obj.KernelMemoryControlOutputREG(5,3)||obj.KernelMemoryControlOutputREG(5,4)||hStartOut||hEndOut||vStartOut||vEndOut;
                else
                    vStartOut=obj.KernelMemoryControlOutputREG(3,3);
                    vEndOut=obj.KernelMemoryControlOutputREG(4,3)&&hEndOut;
                    validOut=obj.KernelMemoryControlOutputREG(5,3)||hStartOut||hEndOut||vStartOut||vEndOut;
                end

                obj.KernelMemoryPadREG(:)=obj.KernelMemoryDataReadControlREG(:);


                obj.KernelMemoryPixelInputReg(2:end,1:obj.KernelMemoryNumberOfPixels)=obj.KernelMemoryPixelInputReg(1:end-1,1:obj.KernelMemoryNumberOfPixels);
                obj.KernelMemoryPixelInputReg(1,1:obj.KernelMemoryNumberOfPixels)=pixelIn;


                if obj.KernelMemoryKernelWidth>1&&~strcmpi(obj.KernelMemoryPaddingMethod,'None')

                    if strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels==1
                        PrePadFlag=obj.KernelMemoryhStartDelayLine(ceil(obj.KernelMemoryKernelPWidth/2));
                    elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels==1
                        PrePadFlag=obj.KernelMemoryhStartDelayLine(ceil(obj.KernelMemoryKernelPWidth/2)+1);
                    elseif(strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels>1)||(strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryTwoPixelEdgeCase)
                        PrePadFlag=obj.KernelMemoryhStartDelayLine(2);
                    else
                        PrePadFlag=obj.KernelMemoryhStartDelayLine(1);
                    end

                    OnLineFlag=obj.KernelMemoryhStartDelayLine(end);

                    DumpingFlag=obj.KernelMemoryhEndDelayLine(1);

                    if strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels==1
                        if mod(obj.KernelMemoryKernelPWidth,2)==0
                            PostPadFlag=obj.KernelMemoryhEndDelayLine((obj.KernelMemoryKernelPWidth)-2);
                        else
                            PostPadFlag=obj.KernelMemoryhEndDelayLine((obj.KernelMemoryKernelPWidth)-1);
                        end
                    elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels==1
                        if mod(obj.KernelMemoryKernelPWidth,2)==0
                            PostPadFlag=obj.KernelMemoryhEndDelayLine((obj.KernelMemoryKernelPWidth)-1);
                        else
                            PostPadFlag=obj.KernelMemoryhEndDelayLine((obj.KernelMemoryKernelPWidth));
                        end
                    elseif(strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels>1)||(strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryTwoPixelEdgeCase)
                        if mod(obj.KernelMemoryKernelPWidth,2)==0
                            PostPadFlag=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2));
                        else
                            PostPadFlag=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2)+1);
                        end
                    elseif mod(obj.KernelMemoryKernelPWidth,2)==0&&(obj.KernelMemoryKernelPWidth>2)&&obj.KernelMemoryBiasUp
                        PostPadFlag=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2)-1);
                    elseif mod(obj.KernelMemoryKernelPWidth,2)==0&&(obj.KernelMemoryKernelPWidth>2)&&~obj.KernelMemoryBiasUp
                        PostPadFlag=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2));
                    else
                        PostPadFlag=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2));
                    end

                    BlankingFlag=obj.KernelMemoryhEndDelayLine(end);

                    [processData,countReset,countEn,dumpControl,preProcess]=...
                    PaddingController(obj,PrePadFlag,OnLineFlag,PostPadFlag,DumpingFlag,BlankingFlag);

                    [padControl]=...
                    StateTransitionFlagGen(obj,dataReadCtrlOut,dumpControl,preProcess);

                    obj.KernelMemoryControlOutputREG(:,2:end)=obj.KernelMemoryControlOutputREG(:,1:end-1);
                    obj.KernelMemoryControlOutputREG(1,1)=padControl.hStart;
                    obj.KernelMemoryControlOutputREG(2,1)=padControl.hEnd;

                    obj.KernelMemoryControlOutputREG(4,1)=padControl.vEnd;
                    obj.KernelMemoryControlOutputREG(5,1)=padControl.valid;

                    obj.KernelMemoryPreProcessREG=obj.KernelMemoryPreProcess;

                    [processDataGated,dumporvalid]=GateProcessData(obj,processData,dataReadCtrlOut,dumpControl,outputData);

                    padShift=obj.KernelMemorydumpControlREG(1)||obj.KernelMemorydumpControlREG(2)||obj.KernelMemoryPopREG||dumpControl;

                    pixelHorV=HorizontalPadding(obj,obj.KernelMemoryRAMColumnREG,obj.KernelMemoryHorizontalPadCount(2),padShift);

                    if obj.KernelMemoryKernelHeight>1
                        VerticalPadCount(obj,vStartIn,Unloading,Running,dataReadCtrlOut.hStart);
                        pixelVerV=VerticalPadding(obj,pixelHorV);
                    else
                        pixelVerV=pixelHorV;
                    end

                    if outputData
                        pixelOutV=obj.KernelMemoryPixelOutputREG;
                    else
                        obj.KernelMemoryPixelOutputREG(:)=0;
                        pixelOutV=obj.KernelMemoryPixelOutputREG;
                    end

                    if~obj.KernelMemoryProcessDataGatedREG||~outputData||(obj.KernelMemoryControlOutputREG(1,2)&&obj.KernelMemoryKernelWidth==2)&&obj.KernelMemoryBiasUp
                        obj.KernelMemoryPixelOutputREG(1:end,1:end)=0;
                    elseif~obj.KernelMemoryProcessDataGatedREG||~outputData||(obj.KernelMemoryControlOutputREG(2,3)&&obj.KernelMemoryKernelWidth==2)&&~obj.KernelMemoryBiasUp
                        obj.KernelMemoryPixelOutputREG(1:end,1:end)=0;
                    else
                        obj.KernelMemoryOutputCastHandle(obj,pixelVerV);
                    end

                    obj.KernelMemorydumpControlREG(2:end)=obj.KernelMemorydumpControlREG(1:end-1);
                    obj.KernelMemorydumpControlREG(1)=dumpControl;

                    if obj.KernelMemoryPopREG||dumpControl
                        obj.KernelMemoryRAMColumnREG(:)=pixelMemV;
                    end

                    obj.KernelMemoryHorizontalPadCount(2:end)=obj.KernelMemoryHorizontalPadCount(1:end-1);
                    if countEn&&dumporvalid
                        obj.KernelMemoryHorizontalPadCount(1)=obj.KernelMemoryHorizontalPadCount(1)+1;
                    elseif countReset
                        obj.KernelMemoryHorizontalPadCount(:)=0;
                    end

                    obj.KernelMemoryPopREG=obj.KernelMemoryWriteEnableReg(1);

                    if padControl.vEnd
                        obj.KernelMemoryFirstLineEn=false;
                    end



                else
                    obj.KernelMemoryControlOutputREG(:,2:end)=obj.KernelMemoryControlOutputREG(:,1:end-1);
                    obj.KernelMemoryControlOutputREG(1,1)=dataReadCtrlOut.hStart;
                    obj.KernelMemoryControlOutputREG(2,1)=dataReadCtrlOut.hEnd;
                    obj.KernelMemoryControlOutputREG(4,1)=dataReadCtrlOut.vEnd;
                    obj.KernelMemoryControlOutputREG(5,1)=dataReadCtrlOut.valid;

                    if obj.KernelMemoryPopREG&&outputData
                        obj.KernelMemoryRAMColumnREG(:)=pixelMemV;
                    end
                    obj.KernelMemoryPopREG=obj.KernelMemoryWriteEnableReg(1);

                    if~strcmpi(obj.KernelMemoryPaddingMethod,'None')
                        VerticalPadCount(obj,vStartIn,Unloading,Running,dataReadCtrlOut.hStart);
                        if~validOut||~outputData
                            obj.KernelMemoryPixelOutputREG(:)=0;
                        else
                            pixelVerV=VerticalPadding(obj,obj.KernelMemoryRAMColumnREG);
                            obj.KernelMemoryOutputCastHandle(obj,pixelVerV);
                        end
                        pixelOutV=obj.KernelMemoryPixelOutputREG(:);
                    else
                        if~validOut||~outputData
                            obj.KernelMemoryPixelOutputREG(:)=0;
                        else
                            obj.KernelMemoryOutputCastHandle(obj,obj.KernelMemoryRAMColumnREG(:,:));
                        end

                        if obj.KernelMemoryKernelHeight==2
                            pixelOutV=obj.KernelMemoryHorizontalPaddingShiftReg(1:2,:);
                            obj.KernelMemoryHorizontalPaddingShiftReg(:,:)=pixelMemV;
                        else
                            pixelOutV=obj.KernelMemoryHorizontalPaddingShiftReg(:,:);
                            obj.KernelMemoryHorizontalPaddingShiftReg(:,:)=pixelMemV;
                        end

                    end

                    if strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&mod(obj.KernelMemoryKernelHeight,2)==0&&~obj.KernelMemoryTwo
                        obj.KernelMemoryOutputCastHandle(obj,obj.KernelMemoryRAMColumnREG(1:obj.KernelMemoryKernelHeight));
                    else
                        obj.KernelMemoryOutputCastHandle(obj,obj.KernelMemoryRAMColumnREG);
                    end
                    obj.KernelMemoryDataReadControlREG(:)=dataReadCtrlOut;

                end

                if obj.KernelMemoryKernelWidth>1&&~strcmpi(obj.KernelMemoryPaddingMethod,'None')

                    if obj.KernelMemoryKernelWidth>3&&obj.KernelMemoryNumberOfPixels>1
                        processOut=MultiPixelShortenProcessData(obj,obj.KernelMemoryProcessOutREG,hStartOut,hEndOut);
                    else
                        processOut=obj.KernelMemoryProcessOutREG;
                    end

                    if obj.KernelMemoryKernelWidth==2&&obj.KernelMemoryBiasUp
                        obj.KernelMemoryProcessOutREG=obj.KernelMemoryProcessDataGatedREG&&(~obj.KernelMemoryControlOutputREG(1,2));
                    elseif obj.KernelMemoryKernelWidth==2&&~obj.KernelMemoryBiasUp
                        obj.KernelMemoryProcessOutREG=obj.KernelMemoryProcessDataGatedREG&&(~obj.KernelMemoryControlOutputREG(2,3));
                    else
                        obj.KernelMemoryProcessOutREG=obj.KernelMemoryProcessDataGatedREG;
                    end

                    obj.KernelMemoryProcessDataGatedREG=processDataGated;

                    if obj.KernelMemoryPopREG
                        obj.KernelMemoryDataVectorREG(:,2,:)=obj.KernelMemoryDataVectorREG(:,1,:);
                        obj.KernelMemoryDataVectorREG(:,1,:)=pixelMemV;
                    end

                    obj.KernelMemoryDataReadControlREG(:)=dataReadCtrlOut;

                    if~outputData||~processOut||(obj.KernelMemoryControlOutputREG(1,2)&&obj.KernelMemoryTwo)
                        hStartOut=false;
                        hEndOut=false;
                        vStartOut=false;
                        vEndOut=false;
                        validOut=false;
                    end

                    if~outputData
                        processOut=false;
                    end

                    if hStartOut==true&&obj.KernelMemoryFirstLineEn==false&&outputData
                        hStartOut=true;
                        hEndOut=false;
                        vStartOut=true;
                        vEndOut=false;
                        validOut=true;
                        obj.KernelMemoryFirstLineEn=true;
                    end

                else
                    if~outputData
                        hStartOut=false;
                        hEndOut=false;
                        vStartOut=false;
                        vEndOut=false;
                        validOut=false;
                    end

                    processOut=validOut;

                    if hStartOut==true&&obj.KernelMemoryFirstLineEn==false&&outputData
                        hStartOut=true;
                        hEndOut=false;
                        vStartOut=true;
                        vEndOut=false;
                        validOut=true;
                        obj.KernelMemoryFirstLineEn=true;
                    end
                end

                if vStartIn
                    obj.KernelMemoryFirstLineEn=false;
                end

                if vEndOut
                    obj.KernelMemoryLineStartV(:)=false;
                end

                if~processOut
                    pixelOutV=cast((zeros(size(obj.KernelMemoryPixelOutputREG))),'like',obj.KernelMemoryPixelOutputREG);
                end

            else
                obj.KernelMemoryPixelOutputREG(1,:)=pixelIn;
                pixelOutV=obj.KernelMemoryPixelOutputREG;
                hStartOut=hStartIn;
                hEndOut=hEndIn;
                vStartOut=vStartIn;
                vEndOut=vEndIn;
                validOut=validIn;
                processOut=validIn;
            end
        end



        function resetKernelMemoryStates(obj)
            obj.KernelMemoryInLine=false;
            obj.KernelMemoryInFrame=false;
            obj.KernelMemoryInLineInFrame=false;
            obj.KernelMemoryCtrlDelay=...
            pixelcontrolstruct(false,false,false,false,false);
            obj.KernelMemoryValidationDelay=...
            pixelcontrolstruct(false,false,false,false,false);
            obj.KernelMemoryLineSpaceCounter=uint16(0);
            obj.KernelMemoryInLineInFrameDelay=false;
            obj.KernelMemoryDataReadFSMState(:)=0;
            obj.KernelMemoryDataReadFSMInBetween=false;
            obj.KernelMemoryDataReadControlREG=...
            pixelcontrolstruct(false,false,false,false,false);

            obj.KernelMemoryLineSpaceDelayLine(:)=0;
            obj.KernelMemoryLineStartV(:)=false;

            obj.KernelMemoryRAMColumn(:)=0;
            obj.KernelMemoryPushPopReadCounterV(:)=1;
            obj.KernelMemoryPushPopWriteCounterV(:)=1;
            obj.KernelMemoryPushPopLineLengthNext(:)=1;
            obj.KernelMemoryPushPopLineLengthCurrent(:)=1;
            obj.KernelMemoryPushPopInBetween(:)=false;
            obj.KernelMemoryhEndRegV(:)=false;
            obj.KernelMemoryAllEndOfLine(:)=false;
            obj.KernelMemoryBlankingCount(:)=0;
            obj.KernelMemoryWriteCounterReg(:)=1;
            obj.KernelMemoryWriteEnableReg(:)=false;
            obj.KernelMemoryPixelInputReg(:)=0;
            obj.KernelMemoryPadREG(:)=pixelcontrolstruct(false,false,false,false,false);
            obj.KernelMemoryControlOutputREG(:)=false;
            obj.KernelMemoryPaddingFSMState(:)=0;
            obj.KernelMemoryhStartDelayLine(:)=false;
            obj.KernelMemoryhEndDelayLine(:)=false;
            obj.KernelMemoryvStartDelayLine(:)=false;
            obj.KernelMemoryvEndDelayLine(:)=false;
            obj.KernelMemoryvalidDelayLine(:)=false;
            obj.KernelMemorydumpControlREG(:)=false;
            obj.KernelMemoryPreProcess=false;
            obj.KernelMemoryHorizontalPadCount(:)=0;
            obj.KernelMemoryDataVectorREG(:)=false;
            obj.KernelMemoryPopREG=false;
            obj.KernelMemoryHorizontalPaddingShiftReg(:)=0;
            obj.KernelMemoryProcessDataGatedREG(:)=false;
            obj.KernelMemoryPreProcessREG=false;
            obj.KernelMemoryOnLineFlag=false;
            obj.KernelMemoryRAMColumnREG(:)=0;
            obj.KernelMemoryVerticalPadCounter(:)=0;
            obj.KernelMemoryFirstLineEn=false;
            obj.KernelMemoryOnLine=false;
            obj.KernelMemoryPushPopWriteCounterPrevV(:)=1;
        end



        function s=saveObjectKernelMemory(obj,s)
            if obj.isLocked
                s.KernelMemoryKernelHeight=obj.KernelMemoryKernelHeight;
                s.KernelMemoryKernelWidth=obj.KernelMemoryKernelWidth;
                s.KernelMemoryPaddingMethod=obj.KernelMemoryPaddingMethod;
                s.KernelMemoryPaddingValue=obj.KernelMemoryPaddingValue;
                s.KernelMemoryMaxLineSize=obj.KernelMemoryMaxLineSize;
                s.KernelMemoryCeilMaxLineSize=obj.KernelMemoryCeilMaxLineSize;
                s.KernelMemoryBiasUp=obj.KernelMemoryBiasUp;

                s.KernelMemoryInLine=obj.KernelMemoryInLine;
                s.KernelMemoryInFrame=obj.KernelMemoryInFrame;
                s.KernelMemoryInLineInFrame=obj.KernelMemoryInLineInFrame;
                s.KernelMemoryCtrlDelay=obj.KernelMemoryCtrlDelay;
                s.KernelMemoryValidationDelay=obj.KernelMemoryValidationDelay;
                s.KernelMemoryInLineInFrameDelay=obj.KernelMemoryInLineInFrameDelay;
                s.KernelMemoryDataReadFSMState=obj.KernelMemoryDataReadFSMState;
                s.KernelMemoryDataReadFSMInBetween=obj.KernelMemoryDataReadFSMInBetween;
                s.KernelMemoryDataReadControlREG=obj.KernelMemoryDataReadControlREG;
                s.KernelMemoryLineSpaceCounter=obj.KernelMemoryLineSpaceCounter;
                s.KernelMemoryLineSpaceDelayLine=obj.KernelMemoryLineSpaceDelayLine;
                s.KernelMemoryLineStartV=obj.KernelMemoryLineStartV;
                s.KernelMemoryLineInfoStore=obj.KernelMemoryLineInfoStore;
                s.KernelMemoryRAMColumn=obj.KernelMemoryRAMColumn;
                s.KernelMemoryPushPopReadCounterV=obj.KernelMemoryPushPopReadCounterV;
                s.KernelMemoryPushPopWriteCounterV=obj.KernelMemoryPushPopWriteCounterV;
                s.KernelMemoryPushPopLineLengthNext=obj.KernelMemoryPushPopLineLengthNext;
                s.KernelMemoryPushPopLineLengthCurrent=obj.KernelMemoryPushPopLineLengthCurrent;
                s.KernelMemoryPushPopInBetween=obj.KernelMemoryPushPopInBetween;
                s.KernelMemoryhEndRegV=obj.KernelMemoryhEndRegV;
                s.KernelMemoryAllEndOfLine=obj.KernelMemoryAllEndOfLine;
                s.KernelMemoryBlankingCount=obj.KernelMemoryBlankingCount;
                s.KernelMemoryWriteCounterReg=obj.KernelMemoryWriteCounterReg;
                s.KernelMemoryWriteEnableReg=obj.KernelMemoryWriteEnableReg;
                s.KernelMemoryPixelInputReg=obj.KernelMemoryPixelInputReg;
                s.KernelMemoryPadREG=obj.KernelMemoryPadREG;
                s.KernelMemoryControlOutputREG=obj.KernelMemoryControlOutputREG;
                s.KernelMemoryPaddingFSMState=obj.KernelMemoryPaddingFSMState;
                s.KernelMemoryhStartDelayLine=obj.KernelMemoryhStartDelayLine;
                s.KernelMemoryhEndDelayLine=obj.KernelMemoryhEndDelayLine;
                s.KernelMemoryvStartDelayLine=obj.KernelMemoryvStartDelayLine;
                s.KernelMemoryvEndDelayLine=obj.KernelMemoryvEndDelayLine;
                s.KernelMemoryvalidDelayLine=obj.KernelMemoryvalidDelayLine;
                s.KernelMemorydumpControlREG=obj.KernelMemorydumpControlREG;
                s.KernelMemoryPreProcess=obj.KernelMemoryPreProcess;
                s.KernelMemoryHorizontalPadCount=obj.KernelMemoryHorizontalPadCount;
                s.KernelMemoryDataVectorREG=obj.KernelMemoryDataVectorREG;
                s.KernelMemoryPopREG=obj.KernelMemoryPopREG;
                s.KernelMemoryHorizontalPaddingShiftReg=obj.KernelMemoryHorizontalPaddingShiftReg;
                s.KernelMemoryProcessDataGatedREG=obj.KernelMemoryProcessDataGatedREG;
                s.KernelMemoryPreProcessREG=obj.KernelMemoryPreProcessREG;
                s.KernelMemoryOnLineFlag=obj.KernelMemoryOnLineFlag;
                s.KernelMemoryRAMColumnREG=obj.KernelMemoryRAMColumnREG;
                s.KernelMemoryVerticalPadCounter=obj.KernelMemoryVerticalPadCounter;
                s.KernelMemoryFirstLineEn=obj.KernelMemoryFirstLineEn;
                s.KernelMemoryLineLoadTo=obj.KernelMemoryLineLoadTo;
                s.KernelMemoryEvenBiasConstant=obj.KernelMemoryEvenBiasConstant;
                s.KernelMemoryOnLine=obj.KernelMemoryOnLine;
                s.KernelMemoryKernelPHeight=obj.KernelMemoryKernelPHeight;
                s.KernelMemoryKernelPWidth=obj.KernelMemoryKernelPWidth;
                s.KernelMemoryTwo=obj.KernelMemoryTwo;
                s.KernelMemorySymmetricPadArray=obj.KernelMemorySymmetricPadArray;
                s.KernelMemoryPixelOutputREG=obj.KernelMemoryPixelOutputREG;
                s.KernelMemoryOutputCastHandle=obj.KernelMemoryOutputCastHandle;
                s.KernelMemoryProcessOutREG=obj.KernelMemoryProcessOutREG;
                s.KernelMemoryCtrlInputREG=obj.KernelMemoryCtrlInputREG;
                s.KernelMemoryPushPopWriteCounterPrevV=obj.KernelMemoryPushPopWriteCounterPrevV;
                s.KernelMemoryLineSpaceAverageSum=obj.KernelMemoryLineSpaceAverageSum;
                s.KernelMemoryNumberOfPixels=obj.KernelMemoryNumberOfPixels;
                s.KernelMemoryDataMemoryHandle=obj.KernelMemoryDataMemoryHandle;
                s.KernelMemoryLowerPaddingLUT=obj.KernelMemoryLowerPaddingLUT;
                s.KernelMemoryUpperPaddingLUT=obj.KernelMemoryUpperPaddingLUT;
                s.KernelMemoryProcessOnLine=obj.KernelMemoryProcessOnLine;
                s.KernelMemoryProcessPrePad=obj.KernelMemoryProcessPrePad;
                s.KernelMemoryProcessPostPad=obj.KernelMemoryProcessPostPad;
                s.KernelMemoryProcessCounter=obj.KernelMemoryProcessCounter;
                s.KernelMemoryTwoPixelEdgeCase=obj.KernelMemoryTwoPixelEdgeCase;
            end
        end


        function loadObjectKernelMemory(obj,s,~)

            if any(strncmp(fieldnames(s),'KernelMemory',length('KernelMemory')))
                obj.KernelMemoryKernelHeight=s.KernelMemoryKernelHeight;
                obj.KernelMemoryKernelWidth=s.KernelMemoryKernelWidth;
                obj.KernelMemoryPaddingMethod=s.KernelMemoryPaddingMethod;
                obj.KernelMemoryPaddingValue=s.KernelMemoryPaddingValue;
                obj.KernelMemoryMaxLineSize=s.KernelMemoryMaxLineSize;
                obj.KernelMemoryCeilMaxLineSize=s.KernelMemoryCeilMaxLineSize;
                obj.KernelMemoryBiasUp=s.KernelMemoryBiasUp;

                obj.KernelMemoryInLine=s.KernelMemoryInLine;
                obj.KernelMemoryInFrame=s.KernelMemoryInFrame;
                obj.KernelMemoryInLineInFrame=s.KernelMemoryInLineInFrame;
                obj.KernelMemoryCtrlDelay=s.KernelMemoryCtrlDelay;
                obj.KernelMemoryValidationDelay=s.KernelMemoryValidationDelay;
                obj.KernelMemoryInLineInFrameDelay=s.KernelMemoryInLineInFrameDelay;
                obj.KernelMemoryDataReadFSMState=s.KernelMemoryDataReadFSMState;
                obj.KernelMemoryDataReadFSMInBetween=s.KernelMemoryDataReadFSMInBetween;
                obj.KernelMemoryDataReadControlREG=s.KernelMemoryDataReadControlREG;
                obj.KernelMemoryLineSpaceCounter=s.KernelMemoryLineSpaceCounter;
                obj.KernelMemoryLineSpaceDelayLine=s.KernelMemoryLineSpaceDelayLine;
                obj.KernelMemoryLineStartV=s.KernelMemoryLineStartV;
                obj.KernelMemoryLineInfoStore=s.KernelMemoryLineInfoStore;
                obj.KernelMemoryRAMColumn=s.KernelMemoryRAMColumn;
                obj.KernelMemoryPushPopReadCounterV=s.KernelMemoryPushPopReadCounterV;
                obj.KernelMemoryPushPopWriteCounterV=s.KernelMemoryPushPopWriteCounterV;
                obj.KernelMemoryPushPopLineLengthNext=s.KernelMemoryPushPopLineLengthNext;
                obj.KernelMemoryPushPopLineLengthCurrent=s.KernelMemoryPushPopLineLengthCurrent;
                obj.KernelMemoryPushPopInBetween=s.KernelMemoryPushPopInBetween;
                obj.KernelMemoryhEndRegV=s.KernelMemoryhEndRegV;
                obj.KernelMemoryAllEndOfLine=s.KernelMemoryAllEndOfLine;
                obj.KernelMemoryBlankingCount=s.KernelMemoryBlankingCount;
                obj.KernelMemoryWriteCounterReg=s.KernelMemoryWriteCounterReg;
                obj.KernelMemoryWriteEnableReg=s.KernelMemoryWriteEnableReg;
                obj.KernelMemoryPixelInputReg=s.KernelMemoryPixelInputReg;
                obj.KernelMemoryPadREG=s.KernelMemoryPadREG;
                obj.KernelMemoryControlOutputREG=s.KernelMemoryControlOutputREG;
                obj.KernelMemoryPaddingFSMState=s.KernelMemoryPaddingFSMState;
                obj.KernelMemoryhStartDelayLine=s.KernelMemoryhStartDelayLine;
                obj.KernelMemoryhEndDelayLine=s.KernelMemoryhEndDelayLine;
                obj.KernelMemoryvStartDelayLine=s.KernelMemoryvStartDelayLine;
                obj.KernelMemoryvEndDelayLine=s.KernelMemoryvEndDelayLine;
                obj.KernelMemoryvalidDelayLine=s.KernelMemoryvalidDelayLine;
                obj.KernelMemorydumpControlREG=s.KernelMemorydumpControlREG;
                obj.KernelMemoryPreProcess=s.KernelMemoryPreProcess;
                obj.KernelMemoryHorizontalPadCount=s.KernelMemoryHorizontalPadCount;
                obj.KernelMemoryDataVectorREG=s.KernelMemoryDataVectorREG;
                obj.KernelMemoryPopREG=s.KernelMemoryPopREG;
                obj.KernelMemoryHorizontalPaddingShiftReg=s.KernelMemoryHorizontalPaddingShiftReg;
                obj.KernelMemoryProcessDataGatedREG=s.KernelMemoryProcessDataGatedREG;
                obj.KernelMemoryPreProcessREG=s.KernelMemoryPreProcessREG;
                obj.KernelMemoryOnLineFlag=s.KernelMemoryOnLineFlag;
                obj.KernelMemoryRAMColumnREG=s.KernelMemoryRAMColumnREG;
                obj.KernelMemoryVerticalPadCounter=s.KernelMemoryVerticalPadCounter;
                obj.KernelMemoryFirstLineEn=s.KernelMemoryFirstLineEn;
                obj.KernelMemoryLineLoadTo=s.KernelMemoryLineLoadTo;
                obj.KernelMemoryEvenBiasConstant=s.KernelMemoryEvenBiasConstant;
                obj.KernelMemoryOnLine=s.KernelMemoryOnLine;
                obj.KernelMemoryKernelPHeight=s.KernelMemoryKernelPHeight;
                obj.KernelMemoryKernelPWidth=s.KernelMemoryKernelPWidth;
                obj.KernelMemoryTwo=s.KernelMemoryTwo;
                obj.KernelMemorySymmetricPadArray=s.KernelMemorySymmetricPadArray;
                obj.KernelMemoryPixelOutputREG=s.KernelMemoryPixelOutputREG;
                obj.KernelMemoryOutputCastHandle=s.KernelMemoryOutputCastHandle;
                obj.KernelMemoryProcessOutREG=s.KernelMemoryProcessOutREG;
                obj.KernelMemoryCtrlInputREG=s.KernelMemoryCtrlInputREG;
                obj.KernelMemoryPushPopWriteCounterPrevV=s.KernelMemoryPushPopWriteCounterPrevV;
                obj.KernelMemoryLineSpaceAverageSum=s.KernelMemoryLineSpaceAverageSum;
                obj.KernelMemoryNumberOfPixels=s.KernelMemoryNumberOfPixels;
                obj.KernelMemoryDataMemoryHandle=s.KernelMemoryDataMemoryHandle;
                obj.KernelMemoryLowerPaddingLUT=s.KernelMemoryLowerPaddingLUT;
                obj.KernelMemoryUpperPaddingLUT=s.KernelMemoryUpperPaddingLUT;
                obj.KernelMemoryProcessOnLine=s.KernelMemoryProcessOnLine;
                obj.KernelMemoryProcessPrePad=s.KernelMemoryProcessPrePad;
                obj.KernelMemoryProcessPostPad=s.KernelMemoryProcessPostPad;
                obj.KernelMemoryProcessCounter=s.KernelMemoryProcessCounter;
                obj.KernelMemoryTwoPixelEdgeCase=s.KernelMemoryTwoPixelEdgeCase;
            end
        end



        function[ctrlOut,InBetween]=InputControlValidation(obj,ctrlIn)

            ctrlOut=pixelcontrolstruct(false,false,false,...
            false,false);
            InBetween=~obj.KernelMemoryInLine&&obj.KernelMemoryInFrame;

            ctrlOut.hStart=obj.KernelMemoryValidationDelay.hStart&&...
            obj.KernelMemoryInLineInFrame;

            hEndTemp=obj.KernelMemoryCtrlDelay.hEnd...
            &&obj.KernelMemoryInLineInFrameDelay;
            ctrlOut.hEnd=obj.KernelMemoryValidationDelay.hEnd;

            ctrlOut.vStart=obj.KernelMemoryValidationDelay.vStart&&...
            obj.KernelMemoryInLineInFrame;

            vEndTemp=obj.KernelMemoryCtrlDelay.vEnd&&...
            obj.KernelMemoryInLineInFrameDelay;
            ctrlOut.vEnd=obj.KernelMemoryValidationDelay.vEnd;

            validTemp1=obj.KernelMemoryValidationDelay.valid&&...
            obj.KernelMemoryInLineInFrame;

            validTemp2=obj.KernelMemoryValidationDelay.valid&&...
            obj.KernelMemoryInLineInFrameDelay;

            ctrlOut.valid=validTemp1||validTemp2||ctrlOut.hEnd;

            obj.KernelMemoryInLineInFrameDelay=obj.KernelMemoryInLineInFrame;

            inFrameTerm1=~ctrlIn.vEnd&&obj.KernelMemoryInFrame;
            inFrameTerm2=ctrlIn.valid&&ctrlIn.vStart;
            inFrameTerm3=~ctrlIn.valid&&obj.KernelMemoryInFrame;

            obj.KernelMemoryInFrame=inFrameTerm1||inFrameTerm2||inFrameTerm3;

            validTemp=obj.KernelMemoryInLineInFrame&&ctrlIn.valid;%#ok<NASGU>

            inLineTerm1=~ctrlIn.hEnd&&obj.KernelMemoryInLine;
            inLineTerm2=ctrlIn.valid&&ctrlIn.hStart&&ctrlIn.vStart;
            inLineTerm3=ctrlIn.vStart&&obj.KernelMemoryInLine;
            inLineTerm4=~obj.KernelMemoryInFrame&&obj.KernelMemoryInLine;
            inLineTerm5=~ctrlIn.valid&&obj.KernelMemoryInLine;
            inLineTerm6=ctrlIn.valid&&ctrlIn.hStart&&~ctrlIn.vEnd&&...
            obj.KernelMemoryInFrame&&~obj.KernelMemoryInLine;

            obj.KernelMemoryInLine=inLineTerm1||inLineTerm2||inLineTerm3||...
            inLineTerm4||inLineTerm5||inLineTerm6;

            obj.KernelMemoryInLineInFrame=obj.KernelMemoryInLine&&...
            obj.KernelMemoryInFrame;

            obj.KernelMemoryValidationDelay(:)=obj.KernelMemoryCtrlDelay;
            obj.KernelMemoryValidationDelay.hEnd=hEndTemp;
            obj.KernelMemoryValidationDelay.vEnd=vEndTemp;
            obj.KernelMemoryCtrlDelay(:)=ctrlIn;

        end


        function LineSpaceAverager(obj,InBetween,InLine)

            obj.KernelMemoryLineSpaceAverageSum(:)=(sum(obj.KernelMemoryLineSpaceDelayLine(:)));
            obj.KernelMemoryLineSpaceAverage(:)=(idivide(obj.KernelMemoryLineSpaceAverageSum(:),uint16(4),'floor'))+uint16(1);

            if InLine
                obj.KernelMemoryLineSpaceDelayLine(2:end)=obj.KernelMemoryLineSpaceDelayLine(1:end-1);
                obj.KernelMemoryLineSpaceDelayLine(1)=obj.KernelMemoryLineSpaceCounter;
                obj.KernelMemoryLineSpaceCounter(:)=0;
            elseif InBetween
                obj.KernelMemoryLineSpaceCounter(:)=obj.KernelMemoryLineSpaceCounter+1;
            end

        end


        function[ctrlOut,outputData,Unloading,BlankCountEn,Running]=...
            DataReadController(obj,ctrlIn,lineStartV,lineAverage,AllEndOfLine,BlankCount,frameStart)

            if obj.KernelMemoryBiasUp||mod(obj.KernelMemoryKernelPHeight,2)==1
                BiasTrueConstant=0;
            else
                BiasTrueConstant=1;
            end

            switch obj.KernelMemoryDataReadFSMState

            case 0

                if obj.KernelMemoryKernelHeight==1
                    outputData=true;
                else
                    outputData=false;
                end

                ctrlOut=pixelcontrolstruct(ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);
                Unloading=false;
                obj.KernelMemoryDataReadFSMInBetween=false;
                BlankCountEn=false;
                Running=false;

                if lineStartV(obj.KernelMemoryLineLoadTo)
                    obj.KernelMemoryDataReadFSMState(:)=1;
                else
                    obj.KernelMemoryDataReadFSMState(:)=0;
                end


            case 1
                outputData=true;
                Unloading=false;
                BlankCountEn=false;
                Running=true;


                if frameStart
                    ctrlOut=pixelcontrolstruct(false,false,false,false,false);
                    obj.KernelMemoryDataReadFSMState(:)=0;
                    obj.KernelMemoryDataReadFSMInBetween=false;
                elseif ctrlIn.vEnd

                    if obj.KernelMemoryKernelHeight==1||obj.KernelMemoryKernelPHeight==1
                        ctrlOut=pixelcontrolstruct(false,true,false,true,true);
                        obj.KernelMemoryDataReadFSMState(:)=0;
                        obj.KernelMemoryDataReadFSMInBetween=false;
                    else

                        ctrlOut=pixelcontrolstruct(false,true,false,false,true);
                        obj.KernelMemoryDataReadFSMState(:)=2;
                        obj.KernelMemoryDataReadFSMInBetween=true;

                    end

                else
                    obj.KernelMemoryDataReadFSMState(:)=1;
                    ctrlOut=pixelcontrolstruct(ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);
                    obj.KernelMemoryDataReadFSMInBetween=false;
                end


            case 2
                outputData=true;
                Unloading=true;
                Running=false;
                if obj.KernelMemoryKernelPHeight>1

                    if frameStart
                        obj.KernelMemoryDataReadFSMState(:)=0;
                        ctrlOut=pixelcontrolstruct(false,false,false,false,false);
                        BlankCountEn=false;
                        obj.KernelMemoryDataReadFSMInBetween=false;

                    elseif(lineStartV(floor(obj.KernelMemoryKernelPHeight/2-BiasTrueConstant))==0&&(~obj.KernelMemoryDataReadFSMInBetween&&AllEndOfLine))
                        obj.KernelMemoryDataReadFSMState(:)=2;
                        ctrlOut=pixelcontrolstruct(false,true,false,true,true);
                        BlankCountEn=false;
                        obj.KernelMemoryDataReadFSMInBetween=true;
                    elseif obj.KernelMemoryDataReadFSMInBetween&&BlankCount<lineAverage
                        obj.KernelMemoryDataReadFSMState(:)=2;
                        ctrlOut=pixelcontrolstruct(false,false,false,false,false);
                        BlankCountEn=true;
                        obj.KernelMemoryDataReadFSMInBetween=true;
                    elseif obj.KernelMemoryDataReadFSMInBetween&&BlankCount==lineAverage&&(lineStartV(floor(obj.KernelMemoryKernelPHeight/2)-BiasTrueConstant))==0
                        obj.KernelMemoryDataReadFSMState(:)=0;
                        ctrlOut=pixelcontrolstruct(false,false,false,false,false);
                        BlankCountEn=false;
                        obj.KernelMemoryDataReadFSMInBetween=false;
                    elseif obj.KernelMemoryDataReadFSMInBetween&&BlankCount==lineAverage
                        obj.KernelMemoryDataReadFSMState(:)=2;
                        ctrlOut=pixelcontrolstruct(true,false,false,false,true);
                        BlankCountEn=false;
                        obj.KernelMemoryDataReadFSMInBetween=false;
                    elseif~obj.KernelMemoryDataReadFSMInBetween&&AllEndOfLine
                        obj.KernelMemoryDataReadFSMState(:)=2;
                        ctrlOut=pixelcontrolstruct(false,true,false,false,true);
                        BlankCountEn=false;
                        obj.KernelMemoryDataReadFSMInBetween=true;
                    elseif~obj.KernelMemoryDataReadFSMInBetween
                        obj.KernelMemoryDataReadFSMState(:)=2;
                        ctrlOut=pixelcontrolstruct(false,false,false,false,true);
                        BlankCountEn=false;
                        obj.KernelMemoryDataReadFSMInBetween=false;
                    else
                        obj.KernelMemoryDataReadFSMState(:)=2;
                        ctrlOut=pixelcontrolstruct(false,false,false,false,true);
                        BlankCountEn=false;
                        obj.KernelMemoryDataReadFSMInBetween=false;
                    end
                else
                    obj.KernelMemoryDataReadFSMState(:)=2;
                    ctrlOut=pixelcontrolstruct(false,false,false,false,true);
                    BlankCountEn=false;
                    obj.KernelMemoryDataReadFSMInBetween=false;

                end
            otherwise
                ctrlOut=pixelcontrolstruct(ctrlIn.hStart,ctrlIn.hEnd,ctrlIn.vStart,ctrlIn.vEnd,ctrlIn.valid);
                outputData=true;
                Unloading=false;
                BlankCountEn=false;
                obj.KernelMemoryDataReadFSMInBetween=false;
                Running=false;
            end
        end


        function LineInfoStore(obj,LineStartIn,Unloading,frameEnd)
            if~Unloading&&LineStartIn
                obj.KernelMemoryLineStartV(2:end)=...
                obj.KernelMemoryLineStartV(1:end-1);
                obj.KernelMemoryLineStartV(1)=true;
            elseif Unloading&&LineStartIn
                obj.KernelMemoryLineStartV(2:end)=...
                obj.KernelMemoryLineStartV(1:end-1);
                obj.KernelMemoryLineStartV(1)=false;
            end



            if frameEnd
                obj.KernelMemoryLineStartV(:)=false;
            end


        end


        function[pushOut,popOut,EndOfLine]=PushPopCounter(obj,hStartIn,popIn,popEnable,hEndIn,N,M)

            popEn=popEnable(M);
            readTerm=obj.KernelMemoryPushPopReadCounterV(N)<=...
            obj.KernelMemoryPushPopLineLengthCurrent(N);

            popTerm1=popEn&&readTerm;
            popTerm2=popTerm1&&popIn;
            popTerm3=obj.KernelMemoryPushPopInBetween(N)&&popTerm1;
            readPop=popTerm2||popTerm3;

            if N>1
                pushOut=popIn||(obj.KernelMemoryPushPopWriteCounterV(N)<obj.KernelMemoryPushPopWriteCounterPrevV(N-1)&&obj.KernelMemoryPushPopInBetween(N));
            else
                pushOut=popIn;
            end

            popOut=readPop;
            EndOfLine=obj.KernelMemoryPushPopLineLengthCurrent(N)==...
            obj.KernelMemoryPushPopReadCounterV(N)+3;


            if hStartIn
                obj.KernelMemoryPushPopWriteCounterPrevV(N)=obj.KernelMemoryPushPopWriteCounterV(N);
                obj.KernelMemoryPushPopWriteCounterV(N)=1;

            elseif N>1&&(popIn||(obj.KernelMemoryPushPopWriteCounterV(N)<obj.KernelMemoryPushPopWriteCounterPrevV(N-1)&&obj.KernelMemoryPushPopInBetween(N)))
                obj.KernelMemoryPushPopWriteCounterV(N)=...
                obj.KernelMemoryPushPopWriteCounterV(N)+1;
            else
                if popIn
                    obj.KernelMemoryPushPopWriteCounterV(N)=...
                    obj.KernelMemoryPushPopWriteCounterV(N)+1;
                end
            end


            if hStartIn
                obj.KernelMemoryPushPopReadCounterV(N)=1;
            elseif readPop
                obj.KernelMemoryPushPopReadCounterV(N)=...
                obj.KernelMemoryPushPopReadCounterV(N)+1;
            end


            if hStartIn
                obj.KernelMemoryPushPopInBetween(N)=false;
            elseif hEndIn
                obj.KernelMemoryPushPopInBetween(N)=true;
            end


            if obj.KernelMemoryhEndRegV(N)
                obj.KernelMemoryPushPopLineLengthNext(N)=...
                obj.KernelMemoryPushPopWriteCounterV(N);
            end


            if hStartIn
                obj.KernelMemoryPushPopLineLengthCurrent(N)=...
                obj.KernelMemoryPushPopLineLengthNext(N);
            end

            obj.KernelMemoryhEndRegV(N)=hEndIn;

            if obj.KernelMemoryPushPopReadCounterV(N)>obj.KernelMemoryCeilMaxLineSize
                obj.KernelMemoryPushPopReadCounterV(N)=1;
            end

            if obj.KernelMemoryPushPopWriteCounterV(N)>obj.KernelMemoryCeilMaxLineSize
                obj.KernelMemoryPushPopWriteCounterV(N)=1;
                coder.internal.warning('visionhdl:LineBuffer:FIFOOverflow');
            end

        end


        function[controlOut]=...
            StateTransitionFlagGen(obj,controlIn,dumpControl,preProcess)

            controlOut=pixelcontrolstruct(false,false,false,false,false);

            enableRegisters=dumpControl||controlIn.valid||controlIn.hEnd;

            PrePadFlag=obj.KernelMemoryhStartDelayLine(1);

            DumpingFlag=obj.KernelMemoryhEndDelayLine(1);%#ok<NASGU> 

            if mod(obj.KernelMemoryKernelPWidth,2)==0&&obj.KernelMemoryKernelPWidth>2
                PostPadFlag=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2)-1);%#ok<NASGU>
            else
                PostPadFlag=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2));%#ok<NASGU>
            end

            BlankingFlag=obj.KernelMemoryhEndDelayLine(end);%#ok<NASGU>

            controlOut.hStart=obj.KernelMemoryhStartDelayLine(end);

            if(strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')||strcmpi(obj.KernelMemoryPaddingMethod,'Reflection'))&&obj.KernelMemoryKernelPWidth>2&&obj.KernelMemoryNumberOfPixels==1
                if mod(obj.KernelMemoryKernelPWidth,2)==1&&obj.KernelMemoryKernelPWidth>4
                    controlOut.hEnd=obj.KernelMemoryhEndDelayLine((obj.KernelMemoryKernelPWidth)-1);
                else
                    if obj.KernelMemoryKernelPWidth<=4
                        controlOut.hEnd=obj.KernelMemoryhEndDelayLine(3);
                    else
                        controlOut.hEnd=obj.KernelMemoryhEndDelayLine((obj.KernelMemoryKernelPWidth)-2);
                    end
                end
            elseif obj.KernelMemoryKernelPWidth==3
                controlOut.hEnd=obj.KernelMemoryhEndDelayLine(2);
            elseif obj.KernelMemoryKernelPWidth<=4&&obj.KernelMemoryBiasUp
                controlOut.hEnd=obj.KernelMemoryhEndDelayLine(2);
            elseif obj.KernelMemoryKernelPWidth<=4&&~obj.KernelMemoryBiasUp
                controlOut.hEnd=obj.KernelMemoryhEndDelayLine(3);
            elseif mod(obj.KernelMemoryKernelPWidth,2)==0&&obj.KernelMemoryBiasUp
                controlOut.hEnd=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2)-1);
            elseif mod(obj.KernelMemoryKernelPWidth,2)==0&&~obj.KernelMemoryBiasUp
                controlOut.hEnd=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2));
            else
                controlOut.hEnd=obj.KernelMemoryhEndDelayLine(floor(obj.KernelMemoryKernelPWidth/2));
            end

            if obj.KernelMemoryhStartDelayLine(end)
                obj.KernelMemoryOnLineFlag=true;
            elseif controlOut.hEnd
                obj.KernelMemoryOnLineFlag=false;
            end

            controlOut.vStart=obj.KernelMemoryvStartDelayLine(end);
            controlOut.vEnd=obj.KernelMemoryvEndDelayLine(end);
            validTemp1=PrePadFlag&&obj.KernelMemoryvalidDelayLine(end);
            validTemp2=~preProcess&&obj.KernelMemoryvalidDelayLine(end);
            controlOut.valid=(validTemp2||validTemp1)&&(obj.KernelMemoryOnLineFlag);

            if enableRegisters
                obj.KernelMemoryhStartDelayLine(2:end)=obj.KernelMemoryhStartDelayLine(1:end-1);
                obj.KernelMemoryhStartDelayLine(1)=controlIn.hStart;
                obj.KernelMemoryhEndDelayLine(2:end)=obj.KernelMemoryhEndDelayLine(1:end-1);
                obj.KernelMemoryhEndDelayLine(1)=controlIn.hEnd;
                obj.KernelMemoryvStartDelayLine(2:end)=obj.KernelMemoryvStartDelayLine(1:end-1);
                obj.KernelMemoryvStartDelayLine(1)=controlIn.vStart;
                obj.KernelMemoryvEndDelayLine(2:end)=obj.KernelMemoryvEndDelayLine(1:end-1);
                obj.KernelMemoryvEndDelayLine(1)=controlIn.vEnd;
                obj.KernelMemoryvalidDelayLine(2:end)=obj.KernelMemoryvalidDelayLine(1:end-1);
                obj.KernelMemoryvalidDelayLine(1)=controlIn.valid;
            end

        end


        function[processData,countReset,countEn,dumpControl,PrePadding]=...
            PaddingController(obj,PrePadFlag,OnLineFlag,PostPadFlag,DumpingFlag,BlankingFlag)

            switch obj.KernelMemoryPaddingFSMState

            case 0
                processData=false;
                countReset=true;
                countEn=false;
                dumpControl=false;
                PrePadding=false;

                if PrePadFlag
                    obj.KernelMemoryPaddingFSMState(:)=1;
                else
                    obj.KernelMemoryPaddingFSMState(:)=0;
                end


            case 1
                processData=true;
                countReset=false;
                countEn=true;
                dumpControl=false;
                PrePadding=true;

                if OnLineFlag
                    obj.KernelMemoryPaddingFSMState(:)=2;
                else
                    obj.KernelMemoryPaddingFSMState(:)=1;
                end


            case 2
                processData=true;
                countReset=false;
                countEn=false;
                dumpControl=false;
                PrePadding=false;

                if DumpingFlag
                    obj.KernelMemoryPaddingFSMState(:)=3;

                else
                    obj.KernelMemoryPaddingFSMState(:)=2;
                end

            case 3
                processData=true;
                countReset=false;
                countEn=false;
                dumpControl=true;
                PrePadding=false;

                if PostPadFlag
                    obj.KernelMemoryPaddingFSMState(:)=4;
                else
                    obj.KernelMemoryPaddingFSMState(:)=3;
                end

            case 4
                processData=true;
                countReset=false;
                countEn=true;
                dumpControl=true;
                PrePadding=false;

                if BlankingFlag
                    obj.KernelMemoryPaddingFSMState(:)=0;
                else
                    obj.KernelMemoryPaddingFSMState(:)=4;
                end


            otherwise
                processData=false;
                countReset=false;
                countEn=false;
                dumpControl=false;
                PrePadding=false;

            end

        end


        function[processData,dumporvalid]=GateProcessData(obj,processDataIn,controlIn,dumping,outputData)%#ok<INUSL>
            processDataTemp1=obj.KernelMemoryDataReadControlREG.valid||dumping;
            processDataTemp2=processDataTemp1&&processDataIn;

            if outputData
                processData=processDataTemp2;
            else
                processData=false;
            end
            dumporvalid=processDataTemp1;
        end



        function dataVectorOut=HorizontalPadding(obj,dataVectorIn,HorizontalPaddingCount,padShift)

            dataVectorOut=cast(ones(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels),'like',dataVectorIn);

            evenKernel=mod(obj.KernelMemoryKernelPWidth,2)==0;

            if strcmpi(obj.KernelMemoryPaddingMethod,'Constant')
                if mod(obj.KernelMemoryKernelPWidth,2)==1||obj.KernelMemoryKernelPWidth==2
                    if HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,floor(obj.KernelMemoryKernelPWidth/2),1:obj.KernelMemoryNumberOfPixels);
                    else
                        dataVectorOut=cast(ones(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels).*obj.KernelMemoryPaddingValue...
                        ,'like',dataVectorIn);
                    end

                else
                    if obj.KernelMemoryBiasUp
                        if HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)-1
                            dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,floor(obj.KernelMemoryKernelPWidth/2)-1,1:obj.KernelMemoryNumberOfPixels);
                        else
                            dataVectorOut=cast(ones(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels).*obj.KernelMemoryPaddingValue...
                            ,'like',dataVectorIn);
                        end
                    else
                        if HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)
                            dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,floor(obj.KernelMemoryKernelPWidth/2),1:obj.KernelMemoryNumberOfPixels);
                        else
                            dataVectorOut=cast(ones(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels).*obj.KernelMemoryPaddingValue...
                            ,'like',dataVectorIn);
                        end

                    end

                end
            elseif strcmpi(obj.KernelMemoryPaddingMethod,'Replicate')||...
                strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&obj.KernelMemoryKernelWidth<=4&&obj.KernelMemoryNumberOfPixels>1


                if obj.KernelMemoryNumberOfPixels>1
                    for ii=1:1:obj.KernelMemoryNumberOfPixels


                        if HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                            dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(1:obj.KernelMemoryKernelPHeight,HorizontalPaddingCount,ii));
                        elseif HorizontalPaddingCount>floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                            dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(1:obj.KernelMemoryKernelPHeight,HorizontalPaddingCount,obj.KernelMemoryNumberOfPixels));
                        else
                            if HorizontalPaddingCount==0
                                dataVectorOut(:,ii)=dataVectorIn(1:obj.KernelMemoryKernelPHeight,1);
                            else
                                dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(1:obj.KernelMemoryKernelPHeight,HorizontalPaddingCount,1));
                            end
                        end

                    end

                else
                    if HorizontalPaddingCount==0
                        dataVectorOut=dataVectorIn;

                    elseif HorizontalPaddingCount>0
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,HorizontalPaddingCount)';
                    else
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,1)';
                    end

                end


            elseif strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')

                evenKernel=double(evenKernel);

                if obj.KernelMemoryTwoPixelEdgeCase
                    for ii=1:1:obj.KernelMemoryNumberOfPixels

                        HPadCountThreshold=floor((floor(obj.KernelMemoryKernelPWidth/2)-evenKernel)/obj.KernelMemoryNumberOfPixels);

                        if HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                            dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,HorizontalPaddingCount+1,ii));

                        elseif HorizontalPaddingCount>floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                            dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryUpperPaddingLUT(HorizontalPaddingCount-floor(obj.KernelMemoryKernelPWidth/2)+(evenKernel))+1,obj.KernelMemoryNumberOfPixels-(ii-1)));
                        else

                            if HorizontalPaddingCount<HPadCountThreshold&&ii==1
                                dataVectorOut(:,ii)=zeros(obj.KernelMemoryKernelPHeight,1);

                            elseif HorizontalPaddingCount<=HPadCountThreshold
                                dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,1,obj.KernelMemoryNumberOfPixels-(ii-1)));

                            elseif HorizontalPaddingCount>HPadCountThreshold
                                dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryLowerPaddingLUT(HorizontalPaddingCount+evenKernel)+1,obj.KernelMemoryNumberOfPixels-(ii-1)));
                            end
                        end
                    end
                elseif obj.KernelMemoryNumberOfPixels>1

                    for ii=1:1:obj.KernelMemoryNumberOfPixels
                        if HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                            dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(1:obj.KernelMemoryKernelHeight,HorizontalPaddingCount,ii));
                        elseif HorizontalPaddingCount>floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                            dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(1:obj.KernelMemoryKernelHeight,obj.KernelMemoryUpperPaddingLUT(HorizontalPaddingCount-floor(obj.KernelMemoryKernelPWidth/2)+(evenKernel)),obj.KernelMemoryNumberOfPixels-(ii-1)));
                        else
                            if HorizontalPaddingCount==0
                                dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(1:obj.KernelMemoryKernelHeight,1+evenKernel,obj.KernelMemoryNumberOfPixels-(ii-1)));
                            else
                                dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(1:obj.KernelMemoryKernelHeight,obj.KernelMemoryLowerPaddingLUT(HorizontalPaddingCount+evenKernel),obj.KernelMemoryNumberOfPixels-(ii-1)));
                            end
                        end
                    end

                else

                    if mod(obj.KernelMemoryKernelPWidth,2)==0
                        KernelMemoryEven=1;
                    else
                        KernelMemoryEven=0;
                    end

                    if HorizontalPaddingCount==0
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,1,:);
                    elseif HorizontalPaddingCount<floor(obj.KernelMemoryKernelPWidth/2)-KernelMemoryEven
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,HorizontalPaddingCount*2+1,:);
                    elseif HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)-KernelMemoryEven
                        if mod(obj.KernelMemoryKernelPWidth,2)==1
                            dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryKernelPWidth-1,:);
                        else
                            dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryKernelPWidth-2,:);
                        end

                    else
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,(HorizontalPaddingCount*2)-1,:);
                    end
                end

            elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')

                evenKernel=double(evenKernel);


                if obj.KernelMemoryKernelWidth==2
                    kernelWidthTwo=1;
                else
                    kernelWidthTwo=0;
                end


                if obj.KernelMemoryNumberOfPixels>1
                    for ii=1:1:obj.KernelMemoryNumberOfPixels

                        if HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                            dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,HorizontalPaddingCount+1,ii));

                        elseif HorizontalPaddingCount>floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                            if ii<obj.KernelMemoryNumberOfPixels
                                dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryUpperPaddingLUT(HorizontalPaddingCount-floor(obj.KernelMemoryKernelPWidth/2)+evenKernel)+1+kernelWidthTwo,obj.KernelMemoryNumberOfPixels-ii));
                            else
                                dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryUpperPaddingLUT(HorizontalPaddingCount-floor(obj.KernelMemoryKernelPWidth/2)+evenKernel)+2+kernelWidthTwo,obj.KernelMemoryNumberOfPixels));
                            end

                        else

                            if HorizontalPaddingCount>0

                                if obj.KernelMemoryTwoPixelEdgeCase

                                    HPadCountThreshold=floor((floor(obj.KernelMemoryKernelPWidth/2)-evenKernel)/obj.KernelMemoryNumberOfPixels);

                                    if ii>1&&HorizontalPaddingCount<=HPadCountThreshold
                                        dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,1,obj.KernelMemoryNumberOfPixels-(ii-2)));

                                    elseif ii>1
                                        dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryLowerPaddingLUT(HorizontalPaddingCount+evenKernel)+1,obj.KernelMemoryNumberOfPixels-(ii-2)));

                                    elseif HorizontalPaddingCount<=HPadCountThreshold
                                        dataVectorOut(:,ii)=zeros(obj.KernelMemoryKernelPHeight,1);

                                    else
                                        dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryLowerPaddingLUT(HorizontalPaddingCount+evenKernel),1));
                                    end

                                else
                                    if ii>1
                                        dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryLowerPaddingLUT(HorizontalPaddingCount+evenKernel)+1,obj.KernelMemoryNumberOfPixels-(ii-2)));
                                    else
                                        dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryLowerPaddingLUT(HorizontalPaddingCount+evenKernel),1));
                                    end
                                end

                            elseif HorizontalPaddingCount==0
                                if ii>1
                                    dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,HorizontalPaddingCount+1,obj.KernelMemoryNumberOfPixels-(ii-2)));
                                else
                                    dataVectorOut(:,ii)=(obj.KernelMemoryHorizontalPaddingShiftReg(:,HorizontalPaddingCount+2,1));
                                end
                            end
                        end
                    end
                else

                    if HorizontalPaddingCount==0
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,1,:);

                    elseif HorizontalPaddingCount<floor(obj.KernelMemoryKernelPWidth/2)-evenKernel||HorizontalPaddingCount>floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,(HorizontalPaddingCount*2)+1,:);

                    elseif HorizontalPaddingCount==floor(obj.KernelMemoryKernelPWidth/2)-evenKernel
                        dataVectorOut=obj.KernelMemoryHorizontalPaddingShiftReg(:,obj.KernelMemoryKernelPWidth-evenKernel,:);
                    end
                end
            end

            if padShift
                obj.KernelMemoryHorizontalPaddingShiftReg(:,2:end,:)=obj.KernelMemoryHorizontalPaddingShiftReg(:,1:end-1,:);
                obj.KernelMemoryHorizontalPaddingShiftReg(:,1,:)=dataVectorIn;
            end

        end


        function VerticalPadCount(obj,frameEnd,Unloading,Running,lineStart)

            verCountEN1=Running&&lineStart;
            verCountEN2=Unloading&&lineStart;
            verCountEN3=verCountEN1&&(obj.KernelMemoryVerticalPadCounter<floor(obj.KernelMemoryKernelPHeight/2));
            verPadCountEn=verCountEN2||verCountEN3;

            if verPadCountEn
                obj.KernelMemoryVerticalPadCounter(:)=obj.KernelMemoryVerticalPadCounter+1;
            end

            if frameEnd
                obj.KernelMemoryVerticalPadCounter(:)=0;
            end

        end



        function dataVectorOut=VerticalPadding(obj,dataVectorIn)

            if obj.KernelMemoryBiasUp&&mod(obj.KernelMemoryKernelPHeight,2)==0
                BiasConstant=1;
            elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&mod(obj.KernelMemoryKernelHeight,2)==0
                BiasConstant=1;
            else
                BiasConstant=0;
            end


            if strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')&&mod(obj.KernelMemoryKernelHeight,2)==0&&obj.KernelMemoryKernelHeight>2
                dataVectorOut=cast(zeros(obj.KernelMemoryKernelHeight,obj.KernelMemoryNumberOfPixels),'like',dataVectorIn);
            else
                dataVectorOut=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels),'like',dataVectorIn);
            end

            if strcmpi(obj.KernelMemoryPaddingMethod,'Constant')

                if obj.KernelMemoryKernelHeight>2||(obj.KernelMemoryKernelHeight==2&&obj.KernelMemoryBiasUp)
                    for ii=1:1:obj.KernelMemoryKernelPHeight

                        if ii==ceil(obj.KernelMemoryKernelPHeight/2)&&mod(obj.KernelMemoryKernelPHeight,2)==1||ii==ceil(obj.KernelMemoryKernelPHeight/2)&&(~obj.KernelMemoryBiasUp&&mod(obj.KernelMemoryKernelPHeight,2)==0)
                            dataVectorOut(ii,1:obj.KernelMemoryNumberOfPixels)=dataVectorIn(ii,1:obj.KernelMemoryNumberOfPixels);


                        elseif ii<ceil(obj.KernelMemoryKernelPHeight/2)+(2*obj.KernelMemoryEvenBiasConstant*BiasConstant)

                            if obj.KernelMemoryVerticalPadCounter>(floor(obj.KernelMemoryKernelPHeight/2)+(ii)-1)
                                dataVectorOut(ii,1:obj.KernelMemoryNumberOfPixels)=cast(obj.KernelMemoryPaddingValue,'like',dataVectorIn);
                            else
                                dataVectorOut(ii,1:obj.KernelMemoryNumberOfPixels)=dataVectorIn(ii,1:obj.KernelMemoryNumberOfPixels);
                            end

                        elseif ii>ceil(obj.KernelMemoryKernelPHeight/2)

                            if obj.KernelMemoryBiasUp||mod(obj.KernelMemoryKernelPHeight,2)==1
                                if obj.KernelMemoryVerticalPadCounter<ii-ceil(obj.KernelMemoryKernelPHeight/2)-obj.KernelMemoryEvenBiasConstant
                                    dataVectorOut(ii,1:obj.KernelMemoryNumberOfPixels)=cast(obj.KernelMemoryPaddingValue,'like',dataVectorIn);
                                else
                                    dataVectorOut(ii,1:obj.KernelMemoryNumberOfPixels)=dataVectorIn(ii,1:obj.KernelMemoryNumberOfPixels);
                                end
                            else
                                if obj.KernelMemoryVerticalPadCounter<=ii-ceil(obj.KernelMemoryKernelPHeight/2)-obj.KernelMemoryEvenBiasConstant
                                    dataVectorOut(ii,1:obj.KernelMemoryNumberOfPixels)=cast(obj.KernelMemoryPaddingValue,'like',dataVectorIn);
                                else
                                    dataVectorOut(ii,1:obj.KernelMemoryNumberOfPixels)=dataVectorIn(ii,1:obj.KernelMemoryNumberOfPixels);
                                end
                            end


                        end
                    end


                else
                    if obj.KernelMemoryVerticalPadCounter==0
                        dataVectorOut(1,:)=dataVectorIn(1,:);
                        dataVectorOut(2,:)=dataVectorIn(2,:);
                        dataVectorOut(3,:)=cast(obj.KernelMemoryPaddingValue,'like',dataVectorIn(2));
                    else
                        dataVectorOut(1,:)=dataVectorIn(1,:);
                        dataVectorOut(2,:)=dataVectorIn(2,:);
                        dataVectorOut(3,:)=dataVectorIn(3,:);

                    end
                end


            elseif strcmpi(obj.KernelMemoryPaddingMethod,'Replicate')||...
                strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')&&(obj.KernelMemoryKernelPHeight==2||obj.KernelMemoryKernelPWidth==4)&&obj.KernelMemoryNumberOfPixels>1

                if obj.KernelMemoryNumberOfPixels>1

                    for ii=1:1:obj.KernelMemoryNumberOfPixels
                        if obj.KernelMemoryVerticalPadCounter<floor(obj.KernelMemoryKernelPHeight/2)
                            dataVectorOut(end:-1:ceil(obj.KernelMemoryKernelPHeight/2)+(obj.KernelMemoryVerticalPadCounter)-obj.KernelMemoryEvenBiasConstant,ii)=dataVectorIn((ceil(obj.KernelMemoryKernelPHeight/2))+(obj.KernelMemoryVerticalPadCounter)+obj.KernelMemoryEvenBiasConstant,ii);
                            dataVectorOut(1:ceil(obj.KernelMemoryKernelPHeight/2)+(obj.KernelMemoryVerticalPadCounter),ii)=dataVectorIn(1:ceil(obj.KernelMemoryKernelPHeight/2)+(obj.KernelMemoryVerticalPadCounter),ii);
                        elseif obj.KernelMemoryVerticalPadCounter==floor(obj.KernelMemoryKernelPHeight/2)
                            dataVectorOut=dataVectorIn;
                        else
                            dataVectorOut(1:obj.KernelMemoryVerticalPadCounter-floor(obj.KernelMemoryKernelPHeight/2),ii)=dataVectorIn(obj.KernelMemoryVerticalPadCounter-floor(obj.KernelMemoryKernelPHeight/2)+1,ii);
                            dataVectorOut(obj.KernelMemoryVerticalPadCounter-floor(obj.KernelMemoryKernelPHeight/2)+1:end,ii)=dataVectorIn(obj.KernelMemoryVerticalPadCounter-floor(obj.KernelMemoryKernelPHeight/2)+1:end,ii);
                        end
                    end


                else

                    if obj.KernelMemoryVerticalPadCounter<floor(obj.KernelMemoryKernelPHeight/2)
                        dataVectorOut(end:-1:ceil(obj.KernelMemoryKernelPHeight/2)+(obj.KernelMemoryVerticalPadCounter)-obj.KernelMemoryEvenBiasConstant)=dataVectorIn((ceil(obj.KernelMemoryKernelPHeight/2))+(obj.KernelMemoryVerticalPadCounter)+obj.KernelMemoryEvenBiasConstant);
                        dataVectorOut(1:ceil(obj.KernelMemoryKernelPHeight/2)+(obj.KernelMemoryVerticalPadCounter))=dataVectorIn(1:ceil(obj.KernelMemoryKernelPHeight/2)+(obj.KernelMemoryVerticalPadCounter));
                    elseif obj.KernelMemoryVerticalPadCounter==floor(obj.KernelMemoryKernelPHeight/2)
                        dataVectorOut=dataVectorIn;
                    else
                        dataVectorOut(1:obj.KernelMemoryVerticalPadCounter-floor(obj.KernelMemoryKernelPHeight/2))=dataVectorIn(obj.KernelMemoryVerticalPadCounter-floor(obj.KernelMemoryKernelPHeight/2)+1);
                        dataVectorOut(obj.KernelMemoryVerticalPadCounter-floor(obj.KernelMemoryKernelPHeight/2)+1:end)=dataVectorIn(obj.KernelMemoryVerticalPadCounter-floor(obj.KernelMemoryKernelPHeight/2)+1:end);
                    end

                end

            elseif strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric')

                for ii=1:1:obj.KernelMemoryKernelPHeight
                    if ii==ceil(obj.KernelMemoryKernelPHeight/2)-obj.KernelMemoryEvenBiasConstant&&mod(obj.KernelMemoryKernelPHeight,2)==1
                        dataVectorOut(ii,:)=dataVectorIn(ii,:);


                    elseif ii<ceil(obj.KernelMemoryKernelPHeight/2)+2*obj.KernelMemoryEvenBiasConstant


                        padIndex=(obj.KernelMemoryVerticalPadCounter+1)-floor(obj.KernelMemoryKernelPHeight/2)-ii;


                        if padIndex>0&&(obj.KernelMemoryVerticalPadCounter>floor(obj.KernelMemoryKernelPHeight/2))
                            dataVectorOut(ii,:)=dataVectorIn(obj.KernelMemorySymmetricPadArray(padIndex)+ii,:);
                        else
                            dataVectorOut(ii,:)=dataVectorIn(ii,:);
                        end

                    elseif ii>ceil(obj.KernelMemoryKernelPHeight/2)

                        padIndex=ii-(ceil(obj.KernelMemoryKernelPHeight/2)+obj.KernelMemoryVerticalPadCounter)-obj.KernelMemoryEvenBiasConstant;


                        if padIndex>0
                            dataVectorOut(ii,:)=dataVectorIn(ii-obj.KernelMemorySymmetricPadArray(padIndex),:);
                        else
                            dataVectorOut(ii,:)=dataVectorIn(ii,:);
                        end

                    end

                end

            elseif strcmpi(obj.KernelMemoryPaddingMethod,'Reflection')
                for ii=1:1:obj.KernelMemoryKernelHeight

                    if ii==ceil(obj.KernelMemoryKernelHeight/2)&&mod(obj.KernelMemoryKernelHeight,2)==1
                        dataVectorOut(ii,:)=dataVectorIn(ii,:);

                    elseif ii<ceil(obj.KernelMemoryKernelHeight/2)+2*BiasConstant
                        padIndex=(obj.KernelMemoryVerticalPadCounter+1)-floor(obj.KernelMemoryKernelHeight/2)-ii;
                        if padIndex>0&&(obj.KernelMemoryVerticalPadCounter>floor(obj.KernelMemoryKernelHeight/2))
                            dataVectorOut(ii,:)=dataVectorIn(obj.KernelMemorySymmetricPadArray(padIndex)+ii+1,:);
                        else
                            dataVectorOut(ii,:)=dataVectorIn(ii,:);
                        end

                    elseif ii>ceil(obj.KernelMemoryKernelHeight/2)||(ii>=ceil(obj.KernelMemoryKernelHeight/2)&&obj.KernelMemoryKernelHeight==2)
                        padIndex=ii-(ceil(obj.KernelMemoryKernelHeight/2)+obj.KernelMemoryVerticalPadCounter)-BiasConstant;
                        if padIndex>0
                            dataVectorOut(ii,:)=dataVectorIn(ii-obj.KernelMemorySymmetricPadArray(padIndex)-1,:);
                        else
                            dataVectorOut(ii,:)=dataVectorIn(ii,:);
                        end
                    end
                end

            end

        end



        function OutputFullKernel(obj,pixelVector)
            obj.KernelMemoryPixelOutputREG(:)=pixelVector;
        end

        function OutputEvenColumnKernel(obj,pixelVector)

            obj.KernelMemoryPixelOutputREG(:)=pixelVector(1:obj.KernelMemoryKernelHeight,:);
        end

        function OutputTwoKernelUp(obj,pixelVector)
            if obj.KernelMemoryNumberOfPixels==1
                obj.KernelMemoryPixelOutputREG(1:end)=pixelVector(1:2);
            else
                obj.KernelMemoryPixelOutputREG(1:end,:)=pixelVector(1:2,:);
            end
        end

        function OutputTwoKernelDown(obj,pixelVector)

            if obj.KernelMemoryNumberOfPixels==1
                obj.KernelMemoryPixelOutputREG(1:end)=pixelVector(2:3);
            else
                obj.KernelMemoryPixelOutputREG(1:end,:)=pixelVector(2:3,:);
            end


        end


        function pixelMemV=DataMemory(obj,pixelIn)

            pixelMemV=cast(zeros(1,obj.KernelMemoryKernelPHeight),'like',pixelIn);

            pixelMemV(1,1)=obj.KernelMemoryPixelInputReg(end);

            for ii=2:1:obj.KernelMemoryKernelPHeight
                pixelMemV(1,ii)=obj.KernelMemoryRAMColumn(ii-1,obj.KernelMemoryPushPopReadCounterV(ii-1));
            end


            for ii=obj.KernelMemoryKernelPHeight:-1:1
                if ii==1
                    if obj.KernelMemoryWriteEnableReg(ii)
                        obj.KernelMemoryRAMColumn(ii,obj.KernelMemoryPushPopWriteCounterV(ii))=...
                        obj.KernelMemoryPixelInputReg(end);
                    end
                else
                    if obj.KernelMemoryWriteEnableReg(ii)
                        obj.KernelMemoryRAMColumn(ii,obj.KernelMemoryWriteCounterReg(ii))=...
                        obj.KernelMemoryRAMColumn(ii-1,obj.KernelMemoryPushPopReadCounterV(ii-1));
                    end
                end
            end

        end


        function pixelMemV=DataMemoryMultiPixels(obj,pixelIn)


            pixelMemV=cast(zeros(obj.KernelMemoryKernelPHeight,obj.KernelMemoryNumberOfPixels),'like',pixelIn);

            pixelMemV(1,1:obj.KernelMemoryNumberOfPixels)=obj.KernelMemoryPixelInputReg(end,1:obj.KernelMemoryNumberOfPixels);

            for ii=2:1:obj.KernelMemoryKernelPHeight
                pixelMemV(ii,1:obj.KernelMemoryNumberOfPixels)=obj.KernelMemoryRAMColumn(ii-1,obj.KernelMemoryPushPopReadCounterV(ii-1),1:obj.KernelMemoryNumberOfPixels);
            end

            for ii=obj.KernelMemoryKernelPHeight:-1:1
                if ii==1
                    if obj.KernelMemoryWriteEnableReg(ii)
                        obj.KernelMemoryRAMColumn(ii,obj.KernelMemoryPushPopWriteCounterV(ii),1:obj.KernelMemoryNumberOfPixels)=...
                        obj.KernelMemoryPixelInputReg(end,1:obj.KernelMemoryNumberOfPixels);
                    end
                else
                    if obj.KernelMemoryWriteEnableReg(ii)
                        obj.KernelMemoryRAMColumn(ii,obj.KernelMemoryWriteCounterReg(ii),1:obj.KernelMemoryNumberOfPixels)=...
                        obj.KernelMemoryRAMColumn(ii-1,obj.KernelMemoryPushPopReadCounterV(ii-1),1:obj.KernelMemoryNumberOfPixels);
                    end
                end
            end

        end


        function processOut=MultiPixelShortenProcessData(obj,processIn,hStart,hEnd)

            evenKernelConstant=double(mod(obj.KernelMemoryKernelWidth,2)==0);

            if mod(obj.KernelMemoryKernelWidth,2)==0
                if(mod((floor(obj.KernelMemoryKernelWidth/2))-1,obj.KernelMemoryNumberOfPixels)==0)||~obj.KernelMemoryBiasUp
                    evenBiasConstant=1;
                else
                    evenBiasConstant=0;
                end
            else
                evenBiasConstant=0;
            end

            if obj.KernelMemoryKernelWidth==4
                if obj.KernelMemoryBiasUp
                    prePadValue=0;
                    postPadValue=1;
                    EndOfLineValue=3;
                else
                    prePadValue=1;
                    postPadValue=3;
                    EndOfLineValue=3;
                end
            else
                twoPixelEdgeCase=double(obj.KernelMemoryTwoPixelEdgeCase&&~logical(evenKernelConstant)&&strcmpi(obj.KernelMemoryPaddingMethod,'Symmetric'));
                paddingCycles=ceil((floor(obj.KernelMemoryKernelWidth/2))/obj.KernelMemoryNumberOfPixels)-1;
                prePadValue=floor(obj.KernelMemoryKernelWidth/2)-1-paddingCycles-evenKernelConstant+evenBiasConstant;
                postPadValue=floor(obj.KernelMemoryKernelWidth/2)+1-evenKernelConstant+evenBiasConstant;
                EndOfLineValue=obj.KernelMemoryKernelWidth-1-evenKernelConstant+evenBiasConstant+(double(obj.KernelMemoryKernelWidth==10&&obj.KernelMemoryNumberOfPixels==8))-(paddingCycles-1)-twoPixelEdgeCase;

            end
            prePadStart=obj.KernelMemoryProcessCounter==prePadValue;
            EndOfLine=obj.KernelMemoryProcessCounter==EndOfLineValue;
            postPadStart=obj.KernelMemoryProcessCounter<=postPadValue;

            prePadding=obj.KernelMemoryProcessOnLine||obj.KernelMemoryProcessPrePad;
            postPadding=postPadStart&&obj.KernelMemoryProcessPostPad;
            postOrPrePad=prePadding||postPadding;
            processANDVal=postOrPrePad||prePadStart;

            processOut=processIn&&processANDVal;

            if EndOfLine
                obj.KernelMemoryProcessPostPad=false;
            elseif hEnd&&processIn
                obj.KernelMemoryProcessPostPad=true;
            end

            if EndOfLine
                obj.KernelMemoryProcessCounter(:)=0;
            elseif(processIn&&((~obj.KernelMemoryProcessPrePad)||obj.KernelMemoryProcessPostPad))||(prePadStart&&(obj.KernelMemoryKernelWidth~=4))
                obj.KernelMemoryProcessCounter(:)=obj.KernelMemoryProcessCounter+1;
            end

            if hEnd
                obj.KernelMemoryProcessPrePad=false;
            elseif prePadStart
                obj.KernelMemoryProcessPrePad=true;
            end

            if hEnd
                obj.KernelMemoryProcessOnLine=false;
            elseif hStart
                obj.KernelMemoryProcessOnLine=true;
            end

        end

    end

end
