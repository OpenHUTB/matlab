classdef(StrictDefaults)ImageStatistics<matlab.System



























































%#codegen


    properties(Nontunable)



        mean(1,1)logical=true;




        variance(1,1)logical=true;




        stdDev(1,1)logical=true;
    end

    properties(Access=private)
        lvlOneAcc;
        lvlTwoAcc;
        lvlThreeAcc;
        lvlFourAcc;

        lvlOneCount;
        lvlTwoCount;
        lvlThreeCount;
        lvlFourCount;


        lvlOneAccVar;
        lvlTwoAccVar;
        lvlThreeAccVar;
        lvlFourAccVar;
        lvlOneCountVar;
        lvlTwoCountVar;
        lvlThreeCountVar;
        lvlFourCountVar;

        validPipeline;

        recipLUT;
        inFrame=false;
        inLine=false;
        processfhandle;
        endnormfhandle;
        normalizePipelineCast;
        lvlOneNormCast;
        lvlTwoNormCast;
        lvlThreeNormCast;
        lvlOneNormVarCast;
        lvlTwoNormVarCast;
        lvlThreeNormVarCast;
        lvlOneNorm;
        lvlTwoNorm;
        lvlThreeNorm;
        normalizePipeline;
        absDataIn;
        lvlOneNormVar;
        lvlTwoNormVar;
        lvlThreeNormVar;
        finalVar;
        meanSquared;
        normalizePipelineVar;
        normalizePipelineVarCast;
        dataInSquare;
        normalizePipelineStdDev;
        normalizePipelineStdDevCast;
        inputInteger;
        outputWrite;
        outputWriteCount;
        statusComplete;
    end

    methods
        function obj=ImageStatistics(varargin)
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
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('visionhdl.ImageStatistics',...
            'ShowSourceLink',false,...
            'Title','Image Statistics');
        end

        function groups=getPropertyGroupsImpl

            groups=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'mean','variance','stdDev'});
        end

    end

    methods(Access=protected)

        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(obj)
            numStats=(double(obj.mean)+double(obj.variance)+double(obj.stdDev));
            num=numStats+min(numStats,1);

        end

        function icon=getIconImpl(~)
            icon=sprintf('Image Statistics');
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='pixel';
            varargout{2}='ctrl';
        end

        function varargout=getOutputSizeImpl(obj)
            for ii=1:obj.getNumOutputsImpl
                varargout{ii}=propagatedInputSize(obj,1);
            end
        end

        function varargout=isOutputComplexImpl(obj)
            for ii=1:obj.getNumOutputsImpl
                varargout{ii}=propagatedInputComplexity(obj,1);
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            dataInDT=propagatedInputDataType(obj,1);
            if isnumerictype(dataInDT)
                meanDT=numerictype(false,dataInDT.WordLength,dataInDT.FractionLength);
                varDT=numerictype(false,2*(dataInDT.WordLength),dataInDT.FractionLength);
                stdvDT=numerictype(false,dataInDT.WordLength,dataInDT.FractionLength);
            elseif strcmp(dataInDT,'double')||strcmp(dataInDT,'single')
                meanDT=dataInDT;
                varDT=dataInDT;
                stdvDT=dataInDT;
            elseif strcmp(dataInDT,'int8')||strcmp(dataInDT,'uint8')
                meanDT='uint8';
                varDT='uint16';
                stdvDT='uint8';
            elseif strcmp(dataInDT,'int16')||strcmp(dataInDT,'uint16')
                meanDT='uint16';
                varDT='uint32';
                stdvDT='uint16';
            elseif strcmp(dataInDT,'half')||strcmp(dataInDT,'int32')||strcmp(dataInDT,'uint32')||strcmp(dataInDT,'int64')||strcmp(dataInDT,'uint64')||strcmp(dataInDT,'logical')

                meanDT='uint8';
                varDT='uint16';
                stdvDT='uint8';
            else
                meanDT=numerictype(false,dataInDT.WordLength,dataInDT.FractionLength);
                varDT=numerictype(false,2*(dataInDT.WordLength),dataInDT.FractionLength);
                stdvDT=numerictype(false,dataInDT.WordLength,dataInDT.FractionLength);
            end

            switch double(obj.mean)+(2*double(obj.variance))+(4*double(obj.stdDev))
            case 1
                varargout{1}=meanDT;
                varargout{2}='logical';
            case 2
                varargout{1}=varDT;
                varargout{2}='logical';
            case 3
                varargout{1}=meanDT;
                varargout{2}=varDT;
                varargout{3}='logical';
            case 4
                varargout{1}=stdvDT;
                varargout{2}='logical';
            case 5
                varargout{1}=meanDT;
                varargout{2}=stdvDT;
                varargout{3}='logical';
            case 6
                varargout{1}=varDT;
                varargout{2}=stdvDT;
                varargout{3}='logical';
            case 7
                varargout{1}=meanDT;
                varargout{2}=varDT;
                varargout{3}=stdvDT;
                varargout{4}='logical';
            otherwise
                varargout=cell(0);
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            for ii=1:obj.getNumOutputsImpl
                varargout{ii}=propagatedInputFixedSize(obj,1);
            end
        end

        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));
            num=1;

            if obj.mean==true
                varargout{num}='mean';
                num=num+1;
            end

            if obj.variance==true
                varargout{num}='var';
                num=num+1;
            end

            if obj.stdDev==true
                varargout{num}='stdDev';
                num=num+1;
            end

            varargout{num}='validOut';
        end


        function validateInputsImpl(~,pixelIn,ctrlIn)

            if isempty(coder.target)||~eml_ambiguous_types



                validateattributes(pixelIn,{'single','double','uint8','uint16','embedded.fi'},...
                {'scalar','real','nonnan','finite'},'ImageStatistics','pixel input');
                if isfi(pixelIn)

                    coder.internal.errorIf(issigned(pixelIn),'visionhdl:ImageStatistics:SignedType');

                    coder.internal.errorIf((pixelIn.WordLength>42),'visionhdl:ImageStatistics:WordLength');

                    coder.internal.errorIf((pixelIn.FractionLength~=0),'visionhdl:ImageStatistics:NoFraction');
                end

                validatecontrolsignals(ctrlIn);
            end

        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.inFrame=obj.inFrame;
                s.recipLUT=obj.recipLUT;
                s.inLine=obj.inLine;
                s.processfhandle=obj.processfhandle;
                s.endnormfhandle=obj.endnormfhandle;
                s.normalizePipelineCast=obj.normalizePipelineCast;
                s.lvlOneNormCast=obj.lvlOneNormCast;
                s.lvlOneNormVarCast=obj.lvlOneNormVarCast;
                s.lvlTwoNormCast=obj.lvlTwoNormCast;
                s.lvlTwoNormVarCast=obj.lvlTwoNormVarCast;
                s.lvlOneNorm=obj.lvlOneNorm;
                s.statusComplete=obj.statusComplete;
                s.lvlTwoNorm=obj.lvlTwoNorm;
                s.normalizePipeline=obj.normalizePipeline;
                s.absDataIn=obj.absDataIn;
                s.lvlOneNormVar=obj.lvlOneNormVar;
                s.lvlTwoNormVar=obj.lvlTwoNormVar;
                s.finalVar=obj.finalVar;
                s.meanSquared=obj.meanSquared;
                s.normalizePipelineVar=obj.normalizePipelineVar;
                s.dataInSquare=obj.dataInSquare;
                s.normalizePipelineStdDev=obj.normalizePipelineStdDev;
                s.normalizePipelineStdDevCast=obj.normalizePipelineStdDevCast;

                s.lvlOneAcc=obj.lvlOneAcc;
                s.lvlTwoAcc=obj.lvlTwoAcc;
                s.lvlThreeAcc=obj.lvlThreeAcc;
                s.lvlFourAcc=obj.lvlFourAcc;
                s.lvlOneCount=obj.lvlOneCount;
                s.lvlTwoCount=obj.lvlTwoCount;
                s.lvlThreeCount=obj.lvlThreeCount;
                s.lvlFourCount=obj.lvlFourCount;
                s.lvlOneAccVar=obj.lvlOneAccVar;
                s.lvlTwoAccVar=obj.lvlTwoAccVar;
                s.lvlThreeAccVar=obj.lvlThreeAccVar;
                s.lvlFourAccVar=obj.lvlFourAccVar;
                s.lvlOneCountVar=obj.lvlOneCountVar;
                s.lvlTwoCountVar=obj.lvlTwoCountVar;
                s.lvlThreeCountVar=obj.lvlThreeCountVar;
                s.lvlFourCountVar=obj.lvlFourCountVar;
                s.validPipeline=obj.validPipeline;
            end

        end


        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end


        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end


        function setupImpl(obj,dataIn,~)

            coder.internal.errorIf(((obj.mean==false)&&(obj.variance==false)&&(obj.stdDev==false)),'visionhdl:ImageStatistics:Properties');

            if isa(dataIn,'double')
                obj.setupFloat('double');
            elseif isa(dataIn,'single')
                obj.setupFloat('single');
            end

            if isempty(coder.target)||~eml_ambiguous_types
                if isa(dataIn,'embedded.fi')
                    obj.setupFixed(dataIn.WordLength,dataIn.FractionLength);
                    obj.inputInteger=false;
                elseif isinteger(dataIn)
                    if isa(dataIn,'uint8')
                        WL=8;FL=0;
                        obj.inputInteger=true;



                    elseif(isa(dataIn,'uint16'))
                        WL=16;FL=0;
                        obj.inputInteger=true;









                    end

                    obj.setupInteger(WL,FL);
                end
            end


            if(obj.mean==true)&&(obj.variance==false)&&(obj.stdDev==false)
                obj.processfhandle=@calcMean;
                obj.endnormfhandle=@normMean;
            end

            if(obj.variance==true)&&(obj.stdDev==false)
                obj.processfhandle=@calcVariance;
                obj.endnormfhandle=@normVariance;
            end

            if obj.stdDev==true
                obj.processfhandle=@calcStdDev;
                obj.endnormfhandle=@normStdDev;
            end

        end


        function resetImpl(obj)
            obj.lvlOneAcc(:)=0;
            obj.lvlTwoAcc(:)=0;
            obj.lvlThreeAcc(:)=0;
            obj.lvlFourAcc(:)=0;

            obj.lvlOneCount(:)=0;
            obj.lvlTwoCount(:)=0;
            obj.lvlThreeCount(:)=0;
            obj.lvlFourCount(:)=0;


            obj.lvlOneAccVar(:)=0;
            obj.lvlTwoAccVar(:)=0;
            obj.lvlThreeAccVar(:)=0;
            obj.lvlFourAccVar(:)=0;
            obj.lvlOneCountVar(:)=0;
            obj.lvlTwoCountVar(:)=0;
            obj.lvlThreeCountVar(:)=0;
            obj.lvlFourCountVar(:)=0;

            obj.validPipeline(:)=0;

            obj.inFrame=false;
            obj.inLine=false;

            obj.normalizePipelineCast(:)=0;
            obj.lvlOneNormCast(:)=0;
            obj.lvlTwoNormCast(:)=0;
            obj.lvlThreeNormCast(:)=0;
            obj.lvlOneNormVarCast(:)=0;
            obj.lvlTwoNormVarCast(:)=0;
            obj.lvlThreeNormVarCast(:)=0;
            obj.lvlOneNorm(:)=0;
            obj.lvlTwoNorm(:)=0;
            obj.lvlThreeNorm(:)=0;
            obj.normalizePipeline(:)=0;
            obj.absDataIn(:)=0;
            obj.lvlOneNormVar(:)=0;
            obj.lvlTwoNormVar(:)=0;
            obj.lvlThreeNormVar(:)=0;
            obj.finalVar(:)=0;
            obj.meanSquared(:)=0;
            obj.normalizePipelineVar(:)=0;
            obj.normalizePipelineVarCast(:)=0;
            obj.dataInSquare(:)=0;
            obj.normalizePipelineStdDev(:)=0;
            obj.normalizePipelineStdDevCast(:)=0;
            obj.outputWrite=false;
            obj.outputWriteCount(:)=0;
            obj.statusComplete=false;
        end



        function[varargout]=outputImpl(obj,~,~)









            switch double(obj.mean)+(2*double(obj.variance))+(4*double(obj.stdDev))


            case 1
                varargout{1}=obj.normalizePipeline(end-1);
                varargout{2}=obj.validPipeline(end-1);


            case 2
                varargout{1}=obj.normalizePipelineVar(end-1);
                varargout{2}=obj.validPipeline(end-1);


            case 3
                varargout{1}=obj.normalizePipeline(end-1);
                varargout{2}=obj.normalizePipelineVar(end-1);
                varargout{3}=obj.validPipeline(end-1);


            case 4
                varargout{1}=obj.normalizePipelineStdDev(end-1);
                varargout{2}=obj.validPipeline(end-1);


            case 5
                varargout{1}=obj.normalizePipeline(end-1);
                varargout{2}=obj.normalizePipelineStdDev(end-1);
                varargout{3}=obj.validPipeline(end-1);


            case 6
                varargout{1}=obj.normalizePipelineVar(end-1);
                varargout{2}=obj.normalizePipelineStdDev(end-1);
                varargout{3}=obj.validPipeline(end-1);


            case 7
                varargout{1}=obj.normalizePipeline(end-1);
                varargout{2}=obj.normalizePipelineVar(end-1);
                varargout{3}=obj.normalizePipelineStdDev(end-1);
                varargout{4}=obj.validPipeline(end-1);


            otherwise
                varargout{1}=obj.normalizePipeline(end-1);
                varargout{2}=obj.validPipeline(end-1);


            end
        end



        function updateImpl(obj,dataIn,CtrlIn)


            [hStart,hEnd,vStart,vEnd,validIn]=pixelcontrolsignals(CtrlIn);


            if validIn

                if vStart
                    obj.inFrame=true;
                    startVideoFrame(obj)

                    if hStart
                        obj.inLine=true;
                    end

                elseif obj.inFrame&&vEnd
                    if((~obj.outputWrite)&&(~obj.statusComplete))
                        endVideoFrame(obj,obj.processfhandle,obj.endnormfhandle,dataIn);
                    end
                    obj.inFrame=false;
                    obj.inLine=false;
                    obj.outputWrite=true;

                    if~hEnd
                        coder.internal.warning('visionhdl:PixelsToFrame:vendhend');
                    end

                    obj.statusComplete=false;

                elseif obj.inFrame&&obj.inLine&&hEnd
                    obj.inLine=false;
                    endVideoLine(obj,obj.processfhandle,dataIn);

                elseif obj.inFrame&&hStart
                    obj.inLine=true;

                elseif obj.inFrame&&~obj.inLine&&hEnd
                    obj.inLine=false;
                    coder.internal.warning('visionhdl:PixelsToFrame:extrahend');

                elseif~obj.inFrame&&(hStart||hEnd)
                    coder.internal.warning('visionhdl:PixelsToFrame:lineoutsideframe');
                end

                if((obj.inFrame&&obj.inLine)&&(~obj.statusComplete))
                    processInputPixel(obj,obj.processfhandle,dataIn);
                end
            end

            if obj.statusComplete
                obj.lvlOneAcc(:)=0;
                obj.lvlTwoAcc(:)=0;
                obj.lvlThreeAcc(:)=0;
                obj.lvlFourAcc(:)=0;
                obj.lvlOneCount(:)=0;
                obj.lvlTwoCount(:)=0;
                obj.lvlThreeCount(:)=0;
                obj.lvlFourCount(:)=0;
                obj.lvlOneAccVar(:)=0;
                obj.lvlTwoAccVar(:)=0;
                obj.lvlThreeAccVar(:)=0;
                obj.lvlFourAccVar(:)=0;
                obj.lvlOneCountVar(:)=0;
                obj.lvlTwoCountVar(:)=0;
                obj.lvlThreeCountVar(:)=0;
                obj.lvlFourCountVar(:)=0;

            end


            if obj.outputWrite
                obj.outputWriteCount(:)=obj.outputWriteCount+1;
            end

            if obj.outputWriteCount==15
                obj.outputWrite=false;
                obj.outputWriteCount(:)=0;
            end



            obj.normalizePipeline(2:end)=obj.normalizePipeline(1:(end-1));
            obj.normalizePipelineVar(2:end)=obj.normalizePipelineVar(1:(end-1));
            obj.normalizePipelineStdDev(2:end)=obj.normalizePipelineStdDev(1:(end-1));
            obj.validPipeline(2:end)=obj.validPipeline(1:(end-1));
            obj.validPipeline(1)=false;


        end


    end


    methods(Access=private)



        function startVideoFrame(obj)

            obj.lvlOneAcc(:)=0;
            obj.lvlTwoAcc(:)=0;
            obj.lvlThreeAcc(:)=0;
            obj.lvlFourAcc(:)=0;

            obj.lvlOneAccVar(:)=0;
            obj.lvlTwoAccVar(:)=0;
            obj.lvlThreeAccVar(:)=0;
            obj.lvlFourAccVar(:)=0;

            obj.lvlOneCount(:)=0;
            obj.lvlTwoCount(:)=0;
            obj.lvlThreeCount(:)=0;
            obj.lvlFourCount(:)=0;

            obj.lvlOneCountVar(:)=0;
            obj.lvlTwoCountVar(:)=0;
            obj.lvlThreeCountVar(:)=0;
            obj.lvlFourCountVar(:)=0;

        end

        function endVideoFrame(obj,processfhandle,normalfhandle,dataIn)

            processInputPixel(obj,processfhandle,dataIn);
            normalfhandle(obj);
        end

        function endVideoLine(obj,processfhandle,dataIn)
            processInputPixel(obj,processfhandle,dataIn);
        end

        function processInputPixel(obj,processfhandle,dataIn)

            processfhandle(obj,dataIn);

        end







        function calcMean(obj,dataIn)



            obj.absDataIn(:)=(abs(dataIn));
            obj.lvlOneAcc(:)=obj.lvlOneAcc+obj.absDataIn;
            obj.lvlOneCount(:)=obj.lvlOneCount+1;

            if obj.lvlOneCount==64


                obj.lvlOneCount(:)=0;
                obj.lvlOneNorm(:)=((obj.lvlOneAcc)*obj.recipLUT(64));
                obj.lvlOneNormCast(:)=obj.lvlOneNorm;
                obj.lvlTwoAcc(:)=obj.lvlTwoAcc+obj.lvlOneNormCast;
                obj.lvlTwoCount(:)=obj.lvlTwoCount+1;
                obj.lvlOneAcc(:)=0;
            end

            if obj.lvlTwoCount==64


                obj.lvlTwoCount(:)=0;
                obj.lvlTwoNorm(:)=((obj.lvlTwoAcc)*obj.recipLUT(64));
                obj.lvlTwoNormCast(:)=obj.lvlTwoNorm;
                obj.lvlThreeAcc(:)=obj.lvlThreeAcc+obj.lvlTwoNormCast;
                obj.lvlThreeCount(:)=obj.lvlThreeCount+1;
                obj.lvlTwoAcc(:)=0;
            end

            if obj.lvlThreeCount==64


                obj.lvlThreeCount(:)=0;
                obj.lvlThreeNorm(:)=((obj.lvlThreeAcc)*obj.recipLUT(64));
                obj.lvlThreeNormCast(:)=obj.lvlThreeNorm;
                obj.lvlFourAcc(:)=obj.lvlFourAcc+obj.lvlThreeNormCast;
                obj.lvlFourCount(:)=obj.lvlFourCount+1;
                obj.lvlThreeAcc(:)=0;
            end

            if obj.lvlFourCount==64

                obj.normalizePipelineCast(:)=obj.lvlFourAcc*obj.recipLUT(obj.lvlFourCount);
                obj.normalizePipeline(1:10)=obj.normalizePipelineCast;
                obj.validPipeline(10)=true;
                obj.statusComplete=true;
            end




        end



        function calcVariance(obj,dataIn)





            obj.absDataIn(:)=(abs(dataIn));

            obj.lvlOneAcc(:)=obj.lvlOneAcc+obj.absDataIn;
            obj.lvlOneCount(:)=obj.lvlOneCount+1;


            if obj.lvlOneCount==64



                obj.lvlOneCount(:)=0;
                obj.lvlOneNorm(:)=((obj.lvlOneAcc)*obj.recipLUT(64));
                obj.lvlOneNormCast(:)=obj.lvlOneNorm;
                obj.lvlTwoAcc(:)=obj.lvlTwoAcc+obj.lvlOneNormCast;
                obj.lvlTwoCount(:)=obj.lvlTwoCount+1;
                obj.lvlOneAcc(:)=0;
            end

            if obj.lvlTwoCount==64

                obj.lvlTwoCount(:)=0;
                obj.lvlTwoNorm(:)=((obj.lvlTwoAcc)*obj.recipLUT(64));
                obj.lvlTwoNormCast(:)=obj.lvlTwoNorm;
                obj.lvlThreeAcc(:)=obj.lvlThreeAcc+obj.lvlTwoNormCast;
                obj.lvlThreeCount(:)=obj.lvlThreeCount+1;
                obj.lvlTwoAcc(:)=0;
            end

            if obj.lvlThreeCount==64

                obj.lvlThreeCount(:)=0;
                obj.lvlThreeNorm(:)=((obj.lvlThreeAcc)*obj.recipLUT(64));
                obj.lvlThreeNormCast(:)=obj.lvlThreeNorm;
                obj.lvlFourAcc(:)=obj.lvlFourAcc+obj.lvlThreeNormCast;
                obj.lvlFourCount(:)=obj.lvlFourCount+1;
                obj.lvlThreeAcc(:)=0;
            end

            if obj.lvlFourCount==64

                obj.normalizePipelineCast(:)=obj.lvlFourAcc*obj.recipLUT(obj.lvlFourCount);
                obj.normalizePipeline(1:10)=obj.normalizePipelineCast;
                obj.statusComplete=true;
            end



            obj.dataInSquare(:)=obj.absDataIn*obj.absDataIn;
            obj.lvlOneAccVar(:)=obj.lvlOneAccVar+(obj.dataInSquare);
            obj.lvlOneCountVar(:)=obj.lvlOneCountVar+1;


            if obj.lvlOneCountVar==64



                obj.lvlOneCountVar(:)=0;
                obj.lvlOneNormVar(:)=((obj.lvlOneAccVar)*obj.recipLUT(64));
                obj.lvlOneNormVarCast(:)=obj.lvlOneNormVar;
                obj.lvlTwoAccVar(:)=obj.lvlTwoAccVar+obj.lvlOneNormVarCast;
                obj.lvlTwoCountVar(:)=obj.lvlTwoCountVar+1;
                obj.lvlOneAccVar(:)=0;
            end

            if obj.lvlTwoCountVar==64


                obj.lvlTwoCountVar(:)=0;
                obj.lvlTwoNormVar(:)=((obj.lvlTwoAccVar)*obj.recipLUT(64));
                obj.lvlTwoNormVarCast(:)=obj.lvlTwoNormVar;
                obj.lvlThreeAccVar(:)=obj.lvlThreeAccVar+obj.lvlTwoNormVarCast;
                obj.lvlThreeCountVar(:)=obj.lvlThreeCountVar+1;
                obj.lvlTwoAccVar(:)=0;
            end

            if obj.lvlThreeCountVar==64

                obj.lvlThreeCountVar(:)=0;
                obj.lvlThreeNormVar(:)=((obj.lvlThreeAccVar)*obj.recipLUT(64));
                obj.lvlThreeNormVarCast(:)=obj.lvlThreeNormVar;
                obj.lvlFourAccVar(:)=obj.lvlFourAccVar+obj.lvlThreeNormVarCast;
                obj.lvlFourCountVar(:)=obj.lvlFourCountVar+1;
                obj.lvlThreeAccVar(:)=0;
            end

            if obj.lvlFourCountVar==64

                obj.meanSquared(:)=obj.normalizePipelineCast(1)*obj.normalizePipelineCast(1);
                obj.finalVar(:)=obj.lvlFourAccVar*obj.recipLUT(obj.lvlFourCountVar);
                obj.normalizePipelineVarCast(:)=(obj.finalVar-obj.meanSquared);
                obj.normalizePipelineVar(1:10)=obj.normalizePipelineVarCast;
                obj.validPipeline(10)=true;
            end




        end


        function calcStdDev(obj,dataIn)





            obj.absDataIn(:)=(abs(dataIn));

            obj.lvlOneAcc(:)=obj.lvlOneAcc+obj.absDataIn;
            obj.lvlOneCount(:)=obj.lvlOneCount+1;


            if obj.lvlOneCount==64



                obj.lvlOneCount(:)=0;
                obj.lvlOneNorm(:)=((obj.lvlOneAcc)*obj.recipLUT(64));
                obj.lvlOneNormCast(:)=obj.lvlOneNorm;
                obj.lvlTwoAcc(:)=obj.lvlTwoAcc+obj.lvlOneNormCast;
                obj.lvlTwoCount(:)=obj.lvlTwoCount+1;
                obj.lvlOneAcc(:)=0;
            end

            if obj.lvlTwoCount==64

                obj.lvlTwoCount(:)=0;
                obj.lvlTwoNorm(:)=((obj.lvlTwoAcc)*obj.recipLUT(64));
                obj.lvlTwoNormCast(:)=obj.lvlTwoNorm;
                obj.lvlThreeAcc(:)=obj.lvlThreeAcc+obj.lvlTwoNormCast;
                obj.lvlThreeCount(:)=obj.lvlThreeCount+1;
                obj.lvlTwoAcc(:)=0;
            end

            if obj.lvlThreeCount==64

                obj.lvlThreeCount(:)=0;
                obj.lvlThreeNorm(:)=((obj.lvlThreeAcc)*obj.recipLUT(64));
                obj.lvlThreeNormCast(:)=obj.lvlThreeNorm;
                obj.lvlFourAcc(:)=obj.lvlFourAcc+obj.lvlThreeNormCast;
                obj.lvlFourCount(:)=obj.lvlFourCount+1;
                obj.lvlThreeAcc(:)=0;
            end


            if obj.lvlFourCount==64

                obj.outputWrite=false;
                obj.normalizePipelineCast(:)=obj.lvlFourAcc*obj.recipLUT(obj.lvlFourCount);
                obj.normalizePipeline(1:10)=obj.normalizePipelineCast;
                obj.statusComplete=true;
            end




            obj.dataInSquare(:)=obj.absDataIn*obj.absDataIn;
            obj.lvlOneAccVar(:)=obj.lvlOneAccVar+(obj.dataInSquare);
            obj.lvlOneCountVar(:)=obj.lvlOneCountVar+1;


            if obj.lvlOneCountVar==64



                obj.lvlOneCountVar(:)=0;
                obj.lvlOneNormVar(:)=((obj.lvlOneAccVar)*obj.recipLUT(64));
                obj.lvlOneNormVarCast(:)=obj.lvlOneNormVar;
                obj.lvlTwoAccVar(:)=obj.lvlTwoAccVar+obj.lvlOneNormVarCast;
                obj.lvlTwoCountVar(:)=obj.lvlTwoCountVar+1;
                obj.lvlOneAccVar(:)=0;
            end

            if obj.lvlTwoCountVar==64


                obj.lvlTwoCountVar(:)=0;
                obj.lvlTwoNormVar(:)=((obj.lvlTwoAccVar)*obj.recipLUT(64));
                obj.lvlTwoNormVarCast(:)=obj.lvlTwoNormVar;
                obj.lvlThreeAccVar(:)=obj.lvlThreeAccVar+obj.lvlTwoNormVarCast;
                obj.lvlThreeCountVar(:)=obj.lvlThreeCountVar+1;
                obj.lvlTwoAccVar(:)=0;
            end

            if obj.lvlThreeCountVar==64


                obj.lvlThreeCountVar(:)=0;
                obj.lvlThreeNormVar(:)=((obj.lvlThreeAccVar)*obj.recipLUT(64));
                obj.lvlThreeNormVarCast(:)=obj.lvlThreeNormVar;
                obj.lvlFourAccVar(:)=obj.lvlFourAccVar+obj.lvlThreeNormVarCast;
                obj.lvlFourCountVar(:)=obj.lvlFourCountVar+1;
                obj.lvlThreeAccVar(:)=0;
            end

            if obj.lvlThreeCountVar==64

                obj.meanSquared(:)=obj.normalizePipelineCast*obj.normalizePipelineCast;
                obj.finalVar(:)=obj.lvlFourAccVar*obj.recipLUT(obj.lvlFourCountVar);
                obj.normalizePipelineVarCast(:)=(obj.finalVar-obj.meanSquared);
                obj.normalizePipelineVar(1:10)=obj.normalizePipelineVarCast;
                obj.normalizePipelineStdDevCast(:)=sqrt(obj.normalizePipelineVarCast);
                obj.normalizePipelineStdDev(1:10)=obj.normalizePipelineStdDevCast;
                obj.validPipeline(10)=true;
            end



        end




        function normMean(obj)



            if obj.lvlOneCount>0
                obj.lvlOneNorm(:)=((obj.lvlOneAcc)*obj.recipLUT(obj.lvlOneCount));
                obj.lvlOneNormCast(:)=obj.lvlOneNorm;
                obj.lvlTwoAcc(:)=obj.lvlTwoAcc+obj.lvlOneNormCast;
                obj.lvlTwoCount(:)=obj.lvlTwoCount+1;
            end

            if obj.lvlTwoCount>0
                obj.lvlTwoNorm(:)=((obj.lvlTwoAcc)*obj.recipLUT(obj.lvlTwoCount));
                obj.lvlTwoNormCast(:)=obj.lvlTwoNorm;
                obj.lvlThreeAcc(:)=obj.lvlThreeAcc+obj.lvlTwoNormCast;
                obj.lvlThreeCount(:)=obj.lvlThreeCount+1;
            end

            if obj.lvlThreeCount>0
                obj.lvlThreeNorm(:)=((obj.lvlThreeAcc)*obj.recipLUT(obj.lvlThreeCount));
                obj.lvlThreeNormCast(:)=obj.lvlThreeNorm;
                obj.lvlFourAcc(:)=obj.lvlFourAcc+obj.lvlThreeNormCast;
                obj.lvlFourCount(:)=obj.lvlFourCount+1;
            end



            if obj.lvlFourCount~=64
                if obj.lvlFourCount==0
                    obj.lvlFourCount(:)=obj.lvlFourCount+1;
                end

                obj.normalizePipelineCast(:)=obj.lvlFourAcc*obj.recipLUT(obj.lvlFourCount);

                if(obj.lvlThreeCount>1)&&(obj.lvlOneCount<10)&&(obj.lvlOneCount>0)
                    obj.normalizePipeline(1:obj.lvlOneCount)=obj.normalizePipelineCast;
                    obj.validPipeline(obj.lvlOneCount)=true;
                elseif(obj.lvlThreeCount>1)&&(obj.lvlOneCount==10)
                    obj.normalizePipeline(1:5)=obj.normalizePipelineCast;
                    obj.validPipeline(5)=true;
                elseif(obj.lvlTwoCount>0)&&(obj.lvlOneCount<5)&&(obj.lvlOneCount>0)
                    obj.normalizePipeline(1:obj.lvlOneCount+5)=obj.normalizePipelineCast;
                    obj.validPipeline(obj.lvlOneCount+5)=true;
                else
                    obj.normalizePipeline(1:10)=obj.normalizePipelineCast;
                    obj.validPipeline(10)=true;
                end


            end



            obj.lvlOneAcc(:)=0;
            obj.lvlTwoAcc(:)=0;
            obj.lvlThreeAcc(:)=0;
            obj.lvlFourAcc(:)=0;
            obj.lvlOneCount(:)=0;
            obj.lvlTwoCount(:)=0;
            obj.lvlThreeCount(:)=0;
            obj.lvlFourCount(:)=0;

        end


        function normVariance(obj)





            if obj.lvlOneCount>0
                obj.lvlOneNorm(:)=((obj.lvlOneAcc)*obj.recipLUT(obj.lvlOneCount));
                obj.lvlOneNormCast(:)=obj.lvlOneNorm;
                obj.lvlTwoAcc(:)=obj.lvlTwoAcc+obj.lvlOneNormCast;
                obj.lvlTwoCount(:)=obj.lvlTwoCount+1;
            end

            if obj.lvlTwoCount>0
                obj.lvlTwoNorm(:)=((obj.lvlTwoAcc)*obj.recipLUT(obj.lvlTwoCount));
                obj.lvlTwoNormCast(:)=obj.lvlTwoNorm;
                obj.lvlThreeAcc(:)=obj.lvlThreeAcc+obj.lvlTwoNormCast;
                obj.lvlThreeCount(:)=obj.lvlThreeCount+1;
            end

            if obj.lvlThreeCount>0
                obj.lvlThreeNorm(:)=((obj.lvlThreeAcc)*obj.recipLUT(obj.lvlThreeCount));
                obj.lvlThreeNormCast(:)=obj.lvlThreeNorm;
                obj.lvlFourAcc(:)=obj.lvlFourAcc+obj.lvlThreeNormCast;
                obj.lvlFourCount(:)=obj.lvlFourCount+1;
            end




            if obj.lvlFourCount~=64
                if obj.lvlThreeCount==0
                    obj.lvlThreeCount(:)=obj.lvlThreeCount+1;
                end
                obj.normalizePipelineCast(:)=obj.lvlFourAcc*obj.recipLUT(obj.lvlFourCount);

                if(obj.lvlThreeCount>1)&&(obj.lvlOneCount<10)&&(obj.lvlOneCount>0)
                    obj.normalizePipeline(1:obj.lvlOneCount)=obj.normalizePipelineCast;
                    obj.validPipeline(obj.lvlOneCount)=true;
                elseif(obj.lvlThreeCount>1)&&(obj.lvlOneCount==10)
                    obj.normalizePipeline(1:5)=obj.normalizePipelineCast;
                    obj.validPipeline(5)=true;
                elseif(obj.lvlTwoCount>0)&&(obj.lvlOneCount<5)&&(obj.lvlOneCount>0)
                    obj.normalizePipeline(1:obj.lvlOneCount+5)=obj.normalizePipelineCast;
                    obj.validPipeline(obj.lvlOneCount+5)=true;
                else
                    obj.normalizePipeline(1:10)=obj.normalizePipelineCast;
                    obj.validPipeline(10)=true;
                end
            end






            if obj.lvlOneCountVar>0
                obj.lvlOneNormVar(:)=((obj.lvlOneAccVar)*obj.recipLUT(obj.lvlOneCountVar));
                obj.lvlOneNormVarCast(:)=obj.lvlOneNormVar;
                obj.lvlTwoAccVar(:)=obj.lvlTwoAccVar+obj.lvlOneNormVarCast;
                obj.lvlTwoCountVar(:)=obj.lvlTwoCountVar+1;
            end

            if obj.lvlTwoCountVar>0
                obj.lvlTwoNormVar(:)=((obj.lvlTwoAccVar)*obj.recipLUT(obj.lvlTwoCountVar));
                obj.lvlTwoNormVarCast(:)=obj.lvlTwoNormVar;
                obj.lvlThreeAccVar(:)=obj.lvlThreeAccVar+obj.lvlTwoNormVarCast;
                obj.lvlThreeCountVar(:)=obj.lvlThreeCountVar+1;
            end

            if obj.lvlThreeCountVar>0
                obj.lvlThreeNormVar(:)=((obj.lvlThreeAccVar)*obj.recipLUT(obj.lvlThreeCountVar));
                obj.lvlThreeNormVarCast(:)=obj.lvlThreeNormVar;
                obj.lvlFourAccVar(:)=obj.lvlFourAccVar+obj.lvlThreeNormVarCast;
                obj.lvlFourCountVar(:)=obj.lvlFourCountVar+1;
            end




            if obj.lvlFourCountVar~=64
                if obj.lvlFourCountVar==0
                    obj.lvlFourCountVar(:)=obj.lvlFourCountVar+1;
                end
                obj.meanSquared(:)=obj.normalizePipelineCast*obj.normalizePipelineCast;
                obj.finalVar(:)=obj.lvlFourAccVar*obj.recipLUT(obj.lvlFourCountVar);
                obj.normalizePipelineVarCast(:)=(obj.finalVar-obj.meanSquared);

                if obj.lvlThreeCountVar~=64
                    if obj.lvlThreeCountVar==0
                        obj.lvlThreeCount(:)=obj.lvlThreeCountVar+1;
                    end

                    if(obj.lvlThreeCountVar>1)&&(obj.lvlOneCountVar<10)&&(obj.lvlOneCountVar>0)
                        obj.normalizePipelineVar(1:obj.lvlOneCountVar)=obj.normalizePipelineVarCast;
                        obj.validPipeline(obj.lvlOneCountVar)=true;
                    elseif(obj.lvlThreeCountVar>1)&&(obj.lvlOneCountVar==10)
                        obj.normalizePipelineVar(1:5)=obj.normalizePipelineVarCast;
                        obj.validPipeline(5)=true;
                    elseif(obj.lvlTwoCountVar>0)&&(obj.lvlOneCountVar<5)&&(obj.lvlOneCountVar>0)
                        obj.normalizePipelineVar(1:obj.lvlOneCountVar+5)=obj.normalizePipelineVarCast;
                        obj.validPipeline(obj.lvlOneCountVar+5)=true;
                    else
                        obj.normalizePipelineVar(1:10)=obj.normalizePipelineVarCast;
                        obj.validPipeline(10)=true;
                    end
                end
            end



            obj.lvlOneAcc(:)=0;
            obj.lvlTwoAcc(:)=0;
            obj.lvlThreeAcc(:)=0;
            obj.lvlFourAcc(:)=0;
            obj.lvlOneCount(:)=0;
            obj.lvlTwoCount(:)=0;
            obj.lvlThreeCount(:)=0;
            obj.lvlFourCount(:)=0;


            obj.lvlOneAccVar(:)=0;
            obj.lvlTwoAccVar(:)=0;
            obj.lvlThreeAccVar(:)=0;
            obj.lvlFourAccVar(:)=0;
            obj.lvlOneCountVar(:)=0;
            obj.lvlTwoCountVar(:)=0;
            obj.lvlThreeCountVar(:)=0;
            obj.lvlFourCountVar(:)=0;



        end


        function normStdDev(obj)





            if obj.lvlOneCount>0
                obj.lvlOneNorm(:)=((obj.lvlOneAcc)*obj.recipLUT(obj.lvlOneCount));
                obj.lvlOneNormCast(:)=obj.lvlOneNorm;
                obj.lvlTwoAcc(:)=obj.lvlTwoAcc+obj.lvlOneNormCast;
                obj.lvlTwoCount(:)=obj.lvlTwoCount+1;
            end

            if obj.lvlTwoCount>0
                obj.lvlTwoNorm(:)=((obj.lvlTwoAcc)*obj.recipLUT(obj.lvlTwoCount));
                obj.lvlTwoNormCast(:)=obj.lvlTwoNorm;
                obj.lvlThreeAcc(:)=obj.lvlThreeAcc+obj.lvlTwoNormCast;
                obj.lvlThreeCount(:)=obj.lvlThreeCount+1;
            end

            if obj.lvlThreeCount>0
                obj.lvlThreeNorm(:)=((obj.lvlThreeAcc)*obj.recipLUT(obj.lvlThreeCount));
                obj.lvlThreeNormCast(:)=obj.lvlThreeNorm;
                obj.lvlFourAcc(:)=obj.lvlFourAcc+obj.lvlThreeNormCast;
                obj.lvlFourCount(:)=obj.lvlFourCount+1;
            end



            if obj.lvlFourCount~=64
                if obj.lvlFourCount==0
                    obj.lvlFourCount(:)=obj.lvlFourCount+1;
                end
                obj.normalizePipelineCast(:)=obj.lvlFourAcc*obj.recipLUT(obj.lvlFourCount);

                if(obj.lvlThreeCount>1)&&(obj.lvlOneCount<10)&&(obj.lvlOneCount>0)
                    obj.normalizePipeline(1:obj.lvlOneCount)=obj.normalizePipelineCast;
                    obj.validPipeline(obj.lvlOneCount)=true;
                elseif(obj.lvlThreeCount>1)&&(obj.lvlOneCount==10)
                    obj.normalizePipeline(1:5)=obj.normalizePipelineCast;
                    obj.validPipeline(5)=true;
                elseif(obj.lvlTwoCount>0)&&(obj.lvlOneCount<5)&&(obj.lvlOneCount>0)
                    obj.normalizePipeline(1:obj.lvlOneCount+5)=obj.normalizePipelineCast;
                    obj.validPipeline(obj.lvlOneCount+5)=true;
                else
                    obj.normalizePipeline(1:10)=obj.normalizePipelineCast;
                    obj.validPipeline(10)=true;
                end



            end






            if obj.lvlOneCountVar>0
                obj.lvlOneNormVar(:)=((obj.lvlOneAccVar)*obj.recipLUT(obj.lvlOneCountVar));
                obj.lvlOneNormVarCast(:)=obj.lvlOneNormVar;
                obj.lvlTwoAccVar(:)=obj.lvlTwoAccVar+obj.lvlOneNormVarCast;
                obj.lvlTwoCountVar(:)=obj.lvlTwoCountVar+1;
            end

            if obj.lvlTwoCountVar>0
                obj.lvlTwoNormVar(:)=((obj.lvlTwoAccVar)*obj.recipLUT(obj.lvlTwoCountVar));
                obj.lvlTwoNormVarCast(:)=obj.lvlTwoNormVar;
                obj.lvlThreeAccVar(:)=obj.lvlThreeAccVar+obj.lvlTwoNormVarCast;
                obj.lvlThreeCountVar(:)=obj.lvlThreeCountVar+1;
            end


            if obj.lvlThreeCountVar>0
                obj.lvlThreeNormVar(:)=((obj.lvlThreeAccVar)*obj.recipLUT(obj.lvlThreeCountVar));
                obj.lvlThreeNormVarCast(:)=obj.lvlThreeNormVar;
                obj.lvlFourAccVar(:)=obj.lvlFourAccVar+obj.lvlThreeNormVarCast;
                obj.lvlFourCountVar(:)=obj.lvlFourCountVar+1;
            end




            if obj.lvlFourCountVar~=64
                if obj.lvlFourCountVar==0
                    obj.lvlFourCountVar(:)=obj.lvlFourCountVar+1;
                end
                obj.meanSquared(:)=obj.normalizePipelineCast*obj.normalizePipelineCast;
                obj.finalVar(:)=obj.lvlFourAccVar*obj.recipLUT(obj.lvlFourCountVar);
                obj.normalizePipelineVarCast(:)=(obj.finalVar-obj.meanSquared);
                if(obj.lvlThreeCountVar>1)&&(obj.lvlOneCountVar<10)&&(obj.lvlOneCountVar>0)
                    obj.normalizePipelineVar(1:obj.lvlOneCountVar)=obj.normalizePipelineVarCast;
                    obj.validPipeline(obj.lvlOneCountVar)=true;
                elseif(obj.lvlThreeCountVar>1)&&(obj.lvlOneCountVar==10)
                    obj.normalizePipelineVar(1:5)=obj.normalizePipelineVarCast;
                    obj.validPipeline(5)=true;
                elseif(obj.lvlTwoCountVar>0)&&(obj.lvlOneCountVar<5)&&(obj.lvlOneCountVar>0)
                    obj.normalizePipelineVar(1:obj.lvlOneCountVar+5)=obj.normalizePipelineVarCast;
                    obj.validPipeline(obj.lvlOneCountVar+5)=true;
                else
                    obj.normalizePipelineVar(1:10)=obj.normalizePipelineVarCast;
                    obj.validPipeline(10)=true;
                end
            end

            obj.normalizePipelineStdDevCast(:)=sqrt((obj.normalizePipelineVarCast));

            if(obj.lvlThreeCount>1)&&(obj.lvlOneCount<10)&&(obj.lvlOneCount>0)
                obj.normalizePipelineStdDev(1:obj.lvlOneCount)=obj.normalizePipelineStdDevCast;
            elseif(obj.lvlThreeCount>1)&&(obj.lvlOneCount==10)
                obj.normalizePipelineStdDev(1:5)=obj.normalizePipelineStdDevCast;
            elseif(obj.lvlTwoCount>0)&&(obj.lvlOneCount<5)&&(obj.lvlOneCount>0)
                obj.normalizePipelineStdDev(1:obj.lvlOneCount+5)=obj.normalizePipelineStdDevCast;
            else
                obj.normalizePipelineStdDev(1:10)=obj.normalizePipelineStdDevCast;
            end


            obj.lvlOneAcc(:)=0;
            obj.lvlTwoAcc(:)=0;
            obj.lvlThreeAcc(:)=0;
            obj.lvlFourAcc(:)=0;
            obj.lvlOneCount(:)=0;
            obj.lvlTwoCount(:)=0;
            obj.lvlThreeCount(:)=0;
            obj.lvlFourCount(:)=0;
            obj.lvlOneAccVar(:)=0;
            obj.lvlTwoAccVar(:)=0;
            obj.lvlThreeAccVar(:)=0;
            obj.lvlFourAccVar(:)=0;
            obj.lvlOneCountVar(:)=0;
            obj.lvlTwoCountVar(:)=0;
            obj.lvlThreeCountVar(:)=0;
            obj.lvlFourCountVar(:)=0;


        end






        function setupFloat(obj,type)


            if strcmpi(type,'single')

                obj.lvlOneAcc=single(0);
                obj.lvlTwoAcc=single(0);
                obj.lvlThreeAcc=single(0);
                obj.lvlFourAcc=single(0);
                [obj.lvlOneCount,obj.lvlTwoCount,obj.lvlThreeCount,obj.lvlFourCount]=deal(uint8(0));
                obj.recipLUT=single(ones(1,64)./(1:64));
                obj.normalizePipeline=single(zeros(1,30));

                obj.absDataIn=single(0);
                obj.lvlOneNorm=single(0);
                obj.lvlTwoNorm=single(0);
                obj.lvlThreeNorm=single(0);
                obj.lvlOneNormCast=single(0);
                obj.lvlTwoNormCast=single(0);
                obj.lvlThreeNormCast=single(0);


                obj.lvlOneAccVar=single(0);
                obj.lvlTwoAccVar=single(0);
                obj.lvlThreeAccVar=single(0);
                obj.lvlFourAccVar=single(0);
                [obj.lvlOneCountVar,obj.lvlTwoCountVar,obj.lvlThreeCountVar,obj.lvlFourCountVar]=deal(uint8(0));
                obj.normalizePipelineVar=single(zeros(1,30));
                obj.normalizePipelineCast=single(0);
                obj.finalVar=single(0);
                obj.meanSquared=single(0);
                obj.normalizePipelineStdDev=single(zeros(1,30));
                obj.dataInSquare=single(0);
                obj.lvlOneNormVar=single(0);
                obj.lvlTwoNormVar=single(0);
                obj.lvlThreeNormVar=single(0);
                obj.lvlOneNormVarCast=single(0);
                obj.lvlTwoNormVarCast=single(0);
                obj.lvlThreeNormVarCast=single(0);
                obj.validPipeline=false(1,30);

                obj.normalizePipelineCast=single(0);
                obj.normalizePipelineVarCast=single(0);
                obj.normalizePipelineStdDevCast=single(0);

                obj.outputWriteCount=uint8(0);
                obj.outputWrite=false;


            elseif strcmpi(type,'double')


                obj.lvlOneAcc=double(0);
                obj.lvlTwoAcc=double(0);
                obj.lvlThreeAcc=double(0);
                obj.lvlFourAcc=double(0);
                [obj.lvlOneCount,obj.lvlTwoCount,obj.lvlThreeCount,obj.lvlFourCount]=deal(uint8(0));
                obj.recipLUT=double(ones(1,64)./(1:64));
                obj.normalizePipeline=double(zeros(1,30));

                obj.absDataIn=double(0);
                obj.lvlOneNorm=double(0);
                obj.lvlTwoNorm=double(0);
                obj.lvlThreeNorm=double(0);
                obj.lvlOneNormCast=double(0);
                obj.lvlTwoNormCast=double(0);
                obj.lvlThreeNormCast=double(0);


                obj.lvlOneAccVar=double(0);
                obj.lvlTwoAccVar=double(0);
                obj.lvlThreeAccVar=double(0);
                obj.lvlFourAccVar=double(0);
                [obj.lvlOneCountVar,obj.lvlTwoCountVar,obj.lvlThreeCountVar,obj.lvlFourCountVar]=deal(uint8(0));
                obj.normalizePipelineVar=double(zeros(1,30));
                obj.normalizePipelineCast=double(0);
                obj.finalVar=double(0);
                obj.meanSquared=double(0);
                obj.normalizePipelineStdDev=double(zeros(1,30));
                obj.dataInSquare=double(0);
                obj.lvlOneNormVar=double(0);
                obj.lvlTwoNormVar=double(0);
                obj.lvlThreeNormVar=double(0);
                obj.lvlOneNormVarCast=double(0);
                obj.lvlTwoNormVarCast=double(0);
                obj.lvlThreeNormVarCast=double(0);
                obj.validPipeline=false(1,30);

                obj.normalizePipelineCast=double(0);
                obj.normalizePipelineVarCast=double(0);
                obj.normalizePipelineStdDevCast=double(0);

                obj.outputWriteCount=uint8(0);
                obj.outputWrite=false;

            end

        end

        function setupFixed(obj,WL,FL)




            lvlOneAccT=numerictype(0,(WL+6+FL),FL);
            lvlTwoAccT=numerictype(0,(WL+12+FL),FL+6);
            lvlThreeAccT=numerictype(0,(WL+18+FL),FL+12);
            lvlFourAccT=numerictype(0,(WL+24+FL),FL+18);
            normalizeT=numerictype(0,(WL+24+FL),(FL+24));
            outT=numerictype(0,(WL),FL);
            outTVar=numerictype(0,(WL*2),FL);


            obj.lvlOneAcc=fi(0,lvlOneAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.absDataIn=fi(0,lvlOneAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoAcc=fi(0,lvlTwoAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlOneNorm=fi(0,normalizeT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlOneNormCast=fi(0,lvlTwoAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeAcc=fi(0,lvlThreeAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoNorm=fi(0,normalizeT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoNormCast=fi(0,lvlThreeAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlFourAcc=fi(0,lvlFourAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeNorm=fi(0,normalizeT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeNormCast=fi(0,lvlThreeAccT,'RoundingMethod','Floor','OverflowAction','Wrap');




            obj.normalizePipelineCast=fi(0,outT,'RoundingMethod','Nearest','OverflowAction','Wrap');
            [obj.lvlOneCount,obj.lvlTwoCount,obj.lvlThreeCount,obj.lvlFourCount]=deal(uint8(0));
            if obj.stdDev
                obj.normalizePipeline=fi(zeros(1,35+WL+5),outT,'RoundingMethod','Nearest','OverflowAction','Wrap');
                obj.normalizePipelineVar=fi(zeros(1,35+WL+5),outTVar,'RoundingMethod','Nearest','OverflowAction','Wrap');
                obj.normalizePipelineStdDev=fi(zeros(1,35+WL+5),outT,'RoundingMethod','Nearest','OverflowAction','Wrap');
                obj.validPipeline=(false(1,35+WL+5));
            elseif obj.variance
                obj.normalizePipeline=(fi(zeros(1,35+4),outT,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.normalizePipelineVar=fi(zeros(1,35+4),outTVar,'RoundingMethod','Nearest','OverflowAction','Wrap');
                obj.normalizePipelineStdDev=fi(zeros(1,35+4),outT,'RoundingMethod','Nearest','OverflowAction','Wrap');
                obj.validPipeline=(false(1,35+4));
            else
                obj.normalizePipeline=fi(zeros(1,35),outT,'RoundingMethod','Nearest','OverflowAction','Wrap');
                obj.normalizePipelineVar=fi(zeros(1,35),outTVar,'RoundingMethod','Nearest','OverflowAction','Wrap');
                obj.normalizePipelineStdDev=fi(zeros(1,35),outT,'RoundingMethod','Nearest','OverflowAction','Wrap');
                obj.validPipeline=(false(1,35));
            end



            lvlOneAccVarT=numerictype(0,(((WL*2))+6+FL),FL);
            inT=numerictype(0,(((WL*2))),FL);
            lvlTwoAccVarT=numerictype(0,((WL*2)+12+FL),FL+6);
            lvlThreeAccVarT=numerictype(0,((WL*2)+18+FL),FL+12);
            lvlFourAccVarT=numerictype(0,((WL*2)+24+FL),FL+18);
            normalizeVarT=numerictype(0,((WL*2)+24+FL),(FL+24));


            obj.lvlOneAccVar=fi(0,lvlOneAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.dataInSquare=fi(0,inT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoAccVar=fi(0,lvlTwoAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlOneNormVar=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlOneNormVarCast=fi(0,lvlTwoAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeAccVar=fi(0,lvlThreeAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoNormVar=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoNormVarCast=fi(0,lvlThreeAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlFourAccVar=fi(0,lvlFourAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeNormVar=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeNormVarCast=fi(0,lvlFourAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');



            obj.normalizePipelineVarCast=fi(0,outTVar,'RoundingMethod','Nearest','OverflowAction','Wrap');
            obj.finalVar=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.meanSquared=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');

            [obj.lvlOneCountVar,obj.lvlTwoCountVar,obj.lvlThreeCountVar,obj.lvlFourCountVar]=deal(uint8(0));



            LUT=ones(1,64)./(1:64);
            oType=fi(0,1,18,17);
            Fsat=fimath('RoundMode','Nearest',...
            'OverflowMode','Saturate',...
            'SumMode','KeepLSB',...
            'SumWordLength',18,...
            'SumFractionLength',17,...
            'CastBeforeSum',true);

            LUTD=fi(LUT,oType.numerictype,Fsat);

            obj.recipLUT=fi(zeros(1,64),0,18,17,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.recipLUT(:)=LUTD;

            obj.normalizePipelineStdDevCast=fi(0,outT,'RoundingMethod','Nearest','OverflowAction','Wrap');

            obj.outputWriteCount=uint8(0);
            obj.outputWrite=false;

        end

        function setupInteger(obj,WL,FL)



            lvlOneAccT=numerictype(0,(WL+6+FL),FL);
            lvlTwoAccT=numerictype(0,(WL+12+FL),FL+6);
            lvlThreeAccT=numerictype(0,(WL+18+FL),FL+12);
            lvlFourAccT=numerictype(0,(WL+24+FL),FL+18);
            normalizeT=numerictype(0,(WL+24+FL),(FL+24));
            outT=numerictype(0,(WL),FL);
            outTVar=numerictype(0,(WL*2),FL);


            obj.lvlOneAcc=fi(0,lvlOneAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.absDataIn=fi(0,lvlOneAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoAcc=fi(0,lvlTwoAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlOneNorm=fi(0,normalizeT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlOneNormCast=fi(0,lvlTwoAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeAcc=fi(0,lvlThreeAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoNorm=fi(0,normalizeT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoNormCast=fi(0,lvlThreeAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlFourAcc=fi(0,lvlFourAccT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeNorm=fi(0,normalizeT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeNormCast=fi(0,lvlFourAccT,'RoundingMethod','Floor','OverflowAction','Wrap');






            if obj.stdDev
                obj.normalizePipeline=storedInteger(fi(zeros(1,35+WL+5),outT,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.normalizePipelineVar=storedInteger(fi(zeros(1,35+WL+5),outTVar,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.normalizePipelineStdDev=storedInteger(fi(zeros(1,35+WL+5),outT,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.validPipeline=(false(1,35+WL+5));
            elseif obj.variance
                obj.normalizePipeline=storedInteger(fi(zeros(1,35+4),outT,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.normalizePipelineVar=storedInteger(fi(zeros(1,35+4),outTVar,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.normalizePipelineStdDev=storedInteger(fi(zeros(1,35+4),outT,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.validPipeline=(false(1,35+4));
            else
                obj.normalizePipeline=storedInteger(fi(zeros(1,35),outT,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.normalizePipelineVar=storedInteger(fi(zeros(1,35),outTVar,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.normalizePipelineStdDev=storedInteger(fi(zeros(1,35),outT,'RoundingMethod','Nearest','OverflowAction','Wrap'));
                obj.validPipeline=(false(1,35));
            end

            obj.normalizePipelineCast=fi(0,outT,'RoundingMethod','Nearest','OverflowAction','Wrap');
            [obj.lvlOneCount,obj.lvlTwoCount,obj.lvlThreeCount,obj.lvlFourCount]=deal(uint8(0));



            lvlOneAccVarT=numerictype(0,(((WL*2))+6+FL),FL);
            inT=numerictype(0,(((WL*2))),FL);
            lvlTwoAccVarT=numerictype(0,((WL*2)+12+FL),FL+6);
            lvlThreeAccVarT=numerictype(0,((WL*2)+18+FL),FL+12);
            lvlFourAccVarT=numerictype(0,((WL*2)+24+FL),FL+18);
            normalizeVarT=numerictype(0,((WL*2)+24+FL),(FL+24));



            obj.lvlOneAccVar=fi(0,lvlOneAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.dataInSquare=fi(0,inT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoAccVar=fi(0,lvlTwoAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlOneNormVar=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlOneNormVarCast=fi(0,lvlTwoAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeAccVar=fi(0,lvlThreeAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoNormVar=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlTwoNormVarCast=fi(0,lvlThreeAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlFourAccVar=fi(0,lvlFourAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeNormVar=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.lvlThreeNormVarCast=fi(0,lvlFourAccVarT,'RoundingMethod','Floor','OverflowAction','Wrap');






            obj.normalizePipelineVarCast=fi(0,outTVar,'RoundingMethod','Nearest','OverflowAction','Wrap');

            obj.finalVar=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.meanSquared=fi(0,normalizeVarT,'RoundingMethod','Floor','OverflowAction','Wrap');

            [obj.lvlOneCountVar,obj.lvlTwoCountVar,obj.lvlThreeCountVar,obj.lvlFourCountVar]=deal(uint8(0));



            LUT=ones(1,64)./(1:64);
            oType=fi(0,0,18,17);
            Fsat=fimath('RoundMode','Nearest',...
            'OverflowMode','Saturate',...
            'SumMode','KeepLSB',...
            'SumWordLength',18,...
            'SumFractionLength',17,...
            'CastBeforeSum',true);

            LUTD=fi(LUT,oType.numerictype,Fsat);

            obj.recipLUT=fi(zeros(1,64),0,18,17,'RoundingMethod','Floor','OverflowAction','Wrap');
            obj.recipLUT(:)=LUTD;




            obj.normalizePipelineStdDevCast=fi(0,outT,'RoundingMethod','Nearest','OverflowAction','Wrap');

            obj.outputWriteCount=uint8(0);
            obj.outputWrite=false;

        end

    end

    methods(Static,Access=protected)
        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end
    end

    methods(Access=protected)
        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end
    end

end
