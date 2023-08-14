classdef(StrictDefaults)FarrowRateConverter<matlab.System

































































































%#codegen

    properties(Nontunable)



        RateChangeSource='Property';
    end


    properties(Nontunable)


        RateChange=48/44.1;
    end


    properties(Nontunable)


        Coefficients=[-1/6,1/2,-1/3,0;1/2,-1,-1/2,1;-1/2,1/2,1,0;1/6,0,-1/6,0];
    end



    properties(Nontunable)



        FilterStructure='Direct form systolic';





        NumCycles=1;




        ResetInputPort(1,1)logical=false;



        HDLGlobalReset(1,1)logical=false;










        RoundingMethod='Floor';







        OverflowAction='Wrap';





        CoefficientsDataType='Same word length as input';












        RateChangeDataType=numerictype(0,16);







        MultiplicandDataType='Full precision';







        OutputDataType='Same as first input';

    end




    properties(Constant,Hidden)

        ShowFutureProperties=false;


        FilterStructureSet=matlab.system.StringSet({...
        'Direct form systolic',...
        'Direct form transposed'});



        RateChangeSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});




        RoundingMethodSet=matlab.system.internal.RoundingMethodSet({...
        'Ceiling',...
        'Convergent',...
        'Floor',...
        'Nearest',...
        'Round',...
        'Zero'});

        OverflowActionSet=matlab.system.internal.OverflowActionSet;

        CoefficientsDataTypeSet=matlab.system.internal.DataTypeSet(...
        {...
        'Same word length as input',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed','Unsigned'},...
        'Scaling',{'BinaryPoint','Unspecified'})...
        },...
        'ValuePropertyName','Coefficients',...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);

        OutputDataTypeSet=matlab.system.internal.DataTypeSet({...
        'Same as first input',...
        matlab.system.internal.CustomDataType('Signedness',{'Signed','Unsigned'})},...
        'HasDesignMinimum',false,...
        'HasDesignMaximum',false);










        RateChangeDataTypeSet=matlab.system.internal.DataTypeSet({...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed','Unsigned'},...
        'Scaling',{'BinaryPoint','Unspecified'})});

        MultiplicandDataTypeSet=matlab.system.internal.DataTypeSet({...
        'Full precision',...
        matlab.system.internal.CustomDataType(...
        'Signedness',{'Signed','Unsigned'},...
        'Scaling',{'BinaryPoint','Unspecified'})});

    end

    properties(Access=private)
        pDataRegister;
        pValidRegister;
        pReadyRegister;
        pHFarrow;
        pInputDT;
        pInputComplex;


    end

    methods(Static)

        function helpFixedPoint






            matlab.system.dispFixptHelp('dsphdl.FarrowRateConverter',...
            {'RoundingMethod','OverflowAction',...
            'CoefficientsDataType','RateChangeDataType','MultiplicandDataType','OutputDataType'});
        end

    end



    methods
        function obj=FarrowRateConverter(varargin)
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


        function set.RateChange(obj,val)
            validateattributes(val,{'double'},...
            {'scalar','>',0,'real'},'FarrowRateConverter','RateChange');
            obj.RateChange=val;
        end

        function set.Coefficients(obj,val)
            validateattributes(val,{'double'},{'finite','nonempty','2d','nonnan','real'},'FarrowRateConverter','Coefficients');
            obj.Coefficients=val;
        end


        function set.NumCycles(obj,value)




            validateattributes(value,...
            {'numeric'},...
            {'scalar','positive','integer'},...
            'FarrowRateConverter','NumCycles');






            obj.NumCycles=value;
        end

    end


    methods(Static,Access=protected)

        function header=getHeaderImpl


            header=matlab.system.display.Header('dsphdl.FarrowRateConverter',...
            'ShowSourceLink',false,...
            'Title','Farrow Rate Converter');
        end

        function groups=getPropertyGroupsImpl

            algorithmParameters=matlab.system.display.Section(...
            'Title','Filter parameters',...
            'PropertyList',{'RateChangeSource','RateChange','Coefficients','FilterStructure','NumCycles'});

            mainGroup=matlab.system.display.SectionGroup(mfilename('class'),...
            'TitleSource','Auto',...
            'Sections',algorithmParameters);

            rstPort=matlab.system.display.Section(...
            'Title','Data path register initialization',...
            'PropertyList',{'ResetInputPort','HDLGlobalReset',});

            ctrlGroup=matlab.system.display.SectionGroup(...
            'Title','Control Ports',...
            'Sections',rstPort);

            dtGroup=matlab.system.display.internal.DataTypesGroup(mfilename('class'));

            groups=[mainGroup,dtGroup,ctrlGroup];

        end
    end

    methods(Access=protected)

        function validatePropertiesImpl(obj)
            if size(obj.Coefficients,1)==1||size(obj.Coefficients,2)==1
                coder.internal.error('dsphdl:FarrowRateConverter:CoefficientsDim');
            end

            if size(obj.Coefficients,1)>6
                coder.internal.error('dsphdl:FarrowRateConverter:PolyOrder');
            end

            mulType=obj.MultiplicandDataType;
            if isnumerictype(mulType)
                if mulType.FractionLength>=mulType.WordLength||(mulType.FractionLength==0&&~strcmpi(mulType.DataTypeMode,'Fixed-point: unspecified scaling'))
                    coder.internal.error('dsphdl:FarrowRateConverter:MultiplicandWordlength');
                end

                if(~mulType.SignednessBool)
                    coder.internal.error('dsphdl:FarrowRateConverter:MultiplicandSigned');
                end
            end

            if strcmpi(obj.RateChangeSource,'Property')
                validateattributes(obj.RateChange,{'double'},{'scalar','>',0,'real'},'FarrowRateConverter','RateChange');
                fdType=obj.RateChangeDataType;

                if strcmpi(fdType.Signedness,'Signed')
                    coder.internal.warning('dsphdl:FarrowRateConverter:SignedDeprecated');
                end

                if isnumerictype(fdType)
                    if fdType.FractionLength>=fdType.WordLength||(fdType.FractionLength==0&&~strcmpi(fdType.DataTypeMode,'Fixed-point: unspecified scaling'))
                        coder.internal.error('dsphdl:FarrowRateConverter:RateChangeWordlength');
                    end

                end
            end

        end

        function validateInputsImpl(obj,varargin)


            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(varargin{1},{'single','double','embedded.fi','uint8','int8','uint16','int16','uint32','int32'},{'scalar'},'FarrowRateConverter','data');
                validateattributes(varargin{2},{'logical'},{'scalar'},'FarrowRateConverter','valid');

                num=3;
                if strcmpi(obj.RateChangeSource,'Input port')
                    validateattributes(varargin{num},{'embedded.fi'},{'scalar'},'FarrowRateConverter','rate');
                    if isfloat(varargin{num})||isfloat(varargin{1})


                        fdType=numerictype('double');
                        coder.internal.error('dsphdl:FarrowRateConverter:RateChangeInput');

                    else
                        fdType=numerictype(varargin{num});
                    end
                    if isnumerictype(fdType)
                        if fdType.FractionLength>=fdType.WordLength||fdType.FractionLength==0
                            coder.internal.error('dsphdl:FarrowRateConverter:RateChangeWordlength');
                        end

                        if strcmpi(fdType.Signedness,'Signed')
                            coder.internal.warning('dsphdl:FarrowRateConverter:SignedDeprecated');
                        end

                    end
                    num=num+1;
                end

                if obj.ResetInputPort
                    validateattributes(varargin{num},{'logical'},{'scalar'},'FarrowRateConverter','reset');
                end

            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok
            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end

        function setupImpl(obj,A,varargin)

            dataIn=A;
            obj.pInputComplex=coder.const(~isreal(dataIn));

            if~coder.target('hdl')
                if isempty(coder.target)||~eml_ambiguous_types



                    obj.pInputComplex=coder.const(~isreal(dataIn));

                    if strcmpi(obj.RateChangeSource,'Property')
                        rateType=obj.RateChangeDataType;
                    else
                        if isfloat(varargin{2})


                            rateType=numerictype('double');
                        else
                            rateType=numerictype(varargin{2});
                        end
                    end

                    if strcmpi(rateType.Signedness,'Unsigned')
                        if strcmpi(rateType.Scaling,'Unspecified')
                            fdType=numerictype(true,rateType.WordLength+1);
                        else
                            fdType=numerictype(true,rateType.WordLength+1,rateType.FractionLength);
                        end
                    else
                        fdType=rateType;
                    end


                    if strcmpi(obj.RateChangeSource,'Property')
                        HFarrow=dsphdl.private.AbstractFarrowFilter('Mode','Property','RateChange',obj.RateChange,...
                        'Numerator',obj.Coefficients,...
                        'FilterStructure',obj.FilterStructure,...
                        'NumCycles',obj.NumCycles,...
                        'ResetInputPort',obj.ResetInputPort,...
                        'HDLGlobalReset',obj.HDLGlobalReset,...
                        'RoundingMethod',obj.RoundingMethod,...
                        'OverflowAction',obj.OverflowAction,...
                        'CoefficientsDataType',obj.CoefficientsDataType,...
                        'FractionalDelayDataType',fdType,...
                        'MultiplicandDataType',obj.MultiplicandDataType,...
                        'OutputDataType',obj.OutputDataType);
                    else
                        HFarrow=dsphdl.private.AbstractFarrowFilter('Mode','Input port',...
                        'Numerator',obj.Coefficients,...
                        'FilterStructure',obj.FilterStructure,...
                        'NumCycles',obj.NumCycles,...
                        'ResetInputPort',obj.ResetInputPort,...
                        'HDLGlobalReset',obj.HDLGlobalReset,...
                        'RoundingMethod',obj.RoundingMethod,...
                        'OverflowAction',obj.OverflowAction,...
                        'CoefficientsDataType',obj.CoefficientsDataType,...
                        'FractionalDelayDataType',fdType,...
                        'MultiplicandDataType',obj.MultiplicandDataType,...
                        'OutputDataType',obj.OutputDataType);

                    end

                    HFarrow.isInMATLABSystemBlock=obj.isInMATLABSystemBlock;
                    obj.pHFarrow=HFarrow;

                    if obj.ResetInputPort
                        if strcmpi(obj.RateChangeSource,'Property')
                            setup(obj.pHFarrow,dataIn,false,false);
                            [dataOut,~,~]=output(obj.pHFarrow,dataIn,false,false);
                        else
                            setup(obj.pHFarrow,dataIn,false,varargin{2},false);
                            [dataOut,~,~]=output(obj.pHFarrow,dataIn,false,varargin{2},false);
                        end

                    else
                        if strcmpi(obj.RateChangeSource,'Property')
                            setup(obj.pHFarrow,dataIn,false);
                            [dataOut,~,~]=output(obj.pHFarrow,dataIn,false);
                        else
                            setup(obj.pHFarrow,dataIn,false,varargin{2});
                            [dataOut,~,~]=output(obj.pHFarrow,dataIn,false,varargin{2});
                        end
                    end

                    obj.pDataRegister=cast(0,'like',dataOut);
                    obj.pValidRegister=false;
                    obj.pReadyRegister=false;


                end
            else


                if strcmpi(obj.RateChangeSource,'Property')
                    fdType=obj.RateChangeDataType;
                else
                    if isfloat(varargin{2})


                        fdType=numerictype('double');
                    else
                        fdType=numerictype(varargin{2});
                    end
                end

                if strcmpi(obj.RateChangeSource,'Property')
                    HFarrow=dsphdl.private.AbstractFarrowFilter('Mode','Property','RateChange',obj.RateChange,...
                    'Numerator',obj.Coefficients,...
                    'FilterStructure',obj.FilterStructure,...
                    'NumCycles',obj.NumCycles,...
                    'ResetInputPort',obj.ResetInputPort,...
                    'HDLGlobalReset',obj.HDLGlobalReset,...
                    'RoundingMethod',obj.RoundingMethod,...
                    'OverflowAction',obj.OverflowAction,...
                    'CoefficientsDataType',obj.CoefficientsDataType,...
                    'FractionalDelayDataType',fdType,...
                    'MultiplicandDataType',obj.MultiplicandDataType,...
                    'OutputDataType',obj.OutputDataType);
                else
                    HFarrow=dsphdl.private.AbstractFarrowFilter('Mode','Input port',...
                    'Numerator',obj.Coefficients,...
                    'FilterStructure',obj.FilterStructure,...
                    'NumCycles',obj.NumCycles,...
                    'ResetInputPort',obj.ResetInputPort,...
                    'HDLGlobalReset',obj.HDLGlobalReset,...
                    'RoundingMethod',obj.RoundingMethod,...
                    'OverflowAction',obj.OverflowAction,...
                    'CoefficientsDataType',obj.CoefficientsDataType,...
                    'FractionalDelayDataType',fdType,...
                    'MultiplicandDataType',obj.MultiplicandDataType,...
                    'OutputDataType',obj.OutputDataType);

                    if~(isequal(varargin{2}.numerictype,fdType))
                        coder.internal.error('dsphdl:FarrowRateConverter:FractionalType');
                    end

                    if isa(A,'double')||isa(A,'single')
                        coder.internal.error('dsphdl:FarrowRateConverter:RateChangeInput');
                    end

                end

                HFarrow.isInMATLABSystemBlock=obj.isInMATLABSystemBlock;
                obj.pHFarrow=HFarrow;

                if strcmpi(obj.RateChangeSource,'Property')
                    fdType=obj.RateChangeDataType;
                    dataTypes=determineDataTypes(obj,dataIn,fdType,obj.pInputComplex);
                else
                    if isfloat(varargin{2})


                        fdType=numerictype('double');
                    else
                        fdType=numerictype(varargin{2});
                    end
                    dataTypes=determineDataTypes(obj,dataIn,fdType,obj.pInputComplex);
                end
                outDT=dataTypes.outDT;


                obj.pDataRegister=cast(0,'like',outDT);
                obj.pValidRegister=false;
                obj.pReadyRegister=false;


            end



        end


        function icon=getIconImpl(obj)

            icon=sprintf('Farrow Rate Converter');

        end

        function varargout=isInputDirectFeedthroughImpl(~,varargin)
            for ii=1:nargout
                varargout{ii}=false;
            end
        end


        function resetImpl(obj)
            if~coder.target('hdl')
                reset(obj.pHFarrow);
            end
        end




        function[varargout]=outputImpl(obj,varargin)
            if~coder.target('hdl')
                if obj.ResetInputPort

                    if strcmpi(obj.RateChangeSource,'Property')
                        [varargout{1},varargout{2},varargout{3}]=output(obj.pHFarrow,varargin{1},varargin{2},varargin{3});
                    else
                        [varargout{1},varargout{2},varargout{3}]=output(obj.pHFarrow,varargin{1},varargin{2},varargin{3},varargin{4});
                    end

                else
                    if strcmpi(obj.RateChangeSource,'Property')
                        [varargout{1},varargout{2},varargout{3}]=output(obj.pHFarrow,varargin{1},varargin{2});
                    else
                        [varargout{1},varargout{2},varargout{3}]=output(obj.pHFarrow,varargin{1},varargin{2},varargin{3});
                    end
                end
            else
                varargout{1}=obj.pDataRegister;
                varargout{2}=false;
                varargout{3}=false;

            end
        end



        function updateImpl(obj,varargin)
            if~coder.target('hdl')
                if obj.ResetInputPort
                    if strcmpi(obj.RateChangeSource,'Property')
                        update(obj.pHFarrow,varargin{1},varargin{2},varargin{3});
                    else
                        update(obj.pHFarrow,varargin{1},varargin{2},varargin{3},varargin{4});
                    end
                else
                    if strcmpi(obj.RateChangeSource,'Property')
                        update(obj.pHFarrow,varargin{1},varargin{2});
                    else
                        update(obj.pHFarrow,varargin{1},varargin{2},varargin{3});
                    end
                end
            end
        end

        function num=getNumInputsImpl(obj)

            num=2;

            if obj.ResetInputPort
                num=num+1;
            end

            if strcmpi(obj.RateChangeSource,'Input port')
                num=num+1;
            end

        end

        function N=getNumOutputsImpl(obj)

            N=3;
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,obj.getNumInputs());
            varargout{1}='data';
            varargout{2}='valid';
            num=2;

            if strcmpi(obj.RateChangeSource,'Input port')
                num=num+1;
                varargout{num}='rate';
            end





            if obj.ResetInputPort
                num=num+1;
                varargout{num}='reset';
            end






        end


        function varargout=getOutputNamesImpl(obj)
            varargout{1}='data';
            varargout{2}='valid';


            varargout{3}='ready';

        end

        function varargout=getOutputSizeImpl(obj)

            varargout=cell(1,nargout);
            for k=1:nargout-1
                varargout{k}=propagatedInputSize(obj,1);


            end
            varargout{end}=1;
        end



        function varargout=getOutputDataTypeImpl(obj,varargin)
            dt1=propagatedInputDataType(obj,1);
            dt1Cmplx=propagatedInputComplexity(obj,1);

            if(~isempty(dt1))
                if ischar(dt1)
                    inData=eval([dt1,'(0)']);
                else
                    inData=fi(0,dt1);
                end
            end









            if strcmpi(obj.RateChangeSource,'Property')
                fdType=obj.RateChangeDataType;
            else
                dt3=propagatedInputDataType(obj,3);
                if(~isempty(dt3))
                    if ischar(dt3)
                        fdType=eval([dt3,'(0)']);
                    else
                        fdType=numerictype(0,dt3.WordLength,dt3.FractionLength);
                    end
                end
            end
            if isempty(coder.target)||~eml_ambiguous_types
                dataTypes=determineDataTypes(obj,inData,fdType,dt1Cmplx);

            end


            if isfi(dataTypes.outDT)
                varargout{1}=dataTypes.outDT.numerictype();
            else
                varargout{1}=class(dataTypes.outDT);
            end

            varargout{2}='logical';
            varargout{3}='logical';


        end





        function varargout=isOutputComplexImpl(obj,varargin)

            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=false;
            varargout{3}=false;

        end



        function dataTypes=determineDataTypes(obj,dataInDT,RateChangeDT,inputComplex)

            fdType=RateChangeDT;
            mulType=obj.MultiplicandDataType;

            if isnumerictype(fdType)
                if fdType.FractionLength>=fdType.WordLength
                    coder.internal.error('dsphdl:FarrowRateConverter:RateChangeWordlength');
                end
            end

            if isnumerictype(mulType)
                if mulType.FractionLength>=mulType.WordLength
                    coder.internal.error('dsphdl:FarrowRateConverter:MultiplicandWordlength');
                end
            end

            [dataWL,dataFL,dataS]=dsphdlshared.hdlgetwordsizefromdata(dataInDT);



            outmath=fimath(...
            'OverflowAction',obj.OverflowAction,...
            'RoundingMethod',obj.RoundingMethod);

            mulDTInit=0;

            if ischar(RateChangeDT)
                fracDT=eval([RateChangeDT,'(0)']);
            else
                fracDT=fi(0,RateChangeDT);
            end

            [fracDelayWL,fracDelayFL,fracDelayS]=dsphdlshared.hdlgetwordsizefromdata(fracDT);



            if ischar(obj.MultiplicandDataType)
                multDT=fracDT;
            else
                multDT=fi(0,obj.MultiplicandDataType);
            end
            [multiplicandWL,multiplicandFL,multiplicandS]=dsphdlshared.hdlgetwordsizefromdata(multDT);





            if isa(dataInDT,'single')||isa(dataInDT,'double')
                multiplicandNT=numerictype(1,64,48);
                multiplicandDT=fi(mulDTInit,multiplicandNT,hdlfimath);
                fracDelayNT=numerictype(1,64,48);
                fracDelayDT=fi(mulDTInit,fracDelayNT,hdlfimath);
            else
                multiplicandNT=numerictype(multiplicandS,multiplicandWL,multiplicandFL);
                multiplicandDT=fi(mulDTInit,multiplicandNT,hdlfimath);
                fracDelayNT=numerictype(fracDelayS,fracDelayWL,fracDelayFL);
                fracDelayDT=fi(mulDTInit,fracDelayNT,hdlfimath);

            end










            outDTInit=cast(0,'like',dataInDT);
            if isnumerictype(obj.OutputDataType)

                [outputWL,outputFL,outputS]=dsphdlshared.hdlgetwordsizefromtype(obj.OutputDataType);
                outNT=numerictype(outputS,outputWL,outputFL);
            else
                if~(isa(dataInDT,'single')||isa(dataInDT,'double'))
                    [outputWL,outputFL,outputS]=dsphdlshared.hdlgetwordsizefromdata(dataInDT);
                    outNT=numerictype(outputS,outputWL,outputFL);
                end
            end

            if isa(dataInDT,'single')
                outDT=single(outDTInit);
                sumProdDT=single(outDTInit);
            elseif isa(dataInDT,'double')
                outDT=(outDTInit);
                sumProdDT=(outDTInit);
            else
                outDT=fi(outDTInit,outNT,outmath);
                sumProdNT=numerictype(outputS,outputWL,outputFL);
                sumProdDT=fi(outDTInit,sumProdNT,hdlfimath);
            end
            dataTypes=struct(...
            'sumProdDT',sumProdDT,...
            'fracDelayDT',fracDelayDT,...
            'multiplicandDT',multiplicandDT,...
            'outDT',outDT);

        end


        function DT=getInputDT(obj,data)%#ok<INUSL>
            if isnumerictype(data)
                DT=data;
            elseif isa(data,'embedded.fi')
                DT=numerictype(data);
            elseif isinteger(data)
                DT=numerictype(class(data));
            elseif ischar(data)
                DT=numerictype(data);
            else
                DT=numerictype('double');
            end
        end




        function varargout=isOutputFixedSizeImpl(obj)
            varargout{1}=true;
            varargout{2}=true;
            varargout{3}=true;

        end


        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.pHFarrow=obj.pHFarrow;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function flag=isInputComplexityMutableImpl(~,~)

            flag=true;
        end

        function hide=isInactivePropertyImpl(obj,prop)
            hide=false;
            switch prop
            case 'RateChange'
                if strcmpi(obj.RateChangeSource,'Input port')
                    hide=true;
                end
            case 'RateChangeDataType'
                if strcmpi(obj.RateChangeSource,'Input port')
                    hide=true;
                end
            case 'NumCycles'
                hide=~strcmp(obj.FilterStructure,'Direct form systolic');
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

