





classdef MathFunctionGenerator<handle
    properties
        UserInterp='';
        CustomFcn=[];
        Param=[];
        CandidateFunctionName='';
        Generator=[];
    end

    properties(Constant,GetAccess=public,Hidden)
        INTERP_ZERO='No Interpolation (degree-0)';
        INTERP_ONE='Linear (degree-1 Polynomial)';
        INTERP_TWO='Quadratic (degree-2 Polynomial)';
        INTERP_THREE='Cubic (degree-3 Polynomial)';
    end

    properties(Constant,GetAccess=public,Hidden)
        SupportedFcnList={'acos','acosd','acosh','acoth','asin','asind','asinh','atan','atan2',...
        'atand','atanh','besselj','cos','cosd','cosh','divide','erf','erfc','exp','invlog','log','log_base','normcdf',...
        'polyval','pow','reallog','realsqrt','reciprocal','rsqrt','sin','sinc','sind','sinh','sqrt','tan','tand','VectorMagnitude','Use my own, custom function'};
        SupportedTwoInputFcn={'divide','atan2','VectorMagnitude'};
        Supported4CORDIC={'acos','asin','atan','cos','cosh','divide','exp','invlog','log','log_base','reciprocal','sin','sinh','sqrt','VectorMagnitude'};
        ParameterizedFunctions=coder.internal.mathfcngenerator.MathFunctionGenerator.getParameterizedFunctions();

        SupportedInterpList={coder.internal.mathfcngenerator.MathFunctionGenerator.INTERP_ZERO,...
        coder.internal.mathfcngenerator.MathFunctionGenerator.INTERP_ONE,...
        coder.internal.mathfcngenerator.MathFunctionGenerator.INTERP_TWO,...
        coder.internal.mathfcngenerator.MathFunctionGenerator.INTERP_THREE
        };
    end

    methods(Static)
        function flag=isParameterizedFunction(functionName)
            supported=coder.internal.mathfcngenerator.MathFunctionGenerator.ParameterizedFunctions;
            flag=any(strcmpi(supported.keys(),functionName));
        end

        function flag=isTwoInputFunction(functionName)
            supported=coder.internal.mathfcngenerator.MathFunctionGenerator.SupportedTwoInputFcn;
            flag=any(strcmpi(supported,functionName));
        end

        function flag=isSupportedFunction(functionName)
            supported=coder.internal.mathfcngenerator.MathFunctionGenerator.SupportedFcnList;
            flag=any(strcmpi(supported,functionName));
        end

        function flag=isSupported4CORDIC(functionName)
            supported=coder.internal.mathfcngenerator.MathFunctionGenerator.Supported4CORDIC;
            flag=any(strcmpi(supported,functionName));
        end
    end


    properties(Hidden)
SupportedArch
        UICustomFcnName='Use my own, custom function';
    end

    methods
        function obj=MathFunctionGenerator(varargin)
            obj.SupportedArch=coder.internal.mathfcngenerator.MathFunctionGenerator.getSupportedArch();
            for itr=1:2:nargin
                obj.(varargin{itr})=varargin{itr+1};
            end
        end


        function flag=isSupportedInterpMode(obj)
            assert(~isempty(obj.UserInterp))
            flag=any(strcmpi(obj.SupportedInterpList,obj.UserInterp));
        end

        function interpDegree=getInterpDegree(obj)
            assert(~isempty(obj.UserInterp))
            interpDegree=[];
            tmp=strcmpi(obj.SupportedInterpList,obj.UserInterp);
            if(~isempty(tmp))
                interpDegree=find(tmp)-1;
            end
            assert(interpDegree>=0&&interpDegree<=3);
        end

        function fcnObj=getGeneratorObject(obj,cfgObj)
            if nargin<2
                cfgObj=[];
            end

            if(~isempty(obj.Generator))
                fcnObj=obj.Generator;
            else
                if(isa(cfgObj,'coder.mathfcngenerator.Flat'))
                    obj.Generator=coder.internal.mathfcngenerator.HDLFlat();
                    fcnObj=obj.Generator;
                else
                    fcnObj=obj.createGeneratorObject();
                end
            end
        end

        function fcnObj=createGeneratorObject(obj,archGUIName)
            if(nargin<2)
                arch='UniformInterpolation';
            else
                arch=obj.SupportedArch(archGUIName);
            end

            assert(~isempty(obj.CandidateFunctionName))
            switch obj.CandidateFunctionName
            case 'acos'
                fcnObj=coder.internal.mathfcngenerator.HDLAcos();
            case 'acosd'
                fcnObj=coder.internal.mathfcngenerator.HDLAcosd();
            case 'acosh'
                fcnObj=coder.internal.mathfcngenerator.HDLAcosh();
            case 'acot'
                fcnObj=coder.internal.mathfcngenerator.HDLAcot();
            case 'acotd'
                fcnObj=coder.internal.mathfcngenerator.HDLAcotd();
            case 'acoth'
                fcnObj=coder.internal.mathfcngenerator.HDLAcoth();
            case 'acsc'
                fcnObj=coder.internal.mathfcngenerator.HDLAcsc();
            case 'acscd'
                fcnObj=coder.internal.mathfcngenerator.HDLAcscd();
            case 'acsch'
                fcnObj=coder.internal.mathfcngenerator.HDLAcsch();
            case 'angle'
                fcnObj=coder.internal.mathfcngenerator.HDLAngle();
            case 'asec'
                fcnObj=coder.internal.mathfcngenerator.HDLAsec();
            case 'asecd'
                fcnObj=coder.internal.mathfcngenerator.HDLAsecd();
            case 'asech'
                fcnObj=coder.internal.mathfcngenerator.HDLAsech();
            case 'asin'
                fcnObj=coder.internal.mathfcngenerator.HDLAsin();
            case 'asind'
                fcnObj=coder.internal.mathfcngenerator.HDLAsind();
            case 'asinh'
                fcnObj=coder.internal.mathfcngenerator.HDLAsinh();
            case 'atan2'
                fcnObj=coder.internal.mathfcngenerator.HDLAtan2();
            case 'atan'
                fcnObj=coder.internal.mathfcngenerator.HDLAtan();
            case 'atand'
                fcnObj=coder.internal.mathfcngenerator.HDLAtand();
            case 'atanh'
                fcnObj=coder.internal.mathfcngenerator.HDLAtanh();
            case 'besselj'
                fcnObj=coder.internal.mathfcngenerator.HDLBesselj('Order',obj.Param);
            case 'compan'
                fcnObj=coder.internal.mathfcngenerator.HDLCompan();
            case 'cos'
                fcnObj=coder.internal.mathfcngenerator.HDLCos();
            case 'cosd'
                fcnObj=coder.internal.mathfcngenerator.HDLCosd();
            case 'cosh'
                fcnObj=coder.internal.mathfcngenerator.HDLCosh();
















            case 'divide'
                fcnObj=coder.internal.mathfcngenerator.HDLDivide();
            case 'VectorMagnitude'
                fcnObj=coder.internal.mathfcngenerator.HDLVectormagnitude();
            case 'erf'
                fcnObj=coder.internal.mathfcngenerator.HDLErf();
            case 'erfc'
                fcnObj=coder.internal.mathfcngenerator.HDLErfc();






            case 'exp'
                fcnObj=coder.internal.mathfcngenerator.HDLExp();


            case 'invlog'
                fcnObj=coder.internal.mathfcngenerator.HDLInvlog('Base',obj.Param);
            case 'log'
                fcnObj=coder.internal.mathfcngenerator.HDLLog();
            case 'log_base'
                fcnObj=coder.internal.mathfcngenerator.HDLLog_base('Base',obj.Param);
















            case 'normcdf'
                fcnObj=coder.internal.mathfcngenerator.HDLNormcdf();
            case 'polyval'
                fcnObj=coder.internal.mathfcngenerator.HDLPolyval('Coefficients',obj.Param);
            case 'pow'
                fcnObj=coder.internal.mathfcngenerator.HDLPow('Power',obj.Param);
            case 'reallog'
                fcnObj=coder.internal.mathfcngenerator.HDLLog();
            case{'realsqrt','sqrt'}
                fcnObj=coder.internal.mathfcngenerator.HDLSqrt();
            case{'rsqrt'}
                fcnObj=coder.internal.mathfcngenerator.HDLRsqrt();
            case 'reciprocal'
                fcnObj=coder.internal.mathfcngenerator.HDLReciprocal();








            case 'sin'
                fcnObj=coder.internal.mathfcngenerator.HDLSin();
            case 'sinc'
                fcnObj=coder.internal.mathfcngenerator.HDLSinc();
            case 'sind'
                fcnObj=coder.internal.mathfcngenerator.HDLSind();


            case 'sinh'
                fcnObj=coder.internal.mathfcngenerator.HDLSinh();
            case 'tan'
                fcnObj=coder.internal.mathfcngenerator.HDLTan();
            case 'tand'
                fcnObj=coder.internal.mathfcngenerator.HDLTand();


            otherwise

                fcnObj=coder.internal.mathfcngenerator.HDLLookupTable();



                fcnObj.CandidateFunction=obj.CustomFcn;


            end

            fcnObj.InterpolationDegree=obj.getInterpDegree();

            fcnObj.Mode=arch;
            fcnObj.InputExtents=fcnObj.DefaultRange;
            obj.Generator=fcnObj;
        end
    end

    methods(Static,Access=public)
        function msg=getAboutMsg()
            persistent aboutMsg
            if(isempty(aboutMsg))
                aboutMsg=['Use this application with Simulink, or MATLAB coder products, to generate a MATLAB function suitable for embedded-target or HDL synthesis, via Coder products.'...
                ,'(C) 2013 The Mathworks, Inc.'];
            end
            msg=aboutMsg;
        end

        function paramFcns=getParameterizedFunctions()
            paramFcns=containers.Map();
            paramFcns('log_base')={'Base',10};
            paramFcns('invlog')={'Base',10};
            paramFcns('polyval')={'Coefficients',[1,2,1]};
            paramFcns('pow')={'Power',2};
            paramFcns('besselj')={'Order',0};
            return
        end

        function welcomeMsg=getWelcomeMsg()
            welcomeMsg=['Use this application with Simulink, or MATLAB coder,',char(10),...
            'to generate a MATLAB function suitable',char(10),...
            'for embedded-target or HDL synthesis,',char(10),...
            char(10),...
            'This message will disappear when you hit ''Generate''',char(10),char(10),...
            'via Coder products.',char(10),'(C) 2013 The Mathworks, Inc.'];
        end


        function export2SL(fcn_name,code_str)
            coder.internal.mathfcngenerator.EMLBlockGenerator.generate(fcn_name,code_str);
        end


        function archs=getSupportedArch()
            archs=containers.Map();
            archs('CORDIC/Shift-Add')='ShiftAndAdd';
            archs('Lookup Table')='UniformInterpolation';
        end
    end

end
