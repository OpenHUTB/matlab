classdef(StrictDefaults)BirdsEyeView<matlab.System


























































































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)












        HomographyMatrix=[0.000100990123328,0.000000000000000,0.000000000000000;0.000412396945637,0.001302203393162,0.000001293171994;-0.103019798961327,-0.255811259450009,-0.000222053779501];






        MaxBufferSize=40000;






        MaxSourceLinesBuffered=54;




        BirdsEyeActivePixels=640;




        BirdsEyeActiveLines=700;

    end


    properties(Nontunable)

    end


    properties(Access=private)
        pInputFIFO;
        pOutputPipe;
        pOutputControlPipe;
        pFIFOWriteCounter;
        pFIFOReadCounter;
        pBufferFSMState;
        pColumnCounter;
        pRowCounter;
        pStartLine;
        pEndLine;
        pLineLUT;
        pGradientLUT;
        pRowMap;
        pBirdsEyeDimensions;
        pLineLUTCount;
        pLineLUTCountREG;
        pRunLengthDecoder;
        pCurrentReadAddress;
        pCurrentReadAddressD;
        pBetweenLines;
        pBlankingCounter;
        pBlankingAverage;
        pLockedinFrame;
        pBirdsEyeColumnCounter;
        pBirdsEyeRowCounter;
        pBirdsEyeBlankingCounter;
        pBirdsEyeBlankingInterval;
        pReadAddressGradient;
        pReadAddressOffsetCorrected;
        pReadAddressFinal;
        pRunDecodeAddress;
        DesiredBirdsEyeDimensions;
        pCurrentOffset;
        pOffsetLUT;
    end

    methods

        function obj=BirdsEyeView(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','Vision_HDL_Toolbox'))
                    error(message('visionhdl:visionhdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','Vision_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:});
        end

        function set.MaxBufferSize(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'BirdsEyeView','Max buffer size');
            obj.MaxBufferSize=val;
        end

        function set.MaxSourceLinesBuffered(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'BirdsEyeView','Max source lines buffered');
            obj.MaxSourceLinesBuffered=val;
        end


        function set.BirdsEyeActivePixels(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'BirdsEyeView','Birds eye active pixels');
            obj.BirdsEyeActivePixels=val;
        end

        function set.BirdsEyeActiveLines(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'BirdsEyeView','Birds eye active lines');
            obj.BirdsEyeActiveLines=val;
        end


        function set.HomographyMatrix(obj,val)
            validateattributes(val,{'logical','double','single'},{'2d'},'BirdsEyeView','Homography Matrix');
            [height,width]=size(val);

            if height~=3||width~=3
                coder.internal.error('visionhdl:BirdsEyeView:MatrixSize');
            end

            obj.HomographyMatrix=val;
        end

    end


    methods(Access=protected)

        function setupImpl(obj,pixel,~)







            if~coder.target('hdl')

                rowMap=zeros(1,obj.MaxSourceLinesBuffered);%#ok<PREALL>
                if isempty(coder.target)
                    hMatrix=inv(obj.HomographyMatrix);
                    [rowMap,obj.pStartLine,obj.pEndLine,obj.pBirdsEyeDimensions,ActualSourceLines]=...
                    visionhdl.BirdsEyeView.forwardRowMapping(hMatrix,obj.MaxSourceLinesBuffered,obj.BirdsEyeActiveLines,obj.BirdsEyeActivePixels);
                else

                    hMatrix=coder.const(feval('inv',obj.HomographyMatrix));
                    [rowMap,obj.pStartLine,obj.pEndLine,obj.pBirdsEyeDimensions,ActualSourceLines]=...
                    coder.internal.const(visionhdl.BirdsEyeView.forwardRowMapping(hMatrix,obj.MaxSourceLinesBuffered,obj.BirdsEyeActiveLines,obj.BirdsEyeActivePixels));

                end
                FGrad=fimath('RoundMode','Nearest',...
                'OverflowMode','Saturate',...
                'SumMode','FullPrecision',...
                'SumWordLength',ceil(log2(obj.MaxBufferSize))+10,...
                'SumFractionLength',10,...
                'CastBeforeSum',true);

                FOffset=fimath('RoundMode','Floor',...
                'OverflowMode','Wrap',...
                'SumMode','FullPrecision',...
                'SumWordLength',ceil(log2(obj.MaxBufferSize))+10,...
                'SumFractionLength',10,...
                'CastBeforeSum',true);

                FRow=fimath('RoundMode','Floor',...
                'OverflowMode','Saturate',...
                'SumMode','FullPrecision',...
                'SumWordLength',ceil(log2(obj.MaxBufferSize))+10,...
                'SumFractionLength',10,...
                'CastBeforeSum',true);


                gtype=fi(0,0,ceil(log2(obj.MaxBufferSize))+10,10);
                otype=fi(0,0,ceil(log2(obj.MaxBufferSize))+10,10);
                rtype=fi(0,0,ceil(log2(obj.MaxBufferSize))+10,10);


                if ActualSourceLines>obj.MaxSourceLinesBuffered
                    ActualSourceLines=obj.MaxSourceLinesBuffered;
                end

                vecSize=(obj.pEndLine-obj.pStartLine)+2;
                gradVal=zeros(1,vecSize);%#ok<PREALL>
                offsetVal=zeros(1,vecSize);%#ok<PREALL>

                [gradVal,offsetVal]=visionhdl.BirdsEyeView.forwardColumnMapping(hMatrix,obj.pStartLine,obj.pEndLine,rowMap,obj.BirdsEyeActiveLines,obj.BirdsEyeActivePixels,ActualSourceLines);

                obj.pRowMap=fi(zeros(1,ActualSourceLines),rtype.numerictype,FRow);
                obj.pGradientLUT=fi(zeros(1,ActualSourceLines),gtype.numerictype,FGrad);
                obj.pOffsetLUT=fi(zeros(1,ActualSourceLines),otype.numerictype,FOffset);
                obj.pRowMap(:)=rowMap(1:ActualSourceLines);

                obj.pGradientLUT(:)=gradVal(1:ActualSourceLines);

                obj.pOffsetLUT(:)=offsetVal(1:ActualSourceLines);
                obj.pInputFIFO=cast(zeros(1,obj.MaxBufferSize),'like',pixel);
                obj.pOutputPipe=cast(zeros(1,11),'like',pixel);
                obj.pOutputControlPipe=(false(5,3));
                obj.pFIFOWriteCounter=uint32(1);
                obj.pFIFOReadCounter=uint32(1);
                obj.pBufferFSMState=uint8(0);
                obj.pColumnCounter=uint32(1);
                obj.pRowCounter=uint32(1);
                obj.pLineLUTCount=uint32(1);
                obj.pLineLUTCountREG=uint32(1);
                obj.pRunLengthDecoder=uint32(1);
                obj.pCurrentReadAddress=uint32(1);
                obj.pCurrentReadAddressD=fi(zeros(1,3),otype.numerictype,FOffset);
                obj.pBetweenLines=false;
                obj.pBlankingCounter=uint32(0);
                obj.pBlankingAverage=ones(1,4);
                obj.pLockedinFrame=false;
                obj.pBirdsEyeColumnCounter=uint32(0);
                obj.pBirdsEyeRowCounter=uint32(0);
                obj.pBirdsEyeBlankingCounter=uint32(0);
                obj.pBirdsEyeBlankingInterval=uint32(0);
                obj.pReadAddressGradient=fi(0,0,ceil(log2(obj.MaxBufferSize))+10,10,'RoundingMethod',...
                'Floor','OverflowAction','Wrap','ProductMode',...
                'FullPrecision','SumMode','FullPrecision');
                obj.pReadAddressOffsetCorrected=fi(0,0,ceil(log2(obj.MaxBufferSize))+10,10,'RoundingMethod',...
                'Floor','OverflowAction','Wrap','ProductMode',...
                'FullPrecision','SumMode','FullPrecision');
                obj.pCurrentOffset=fi(0,0,ceil(log2(obj.MaxBufferSize))+10,10,'RoundingMethod',...
                'Floor','OverflowAction','Wrap','ProductMode',...
                'FullPrecision','SumMode','FullPrecision');
                obj.pReadAddressFinal=fi(0,0,ceil(log2(obj.MaxBufferSize)),0,'RoundingMethod',...
                'Floor','OverflowAction','Wrap','ProductMode',...
                'FullPrecision','SumMode','FullPrecision');
                obj.pRunDecodeAddress=fi(0,0,ceil(log2(obj.MaxBufferSize))+10,10,'RoundingMethod',...
                'Floor','OverflowAction','Wrap','ProductMode',...
                'FullPrecision','SumMode','FullPrecision');



            end

        end

        function[dataOut,ctrlOut]=outputImpl(obj,dataIn,~)
            if~coder.target('hdl')
                ctrlOut=pixelcontrolstruct(obj.pOutputControlPipe(1,end),obj.pOutputControlPipe(2,end),obj.pOutputControlPipe(3,end),...
                obj.pOutputControlPipe(4,end),obj.pOutputControlPipe(5,end));

                if obj.pOutputControlPipe(5,end)
                    dataOut=obj.pOutputPipe(end);
                else
                    dataOut=cast(0,'like',dataIn);
                end

            else
                dataOut=cast(0,'like',dataIn);
                ctrlOut=pixelcontrolstruct(false,false,false,false,false);
            end
        end

        function updateImpl(obj,dataIn,ctrlIn)


            if~coder.target('hdl')
                [hStart,hEnd,~,~,~]=pixelcontrolsignals(ctrlIn);

                if obj.pBufferFSMState==2
                    obj.pBirdsEyeBlankingInterval(:)=mean(obj.pBlankingAverage(:));
                end

                if obj.pBufferFSMState==2

                    obj.pCurrentReadAddress=obj.computeReadAddress(false);
                    if obj.pBetweenLines&&obj.pBirdsEyeBlankingCounter<obj.pBirdsEyeBlankingInterval
                        obj.pBirdsEyeBlankingCounter(:)=obj.pBirdsEyeBlankingCounter+1;
                        obj.pBirdsEyeColumnCounter(:)=0;

                        if obj.pBirdsEyeBlankingCounter==obj.pBirdsEyeBlankingInterval
                            obj.pBirdsEyeBlankingCounter(:)=0;
                            obj.pBetweenLines=false;
                        end

                    end

                    if~obj.pBetweenLines&&(obj.pBirdsEyeColumnCounter<obj.BirdsEyeActivePixels)
                        obj.pBirdsEyeColumnCounter(:)=obj.pBirdsEyeColumnCounter+1;
                        validOut=true;
                        if obj.pBirdsEyeColumnCounter==1
                            hStartOut=true;
                            hEndOut=false;
                            fake=obj.computeReadAddress(true);%#ok<NASGU> %dont update

                        elseif obj.pBirdsEyeColumnCounter==(obj.BirdsEyeActivePixels)
                            hEndOut=true;
                            hStartOut=false;
                            obj.pBirdsEyeRowCounter=obj.pBirdsEyeRowCounter+1;
                            obj.pBetweenLines=true;
                            obj.pBirdsEyeColumnCounter(:)=0;
                            obj.pBirdsEyeBlankingCounter(:)=0;
                        else
                            hStartOut=false;
                            hEndOut=false;
                        end

                    else
                        validOut=false;
                        hStartOut=false;
                        hEndOut=false;
                    end


                    if(obj.pBirdsEyeRowCounter==obj.BirdsEyeActiveLines)&&hEndOut
                        vEndOut=true;
                        vStartOut=false;
                    elseif obj.pBirdsEyeRowCounter==0&&hStartOut
                        vStartOut=true;
                        vEndOut=false;
                    else
                        vEndOut=false;
                        vStartOut=false;
                    end
                else
                    validOut=false;
                    hStartOut=false;
                    hEndOut=false;
                    vStartOut=false;
                    vEndOut=false;
                    obj.pCurrentReadAddress=obj.computeReadAddress(hStartOut);

                end

                obj.pOutputPipe(2:end)=obj.pOutputPipe(1:end-1);

                obj.pOutputPipe(1)=obj.readFIFO(obj.pCurrentReadAddress);

                if~obj.pLockedinFrame
                    obj.countRows(ctrlIn,vEndOut);
                end

                obj.countColumns(ctrlIn);

                obj.pOutputControlPipe(:,2:end)=obj.pOutputControlPipe(:,1:end-1);
                obj.pOutputControlPipe(:,1)=[hStartOut,hEndOut,vStartOut,vEndOut,validOut];

                if obj.pBufferFSMState<2
                    if hEnd
                        obj.pBetweenLines(:)=true;
                    elseif hStart
                        obj.pBetweenLines(:)=false;
                        obj.averageLineSpacing(obj.pBlankingCounter);
                    end

                    if obj.pBetweenLines
                        obj.pBlankingCounter(:)=obj.pBlankingCounter+1;
                    else
                        obj.pBlankingCounter(:)=0;
                    end
                end





                if vEndOut==true
                    obj.pInputFIFO(:)=0;
                    obj.pFIFOWriteCounter(:)=1;
                    obj.pFIFOReadCounter(:)=1;
                    obj.pBufferFSMState(:)=0;
                    obj.pColumnCounter(:)=1;
                    obj.pRowCounter(:)=1;
                    obj.pLineLUTCount(:)=1;
                    obj.pLineLUTCountREG(:)=1;
                    obj.pRunLengthDecoder(:)=0;
                    obj.pCurrentReadAddress(:)=1;
                    obj.pBirdsEyeRowCounter(:)=0;
                    obj.pBirdsEyeColumnCounter(:)=0;

                    obj.pBetweenLines=false;
                    obj.pBlankingAverage(:)=0;
                    obj.pBirdsEyeBlankingCounter(:)=0;
                    obj.pBlankingCounter(:)=0;
                    obj.pBirdsEyeColumnCounter(:)=0;
                    obj.pBirdsEyeRowCounter(:)=0;
                    obj.pBirdsEyeBlankingCounter(:)=0;
                    obj.pBirdsEyeBlankingInterval(:)=0;
                end
                homographyBufferFSM(obj,dataIn,ctrlIn,vEndOut);








            end
        end

        function resetImpl(obj)

            if~coder.target('hdl')
                obj.pInputFIFO(:)=0;
                obj.pFIFOWriteCounter(:)=1;
                obj.pFIFOReadCounter(:)=1;
                obj.pBufferFSMState(:)=0;
                obj.pColumnCounter(:)=1;
                obj.pRowCounter(:)=1;






                obj.pLineLUTCount(:)=1;
                obj.pLineLUTCountREG(:)=1;
                obj.pRunLengthDecoder(:)=0;
                obj.pCurrentReadAddress(:)=1;
            end

        end


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end



        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked


























                s.pInputFIFO=obj.pInputFIFO;
                s.pOutputPipe=obj.pOutputPipe;
                s.pOutputControlPipe=obj.pOutputControlPipe;
                s.pFIFOWriteCounter=obj.pFIFOWriteCounter;
                s.pFIFOReadCounter=obj.pFIFOReadCounter;
                s.pBufferFSMState=obj.pBufferFSMState;
                s.pColumnCounter=obj.pColumnCounter;
                s.pRowCounter=obj.pRowCounter;
                s.pStartLine=obj.pStartLine;
                s.pEndLine=obj.pEndLine;
                s.pLineLUT=obj.pLineLUT;
                s.pGradientLUT=obj.pGradientLUT;
                s.pRowMap=obj.pRowMap;
                s.pBirdsEyeDimensions=obj.pBirdsEyeDimensions;
                s.pLineLUTCount=obj.pLineLUTCount;
                s.pLineLUTCountREG=obj.pLineLUTCountREG;
                s.pRunLengthDecoder=obj.pRunLengthDecoder;
                s.pCurrentReadAddress=obj.pCurrentReadAddress;
                s.pCurrentReadAddressD=obj.pCurrentReadAddressD;
                s.pBetweenLines=obj.pBetweenLines;
                s.pBlankingCounter=obj.pBlankingCounter;
                s.pBlankingAverage=obj.pBlankingAverage;
                s.pLockedinFrame=obj.pLockedinFrame;
                s.pBirdsEyeColumnCounter=obj.pBirdsEyeColumnCounter;
                s.pBirdsEyeRowCounter=obj.pBirdsEyeRowCounter;
                s.pBirdsEyeBlankingCounter=obj.pBirdsEyeBlankingCounter;
                s.pBirdsEyeBlankingInterval=obj.pBirdsEyeBlankingInterval;
                s.pReadAddressGradient=obj.pReadAddressGradient;
                s.pReadAddressOffsetCorrected=obj.pReadAddressOffsetCorrected;
                s.pReadAddressFinal=obj.pReadAddressFinal;
                s.pRunDecodeAddress=obj.pRunDecodeAddress;
                s.DesiredBirdsEyeDimensions=obj.DesiredBirdsEyeDimensions;
                s.pCurrentOffset=obj.pCurrentOffset;
                s.pOffsetLUT=obj.pOffsetLUT;
            end



        end

        function loadObjectImpl(obj,s,~)


            fn=fieldnames(s);
            for ii=1:numel(fn)
                if~isempty(findprop(obj,fn{ii}))
                    obj.(fn{ii})=s.(fn{ii});
                end
            end

        end








        function[sz1,sz2]=getOutputSizeImpl(obj)
            sz1=propagatedInputSize(obj,1);
            sz2=propagatedInputSize(obj,2);


        end

        function[cp1,cp2]=isOutputComplexImpl(obj)
            cp1=propagatedInputComplexity(obj,1);
            cp2=propagatedInputComplexity(obj,2);


        end

        function[sz1,sz2]=isOutputFixedSizeImpl(obj)
            sz1=propagatedInputFixedSize(obj,1);
            sz2=propagatedInputFixedSize(obj,2);

        end

        function validateInputsImpl(~,dataIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(dataIn,{'numeric','embedded.fi'},...
                {'scalar','real'},'BirdsEyeView','dataIn');

                validatecontrolsignals(ctrlIn);
            end
        end

        function icon=getIconImpl(~)
            icon=sprintf('Birds-Eye View');

        end



        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=2;
        end


        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
        end


        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';

        end

        function pushFIFO(obj,dataIn)
            obj.pFIFOWriteCounter=obj.pFIFOWriteCounter+1;

            if obj.pFIFOWriteCounter<length(obj.pInputFIFO)
                obj.pInputFIFO(obj.pFIFOWriteCounter)=dataIn;
            end
            if obj.pFIFOWriteCounter>size(obj.pInputFIFO)
                obj.pFIFOWriteCounter(:)=1;
                coder.internal.warning('visionhdl:BirdsEyeView:FIFOOverflow');
            end

        end

        function[dataOut]=readFIFO(obj,readAddress)
            if readAddress>0&&readAddress<length(obj.pInputFIFO)
                dataOut=obj.pInputFIFO(readAddress);
            else
                dataOut=cast(0,'like',obj.pInputFIFO);
            end
        end


        function homographyBufferFSM(obj,dataIn,ctrlIn,vEndIn)
            [~,~,vStartIn,~,valid]=pixelcontrolsignals(ctrlIn);

            switch obj.pBufferFSMState

            case 0

                if vStartIn&&obj.pLockedinFrame
                    obj.pLockedinFrame=false;
                    obj.pRowCounter=obj.pRowCounter+1;
                end

                if obj.pRowCounter==obj.pStartLine+2
                    obj.pBufferFSMState(:)=1;

                    if~obj.pLockedinFrame
                        pushFIFO(obj,dataIn);
                    end

                else
                    obj.pBufferFSMState(:)=0;
                end

            case 1
                if valid&&~obj.pLockedinFrame
                    pushFIFO(obj,dataIn);
                end
                if obj.pRowCounter==obj.pEndLine+4
                    obj.pBufferFSMState(:)=2;
                    obj.pRowCounter(:)=1;
                    obj.pLockedinFrame=true;


                else
                    obj.pBufferFSMState(:)=1;
                end

            case 2

                if vEndIn
                    obj.pBufferFSMState(:)=0;
                else
                    obj.pBufferFSMState(:)=2;
                end

            otherwise

            end

        end

        function countRows(obj,ctrlIn,vEndIn)
            [hStartIn,~,~,~,~]=pixelcontrolsignals(ctrlIn);

            if vEndIn
                obj.pRowCounter(:)=1;
            elseif hStartIn
                obj.pRowCounter(:)=obj.pRowCounter+1;
            end

        end


        function countColumns(obj,ctrlIn)
            [hStartIn,~,~,~,validIn]=pixelcontrolsignals(ctrlIn);

            if hStartIn
                obj.pColumnCounter(:)=1;
            elseif validIn
                obj.pColumnCounter(:)=obj.pColumnCounter+1;
            end

        end


        function averageLineSpacing(obj,blankingInterval)

            obj.pBlankingAverage(2:end)=obj.pBlankingAverage(1:end-1);
            obj.pBlankingAverage(1)=blankingInterval;

        end

        function[readAddress]=computeReadAddress(obj,hStart)


            if obj.pLineLUTCountREG<=length(obj.pRowMap)&&(obj.pLineLUTCountREG>0)
                rowAddress=obj.pRowMap(obj.pLineLUTCountREG);
            else
                rowAddress=cast(0,'like',obj.pRowMap);
            end

            obj.pRunDecodeAddress(:)=(obj.pLineLUTCount-1)*obj.BirdsEyeActivePixels;

            if(obj.pLineLUTCountREG<=length(obj.pGradientLUT)&&(obj.pLineLUTCountREG>0))

                obj.pCurrentOffset(:)=obj.pOffsetLUT(obj.pLineLUTCount);
                obj.pReadAddressGradient(:)=(obj.pBirdsEyeColumnCounter)*obj.pGradientLUT(obj.pLineLUTCount);
                obj.pReadAddressOffsetCorrected(:)=obj.pReadAddressGradient+obj.pOffsetLUT(obj.pLineLUTCount);
                obj.pReadAddressFinal(:)=(obj.pRunDecodeAddress)+obj.pReadAddressOffsetCorrected;
                readAddress=uint32(floor(obj.pReadAddressFinal));
            else
                readAddress=uint32(0);
            end

            obj.pLineLUTCountREG(:)=obj.pLineLUTCount;
            if hStart
                if(obj.pRunLengthDecoder==rowAddress)
                    obj.pLineLUTCount(:)=obj.pLineLUTCount+1;
                    obj.pRunLengthDecoder(:)=0;
                else
                    obj.pRunLengthDecoder(:)=obj.pRunLengthDecoder+1;
                end
            end

        end

        function[dt1,dt2]=getOutputDataTypeImpl(obj)
            intype=propagatedInputDataType(obj,1);
            dt1=intype;
            dt2=pixelcontrolbustype;









        end

    end

    methods(Static,Hidden)

        function[rowMap,startLine,endLine,BirdsEyeDimensions,requiredSourceLines]=...
            forwardRowMapping(hM,sourceLineLimit,BirdsEyeActiveLines,BirdsEyeActivePixels)

            tForm=projective2d(hM);
            rowMap=zeros(1,sourceLineLimit);
            yprev=0;
            centreColumn=ceil(BirdsEyeActivePixels/2);
            kk=1;
            lineCount=1;
            BirdsEyeDimensions=zeros(2,1);

            for ii=1:1:BirdsEyeActiveLines
                [~,yout]=transformPointsForward(tForm,centreColumn,ii);
                if ceil(yout)>yprev
                    yprev=ceil(yout);
                    if(kk<=sourceLineLimit)
                        rowMap(kk)=lineCount;
                        BirdsEyeDimensions(2)=BirdsEyeActivePixels;
                        BirdsEyeDimensions(1)=ii;
                    end

                    lineCount=1;
                    kk=kk+1;
                else
                    lineCount=lineCount+1;

                end
            end

            if sum(rowMap(:))<BirdsEyeActiveLines
                if(kk<=sourceLineLimit)
                    rowMap(kk)=lineCount;
                    BirdsEyeDimensions(2)=BirdsEyeActivePixels;
                    BirdsEyeDimensions(1)=BirdsEyeActiveLines;
                end

                endLine=yprev+1;
            else
                endLine=yprev;
            end

            [~,yout]=transformPointsForward(tForm,centreColumn,1);
            startLine=ceil(yout);

            if endLine<startLine
                startLine=endLine;
                endLine=startLine;
            else

            end

            requiredSourceLines=(endLine-startLine)+1;

        end

        function[gradVal,OffsetLUTV]=...
            forwardColumnMapping(hM,startLine,endLine,rowMap,BirdsEyeActiveLines,BirdsEyeActivePixels,MaxSourceLinesBuffered)

            tForm=projective2d(hM);
            vecSize=(endLine-startLine)+2;
            colIndex=zeros(1,5);
            gradVal=zeros(1,vecSize);
            offsetVal=zeros(1,vecSize);
            columnCount=1;
            rowMapIndex=1;
            kk=1;


            FOffset=fimath('RoundMode','Nearest',...
            'OverflowMode','Saturate',...
            'SumMode','FullPrecision',...
            'SumWordLength',ceil(log2(BirdsEyeActivePixels))*2,...
            'SumFractionLength',10,...
            'CastBeforeSum',true);


            otype=fi(0,0,ceil(log2(BirdsEyeActivePixels))*2,10);



            for ii=1:1:BirdsEyeActiveLines

                colIndex(:)=0;

                if columnCount==rowMap(rowMapIndex)&&rowMapIndex<length(rowMap)

                    [colIndex(1),~]=transformPointsForward(tForm,1,ii);



                    [colIndex(5),~]=transformPointsForward(tForm,BirdsEyeActivePixels,ii);


                    gradVal(kk)=(colIndex(5)-colIndex(1))/BirdsEyeActivePixels;
                    offsetVal(kk)=colIndex(1);
                    rowMapIndex=rowMapIndex+1;
                    columnCount=1;
                    kk=kk+1;
                end
                columnCount=columnCount+1;
            end

            OffsetLUTV=fi(zeros(1,MaxSourceLinesBuffered),otype.numerictype,FOffset);
            OffsetLUTV(:)=offsetVal(1:MaxSourceLinesBuffered);

        end

    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.BirdsEyeView',...
            'ShowSourceLink',false,...
            'Title','Birds-Eye View');
        end

        function group=getPropertyGroupsImpl

            group=matlab.system.display.Section(mfilename('class'));
        end
    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

end
