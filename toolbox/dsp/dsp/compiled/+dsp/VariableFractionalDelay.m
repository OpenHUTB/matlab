classdef VariableFractionalDelay<matlab.system.SFunSystem

















































































%#function mdspvdly2

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)












        InterpolationMethod='Linear';









        FilterHalfLength=4;





        FilterLength=4;







        InterpolationPointsPerSample=10;










        Bandwidth=1;






















        InitialConditions=0;





        MaximumDelay=100;








        FIRSmallDelayAction='Clip to the minimum value necessary for centered kernel';








        FarrowSmallDelayAction='Clip to the minimum value necessary for centered kernel';






        RoundingMethod='Zero';


        OverflowAction='Wrap';



        CoefficientsDataType='Same word length as input';







        CustomCoefficientsDataType=numerictype([],32);





        ProductPolynomialValueDataType='Same as first input';









        CustomProductPolynomialValueDataType=numerictype([],32,10);





        AccumulatorPolynomialValueDataType='Same as first input';









        CustomAccumulatorPolynomialValueDataType=numerictype([],32,10);





        MultiplicandPolynomialValueDataType='Same as first input';









        CustomMultiplicandPolynomialValueDataType=numerictype([],32,10);



        ProductDataType='Same as first input';







        CustomProductDataType=numerictype([],32,10);



        AccumulatorDataType='Same as product';







        CustomAccumulatorDataType=numerictype([],32,10);



        OutputDataType='Same as accumulator';







        CustomOutputDataType=numerictype([],32,10);
    end

    properties(Dependent,SetAccess=private,Hidden=true)
        MinimumDelay;
    end

    properties(Constant,Hidden)
        InterpolationMethodSet=matlab.system.StringSet({...
        'Linear',...
        'FIR',...
        'Farrow'});
        FIRSmallDelayActionSet=matlab.system.StringSet({...
        'Clip to the minimum value necessary for centered kernel',...
        'Switch to linear interpolation if kernel cannot be centered'});
        FarrowSmallDelayActionSet=matlab.system.StringSet({...
        'Clip to the minimum value necessary for centered kernel',...
        'Use off-centered kernel'});
        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        CoefficientsDataTypeSet=dsp.CommonSets.getSet('FixptModeUnscaled');
        ProductPolynomialValueDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
        AccumulatorPolynomialValueDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
        MultiplicandPolynomialValueDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeBasicFirst');
        AccumulatorDataTypeSet=dsp.CommonSets.getSet('FixptModeProdFirst');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeAccumFirst');
    end

    properties(Access=protected)
        pLockedArithmetic=[];
        pInputWordLength=16;
        pInputFractionLength=15;
        pFracDelayWordLength=16;
        pFracDelayFractionLength=15;
    end

    methods
        function obj=VariableFractionalDelay(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspvdly2');
            setProperties(obj,nargin,varargin{:});
            setFrameStatus(obj,true);
            setEmptyAllowedStatus(obj,true);
        end

        function d=get.MinimumDelay(obj)
            switch obj.InterpolationMethod
            case 'Linear'
                d=0;
            case 'FIR'
                if strcmp(obj.FIRSmallDelayAction,...
                    'Switch to linear interpolation if kernel cannot be centered')
                    d=0;
                else
                    d=obj.FilterHalfLength-1;
                end
            case 'Farrow'
                if strcmp(obj.FarrowSmallDelayAction,'Use off-centered kernel')
                    d=0;
                else
                    d=floor(obj.FilterLength/2)-1;
                end
            otherwise
                d=0;
            end
        end

        function set.MaximumDelay(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','integer','scalar','<=',65535},...
            '','MaximumDelay');

            coder.internal.errorIf(val<obj.MinimumDelay,'dsp:system:maxDelayLEMinDelay');%#ok
            coder.internal.warningIf(val<=obj.MinimumDelay,'dsp:system:maxDelayLEMinDelay');%#ok

            obj.MaximumDelay=val;
        end

        function set.InterpolationMethod(obj,method)
            obj.InterpolationMethod=method;
            coder.internal.warningIf(obj.MaximumDelay<=obj.MinimumDelay,'dsp:system:maxDelayLEMinDelay');%#ok
        end

        function set.FilterHalfLength(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','integer','scalar','<=',65535,'>=',1},...
            '','FilterHalfLength');
            obj.FilterHalfLength=val;
            coder.internal.warningIf(obj.MaximumDelay<=obj.MinimumDelay,'dsp:system:maxDelayLEMinDelay');%#ok
        end

        function set.FilterLength(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','integer','scalar','>=',2},...
            '','FilterLength');
            obj.FilterLength=val;
            coder.internal.warningIf(obj.MaximumDelay<=obj.MinimumDelay,'dsp:system:maxDelayLEMinDelay');%#ok
        end

        function set.InterpolationPointsPerSample(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','integer','scalar','>=',2,'<=',65535},...
            '','InterpolationPointsPerSample');
            obj.InterpolationPointsPerSample=val;
            coder.internal.warningIf(obj.MaximumDelay<=obj.MinimumDelay,'dsp:system:maxDelayLEMinDelay');%#ok
        end

        function set.Bandwidth(obj,val)
            validateattributes(val,{'numeric'},...
            {'positive','scalar','<=',1},...
            '','Bandwidth');
            obj.Bandwidth=val;
        end

        function set.InitialConditions(obj,val)
            validateattributes(val,{'numeric'},...
            {'3d'},...
            '','InitialConditions');
            obj.InitialConditions=val;
        end

        function set.CustomCoefficientsDataType(obj,val)
            validateCustomDataType(obj,'CustomCoefficientsDataType',val,...
            {'AUTOSIGNED','NOTSCALED'});
            obj.CustomCoefficientsDataType=val;
        end

        function set.CustomProductPolynomialValueDataType(obj,val)
            validateCustomDataType(obj,'CustomProductPolynomialValueDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductPolynomialValueDataType=val;
        end

        function set.CustomAccumulatorPolynomialValueDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorPolynomialValueDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorPolynomialValueDataType=val;
        end

        function set.CustomMultiplicandPolynomialValueDataType(obj,val)
            validateCustomDataType(obj,'CustomMultiplicandPolynomialValueDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomMultiplicandPolynomialValueDataType=val;
        end

        function set.CustomAccumulatorDataType(obj,val)
            validateCustomDataType(obj,'CustomAccumulatorDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomAccumulatorDataType=val;
        end

        function set.CustomProductDataType(obj,val)
            validateCustomDataType(obj,'CustomProductDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomProductDataType=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','SCALED'});
            obj.CustomOutputDataType=val;
        end

        function fdhdltool(obj,InputNumericType,FracDelayNumericType)


























            if~exist('InputNumericType','var')
                error(message('hdlfilter:privgeneratehdl:fdhdltoolinputdatatypenotspecified'));
            end

            if~exist('FracDelayNumericType','var')
                error(message('hdlfilter:privgeneratehdl:fdhdltoolfracdeldatatypenotspecified'));
            end

            dobj=sysobjHdl(obj,'InputDataType',InputNumericType,'FractionalDelayDataType',FracDelayNumericType);
            if~isempty(dobj)
                fdhdltool(dobj,'InputDataType',InputNumericType,'FractionalDelayDataType',FracDelayNumericType);
            else
                error(message('hdlfilter:generatehdl:VarFrcDlyFIRInterpModeNotSupported'));
            end
        end

        function generatehdl(obj,varargin)



















            for k=1:length(varargin)
                if iscell(varargin{k})
                    [varargin{k}{:}]=convertStringsToChars(varargin{k}{:});
                else
                    varargin{k}=convertStringsToChars(varargin{k});
                end
            end

            dobj=sysobjHdl(obj,varargin{:});
            if~isempty(dobj)
                generatehdl(dobj,varargin{:},'FilterSystemObject',clone(obj));
            else
                error(message('hdlfilter:generatehdl:VarFrcDlyFIRInterpModeNotSupported'));
            end
        end
    end

    methods(Hidden,Access=public)
        function dtInfo=getFixedPointInfo(obj)
            dtInfo=getFixptDataTypeInfo(obj,...
            {'Coefficients','ProductPolynomialValue','AccumulatorPolynomialValue',...
            'MultiplicandPolynomialValue','Product','Accumulator','Output'});
        end

        function dobj=sysobjHdl(obj,varargin)
            t=builtin('license','test','Filter_Design_HDL_Coder')&&~isempty(ver('hdlfilter'));
            if~t
                error(message('dsp:dsp:private:FilterSystemObjectBase:HDLnolicenseavailable'));
            end

            indices=strcmpi(varargin,'inputdatatype');
            pos=1:length(indices);
            pos=pos(indices);
            if isempty(pos)
                error(message('hdlfilter:privgeneratehdl:inputdatatypenotspecified'));
            end
            inputnumerictype=varargin{pos+1};
            if~strcmpi(class(inputnumerictype),'embedded.numerictype')
                error(message('hdlfilter:privgeneratehdl:incorrectinputdatatype'));
            end

            indices=strcmpi(varargin,'fractionaldelaydatatype');
            pos=1:length(indices);
            pos=pos(indices);
            if isempty(pos)
                error(message('hdlfilter:privgeneratehdl:fracdelaydatatypenotspecified'));
            end
            fracdelaynumerictype=varargin{pos+1};
            if~strcmpi(class(fracdelaynumerictype),'embedded.numerictype')
                error(message('hdlfilter:privgeneratehdl:incorrectfracdelaydatatype'));
            end

            d=inputnumerictype.DataTypeMode;

            if strcmpi(d,'double')
                arith='double';
            elseif strcmpi(d,'single')
                arith='single';
            elseif strcmpi(d,'Fixed-point: binary point scaling')
                s=inputnumerictype.Signedness;
                if strcmpi(s,'Signed')
                    arith='fixed';
                else
                    error(message('dsp:dsp:private:FilterSystemObjectBase:HDLNotSupportedDataType'));
                end
            else
                error(message('dsp:dsp:private:FilterSystemObjectBase:HDLNotSupportedDataType'));
            end

            ipval=fi(0,inputnumerictype);
            fdval=fi(0,fracdelaynumerictype);
            cobj=clone(obj);
            release(cobj);
            step(cobj,ipval,fdval);
            dobj=todfilt(cobj,arith,ipval,fdval);
        end

        function d=todfilt(obj,arith,ipval,fdval)

            if strcmp(obj.InterpolationMethod,'FIR')
                d=[];
            else

                if strcmp(obj.InterpolationMethod,'Linear')
                    d=dfilt.farrowlinearfd;
                else
                    d=dfilt.farrowfd;
                end


                if nargin<2

                    if isLocked(obj)&&~isempty(obj.pLockedArithmetic)
                        arith=obj.pLockedArithmetic;
                    else
                        arith='double';
                    end
                elseif isempty(arith)

                    if nargin>2&&~isempty(class(ipval))

                        if isfloat(ipval)
                            arith=class(ipval);
                        else
                            arith='fixed';
                        end
                    elseif isLocked(obj)&&~isempty(obj.pLockedArithmetic)
                        arith=obj.pLockedArithmetic;
                    else
                        arith='double';
                    end
                end

                d.arith=arith;

                if strcmpi(arith,'fixed')
                    if nargin>2&&~isempty(ipval)
                        d.InputWordLength=ipval.WordLength;
                        d.InputFracLength=ipval.FractionLength;
                    elseif isLocked(obj)&&~isempty(obj.pLockedArithmetic)
                        d.InputWordLength=obj.pInputWordLength;
                        d.InputFracLength=obj.pInputFractionLength;
                    end

                    if nargin>3&&~isempty(fdval)
                        d.FDAutoScale=false;
                        d.FDWordLength=fdval.WordLength;
                        d.FDFracLength=fdval.FractionLength;
                    elseif isLocked(obj)&&~isempty(obj.pLockedArithmetic)
                        d.FDAutoScale=false;
                        d.FDWordLength=obj.pFracDelayWordLength;
                        d.FDFracLength=obj.pFracDelayFractionLength;
                    end

                    d.FilterInternals='SpecifyPrecision';
                    d.OverflowMode=obj.OverflowAction;

                    switch obj.RoundingMethod
                    case 'Ceiling'
                        d.RoundMode='ceil';
                    case 'Convergent'
                        d.RoundMode='convergent';
                    case{'Floor','Simplest'}
                        d.RoundMode='floor';
                    case 'Nearest'
                        d.RoundMode='nearest';
                    case 'Round'
                        d.RoundMode='round';
                    case 'Zero'
                        d.RoundMode='fix';
                    end

                    if isLocked(obj)
                        dStrc=getCompiledFixedPointInfo(obj);
                        cffNT=dStrc.CoefficientsDataType;%#ok
                        ppvNT=dStrc.ProductPolynomialValueDataType;
                        apvNT=dStrc.AccumulatorPolynomialValueDataType;
                        mpvNT=dStrc.MultiplicandPolynomialValueDataType;
                        prdNT=dStrc.ProductDataType;
                        accNT=dStrc.AccumulatorDataType;
                        outNT=dStrc.OutputDataType;

                        d.OutputWordLength=outNT.WordLength;
                        d.OutputFracLength=outNT.FractionLength;
                        d.ProductWordLength=ppvNT.WordLength;
                        d.ProductFracLength=ppvNT.FractionLength;
                        d.AccumWordLength=max(accNT.WordLength,apvNT.WordLength);
                        d.AccumFracLength=min(accNT.FractionLength,apvNT.FractionLength);

                        if strcmp(obj.InterpolationMethod,'Farrow')
                            d.MultiplicandWordLength=mpvNT.WordLength;
                            d.MultiplicandFracLength=mpvNT.FractionLength;
                            d.FDProdWordLength=prdNT.WordLength;
                            d.FDProdFracLength=prdNT.FractionLength;
                        end
                    end
                end
            end

        end

    end

    methods(Access=protected)
        function cacheFracDelayFixPtInfo(obj,frdlyData)
            frdlyDataClass=lower(class(frdlyData));
            switch frdlyDataClass
            case{'int8','int16','int32','int64',...
                'uint8','uint16','uint32','uint64'}
                nt=numerictype(frdlyDataClass);

                obj.pFracDelayWordLength=nt.WordLength;
                obj.pFracDelayFractionLength=nt.FractionLength;

            case 'embedded.fi'
                nt=numerictype(frdlyData);

                obj.pFracDelayWordLength=nt.WordLength;
                obj.pFracDelayFractionLength=nt.FractionLength;
            end
        end

        function cacheInputDataTypes(obj,inputData,frdlyData)
            inputDataClass=lower(class(inputData));
            switch inputDataClass
            case{'double','single'}
                obj.pLockedArithmetic=inputDataClass;

            case{'int8','int16','int32','int64',...
                'uint8','uint16','uint32','uint64'}
                nt=numerictype(inputDataClass);
                obj.pLockedArithmetic='fixed';

                obj.pInputWordLength=nt.WordLength;
                obj.pInputFractionLength=nt.FractionLength;

            case 'embedded.fi'
                nt=numerictype(inputData);
                obj.pLockedArithmetic='fixed';

                obj.pInputWordLength=nt.WordLength;
                obj.pInputFractionLength=nt.FractionLength;
            end

            if~isempty(frdlyData)&&strcmp(obj.pLockedArithmetic,'fixed')
                cacheFracDelayFixPtInfo(obj,frdlyData);
            end
        end

        function validateInputsImpl(obj,varargin)

            if(nargin>2)
                cacheInputDataTypes(obj,varargin{1},varargin{2});
            elseif(nargin>1)
                cacheInputDataTypes(obj,varargin{1},[]);
            end
        end

        function s=infoImpl(obj)










            minval=obj.MinimumDelay;
            minvalstr=num2str(minval);
            maxvalstr=num2str(obj.MaximumDelay);
            s.ValidDelayRange=sprintf('[%s, %s]',minvalstr,maxvalstr);
        end
    end

    methods(Hidden)
        function setParameters(obj)
            InterpolationMethodIdx=getIndex(...
            obj.InterpolationMethodSet,obj.InterpolationMethod);
            FIRSmallDelayActionIdx=getIndex(...
            obj.FIRSmallDelayActionSet,obj.FIRSmallDelayAction);
            FarrowSmallDelayActionIdx=getIndex(...
            obj.FarrowSmallDelayActionSet,obj.FarrowSmallDelayAction);

            if InterpolationMethodIdx==3
                b=dspblkvfdly2(obj,InterpolationMethodIdx,obj.FilterLength);
            else
                b=dspblkvfdly2(obj,InterpolationMethodIdx,...
                obj.InterpolationPointsPerSample,obj.FilterHalfLength,...
                obj.Bandwidth);
            end
            InputProcessing=1;

            if isSizesOnlyCall(obj)
                obj.compSetParameters({...
                InterpolationMethodIdx,...
                obj.MaximumDelay,...
                InputProcessing,...
                b,...
                obj.InitialConditions,...
                obj.FilterHalfLength,...
                obj.FilterLength,...
                obj.InterpolationPointsPerSample,...
                obj.Bandwidth,...
                FIRSmallDelayActionIdx,...
                FarrowSmallDelayActionIdx,...
                double(false),...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
                2,...
1...
                });
            else
                dtInfo=getFixptDataTypeInfo(obj,...
                {'Coefficients','ProductPolynomialValue','AccumulatorPolynomialValue',...
                'MultiplicandPolynomialValue','Product','Accumulator','Output'});

                obj.compSetParameters({...
                InterpolationMethodIdx,...
                obj.MaximumDelay,...
                InputProcessing,...
                b,...
                obj.InitialConditions,...
                obj.FilterHalfLength,...
                obj.FilterLength,...
                obj.InterpolationPointsPerSample,...
                obj.Bandwidth,...
                FIRSmallDelayActionIdx,...
                FarrowSmallDelayActionIdx,...
                double(false),...
                dtInfo.CoefficientsDataType,...
                dtInfo.CoefficientsWordLength,...
                dtInfo.CoefficientsFracLength,...
                dtInfo.AccumulatorPolynomialValueDataType,...
                dtInfo.AccumulatorPolynomialValueWordLength,...
                dtInfo.AccumulatorPolynomialValueFracLength,...
                dtInfo.ProductPolynomialValueDataType,...
                dtInfo.ProductPolynomialValueWordLength,...
                dtInfo.ProductPolynomialValueFracLength,...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.AccumulatorDataType,...
                dtInfo.AccumulatorWordLength,...
                dtInfo.AccumulatorFracLength,...
                dtInfo.MultiplicandPolynomialValueDataType,...
                dtInfo.MultiplicandPolynomialValueWordLength,...
                dtInfo.MultiplicandPolynomialValueFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
        function y=supportsUnboundedIO(~)
            y=true;
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case{'FilterHalfLength','InterpolationPointsPerSample',...
                'Bandwidth','FIRSmallDelayAction'}
                if strcmp(obj.InterpolationMethod,'Linear')||...
                    strcmp(obj.InterpolationMethod,'Farrow')
                    flag=true;
                end
            case{'FilterLength','FarrowSmallDelayAction'...
                ,'ProductPolynomialValueDataType','AccumulatorPolynomialValueDataType',...
                'MultiplicandPolynomialValueDataType'}
                if strcmp(obj.InterpolationMethod,'Linear')||...
                    strcmp(obj.InterpolationMethod,'FIR')
                    flag=true;
                end
            case 'CustomProductPolynomialValueDataType'
                if strcmp(obj.InterpolationMethod,'Linear')||...
                    strcmp(obj.InterpolationMethod,'FIR')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.ProductPolynomialValueDataType)
                    flag=true;
                end
            case 'CustomAccumulatorPolynomialValueDataType'
                if strcmp(obj.InterpolationMethod,'Linear')||...
                    strcmp(obj.InterpolationMethod,'FIR')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.AccumulatorPolynomialValueDataType)
                    flag=true;
                end
            case 'CustomMultiplicandPolynomialValueDataType'
                if strcmp(obj.InterpolationMethod,'Linear')||...
                    strcmp(obj.InterpolationMethod,'FIR')||...
                    ~matlab.system.isSpecifiedTypeMode(obj.MultiplicandPolynomialValueDataType)
                    flag=true;
                end
            case 'CustomCoefficientsDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.CoefficientsDataType)
                    flag=true;
                end
            case 'CustomProductDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.ProductDataType)
                    flag=true;
                end
            case 'CustomAccumulatorDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.AccumulatorDataType)
                    flag=true;
                end
            case 'CustomOutputDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end

            end
        end

        function loadObjectImpl(obj,s,~)
            loadObjectImpl@matlab.system.SFunSystem(obj,s);
        end
    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.VariableFractionalDelay',...
            dsp.VariableFractionalDelay.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsigops/Variable Fractional Delay';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'InterpolationMethod'...
            ,'FilterHalfLength'...
            ,'FilterLength',...
'InterpolationPointsPerSample'...
            ,'Bandwidth'...
            ,'InitialConditions'...
            ,'MaximumDelay'...
            ,'FIRSmallDelayAction',...
            'FarrowSmallDelayAction',...
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={'RoundingMethod',...
            'OverflowAction',...
            'CoefficientsDataType',...
            'CustomCoefficientsDataType',...
            'ProductPolynomialValueDataType',...
            'CustomProductPolynomialValueDataType',...
            'AccumulatorPolynomialValueDataType',...
            'CustomAccumulatorPolynomialValueDataType',...
            'MultiplicandPolynomialValueDataType',...
            'CustomMultiplicandPolynomialValueDataType',...
            'ProductDataType',...
            'CustomProductDataType',...
            'AccumulatorDataType',...
            'CustomAccumulatorDataType',...
            'OutputDataType',...
            'CustomOutputDataType'};
        end

        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end
