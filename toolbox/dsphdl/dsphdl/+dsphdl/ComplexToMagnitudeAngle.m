classdef(StrictDefaults)ComplexToMagnitudeAngle<matlab.System

















































































































%#codegen

    properties(Nontunable)





        OutputFormat='Magnitude and angle';
    end

    properties(Nontunable)




        AngleFormat='Normalized';
    end

    properties(Nontunable)





        NumIterationsSource='Auto';
    end

    properties(Nontunable)




        NumIterations=10;





        ScaleOutput(1,1)logical=true;
    end

    properties(Nontunable)



        ScalingMethod='Shift-Add';
    end

    properties(Access=private)
        xPipeline;
        yPipeline;
        zPipeline;
        validPipeline;
    end

    properties(Hidden,Transient)
        OutputFormatSet=matlab.system.StringSet({...
        'Magnitude',...
        'Angle',...
        'Magnitude and angle',...
        });

        AngleFormatSet=matlab.system.StringSet({...
        'Normalized',...
'Radians'...
        });

        NumIterationsSourceSet=matlab.system.StringSet({...
        'Auto',...
'Property'...
        });

        ScalingMethodSet=matlab.system.StringSet({...
        'Shift-Add',...
        'Multiplier',...
        });
    end

    properties(Nontunable,Access=private)
        pMagDataT;
pAngDataT
        pThetaValues;
        pPival;
        pPivalN;
        pPidivtwo;
        pNIterations=10;
        pMaxNIters=10;
        pInvCORDICPGain;
        pValidPipelineDelay;
        pPipelineDelay;
    end

    properties(Access=private)
        pSetNIterations=false;
        pIconNIterations;
        pPostScale;
        pQuadrantIn;
        pXYReversed;
        pQuadrantOut;
        pPipeout;
        pXAbsolute;
        pYAbsolute;
        realInReg;
        imagInReg;
    end

    methods
        function obj=ComplexToMagnitudeAngle(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end

        function set.NumIterations(obj,val)
            validateattributes(val,{'numeric'},...
            {'integer','scalar','>',0},'ComplexToMagnitudeAngle','NumIterations');
            obj.NumIterations=val;
        end


        function set.ScaleOutput(obj,val)
            validateattributes(val,{'logical'},{},...
            'ComplexToMagnitudeAngle','ScaleOutput');
            obj.ScaleOutput=val;
        end
    end

    methods(Static,Access=protected)

        function header=getHeaderImpl


            header=matlab.system.display.Header('dsphdl.ComplexToMagnitudeAngle',...
            'ShowSourceLink',false,...
            'Title','Complex to Magnitude-Angle');
        end

        function groups=getPropertyGroupsImpl


            blockp=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'NumIterationsSource','NumIterations',...
            'OutputFormat','AngleFormat','ScaleOutput','ScalingMethod'});
            groups=blockp;
        end
    end

    methods(Access=protected)



        function validateInputsImpl(obj,varargin)


            if isempty(coder.target)||~eml_ambiguous_types
                validateattributes(varargin{1},{'single','double','embedded.fi','uint8','int8','uint16','int16','uint32','int32','uint64','int64'},{'vector'},'ComplexToMagnitudeAngle','data');
                validateattributes(varargin{2},{'logical'},{'scalar'},'ComplexToMagnitudeAngle','valid');

                input=varargin{1};
                vecLen=max(size(input));
                maxVecSize=64;
                if vecLen>maxVecSize||vecLen<1
                    coder.internal.error('dsphdl:ComplexToMagnitudeAngle:InvalidInputSize',maxVecSize);
                end



                if isa(input,'double')||isa(input,'single')
                    if strcmpi(obj.NumIterationsSource,'Property')
                        obj.pSetNIterations=false;
                    else
                        obj.pIconNIterations=16;
                        obj.pSetNIterations=true;
                    end
                elseif isinteger(input)||isfixed(input)
                    if strcmpi(obj.NumIterationsSource,'Property')
                        obj.pSetNIterations=false;
                    else
                        obj.pSetNIterations=true;
                        if isa(input,'embedded.fi')
                            MaxNIters=get(input,'WordLength')-1;
                        elseif isinteger(input)
                            n=numerictype(class(input));
                            MaxNIters=n.WordLength-1;
                        else
                            MaxNIters=10;
                            obj.pSetNIterations=false;
                        end

                        obj.pIconNIterations=MaxNIters;
                    end
                end
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end

        function setupImpl(obj,varargin)


            sizeIn=size(varargin{1});
            maxSizeIn=max(sizeIn);
            if isa(varargin{1},'double')
                obj.setupfloat('double',sizeIn);
                obj.realInReg=zeros(maxSizeIn,3);
                obj.imagInReg=zeros(maxSizeIn,3);
            elseif isa(varargin{1},'single')
                obj.setupfloat('single',sizeIn);
                obj.realInReg=single(zeros(maxSizeIn,3));
                obj.imagInReg=single(zeros(maxSizeIn,3));
            elseif isinteger(varargin{1})
                if isempty(coder.target)||~eml_ambiguous_types
                    obj.setupfixed(varargin{1},sizeIn);
                    [inputWL,~,inputS]=dsphdlshared.hdlgetwordsizefromdata(varargin{1});
                    obj.realInReg=fi(zeros(maxSizeIn,3),inputS,inputWL,0);
                    obj.imagInReg=fi(zeros(maxSizeIn,3),inputS,inputWL,0);
                end
            elseif isfixed(varargin{1})
                if isempty(coder.target)||~eml_ambiguous_types
                    obj.setupfixed(varargin{1},sizeIn);
                    obj.realInReg=fi(zeros(maxSizeIn,3),varargin{1}.numerictype);
                    obj.imagInReg=fi(zeros(maxSizeIn,3),varargin{1}.numerictype);
                end
            end

        end

        function icon=getIconImpl(obj)

            if strcmpi(obj.NumIterationsSource,'Property')
                icon=sprintf(['Complex to Magnitude-Angle\nLatency:',num2str(getLatency(obj))]);
            else
                if~obj.pSetNIterations
                    icon=sprintf('Complex to Magnitude-Angle');
                else
                    icon=sprintf(['Complex to Magnitude-Angle\nLatency:',num2str(getLatency(obj))]);
                end
            end
        end



        function resetImpl(obj)
            obj.xPipeline(:)=0;
            obj.yPipeline(:)=0;
            obj.zPipeline(:)=0;
            obj.validPipeline(:)=0;
            obj.pPostScale(:)=0;
            obj.pQuadrantIn(:)=0;
            obj.pXYReversed(:)=0;
            obj.pQuadrantOut(:)=0;
            obj.pPipeout(:)=0;
            obj.pXAbsolute(:)=0;
            obj.pYAbsolute(:)=0;
            obj.realInReg(:)=0;
            obj.imagInReg(:)=0;
        end




        function[varargout]=outputImpl(obj,varargin)




            switch obj.getNumOutputs

            case 2
                switch obj.OutputFormat
                case 'Magnitude'
                    varargout{1}=obj.pPostScale;

                case 'Angle'
                    varargout{1}=obj.pQuadrantOut;
                end

                varargout{2}=obj.validPipeline(obj.pValidPipelineDelay);

            case 3
                varargout{1}=obj.pPostScale;
                varargout{2}=obj.pQuadrantOut;
                varargout{3}=obj.validPipeline(obj.pValidPipelineDelay);

            end
        end

        function dataTypes=determineMagTypes(obj,dataInDT)




            if isa(dataInDT,'single')||isa(dataInDT,'double')


                xDT=dataInDT;
                aDT=dataInDT;
            elseif(isa(dataInDT,'embedded.fi')&&isfixed(dataInDT))



                [inputWL,inputFL,inputS]=dsphdlshared.hdlgetwordsizefromdata(dataInDT);

                if inputS
                    xDT=fi(dataInDT,1,inputWL+1,inputFL);
                else
                    xDT=fi(dataInDT,1,inputWL+2,inputFL);
                end

                if strcmpi(obj.AngleFormat,'Radians')
                    aDT=fi(dataInDT,1,inputWL+3,inputWL);
                else
                    aDT=fi(dataInDT,1,inputWL+3,inputWL+2);
                end
            elseif isinteger(dataInDT)
                [inputWL,~,inputS]=dsphdlshared.hdlgetwordsizefromdata(dataInDT);
                if inputS
                    xDT=fi(dataInDT,1,inputWL+1,0);
                else
                    xDT=fi(dataInDT,1,inputWL+2,0);
                end
                if strcmpi(obj.AngleFormat,'Radians')
                    aDT=fi(dataInDT,1,inputWL+3,inputWL);
                else
                    aDT=fi(dataInDT,1,inputWL+3,inputWL+2);
                end
            else

                xDT=dataInDT;
                aDT=dataInDT;
            end
            dataTypes=struct('MagType',xDT,'AngType',aDT);

        end

        function updateImpl(obj,varargin)


            maxSizeIn=max(size(varargin{1}));

            obj.validPipeline(1)=varargin{2};



            obj.pQuadrantIn(:,2:obj.pPipelineDelay)=...
            obj.pQuadrantIn(:,1:((obj.pPipelineDelay)-1));

            obj.pXYReversed(:,2:obj.pPipelineDelay)=...
            obj.pXYReversed(:,1:((obj.pPipelineDelay)-1));

            obj.validPipeline(2:(obj.pValidPipelineDelay))=...
            obj.validPipeline(1:((obj.pValidPipelineDelay)-1));

            obj.xPipeline(:,2:(obj.pPipelineDelay))=...
            obj.xPipeline(:,1:((obj.pPipelineDelay)-1));

            obj.yPipeline(:,2:(obj.pPipelineDelay))=...
            obj.yPipeline(:,1:((obj.pPipelineDelay)-1));

            obj.zPipeline(:,2:(obj.pPipelineDelay))=...
            obj.zPipeline(:,1:((obj.pPipelineDelay)-1));



            obj.realInReg(:,1:end-1)=obj.realInReg(:,2:end);
            obj.imagInReg(:,1:end-1)=obj.imagInReg(:,2:end);
            obj.realInReg(:,end)=real(varargin{1});
            obj.imagInReg(:,end)=imag(varargin{1});

            QuadrantMapper(obj,obj.realInReg(:,1),obj.imagInReg(:,1));



            for ii=2:1:(obj.pNIterations+1)

                rt_shift=ii-1;
                CORDIC_Kernel(obj,rt_shift,ii);
            end



            QuadrantCorrection(obj);


            if isfi(obj.xPipeline)

                if obj.ScaleOutput==true
                    obj.pPostScale(:)=...
                    obj.xPipeline(:,obj.pPipelineDelay)*(fi(obj.pInvCORDICPGain,numerictype(obj.pInvCORDICPGain.Signed,obj.pInvCORDICPGain.WordLength,obj.pInvCORDICPGain.FractionLength),'RoundingMethod','Floor'));
                else
                    obj.pPostScale(:)=obj.xPipeline(:,obj.pPipelineDelay);
                end
            else
                if obj.ScaleOutput==true
                    obj.pPostScale(:)=...
                    (obj.xPipeline(:,obj.pPipelineDelay))*obj.pInvCORDICPGain;
                else
                    obj.pPostScale(:)=obj.xPipeline(:,obj.pPipelineDelay);
                end
            end




            if obj.validPipeline(obj.pValidPipelineDelay)==0

                if isfi(obj.pPostScale)
                    obj.pPostScale(:)=fi(0,numerictype(obj.pPostScale));
                    obj.zPipeline(:,obj.pPipelineDelay)=fi(0,numerictype(obj.zPipeline));
                else
                    obj.pPostScale(:)=cast(0,class(obj.pPostScale));
                    obj.zPipeline(:,obj.pPipelineDelay)=cast(0,class(obj.zPipeline));
                end
                if(isa(varargin{1},'double'))||isa(varargin{1},'single')
                    obj.pQuadrantOut(:)=repmat(cast(0,class(varargin{1})),maxSizeIn,1);
                else


                    if strcmpi(obj.AngleFormat,'Radians')
                        obj.pQuadrantOut(:)=repmat(fi(0,1,(obj.pAngDataT)+3,(obj.pAngDataT),...
                        'RoundingMethod','Floor','OverflowAction','Wrap'),maxSizeIn,1);
                    else
                        obj.pQuadrantOut(:)=repmat(fi(0,1,(obj.pAngDataT)+3,(obj.pAngDataT)+2,...
                        'RoundingMethod','Floor','OverflowAction','Wrap'),maxSizeIn,1);
                    end
                end
            end


        end

        function N=getNumInputsImpl(~)

            N=2;
        end

        function N=getNumOutputsImpl(obj)

            N=2;

            if strcmp(obj.OutputFormat,'Magnitude and angle')
                N=3;
            end

        end

        function varargout=getInputNamesImpl(~)
            varargout=cell(1,2);
            varargout{1}='data';
            varargout{2}='valid';

        end


        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            outputPortInd=1;

            switch(obj.OutputFormat)
            case 'Magnitude'
                varargout{1}='Magnitude';
                outputPortInd=outputPortInd+1;

            case 'Angle'
                varargout{1}='Angle';
                outputPortInd=outputPortInd+1;

            case 'Magnitude and angle'
                varargout{1}='Magnitude';
                varargout{2}='Angle';
                outputPortInd=outputPortInd+2;

            end
            varargout{outputPortInd}='valid';
        end

        function varargout=getOutputSizeImpl(obj)

            varargout=cell(1,nargout);
            for k=1:nargout-1
                varargout{k}=propagatedInputSize(obj,1);


            end
            varargout{end}=1;
        end

        function varargout=getOutputDataTypeImpl(obj)

            dt1=propagatedInputDataType(obj,1);
            if(~isempty(dt1))
                if ischar(dt1)
                    inputDT=eval([dt1,'(0)']);
                else
                    inputDT=fi(0,dt1);
                end

                dataTypes=determineMagTypes(obj,inputDT);

                switch obj.getNumOutputs
                case 2
                    switch obj.OutputFormat
                    case 'Magnitude'
                        if isfi(dataTypes.MagType)
                            varargout{1}=dataTypes.MagType.numerictype;
                        else
                            varargout{1}=class(dataTypes.MagType);
                        end
                    case 'Angle'
                        if isfi(dataTypes.AngType)
                            varargout{1}=dataTypes.AngType.numerictype;
                        else
                            varargout{1}=class(dataTypes.AngType);
                        end
                    end
                    varargout{2}='logical';
                case 3
                    if isfi(dataTypes.MagType)
                        varargout{1}=dataTypes.MagType.numerictype;
                        varargout{2}=dataTypes.AngType.numerictype;
                        varargout{3}='logical';
                    else
                        varargout{1}=class(dataTypes.MagType);
                        varargout{2}=class(dataTypes.AngType);
                        varargout{3}='logical';
                    end

                end
            else
                switch obj.getNumOutputs
                case 2
                    varargout{1}=[];
                    varargout{2}=[];
                case 3
                    varargout{1}=[];
                    varargout{2}=[];
                    varargout{3}=[];
                end
            end

        end

        function varargout=isOutputComplexImpl(~)

            varargout=cell(1,nargout);
            for k=1:nargout
                varargout{k}=false;



            end
        end

        function varargout=isOutputFixedSizeImpl(~)

            varargout=cell(1,nargout);
            for k=1:nargout
                varargout{k}=true;



            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.pMaxNIters=obj.pMaxNIters;
                s.pNIterations=obj.pNIterations;
                s.pValidPipelineDelay=obj.pValidPipelineDelay;
                s.pPipelineDelay=obj.pPipelineDelay;
                s.pPival=obj.pPival;
                s.pPivalN=obj.pPivalN;
                s.pPidivtwo=obj.pPidivtwo;
                s.pInvCORDICPGain=obj.pInvCORDICPGain;
                s.pAngDataT=obj.pAngDataT;
                s.pMagDataT=obj.pMagDataT;
                s.pNIterations=obj.pNIterations;
                s.pPostScale=obj.pPostScale;
                s.pThetaValues=obj.pThetaValues;
                s.pPostScale=obj.pPostScale;
                s.pQuadrantIn=obj.pQuadrantIn;
                s.pXYReversed=obj.pXYReversed;
                s.pQuadrantOut=obj.pQuadrantOut;
                s.pPipeout=obj.pPipeout;
                s.pXAbsolute=obj.pXAbsolute;
                s.pYAbsolute=obj.pYAbsolute;
                s.xPipeline=obj.xPipeline;
                s.yPipeline=obj.yPipeline;
                s.zPipeline=obj.zPipeline;
                s.validPipeline=obj.validPipeline;
                s.realInReg=obj.realInReg;
                s.imagInReg=obj.imagInReg;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end





        function hide=isInactivePropertyImpl(obj,prop)
            hide=false;
            switch prop
            case 'NumIterations'
                if strcmpi(obj.NumIterationsSource,'Auto')
                    hide=true;
                end
            case 'AngleFormat'
                if strcmpi(obj.OutputFormat,'Magnitude')
                    hide=true;
                end
            case 'ScalingMethod'
                if obj.ScaleOutput==false
                    hide=true;
                end
            end
        end


    end


    methods(Access=private)



        function QuadrantMapper(obj,x,y)


            obj.pXAbsolute(:)=x;
            obj.pXAbsolute(:)=abs(obj.pXAbsolute);
            obj.pYAbsolute(:)=y;
            obj.pYAbsolute(:)=abs(obj.pYAbsolute);

            maxSizeIn=max(size(x));
            for ii=1:maxSizeIn
                if(x(ii)<0)&&(y(ii)<0)
                    obj.pQuadrantIn(ii,1)=2;

                elseif(x(ii)>=0)&&(y(ii)<0)
                    obj.pQuadrantIn(ii,1)=1;

                elseif(x(ii)<0)&&(y(ii)>=0)
                    obj.pQuadrantIn(ii,1)=3;

                elseif(x(ii)>=0)&&(y(ii)>=0)
                    obj.pQuadrantIn(ii,1)=0;

                else
                    obj.pQuadrantIn(ii,1)=0;

                end

                if(obj.pXAbsolute(ii)>obj.pYAbsolute(ii))
                    obj.pXYReversed(ii,1)=0;
                    obj.xPipeline(ii,1)=obj.pXAbsolute(ii);
                    obj.yPipeline(ii,1)=obj.pYAbsolute(ii);

                else
                    obj.pXYReversed(ii,1)=1;
                    obj.xPipeline(ii,1)=obj.pYAbsolute(ii);
                    obj.yPipeline(ii,1)=obj.pXAbsolute(ii);

                end
                obj.zPipeline(ii,1)=0;

            end
        end



        function CORDIC_Kernel(obj,rt_shift,idx)

            sizeIn=size(obj.xPipeline,1);
            if(isa(obj.xPipeline(1,idx),'double'))||(isa(obj.xPipeline(1,idx),'single'))
                x1=zeros(sizeIn,1,'like',obj.xPipeline);
                y1=zeros(sizeIn,1,'like',obj.xPipeline);
                for ii=1:sizeIn
                    y1(ii)=obj.yPipeline(ii,idx)*(2^-rt_shift);
                    x1(ii)=obj.xPipeline(ii,idx)*(2^-rt_shift);
                end

            elseif isfixed(obj.xPipeline(1,idx))
                x1=repmat(bitsra(obj.yPipeline(1,idx),rt_shift),sizeIn,1);
                y1=repmat(bitsra(obj.xPipeline(1,idx),rt_shift),sizeIn,1);
                for ii=1:sizeIn
                    y1(ii)=bitsra(obj.yPipeline(ii,idx),rt_shift);
                    x1(ii)=bitsra(obj.xPipeline(ii,idx),rt_shift);
                end
            end

            for ii=1:sizeIn
                if(obj.yPipeline(ii,idx)<0)
                    obj.xPipeline(ii,idx)=(obj.xPipeline(ii,idx))-y1(ii);
                    obj.yPipeline(ii,idx)=(obj.yPipeline(ii,idx))+x1(ii);
                    obj.zPipeline(ii,idx)=(obj.zPipeline(ii,idx)-obj.pThetaValues(idx-1));

                else
                    obj.xPipeline(ii,idx)=(obj.xPipeline(ii,idx))+y1(ii);
                    obj.yPipeline(ii,idx)=(obj.yPipeline(ii,idx))-x1(ii);
                    obj.zPipeline(ii,idx)=(obj.zPipeline(ii,idx)+obj.pThetaValues(idx-1));



                end
            end
        end



        function QuadrantCorrection(obj)

            obj.pPipeout(:)=obj.zPipeline(:,obj.pPipelineDelay);

            sizeIn=size(obj.zPipeline,1);
            for ii=1:sizeIn
                if obj.pXYReversed(ii,obj.pPipelineDelay)==1
                    obj.pQuadrantOut(ii)=obj.pPidivtwo-obj.pPipeout(ii);
                else
                    obj.pQuadrantOut(ii)=obj.pPipeout(ii);
                end

                if obj.pQuadrantIn(ii,obj.pPipelineDelay)==1
                    obj.pQuadrantOut(ii)=-(obj.pQuadrantOut(ii));

                elseif obj.pQuadrantIn(ii,obj.pPipelineDelay)==2
                    obj.pQuadrantOut(ii)=obj.pPivalN+(obj.pQuadrantOut(ii));

                elseif obj.pQuadrantIn(ii,obj.pPipelineDelay)==3
                    obj.pQuadrantOut(ii)=(obj.pPival-(obj.pQuadrantOut(ii)));

                end
            end
        end










        function setupfloat(obj,type,sizeIn)

            maxSizeIn=max(sizeIn);
            if strcmpi(obj.NumIterationsSource,'Property')
                obj.pNIterations=obj.NumIterations;

            else
                obj.pNIterations=16;
            end

            [obj.pValidPipelineDelay,...
            obj.pPipelineDelay]...
            =getPipelineDelay(obj);

            [obj.xPipeline,...
            obj.yPipeline,...
            obj.zPipeline,...
            obj.pQuadrantIn,...
            obj.pXYReversed]...
            =deal(zeros(maxSizeIn,(obj.pPipelineDelay),type));

            obj.pPostScale=repmat(cast(0,type),sizeIn);

            obj.validPipeline=false(obj.pValidPipelineDelay);



            if strcmpi(obj.AngleFormat,'Radians')
                obj.pPival=pi;
                obj.pPivalN=-pi;
                obj.pPidivtwo=pi/2;
            else
                obj.pPival=1;
                obj.pPivalN=-1;
                obj.pPidivtwo=0.5;
            end

            obj.pPipeout=zeros(maxSizeIn,1,type);
            obj.pQuadrantOut=zeros(sizeIn,type);
            obj.pXAbsolute=zeros(maxSizeIn,1,type);
            obj.pYAbsolute=zeros(maxSizeIn,1,type);

            coder.extrinsic('ComputeTheta');
            coder.extrinsic('ComputeGain');


            if isempty(coder.target)
                [obj.pThetaValues]=dsphdl.ComplexToMagnitudeAngle.ComputeTheta(obj.pNIterations,obj.AngleFormat,'Float',type);
                [obj.pInvCORDICPGain]=dsphdl.ComplexToMagnitudeAngle.ComputeGain(obj.pNIterations,'Float',type);
            else
                [obj.pThetaValues]=coder.internal.const(...
                dsphdl.ComplexToMagnitudeAngle.ComputeTheta(obj.pNIterations,obj.AngleFormat,'Float',type));
                [obj.pInvCORDICPGain]=coder.internal.const(...
                dsphdl.ComplexToMagnitudeAngle.ComputeGain(obj.pNIterations,'Float',type));
            end


        end




        function setupfixed(obj,input,sizeIn)

            maxSizeIn=max(sizeIn);
            if isa(input,'embedded.fi')
                obj.pMaxNIters=((input.WordLength)-1);
                if strcmpi(input.Signedness,'Signed')
                    obj.pMagDataT=struct('WordLength',((input.WordLength)+1),...
                    'FractionLength',((input.FractionLength)));
                else
                    obj.pMagDataT=struct('WordLength',((input.WordLength)+2),...
                    'FractionLength',((input.FractionLength)));

                end

                obj.pAngDataT=(input.WordLength);
            else
                [inputWL,~,inputS]=dsphdlshared.hdlgetwordsizefromdata(input);
                if inputS
                    obj.pMaxNIters=inputWL-1;
                    obj.pMagDataT=struct('WordLength',inputWL+1,...
                    'FractionLength',0);
                    obj.pAngDataT=inputWL;
                else
                    obj.pMaxNIters=inputWL-1;
                    obj.pMagDataT=struct('WordLength',inputWL+2,...
                    'FractionLength',0);
                    obj.pAngDataT=inputWL;
                end
            end

            if strcmpi(obj.NumIterationsSource,'Property')
                if obj.NumIterations>(obj.pMaxNIters)

                    coder.internal.errorIf(obj.NumIterations>(obj.pMaxNIters),...
                    'dsphdl:ComplexToMagnitudeAngle:numIterationsGreaterThanWordlength');
                else
                    obj.pNIterations=obj.NumIterations;
                end
            else
                obj.pNIterations=obj.pMaxNIters;

            end

            [obj.pValidPipelineDelay,...
            obj.pPipelineDelay]...
            =getPipelineDelay(obj);

            [obj.xPipeline,...
            obj.yPipeline]...
            =deal(fi(zeros(maxSizeIn,obj.pPipelineDelay),1,obj.pMagDataT.WordLength,...
            obj.pMagDataT.FractionLength,'RoundingMethod','Floor','OverflowAction','Wrap','ProductMode','FullPrecision'));


            obj.pPostScale=repmat(fi(0,1,(obj.pMagDataT.WordLength),obj.pMagDataT.FractionLength,...
            'RoundingMethod','Floor','OverflowAction','Wrap','ProductMode','FullPrecision'),...
            sizeIn);

            [obj.pXAbsolute,...
            obj.pYAbsolute]=deal(repmat(fi(0,1,((obj.pMagDataT.WordLength)+1),obj.pMagDataT.FractionLength,'RoundingMethod','Floor',...
            'OverflowAction','Wrap'),maxSizeIn,1));


            if strcmpi(obj.AngleFormat,'Radians')
                obj.zPipeline=fi(zeros(maxSizeIn,obj.pPipelineDelay),1,obj.pAngDataT+1,...
                obj.pAngDataT,'RoundingMethod','Floor','OverflowAction','Wrap');

            else
                obj.zPipeline=fi(zeros(maxSizeIn,obj.pPipelineDelay),1,obj.pAngDataT+3,...
                obj.pAngDataT+2,'RoundingMethod','Floor','OverflowAction','Wrap');

            end

            if strcmpi(obj.AngleFormat,'Radians')
                obj.pQuadrantOut=repmat(fi(0,1,(obj.pAngDataT)+3,((obj.pAngDataT)),...
                'RoundingMethod','Floor','OverflowAction','Wrap'),sizeIn);
                obj.pPipeout=repmat(fi(0,1,(obj.pAngDataT)+3,((obj.pAngDataT)),...
                'RoundingMethod','Floor','OverflowAction','Wrap'),sizeIn);
                obj.pPival=fi(pi,1,(obj.pAngDataT)+3,((obj.pAngDataT)),...
                'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pPivalN=fi(-pi,1,(obj.pAngDataT)+3,((obj.pAngDataT)),...
                'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pPidivtwo=fi(pi/2,1,(obj.pAngDataT)+3,((obj.pAngDataT)),'RoundingMethod','Floor','OverflowAction','Wrap');
            else

                obj.pPival=fi((1-eps),1,(obj.pAngDataT)+3,((obj.pAngDataT))+2,...
                'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pPivalN=fi(-1,1,(obj.pAngDataT)+3,((obj.pAngDataT))+2,...
                'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pPidivtwo=fi(0.5,1,(obj.pAngDataT)+3,((obj.pAngDataT))+2,'RoundingMethod','Floor','OverflowAction','Wrap');
                obj.pQuadrantOut=repmat(fi(0,1,(obj.pAngDataT)+3,(obj.pAngDataT)+2,...
                'RoundingMethod','Floor','OverflowAction','Wrap'),sizeIn);
                obj.pPipeout=repmat(fi(0,1,(obj.pAngDataT)+3,obj.pAngDataT+2,...
                'RoundingMethod','Floor','OverflowAction','Wrap'),sizeIn);

            end

            coder.extrinsic('dsphdl.ComplexToMagnitudeAngle.ComputeTheta');
            coder.extrinsic('dsphdl.ComplexToMagnitudeAngle.ComputeGain');

            if isempty(coder.target)
                [obj.pThetaValues]=dsphdl.ComplexToMagnitudeAngle.ComputeTheta(obj.pNIterations,obj.AngleFormat,'Fixed',obj.pAngDataT);
                [obj.pInvCORDICPGain]=dsphdl.ComplexToMagnitudeAngle.ComputeGain(obj.pNIterations,'Fixed',obj.pMagDataT,strcmpi(obj.ScalingMethod,'Multiplier'));
            else

                [obj.pThetaValues]=coder.internal.const(...
                dsphdl.ComplexToMagnitudeAngle.ComputeTheta(obj.pNIterations,obj.AngleFormat,'Fixed',obj.pAngDataT));

                [obj.pInvCORDICPGain]=coder.internal.const(...
                dsphdl.ComplexToMagnitudeAngle.ComputeGain(obj.pNIterations,'Fixed',obj.pMagDataT,strcmpi(obj.ScalingMethod,'Multiplier')));

            end

            obj.pXYReversed...
            =fi(zeros(maxSizeIn,obj.pPipelineDelay),0,1,0);

            obj.validPipeline...
            =false(obj.pValidPipelineDelay,1);

            obj.pQuadrantIn=fi(zeros(maxSizeIn,obj.pPipelineDelay),0,2,0);
        end





    end





    methods(Access=public)
        function latency=getLatency(obj,varargin)



            if nargin==2
                NIterations=varargin{1};
            else
                if strcmpi(obj.NumIterationsSource,'Property')
                    NIterations=obj.NumIterations;
                else
                    if~obj.pSetNIterations
                        return;
                    else
                        NIterations=obj.pIconNIterations;
                    end
                end
            end

            if obj.ScaleOutput&&strcmpi(obj.ScalingMethod,'Multiplier')
                latency=NIterations+8;
            else
                latency=NIterations+4;
            end
        end
    end

    methods(Static,Hidden)
        function[Theta]=ComputeTheta(pNIterations,AngleFormat,OutputType,angType)


            if strcmpi(OutputType,'Float')

                Theta=(zeros((pNIterations),1,angType));
                NormalizeStep=pi/(2^(32));

                for ii=1:1:pNIterations
                    if strcmpi(AngleFormat,'Radians')
                        Theta(ii)=(atan(2^(-ii)));
                    else
                        numIncr=round(((atan(2^(-ii)))/(NormalizeStep)));
                        angNorm=numIncr*(1/(2^((32))));
                        Theta(ii)=angNorm;
                    end
                end
            else
                if strcmpi(AngleFormat,'Radians')
                    Theta=fi(zeros((pNIterations),1),0,angType,(angType));
                else
                    Theta=fi(zeros((pNIterations),1),0,(angType),(angType+2));
                    NormalizeStep=pi/(2^((angType)+2));
                end

                for ii=1:1:pNIterations
                    if strcmpi(AngleFormat,'Radians')
                        Theta(ii)=(atan(2^(-ii)));
                    else
                        numIncr=round(((atan(2^(-ii)))/(NormalizeStep)));
                        angNorm=numIncr*(1/(2^((angType)+2)));
                        Theta(ii)=fi(angNorm,...
                        0,angType,(angType+2),'RoundingMethod','Floor','OverflowAction','Wrap');
                    end
                end
            end
        end

        function[Gain]=ComputeGain(pNIterations,OutputType,magType,multType)


            xscaling=(zeros(1,pNIterations));
            for ii=1:1:pNIterations
                xscaling(ii)=cos(atan(2^-ii));

            end

            if strcmpi(OutputType,'Float')
                Gain=cast(prod(xscaling),magType);
            else
                if multType
                    Gain=fi((prod(xscaling)),1,18,17,...
                    'RoundingMethod','Floor','OverflowAction','Wrap');
                else
                    if magType.WordLength>15
                        Gain=fi((prod(xscaling)),0,15,15,...
                        'RoundingMethod','Round','OverflowAction','Wrap');
                    else
                        Gain=fi((prod(xscaling)),0,magType.WordLength,(magType.WordLength),...
                        'RoundingMethod','Floor','OverflowAction','Wrap');
                    end
                end
            end
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

        function[validDelay,xDelay]=getPipelineDelay(obj,varargin)
            if nargin>1
                NIterations=varargin{1};
            else
                NIterations=obj.pNIterations;
            end
            if obj.ScaleOutput&&strcmpi(obj.ScalingMethod,'Multiplier')
                validDelay=NIterations+9;
                xDelay=NIterations+6;
            else
                validDelay=NIterations+5;
                xDelay=NIterations+2;
            end
        end
    end

end

