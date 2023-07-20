classdef(StrictDefaults)NCO<matlab.System




































































































































%#codegen
%#ok<*EMCLS>

    properties(Nontunable)



        PhaseIncrementSource='Input port';




        PhaseIncrement=100;



        PhaseOffsetSource='Property';




        PhaseOffset=0;



        DitherSource='Property';




        NumDitherBits=4;



        SamplesPerFrame=1;




        PhaseQuantization(1,1)logical=true;







        NumQuantizerAccumulatorBits=12;



        LUTCompress(1,1)logical=false;



        Waveform='Sine';



        PhasePort(1,1)logical=false;



        ResetAction(1,1)logical=false;
    end
    properties(Nontunable,Hidden)



        ValidInputPort(1,1)logical=true;
    end
    properties(Constant,Nontunable)



        RoundingMethod='Floor';



        OverflowAction='Wrap';

    end
    properties(Constant,Nontunable)



        AccumulatorDataType='Binary point scaling';

        AccumulatorSigned='yes';

    end
    properties(Nontunable)

        AccumulatorWL=16;
    end
    properties(Constant,Nontunable)

        AccumulatorFL=0;
    end
    properties(Nontunable)



        OutputDataType='Binary point scaling';
    end
    properties(Constant,Nontunable)

        OutputSigned='yes';

    end
    properties(Nontunable)

        OutputWL=16;

        OutputFL=14;
    end


    properties(Constant,Hidden)
        PhaseIncrementSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        PhaseOffsetSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');

        DitherSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port',...
        'None'});
        WaveformSet=matlab.system.StringSet({...
        'Sine',...
        'Cosine',...
        'Complex exponential',...
        'Sine and cosine'});
        OutputDataTypeSet=matlab.system.StringSet({...
        'double',...
        'single',...
        'Binary point scaling'});

    end














    properties(Access=private)
        phaseInc;
        phaseIncReg;
        phaseIncV;
        phaseOff;
        phaseOffReg;
        tmpAcc;
        tmpAcc2;
        dither;
        ditherReg;
        phaseQuant;


        acc;
        phaseOutReg;
        validReg;
        sineReg;
        cosReg;
        pn_reg;
    end

    properties(Nontunable,Access=private)
        incIdx=1;
        offsetIdx=0;
        ditherIdx=0;
        resetIdx=0;
        validIdx=2;
        sineIdx=1;
        cosIdx=0;
        phaseIdx=0;
        validOutIdx=2;
        inMode=false(5,1);
        outMode;
        outType;
        accType;
        phaseOutType;
        quantType;
        pQuantWL;
        F;
        fullSine;
        fullCos;
        doubleMode(1,1)logical=false;
        singleMode(1,1)logical=false;
        NaNInputMode(1,1)logical=false;
        delay;
        rsltDly;
    end
    properties(Access=private)
        initAcc(1,1)logical;
        resetReg(1,1)logical;
        resetReg1(1,1)logical;
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl


            header=matlab.system.display.Header('dsphdl.NCO',...
            'ShowSourceLink',false,...
            'Title','NCO');
        end

        function groups=getPropertyGroupsImpl


            algorithm=matlab.system.display.Section(...
            'Title','Algorithm parameters',...
            'PropertyList',{'PhaseIncrementSource','PhaseIncrement',...
            'PhaseOffsetSource','PhaseOffset','DitherSource','NumDitherBits',...
            'SamplesPerFrame','LUTCompress'});

            reset=matlab.system.display.Section(...
            'Title','Control ports',...
            'PropertyList',{'ResetAction'});

            output=matlab.system.display.Section(...
            'Title','Output parameters',...
            'PropertyList',{'Waveform','PhasePort'});

            main=matlab.system.display.SectionGroup(...
            'TitleSource','Auto',...
            'Sections',[algorithm,reset,output]);

            fixedops=matlab.system.display.Section(...
            'Title','Fixed-point operational parameters',...
            'PropertyList',{'RoundingMethod','OverflowAction'});

            accum=matlab.system.display.Section(...
            'Title','Accumulator data type',...
            'PropertyList',{'AccumulatorDataType','AccumulatorSigned',...
            'AccumulatorWL','AccumulatorFL'});

            quant=matlab.system.display.Section(...
            'Title','Quantization data type',...
            'PropertyList',{'PhaseQuantization','NumQuantizerAccumulatorBits'});

            outputDT=matlab.system.display.Section(...
            'Title','Output data type',...
            'PropertyList',{'OutputDataType','OutputSigned',...
            'OutputWL','OutputFL'});

            datatypeDes=[''];

            datatypes=matlab.system.display.SectionGroup(...
            'Title','Data Types',...
            'Description',datatypeDes,...
            'Sections',[fixedops,accum,quant,outputDT]);

            groups=[main,datatypes];
        end
    end

    methods
        function obj=NCO(varargin)
            coder.allowpcode('plain');

            if coder.target('MATLAB')
                if~(builtin('license','checkout','DSP_HDL_Toolbox'))
                    error(message('dsphdl:dsphdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','DSP_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:},'PhaseIncrement');
        end

        function set.PhaseIncrement(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar'},'NCO','PhaseIncrement');
            obj.PhaseIncrement=val;
        end
        function set.PhaseOffset(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar'},'NCO','PhaseOffset');
            obj.PhaseOffset=val;
        end

        function set.NumDitherBits(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'NCO','NumDitherBits');
            obj.NumDitherBits=double(val);
        end

        function set.NumQuantizerAccumulatorBits(obj,val)

            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'NCO','NumQuantizerAccumulatorBits');
            obj.NumQuantizerAccumulatorBits=val;

        end

        function set.AccumulatorWL(obj,val)

            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'NCO','Accumulator WordLength');
            obj.AccumulatorWL=val;

        end

        function set.OutputWL(obj,val)

            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'NCO','Output WordLength');
            obj.OutputWL=val;

        end

        function set.OutputFL(obj,val)

            validateattributes(val,{'numeric'},{'integer','scalar','>',0},'NCO','Output FractionLength');
            obj.OutputFL=val;

        end

        function set.SamplesPerFrame(obj,val)
            validateattributes(val,{'numeric'},{'integer','scalar','>',0,'<=',64},'NCO','sample per frame');
            obj.SamplesPerFrame=double(val);
        end

    end

    methods(Access=protected)








        function[varargout]=outputImpl(obj,varargin)

            if obj.SamplesPerFrame==1
                switch obj.getNumOutputs
                case 2
                    if obj.validReg(1)
                        if obj.outMode(1)
                            varargout{1}=obj.sineReg(1);
                        elseif obj.outMode(2)
                            varargout{1}=obj.cosReg(1);
                        elseif obj.outMode(3)
                            varargout{1}=complex(obj.cosReg(1),obj.sineReg(1));
                        end
                    else
                        if obj.outMode(3)
                            varargout{1}=cast(complex(zeros(obj.SamplesPerFrame,1)),'like',obj.sineReg);
                        else
                            varargout{1}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                        end
                    end

                case 3
                    if obj.validReg(1)
                        if obj.outMode(1)&&obj.outMode(2)
                            varargout{1}=obj.sineReg(1);
                            varargout{2}=obj.cosReg(1);
                        else
                            if obj.outMode(1)
                                varargout{1}=obj.sineReg(1);
                            elseif obj.outMode(2)
                                varargout{1}=obj.cosReg(1);
                            elseif obj.outMode(3)
                                varargout{1}=complex(obj.cosReg(1),obj.sineReg(1));
                            end
                            varargout{2}=obj.phaseOutReg(1);
                        end
                    else
                        if obj.outMode(1)&&obj.outMode(2)
                            varargout{1}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                            varargout{2}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                        else
                            if obj.outMode(3)
                                varargout{1}=cast(complex(zeros(obj.SamplesPerFrame,1)),'like',obj.sineReg);
                            else
                                varargout{1}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                            end
                            varargout{2}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.phaseOutReg);
                        end
                    end

                case 4
                    if obj.validReg(1)
                        varargout{1}=obj.sineReg(1);
                        varargout{2}=obj.cosReg(1);
                        varargout{3}=obj.phaseOutReg(1);
                    else
                        varargout{1}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                        varargout{2}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                        varargout{3}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.phaseOutReg);
                    end
                end
            else
                switch obj.getNumOutputs
                case 2
                    if obj.validReg(1)
                        if obj.outMode(1)
                            varargout{1}=obj.sineReg(1,:).';
                        elseif obj.outMode(2)
                            varargout{1}=obj.cosReg(1,:).';
                        elseif obj.outMode(3)
                            varargout{1}=complex(obj.cosReg(1,:).',obj.sineReg(1,:).');
                        end
                    else
                        if obj.outMode(3)
                            varargout{1}=cast(complex(zeros(obj.SamplesPerFrame,1)),'like',obj.sineReg);
                        else
                            varargout{1}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                        end
                    end

                case 3
                    if obj.validReg(1)
                        if obj.outMode(1)&&obj.outMode(2)
                            varargout{1}=obj.sineReg(1,:).';
                            varargout{2}=obj.cosReg(1,:).';
                        else
                            if obj.outMode(1)
                                varargout{1}=obj.sineReg(1,:).';
                            elseif obj.outMode(2)
                                varargout{1}=obj.cosReg(1,:).';
                            elseif obj.outMode(3)
                                varargout{1}=complex(obj.cosReg(1,:).',obj.sineReg(1,:).');
                            end
                            varargout{2}=obj.phaseOutReg(1,:).';
                        end
                    else
                        if obj.outMode(1)&&obj.outMode(2)
                            varargout{1}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                            varargout{2}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                        else
                            if obj.outMode(3)
                                varargout{1}=cast(complex(zeros(obj.SamplesPerFrame,1)),'like',obj.sineReg);
                            else
                                varargout{1}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                            end
                            varargout{2}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.phaseOutReg);
                        end
                    end

                case 4
                    if obj.validReg(1)
                        varargout{1}=obj.sineReg(1,:).';
                        varargout{2}=obj.cosReg(1,:).';
                        varargout{3}=obj.phaseOutReg(1,:).';
                    else
                        varargout{1}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                        varargout{2}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.sineReg);
                        varargout{3}=cast(zeros(obj.SamplesPerFrame,1),'like',obj.phaseOutReg);
                    end
                end
            end
            varargout{obj.getNumOutputs}=obj.validReg(1);
        end







































        function updateImpl(obj,varargin)
            if~coder.target('hdl')
                if obj.SamplesPerFrame==1
                    updateImplS(obj,varargin{:});
                else
                    updateImplV(obj,varargin{:});
                end
            end
        end
        function updateImplS(obj,varargin)




            if obj.inMode(1)
                obj.phaseInc(1)=varargin{1};
            else
                obj.phaseInc(1)=obj.PhaseIncrement;
            end

            if obj.inMode(2)
                obj.phaseOff(1)=varargin{obj.offsetIdx};
            else
                obj.phaseOff(1)=obj.PhaseOffset;
            end

            if obj.inMode(3)
                obj.dither(1)=varargin{obj.ditherIdx};
            end

            if obj.inMode(4)
                resetValue=varargin{obj.resetIdx};
            else
                resetValue=false;
            end

            if obj.inMode(5)
                validIn=varargin{obj.validIdx};
            else
                validIn=true;
            end


            obj.sineReg(1:obj.delay-1)=obj.sineReg(2:obj.delay);
            obj.cosReg(1:obj.delay-1)=obj.cosReg(2:obj.delay);
            obj.phaseOutReg(1:obj.delay-1)=obj.phaseOutReg(2:obj.delay);
            obj.validReg(1:obj.delay-1)=obj.validReg(2:obj.delay);

            if obj.doubleMode
                [sinValue,cosValue,tblIdx]=ncocore_float(obj,resetValue,validIn);
            elseif obj.singleMode
                [sinValue,cosValue,tblIdx]=ncocore_float(obj,resetValue,validIn);
            else

                tblIdx=ncocore(obj,resetValue,validIn);
                sinValue=obj.fullSine(tblIdx+1);
                cosValue=obj.fullCos(tblIdx+1);
            end

            if validIn
                obj.sineReg(obj.delay)=sinValue;
                obj.cosReg(obj.delay)=cosValue;
            else
                obj.sineReg(obj.delay)=cast(0,'like',obj.sineReg(1));
                obj.cosReg(obj.delay)=cast(0,'like',obj.cosReg(1));
            end


            obj.phaseOutReg(obj.delay)=cast(tblIdx,'like',obj.phaseOutReg);
            obj.validReg(obj.delay)=validIn;


        end
        function updateImplV(obj,varargin)




            if obj.inMode(1)
                obj.phaseInc(1)=varargin{1};
            else
                obj.phaseInc(1)=obj.PhaseIncrement;
            end

            if obj.inMode(2)
                obj.phaseOff(:)=varargin{obj.offsetIdx};
            else
                obj.phaseOff(:)=obj.PhaseOffset;
            end


            if obj.inMode(3)
                obj.dither(:)=varargin{obj.ditherIdx};
            end

            if obj.inMode(4)
                resetValue=varargin{obj.resetIdx};
            else
                resetValue=false;
            end


            validIn=varargin{obj.validIdx};




            obj.sineReg(1:obj.rsltDly-1,:)=obj.sineReg(2:obj.rsltDly,:);
            obj.cosReg(1:obj.rsltDly-1,:)=obj.cosReg(2:obj.rsltDly,:);
            obj.phaseOutReg(1:obj.rsltDly-1,:)=obj.phaseOutReg(2:obj.rsltDly,:);

            obj.validReg(1:obj.delay-1)=obj.validReg(2:obj.delay);
            obj.phaseOffReg(1:3)=obj.phaseOffReg(2:4);

            if obj.doubleMode||obj.singleMode
                [sinValue,cosValue,tblIdx]=ncocore_float_frame(obj,obj.resetReg1);
            else
                tblIdx=ncocore_frame(obj,obj.resetReg1);
                sinValue=obj.fullSine(tblIdx+1);
                cosValue=obj.fullCos(tblIdx+1);
            end
            if strcmp(obj.DitherSource,'Property')
                obj.ditherReg(:,1:3)=obj.ditherReg(:,2:4);
            else
                obj.ditherReg(:,1:2)=obj.ditherReg(:,2:3);
            end

            if obj.resetReg
                obj.phaseIncV(:)=0;
            else
                obj.phaseIncV(3)=obj.phaseIncV(2);
                obj.phaseIncV(2)=obj.phaseIncV(1);
                obj.phaseIncV(1)=obj.phaseInc(1);
            end
            if resetValue
                obj.phaseIncReg(:)=0;
            else
                obj.phaseIncReg(2,:)=obj.phaseIncReg(1,:);
            end

            if validIn
                if strcmp(obj.DitherSource,'Property')
                    obj.dither(:)=pngen_frame(obj);
                    obj.ditherReg(:,4)=obj.dither;
                else
                    obj.ditherReg(:,3)=obj.dither;
                end

                if double(obj.phaseInc(1,:))==0
                    obj.phaseIncReg(1,:)=0;
                else

                    for loop=2:obj.SamplesPerFrame
                        obj.phaseIncReg(1,loop)=double(obj.phaseIncReg(1,loop-1))+double(obj.phaseInc(1));
                    end
                end
                obj.phaseOffReg(4)=obj.phaseOff;
            else
                obj.sineReg(obj.rsltDly,:)=cast(0,'like',obj.sineReg(1));
                obj.cosReg(obj.rsltDly,:)=cast(0,'like',obj.cosReg(1));
            end
            if obj.validReg(obj.rsltDly)
                obj.sineReg(obj.rsltDly,:)=sinValue;
                obj.cosReg(obj.rsltDly,:)=cosValue;
            else
                obj.sineReg(obj.rsltDly,:)=cast(0,'like',obj.sineReg(1));
                obj.cosReg(obj.rsltDly,:)=cast(0,'like',obj.cosReg(1));
            end


            obj.phaseOutReg(obj.rsltDly,:)=cast(tblIdx,'like',obj.phaseOutReg);
            if resetValue
                obj.validReg(obj.delay:obj.delay)=false;
            else
                obj.validReg(obj.delay)=validIn;
            end
            obj.resetReg1=obj.resetReg;
            obj.resetReg=resetValue;
        end



        function setupImpl(obj,varargin)

            cntDouble=0;
            cntSingle=0;
            for ii=coder.unroll(1:nargin-1)
                in=varargin{ii};

                if isa(in,'double')
                    cntDouble=cntDouble+1;
                elseif isa(in,'single')
                    cntSingle=cntSingle+1;
                end

            end
            if cntDouble>0
                obj.doubleMode=true;
                obj.singleMode=false;
            elseif cntSingle>0
                obj.doubleMode=false;
                obj.singleMode=true;
            else
                obj.doubleMode=false;
                obj.singleMode=false;
            end


            obj.initAcc=true;
            obj.resetReg=false;
            obj.resetReg1=false;
            if obj.SamplesPerFrame==1
                setupImplS(obj,varargin{:})
            else
                setupImplV(obj,varargin{:})
            end
        end
        function setupImplS(obj,varargin)






            tMode=[strcmp(obj.PhaseIncrementSource,'Input port')
            strcmp(obj.PhaseOffsetSource,'Input port')
            strcmp(obj.DitherSource,'Input port')
            obj.ResetAction
            obj.ValidInputPort
            ];

            obj.inMode=tMode';

            toutmode=[strcmp(obj.Waveform,'Sine')||strcmp(obj.Waveform,'Sine and cosine');
            strcmp(obj.Waveform,'Cosine')||strcmp(obj.Waveform,'Sine and cosine');
            strcmp(obj.Waveform,'Complex exponential');
            obj.PhasePort];

            obj.outMode=toutmode';
            getPortsIdx(obj);

            obj.delay=getLatency(obj);




            coder.extrinsic('HDLNCOComputeLUT');

            accWL=obj.AccumulatorWL;
            if obj.PhaseQuantization
                quantWL=obj.NumQuantizerAccumulatorBits;
            else
                quantWL=accWL;
            end
            obj.pQuantWL=quantWL;

            outWL=obj.OutputWL;
            outFL=obj.OutputFL;







            obj.F=hdlfimath;


            obj.pn_reg=zeros(19,1);
            if strcmp(obj.DitherSource,'Property')


                obj.pn_reg(1)=1;
            end
            obj.validReg=false(obj.delay,1);

            if obj.doubleMode


                obj.acc=0;
                obj.phaseInc=0;
                obj.phaseOff=0;
                obj.tmpAcc=0;
                obj.tmpAcc2=0;
                obj.phaseQuant=0;
                obj.dither=0;

            elseif obj.singleMode
                obj.acc=single(0);
                obj.phaseInc=single(0);
                obj.phaseOff=single(0);
                obj.tmpAcc=single(0);
                obj.tmpAcc2=single(0);
                obj.phaseQuant=single(0);
                obj.dither=single(0);
            else


                obj.accType=numerictype(1,accWL,0,'DataTypeOverride','off');
                obj.quantType=numerictype(1,quantWL,quantWL-accWL,'DataTypeOverride','off');



                obj.acc=fi(0,obj.accType,obj.F,'DataTypeOverride','off');
                obj.phaseInc=fi(0,obj.accType,obj.F,'DataTypeOverride','off');
                obj.phaseOff=fi(0,obj.accType,obj.F,'DataTypeOverride','off');

                obj.tmpAcc=fi(0,obj.accType,obj.F,'DataTypeOverride','off');
                obj.tmpAcc2=fi(0,obj.accType,obj.F,'DataTypeOverride','off');
                obj.phaseQuant=fi(0,obj.quantType,obj.F,'DataTypeOverride','off');


                if obj.inMode(3)
                    d=varargin{obj.ditherIdx};

                    if isinteger(d)

                        obj.dither=d;
                    else
                        obj.dither=fi(0,d.numerictype,obj.F,'DataTypeOverride','off');
                    end

                else
                    obj.dither=fi(0,0,obj.NumDitherBits,0,'DataTypeOverride','off');
                end
            end

            if strcmpi(obj.OutputDataType,'double')||obj.doubleMode
                obj.outType=numerictype('double');
            elseif(strcmpi(obj.OutputDataType,'single'))||obj.singleMode
                obj.outType=numerictype('single');
            else
                obj.outType=numerictype(1,outWL,outFL,'DataTypeOverride','off');

            end

            if isempty(coder.target)
                [obj.fullSine,obj.fullCos]=HDLNCOComputeLUT(quantWL,obj.OutputWL,...
                obj.OutputFL,obj.LUTCompress,obj.OutputDataType,obj.outType);
            else
                [obj.fullSine,obj.fullCos]=coder.internal.const(HDLNCOComputeLUT(quantWL,obj.OutputWL,...
                obj.OutputFL,obj.LUTCompress,obj.OutputDataType,obj.outType));
            end

            if strcmpi(obj.OutputDataType,'double')||obj.doubleMode
                obj.sineReg=double(zeros(obj.delay,obj.SamplesPerFrame));
                obj.cosReg=double(zeros(obj.delay,obj.SamplesPerFrame));

            elseif strcmpi(obj.OutputDataType,'single')||obj.singleMode
                obj.sineReg=single(zeros(obj.delay,obj.SamplesPerFrame));
                obj.cosReg=single(zeros(obj.delay,obj.SamplesPerFrame));

            else
                obj.sineReg=fi(zeros(obj.delay,obj.SamplesPerFrame),obj.outType,obj.F,'DataTypeOverride','off');
                obj.cosReg=fi(zeros(obj.delay,obj.SamplesPerFrame),obj.outType,obj.F,'DataTypeOverride','off');

            end

            if obj.doubleMode
                obj.phaseOutReg=double(zeros(obj.delay,obj.SamplesPerFrame));
            elseif obj.singleMode
                obj.phaseOutReg=single(zeros(obj.delay,obj.SamplesPerFrame));
            else
                obj.phaseOutType=numerictype(0,quantWL,0,'DataTypeOverride','off');
                obj.phaseOutReg=fi(zeros(obj.delay,obj.SamplesPerFrame),obj.phaseOutType,obj.F,'DataTypeOverride','off');
            end
            obj.validReg=false(obj.delay,1);

        end
        function setupImplV(obj,varargin)






            tMode=[strcmp(obj.PhaseIncrementSource,'Input port')
            strcmp(obj.PhaseOffsetSource,'Input port')
            strcmp(obj.DitherSource,'Input port')
            obj.ResetAction
            obj.ValidInputPort
            ];

            obj.inMode=tMode';

            toutmode=[strcmp(obj.Waveform,'Sine')||strcmp(obj.Waveform,'Sine and cosine');
            strcmp(obj.Waveform,'Cosine')||strcmp(obj.Waveform,'Sine and cosine');
            strcmp(obj.Waveform,'Complex exponential');
            obj.PhasePort];

            obj.outMode=toutmode';
            getPortsIdx(obj);

            obj.delay=getLatency(obj);
            obj.rsltDly=obj.delay-3;



            coder.extrinsic('HDLNCOComputeLUT');

            accWL=obj.AccumulatorWL;
            if obj.PhaseQuantization
                quantWL=obj.NumQuantizerAccumulatorBits;
            else
                quantWL=accWL;
            end
            obj.pQuantWL=quantWL;

            outWL=obj.OutputWL;
            outFL=obj.OutputFL;








            obj.F=hdlfimath;


            obj.pn_reg=zeros(19,1);
            if strcmp(obj.DitherSource,'Property')


                obj.pn_reg(1)=1;
            end
            obj.validReg=false(obj.delay,1);

            if obj.doubleMode


                obj.acc=zeros(obj.SamplesPerFrame,1);
                obj.phaseInc=0;
                obj.phaseOff=0;
                obj.phaseOffReg=zeros(4,1);
                obj.tmpAcc=zeros(obj.SamplesPerFrame,1);
                obj.tmpAcc2=zeros(obj.SamplesPerFrame,1);
                obj.phaseQuant=zeros(obj.SamplesPerFrame,1);
                obj.dither=zeros(obj.SamplesPerFrame,1);
                obj.phaseIncReg=zeros(2,obj.SamplesPerFrame);
                obj.phaseIncV=zeros(3,1);

            elseif obj.singleMode
                obj.acc=single(zeros(obj.SamplesPerFrame,1));
                obj.phaseInc=single(0);
                obj.phaseOff=single(0);
                obj.phaseOffReg=single(zeros(4,1));
                obj.tmpAcc=single(zeros(obj.SamplesPerFrame,1));
                obj.tmpAcc2=single(zeros(obj.SamplesPerFrame,1));
                obj.phaseQuant=single(zeros(obj.SamplesPerFrame,1));
                obj.dither=single(zeros(obj.SamplesPerFrame,1));
                obj.phaseIncReg=single(zeros(2,obj.SamplesPerFrame));
                obj.phaseIncV=single(zeros(3,1));
            else


                obj.accType=numerictype(1,accWL,0,'DataTypeOverride','off');
                obj.quantType=numerictype(0,quantWL,quantWL-accWL,'DataTypeOverride','off');



                obj.acc=fi(zeros(obj.SamplesPerFrame,1),obj.accType,obj.F,'DataTypeOverride','off');
                obj.phaseInc=fi(0,obj.accType,obj.F,'DataTypeOverride','off');
                obj.phaseOff=fi(0,obj.accType,obj.F,'DataTypeOverride','off');
                obj.phaseOffReg=fi(zeros(4,1),obj.accType,obj.F,'DataTypeOverride','off');
                obj.tmpAcc=fi(zeros(obj.SamplesPerFrame,1),obj.accType,obj.F,'DataTypeOverride','off');
                obj.tmpAcc2=fi(zeros(obj.SamplesPerFrame,1),obj.accType,obj.F,'DataTypeOverride','off');
                obj.phaseQuant=fi(zeros(obj.SamplesPerFrame,1),obj.quantType,obj.F,'DataTypeOverride','off');

                obj.phaseIncReg=fi(zeros(2,obj.SamplesPerFrame),obj.accType,obj.F,'DataTypeOverride','off');
                obj.phaseIncV=fi(zeros(3,1),obj.accType,obj.F,'DataTypeOverride','off');


                if obj.inMode(3)
                    d=varargin{obj.ditherIdx};

                    if isinteger(d)

                        obj.dither=d;
                    else
                        obj.dither=fi(zeros(obj.SamplesPerFrame,1),d.numerictype,obj.F,'DataTypeOverride','off');
                    end

                else
                    obj.dither=fi(zeros(obj.SamplesPerFrame,1),0,obj.NumDitherBits,0,'DataTypeOverride','off');
                end

            end
            if strcmp(obj.DitherSource,'Property')
                obj.ditherReg=cast(zeros(obj.SamplesPerFrame,4),'like',obj.dither);
            else
                obj.ditherReg=cast(zeros(obj.SamplesPerFrame,3),'like',obj.dither);
            end


            if strcmpi(obj.OutputDataType,'double')||obj.doubleMode
                obj.outType=numerictype('double');
            elseif(strcmpi(obj.OutputDataType,'single'))||obj.singleMode
                obj.outType=numerictype('single');
            else
                obj.outType=numerictype(1,outWL,outFL,'DataTypeOverride','off');
            end

            if isempty(coder.target)
                [obj.fullSine,obj.fullCos]=HDLNCOComputeLUT(quantWL,obj.OutputWL,...
                obj.OutputFL,obj.LUTCompress,obj.OutputDataType,obj.outType);
            else
                [obj.fullSine,obj.fullCos]=coder.internal.const(HDLNCOComputeLUT(quantWL,obj.OutputWL,...
                obj.OutputFL,obj.LUTCompress,obj.OutputDataType,obj.outType));
            end

            if strcmpi(obj.OutputDataType,'double')||obj.doubleMode
                obj.sineReg=double(zeros(obj.rsltDly,obj.SamplesPerFrame));
                obj.cosReg=double(zeros(obj.rsltDly,obj.SamplesPerFrame));

            elseif strcmpi(obj.OutputDataType,'single')||obj.singleMode
                obj.sineReg=single(zeros(obj.rsltDly,obj.SamplesPerFrame));
                obj.cosReg=single(zeros(obj.rsltDly,obj.SamplesPerFrame));

            else
                obj.sineReg=fi(zeros(obj.rsltDly,obj.SamplesPerFrame),obj.outType,obj.F,'DataTypeOverride','off');
                obj.cosReg=fi(zeros(obj.rsltDly,obj.SamplesPerFrame),obj.outType,obj.F,'DataTypeOverride','off');

            end

            if obj.doubleMode
                obj.phaseOutReg=double(zeros(obj.rsltDly,obj.SamplesPerFrame));
            elseif obj.singleMode
                obj.phaseOutReg=single(zeros(obj.rsltDly,obj.SamplesPerFrame));
            else
                obj.phaseOutType=numerictype(0,quantWL,0,'DataTypeOverride','off');
                obj.phaseOutReg=fi(zeros(obj.rsltDly,obj.SamplesPerFrame),obj.phaseOutType,obj.F,'DataTypeOverride','off');
            end
            obj.validReg=false(obj.delay,1);
        end



        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetAction
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end


        function validateInputsImpl(obj,varargin)
            coder.extrinsic('gcb','get_param','bdroot');
            if obj.isInMATLABSystemBlock
                blkName=coder.const(gcb);

            else
                blkName='dsphdl.NCO';
            end

            tMode=[strcmp(obj.PhaseIncrementSource,'Input port')
            strcmp(obj.PhaseOffsetSource,'Input port')
            strcmp(obj.DitherSource,'Input port')
            obj.ResetAction
            obj.ValidInputPort
            ];

            obj.inMode=tMode';








            getPortsIdx(obj);



            doubleInput=false;
            for ii=coder.unroll(1:nargin-1)
                in=varargin{ii};
                for jj=1:length(in)
                    if isa(in(jj),'double')||isnan(in(jj))
                        doubleInput=true;
                        break;
                    end
                end
            end
            singleInput=false;
            if~doubleInput

                for ii=coder.unroll(1:nargin-1)
                    in=varargin{ii};
                    for jj=1:length(in)
                        if isa(in(jj),'single')
                            singleInput=true;
                            break;
                        end
                    end

                end
            end



            pInclass={'uint8','uint16','uint32','uint64','int8','int16','int32','int64','embedded.fi','double','single'};
            pOffclass={'uint8','uint16','uint32','uint64','int8','int16','int32','int64','embedded.fi','double','single'};


            if isempty(coder.target)||~eml_ambiguous_types



                if obj.inMode(1)
                    pInc=varargin{1};
                    if doubleInput||singleInput
                        validateattributes(pInc,pInclass,{'scalar'},'NCO','phaseIncrement');
                    else
                        validateattributes(pInc,pInclass,{'integer','scalar'},'NCO','phaseIncrement');
                        if isa(pInc,'embedded.fi')
                            coder.internal.errorIf(pInc.FractionLength~=0,...
                            'dsphdl:NCO:PhaseIncrFracLenNotZero',blkName);
                        end
                        if isfloat(pInc)
                            if floor(pInc)-pInc~=0
                                coder.internal.error('dsphdl:NCO:PhaseIncrNotInteger',blkName);
                            end
                        end
                    end
                end

                if obj.inMode(2)
                    pOff=varargin{obj.offsetIdx};

                    if doubleInput||singleInput
                        validateattributes(pOff,pOffclass,{'scalar'},'NCO','phaseOffset');
                    else
                        validateattributes(pOff,pOffclass,{'integer','scalar'},'NCO','phaseOffset');
                        if isa(pOff,'embedded.fi')
                            coder.internal.errorIf(pOff.FractionLength~=0,...
                            'dsphdl:NCO:PhaseOffsetFracLenNotZero',blkName);
                        end
                        if isfloat(pOff)
                            if floor(pOff)-pOff~=0
                                coder.internal.error('dsphdl:NCO:PhaseOffsetNotInteger',blkName);
                            end
                        end
                    end
                end

                if obj.inMode(3)
                    pDither=varargin{obj.ditherIdx};

                    if obj.SamplesPerFrame==1
                        if doubleInput||singleInput
                            validateattributes(pDither,pInclass,{'scalar'},'NCO','dither');
                        else
                            validateattributes(pDither,pInclass,{'integer','scalar'},'NCO','dither');
                        end
                    else
                        if doubleInput||singleInput
                            validateattributes(pDither,pInclass,{'vector','size',[int32(obj.SamplesPerFrame),1]},'NCO','dither');
                        else
                            validateattributes(pDither,pInclass,{'integer','vector','size',[int32(obj.SamplesPerFrame),1]},'NCO','dither');
                        end
                    end

                    if isa(pDither,'embedded.fi')
                        coder.internal.errorIf(pDither.FractionLength~=0,...
                        'dsphdl:NCO:ditherNotInt','dither');

                    end
                    [inWL,~,~]=dsphdlshared.hdlgetwordsizefromdata(pDither);
                    coder.internal.errorIf(inWL>obj.AccumulatorWL,...
                    'dsphdl:NCO:ditherWordLenNotLtAccWordLen',blkName);

                    if isfloat(pDither)
                        if floor(pDither)-pDither~=0
                            coder.internal.error('dsphdl:NCO:ditherNotInt',blkName);
                        end
                    end
                end



                if obj.inMode(4)
                    validateattributes(varargin{obj.resetIdx},{'logical'},{'scalar'},'NCO','reset');
                end


                if isfloat(varargin{obj.validIdx})
                    coder.internal.error('dsphdl:NCO:ValidInputIsFloat',blkName);
                end
                validateattributes(varargin{obj.validIdx},{'logical'},{'scalar'},'NCO','valid');

            end
        end

        function validatePropertiesImpl(obj)

            coder.internal.errorIf(obj.LUTCompress&&obj.PhaseQuantization&&obj.NumQuantizerAccumulatorBits<5,...
            'dsphdl:NCO:QuanWordLenTooShortC','dsphdl.NCO');
            coder.internal.errorIf(~obj.LUTCompress&&obj.PhaseQuantization&&obj.NumQuantizerAccumulatorBits<3,...
            'dsphdl:NCO:QuanWordLenTooShort','dsphdl.NCO');

            coder.internal.errorIf(obj.LUTCompress&&~obj.PhaseQuantization&&obj.AccumulatorWL<5,...
            'dsphdl:NCO:AccumWordLenTooShortC','dsphdl.NCO');
            coder.internal.errorIf(~obj.LUTCompress&&~obj.PhaseQuantization&&obj.AccumulatorWL<3,...
            'dsphdl:NCO:AccumWordLenTooShort','dsphdl.NCO');



            coder.internal.errorIf(obj.LUTCompress&&obj.PhaseQuantization&&obj.NumQuantizerAccumulatorBits>21,...
            'dsphdl:NCO:NumQuantAccumBitsTooLargeC','dsphdl.NCO');
            coder.internal.errorIf(~obj.LUTCompress&&obj.PhaseQuantization&&obj.NumQuantizerAccumulatorBits>19,...
            'dsphdl:NCO:NumQuantAccumBitsTooLarge','dsphdl.NCO');

            coder.internal.errorIf(obj.LUTCompress&&~obj.PhaseQuantization&&obj.AccumulatorWL>21,...
            'dsphdl:NCO:AccumWordLenTooLargeC','dsphdl.NCO');
            coder.internal.errorIf(~obj.LUTCompress&&~obj.PhaseQuantization&&obj.AccumulatorWL>19,...
            'dsphdl:NCO:AccumWordLenTooLarge','dsphdl.NCO');

            coder.internal.errorIf(obj.PhaseQuantization&&obj.NumQuantizerAccumulatorBits>obj.AccumulatorWL,...
            'dsphdl:NCO:accWordLenNotGtQuanWordLen','dsphdl.NCO');

            coder.internal.errorIf(strcmp(obj.DitherSource,'Property')&&obj.NumDitherBits>obj.AccumulatorWL,...
            'dsphdl:NCO:ditherBitsNotLtAccWordLen','dsphdl.NCO');

        end



        function resetImpl(obj)




            obj.acc(:)=0;
            obj.phaseOutReg(:)=0;
            obj.validReg(:)=0;
            obj.sineReg(:)=0;
            obj.cosReg(:)=0;
            obj.pn_reg(:)=0;
            obj.phaseIncReg(:)=0;
            obj.phaseOff(:)=0;
            obj.phaseOffReg(:)=0;
            obj.phaseIncV(:)=0;
            if strcmp(obj.DitherSource,'Property')


                obj.pn_reg(1)=1;
                if obj.SamplesPerFrame>1
                    obj.dither(:)=pngen_frame(obj);
                    obj.ditherReg(:)=0;
                    obj.ditherReg(:,4)=obj.dither(:);
                    obj.initAcc=true;
                    obj.resetReg=false;
                    obj.resetReg1=false;
                end
            end

        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.incIdx=obj.incIdx;
                s.offsetIdx=obj.offsetIdx;
                s.ditherIdx=obj.ditherIdx;
                s.resetIdx=obj.resetIdx;
                s.validIdx=obj.validIdx;
                s.sineIdx=obj.sineIdx;
                s.cosIdx=obj.cosIdx;
                s.phaseIdx=obj.phaseIdx;
                s.validOutIdx=obj.validOutIdx;
                s.inMode=obj.inMode;
                s.outMode=obj.outMode;
                s.outType=obj.outType;
                s.phaseOutType=obj.phaseOutType;
                s.accType=obj.accType;
                s.quantType=obj.quantType;
                s.pQuantWL=obj.pQuantWL;
                s.F=obj.F;
                s.fullSine=obj.fullSine;
                s.fullCos=obj.fullCos;
                s.phaseQuant=obj.phaseQuant;
                s.phaseInc=obj.phaseInc;
                s.phaseIncReg=obj.phaseIncReg;
                s.phaseIncV=obj.phaseIncV;
                s.phaseOff=obj.phaseOff;
                s.phaseOffReg=obj.phaseOffReg;
                s.tmpAcc=obj.tmpAcc;
                s.tmpAcc2=obj.tmpAcc2;
                s.dither=obj.dither;
                s.ditherReg=obj.ditherReg;
                s.doubleMode=obj.doubleMode;
                s.singleMode=obj.singleMode;
                s.NaNInputMode=obj.NaNInputMode;

                s.acc=obj.acc;
                s.phaseOutReg=obj.phaseOutReg;
                s.validReg=obj.validReg;
                s.sineReg=obj.sineReg;
                s.cosReg=obj.cosReg;
                s.pn_reg=obj.pn_reg;
                s.initAcc=obj.initAcc;
                s.resetReg=obj.resetReg;
                s.resetReg1=obj.resetReg1;
            end
        end


        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});%#ok
            end
        end


        function num=getNumInputsImpl(obj)

            tMode=[strcmp(obj.PhaseIncrementSource,'Input port')
            strcmp(obj.PhaseOffsetSource,'Input port')
            strcmp(obj.DitherSource,'Input port')
            obj.ResetAction
            obj.ValidInputPort
            ];
            num=sum(double(tMode));

        end


        function icon=getIconImpl(obj)
            Latency=getLatency(obj);
            icon=sprintf(['NCO\n Latency = ',num2str(Latency)]);
        end


        function varargout=getInputNamesImpl(obj)

            varargout=cell(1,getNumInputs(obj));
            inputPortInd=1;
            if(strcmp(obj.PhaseIncrementSource,'Input port'))
                varargout{inputPortInd}='inc';
                inputPortInd=inputPortInd+1;
            end
            if(strcmp(obj.PhaseOffsetSource,'Input port'))
                varargout{inputPortInd}='offset';
                inputPortInd=inputPortInd+1;
            end
            if(strcmp(obj.DitherSource,'Input port'))
                varargout{inputPortInd}='dither';
                inputPortInd=inputPortInd+1;
            end
            if obj.ResetAction
                varargout{inputPortInd}='reset accum';
                inputPortInd=inputPortInd+1;
            end
            if obj.ValidInputPort
                varargout{inputPortInd}='valid';
            end
        end


        function varargout=getOutputNamesImpl(obj)

            varargout=cell(1,getNumOutputs(obj));

            outputPortInd=1;
            switch(obj.Waveform)
            case 'Sine'
                varargout{1}='sin';
                outputPortInd=outputPortInd+1;
            case 'Cosine'
                varargout{1}='cos';
                outputPortInd=outputPortInd+1;
            case 'Complex exponential'
                varargout{1}='exp';
                outputPortInd=outputPortInd+1;
            case 'Sine and cosine'
                varargout{1}='sin';
                varargout{2}='cos';
                outputPortInd=outputPortInd+2;
            end
            if obj.PhasePort
                varargout{outputPortInd}='phase';
                outputPortInd=outputPortInd+1;
            end
            varargout{outputPortInd}='valid';
        end


        function num=getNumOutputsImpl(obj)
            num=2;

            if obj.PhasePort
                num=num+1;
            end

            if strcmp(obj.Waveform,'Sine and cosine')
                num=num+1;
            end

        end

        function varargout=getOutputDataTypeImpl(obj)
            tMode=[strcmp(obj.PhaseIncrementSource,'Input port')
            strcmp(obj.PhaseOffsetSource,'Input port')
            strcmp(obj.DitherSource,'Input port')
            ];
            idx=1;
            doubleInput=false;
            singleInput=false;
            isInputInherited=false;
            if tMode(1)==1
                inputDT=propagatedInputDataType(obj,idx);
                if isempty(inputDT)
                    isInputInherited=true;
                end
                if~doubleInput
                    doubleInput=isDoubleIn(obj,inputDT);
                end
                if~singleInput
                    singleInput=isSingleIn(obj,inputDT);
                end
                idx=idx+1;
            end
            if tMode(2)==1
                inputDT=propagatedInputDataType(obj,idx);
                if isempty(inputDT)
                    isInputInherited=true;
                end
                if~doubleInput
                    doubleInput=isDoubleIn(obj,inputDT);
                end
                if~singleInput
                    singleInput=isSingleIn(obj,inputDT);
                end
                idx=idx+1;
            end
            if tMode(3)==1
                inputDT=propagatedInputDataType(obj,idx);
                if isempty(inputDT)
                    isInputInherited=true;
                end
                if~doubleInput
                    singleInput=isDoubleIn(obj,inputDT);
                end
                if~singleInput
                    singleInput=isSingleIn(obj,inputDT);
                end
            end
            if doubleInput
                singleInput=false;
            end
            if strcmpi(obj.OutputDataType,'double')||doubleInput
                outputDT='double';
            elseif strcmpi(obj.OutputDataType,'single')||singleInput
                outputDT='single';
            else
                outputDT=numerictype(1,obj.OutputWL,obj.OutputFL);
            end
            if isInputInherited
                outputDT=[];
            end
            idx=1;
            varargout{idx}=outputDT;

            idx=idx+1;

            if strcmpi(obj.Waveform,'Sine and cosine')
                varargout{idx}=outputDT;
                idx=idx+1;
            end

            if obj.PhasePort
                if doubleInput
                    varargout{idx}='double';
                elseif singleInput
                    varargout{idx}='single';
                else
                    if obj.PhaseQuantization
                        varargout{idx}=numerictype(0,obj.NumQuantizerAccumulatorBits,0);
                    else
                        varargout{idx}=numerictype(0,obj.AccumulatorWL,0);
                    end
                end
                idx=idx+1;
            end

            varargout{idx}=numerictype('logical');



        end

        function varargout=isOutputComplexImpl(obj)
            idx=1;
            if strcmpi(obj.Waveform,'Complex exponential')
                varargout{idx}=true;
            else
                varargout{idx}=false;
            end
            if strcmpi(obj.Waveform,'Sine and cosine')
                idx=2;
                varargout{idx}=false;
            end
            for ii=idx+1:getNumOutputs(obj)
                varargout{ii}=false;
            end

        end

        function varargout=isOutputFixedSizeImpl(obj)
            for ii=1:getNumOutputs(obj)
                varargout{ii}=true;
            end
        end

        function varargout=getOutputSizeImpl(obj)
            idx=1;
            varargout{idx}=obj.SamplesPerFrame;
            idx=idx+1;
            if strcmpi(obj.Waveform,'Sine and cosine')
                varargout{idx}=obj.SamplesPerFrame;
                idx=idx+1;
            end
            if obj.PhasePort
                varargout{idx}=obj.SamplesPerFrame;
                idx=idx+1;
            end
            for ii=idx:getNumOutputs(obj)
                varargout{ii}=1;
            end
        end

        function varargout=isInputDirectFeedthroughImpl(obj,varargin)
            for ii=1:nargout
                varargout{ii}=false;
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'PhaseIncrement'
                if strcmp(obj.PhaseIncrementSource,'Input port')
                    flag=true;
                end
            case 'PhaseOffset'
                if strcmp(obj.PhaseOffsetSource,'Input port')
                    flag=true;
                end
            case 'NumDitherBits'
                if strcmp(obj.DitherSource,'Input port')||strcmp(obj.DitherSource,'None')
                    flag=true;
                end
            case{'NumQuantizerAccumulatorBits'}
                if~obj.PhaseQuantization
                    flag=true;
                end
            case{'OutputSigned','OutputWL','OutputFL'}
                if~strcmp(obj.OutputDataType,'Binary point scaling')
                    flag=true;
                end
            end
        end

        function status=isDoubleIn(obj,inputData)%#ok<INUSL>
            if isnumerictype(inputData)
                status=false;
            elseif strcmpi(inputData,'double')
                status=true;
            else
                status=false;
            end
        end

        function status=isSingleIn(obj,inputData)%#ok<INUSL>
            if isnumerictype(inputData)
                status=false;
            elseif strcmpi(inputData,'single')
                status=true;
            else
                status=false;
            end
        end

        function getPortsIdx(obj)


            obj.incIdx=1;

            obj.offsetIdx=2-(1-obj.inMode(1));


            obj.ditherIdx=3-(2-sum(double(obj.inMode(1:2))));

            obj.resetIdx=4-(3-sum(double(obj.inMode(1:3))));
            obj.validIdx=5-(4-sum(double(obj.inMode(1:4))));


        end

        function tblIdx=ncocore(obj,reset,validIn)

            quantWL=obj.phaseQuant.WordLength;



            obj.tmpAcc2(1)=obj.acc+obj.phaseOff;

            if strcmp(obj.DitherSource,'Property')&&validIn
                obj.dither(1)=pngen(obj);
            end

            obj.tmpAcc(1)=obj.tmpAcc2+obj.dither;


            obj.phaseQuant(1)=obj.tmpAcc;


            tblIdx=int32(storedInteger(obj.phaseQuant));
            if(tblIdx<0)
                tblIdx=tblIdx+2^quantWL;
            end


            if reset
                obj.acc(1)=0;
            else
                if validIn
                    obj.acc(1)=obj.acc+obj.phaseInc;
                end
            end

        end

        function tblIdx=ncocore_frame(obj,reset)
            quantWL=obj.phaseQuant.WordLength;



            obj.tmpAcc2(:)=obj.acc+obj.phaseOffReg(1);

            obj.tmpAcc(:)=obj.tmpAcc2+obj.ditherReg(:,1);







            obj.phaseQuant(:)=obj.tmpAcc;

            tblIdx=uint32(storedInteger(obj.phaseQuant));
            if(tblIdx<0)
                tblIdx=tblIdx+2^quantWL;
            end

            if reset
                obj.acc(:)=0;
                obj.initAcc=true;
            else

                if obj.validReg(7)
                    if obj.initAcc
                        obj.acc(:)=obj.phaseIncReg(2,:);
                        obj.initAcc=false;
                    else
                        if obj.phaseIncV(2)==0
                            obj.acc(:)=obj.acc(end)+zeros(1,obj.SamplesPerFrame,'like',obj.phaseIncV);
                        else

                            tmp=zeros(1,obj.SamplesPerFrame,'like',obj.phaseIncV);
                            tmp(1)=obj.phaseIncV(2);
                            for loop=2:obj.SamplesPerFrame
                                tmp(loop)=tmp(loop-1)+obj.phaseIncV(2);
                            end
                            obj.acc(:)=obj.acc(end)+tmp;
                        end
                    end
                end
            end
        end

        function[sinV,cosV,tblIdx]=ncocore_float(obj,reset,validIn)
            quantWL=obj.pQuantWL;
            minIncr=(2*pi/2^quantWL);
            shft=obj.AccumulatorWL-quantWL;

            obj.tmpAcc2(1)=obj.acc+obj.phaseOff;

            if strcmp(obj.DitherSource,'Property')
                obj.dither=pngen(obj);
            end

            obj.tmpAcc=obj.tmpAcc2+obj.dither;


            obj.phaseQuant=mod(floor(obj.tmpAcc/(2^shft)),2^quantWL);
            tblIdx=double(obj.phaseQuant);
            if strcmpi(obj.OutputDataType,'double')
                sinV=sin(double(minIncr*obj.phaseQuant));
                cosV=cos(double(minIncr*obj.phaseQuant));
            else
                sinV=sin(single(minIncr*obj.phaseQuant));
                cosV=cos(single(minIncr*obj.phaseQuant));
            end


            if reset
                obj.acc(:)=0;
            else
                if validIn
                    obj.acc(:)=obj.acc+floor(obj.phaseInc);
                end
            end
        end

        function[sinV,cosV,tblIdx]=ncocore_float_frame(obj,reset)
            quantWL=obj.pQuantWL;
            minIncr=(2*pi/2^quantWL);
            shft=obj.AccumulatorWL-quantWL;

            obj.tmpAcc2(:)=obj.acc+obj.phaseOffReg(1);
            obj.tmpAcc(:)=obj.tmpAcc2+obj.ditherReg(:,1);



            obj.phaseQuant=mod(floor(obj.tmpAcc/(2^shft)),2^quantWL);
            tblIdx=double(obj.phaseQuant);
            if strcmpi(obj.OutputDataType,'double')
                sinV=sin(double(minIncr*obj.phaseQuant));
                cosV=cos(double(minIncr*obj.phaseQuant));
            else
                sinV=sin(single(minIncr*obj.phaseQuant));
                cosV=cos(single(minIncr*obj.phaseQuant));
            end


            if reset
                obj.acc(:)=0;
                obj.initAcc=true;
            else
                if obj.validReg(7)
                    if obj.initAcc
                        obj.acc(:)=obj.phaseIncReg(2,:);
                        obj.initAcc=false;
                    else
                        if obj.phaseIncV(2)==0
                            obj.acc(:)=obj.acc(end)+zeros(1,obj.SamplesPerFrame,'like',obj.phaseIncV);
                        else
                            obj.acc(:)=obj.acc(end)+floor([obj.phaseIncV(2):obj.phaseIncV(2):obj.SamplesPerFrame*obj.phaseIncV(2)]');
                        end
                    end
                end
            end
        end

        function pn_out=pngen(obj)



            numBits=double(obj.NumDitherBits);

            tpn_out=zeros(numBits,1);

            for k=1:numBits
                t1=xor(obj.pn_reg(19),obj.pn_reg(18));
                t2=xor(obj.pn_reg(15),obj.pn_reg(1));
                xor1=xor(t1,t2);

                tpn_out(k)=obj.pn_reg(1);
                obj.pn_reg=[obj.pn_reg(2:19);xor1];
            end
            pn_out=0;

            for m=1:numBits
                pn_out=pn_out+tpn_out(m)*2^(numBits-m);
            end
        end

        function pn_out=pngen_frame(obj)



            numBits=double(obj.NumDitherBits);
            tpn_out=zeros(numBits,1);
            pn_out=zeros(obj.SamplesPerFrame,1);
            for n=1:obj.SamplesPerFrame
                for k=1:numBits
                    t1=xor(obj.pn_reg(19),obj.pn_reg(18));
                    t2=xor(obj.pn_reg(15),obj.pn_reg(1));
                    xor1=xor(t1,t2);

                    tpn_out(k)=obj.pn_reg(1);
                    obj.pn_reg=[obj.pn_reg(2:19);xor1];
                end

                for m=1:numBits
                    pn_out(n,1)=pn_out(n,1)+tpn_out(m)*2^(numBits-m);%#ok<*EMGRO>
                end



            end
        end

    end

    methods(Access=public)
        function latency=getLatency(obj,varargin)
            if nargin>1
                NoOfSamples=varargin{1};
            else
                NoOfSamples=obj.SamplesPerFrame;
            end
            if NoOfSamples==1
                latency=6;
            else
                latency=9;
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
    end

end




























