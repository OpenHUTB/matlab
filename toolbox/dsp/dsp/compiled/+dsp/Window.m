classdef(TunablesDetermineInactiveStatus)Window<matlab.system.SFunSystem


























































%#function mdspwindow2
%#function dspblkwinfcn2get
%#function dspblkwinfcn2getPrecisionHelper

%#ok<*EMCLS>
%#ok<*EMCA>

    properties





        WindowFunction='Hamming';





        StopbandAttenuation=50;






        Beta=10;





        NumConstantSidelobes=4;






        MaximumSidelobeLevel=-30;





        Sampling='Symmetric';
    end

    properties(Nontunable)






        RoundingMethod='Floor';




        OverflowAction='Wrap';





        WindowDataType='Same word length as input';







        CustomWindowDataType=numerictype([],16,15);






        ProductDataType='Full precision';








        CustomProductDataType=numerictype([],16,15);






        OutputDataType='Same as product';








        CustomOutputDataType=numerictype([],16,15);





        WeightsOutputPort(1,1)logical=false;












        FullPrecisionOverride(1,1)logical=true;
    end

    properties(Constant,Hidden)
        WindowFunctionSet=matlab.system.StringSet({...
        'Bartlett','Blackman','Boxcar','Chebyshev',...
        'Hamming','Hann','Hanning','Kaiser',...
        'Taylor','Triang'});
        SamplingSet=matlab.system.StringSet({'Symmetric','Periodic'});


        RoundingMethodSet=dsp.CommonSets.getSet('RoundingMethod');
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        WindowDataTypeSet=dsp.CommonSets.getSet('FixptModeEitherScale');
        ProductDataTypeSet=dsp.CommonSets.getSet('FixptModeInherit');
        OutputDataTypeSet=dsp.CommonSets.getSet('FixptModeProd');
    end

    methods

        function obj=Window(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:Window_NotSupported');
            obj@matlab.system.SFunSystem('mdspwindow2');
            setProperties(obj,nargin,varargin{:},'WindowFunction');
            setVarSizeAllowedStatus(obj,false);
        end

        function set.CustomWindowDataType(obj,val)
            validateCustomDataType(obj,'CustomWindowDataType',val,...
            {'AUTOSIGNED'});
            obj.CustomWindowDataType=val;
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

    end

    methods(Hidden)
        function setParameters(obj)

            OperationSet=matlab.system.StringSet({...
            'Apply window to input',...
            'Generate window',...
            'Generate and apply window'});
            if obj.WeightsOutputPort
                Operation='Generate and apply window';
            else
                Operation='Apply window to input';
            end
            OperationIdx=getIndex(...
            OperationSet,Operation);
            WindowFunctionIdx=getIndex(...
            obj.WindowFunctionSet,obj.WindowFunction);
            SamplingIdx=getIndex(...
            obj.SamplingSet,obj.Sampling);
            OutputDataTypeIdx=getIndex(...
            obj.OutputDataTypeSet,obj.OutputDataType);
            OutputDataTypeIdx=OutputDataTypeIdx-1;
            if(OutputDataTypeIdx==2)
                OutputDataTypeIdx=-2;
            end
            dtInfo=getFixptDataTypeInfo(obj,...
            {'Window','Product','Output'});
            if(dtInfo.OutputWordLength==0)
                OutputWordLength=64;
            else
                OutputWordLength=dtInfo.OutputWordLength;
            end
            if(dtInfo.OutputFracLength==0)
                OutputFracLength=52;
            else
                OutputFracLength=dtInfo.OutputFracLength;
            end

            WinFunctionName='';
            HasOptParams=0;
            OptParameters={};
            Sampmode=1;
            Length=64;

            if obj.FullPrecisionOverride
                obj.compSetParameters({...
                OperationIdx,...
                Length,...
                Sampmode,...
                1,...
                WindowFunctionIdx,...
                SamplingIdx,...
                obj.StopbandAttenuation,...
                obj.Beta,...
                obj.NumConstantSidelobes,...
                obj.MaximumSidelobeLevel...
                ,WinFunctionName,...
                HasOptParams,...
                OptParameters,...
                0,...
                0,...
                OutputDataTypeIdx,...
                OutputWordLength,...
                OutputFracLength,...
                dtInfo.WindowDataType,...
                dtInfo.WindowWordLength,...
                dtInfo.WindowFracLength,...
                5,...
                2,...
                2,...
                3,...
                2,...
                2,...
                3,...
1...
                });
            else

                obj.compSetParameters({...
                OperationIdx,...
                Length,...
                Sampmode,...
                1,...
                WindowFunctionIdx,...
                SamplingIdx,...
                obj.StopbandAttenuation,...
                obj.Beta,...
                obj.NumConstantSidelobes,...
                obj.MaximumSidelobeLevel...
                ,WinFunctionName,...
                HasOptParams,...
                OptParameters,...
                0,...
                0,...
                OutputDataTypeIdx,...
                OutputWordLength,...
                OutputFracLength,...
                dtInfo.WindowDataType,...
                dtInfo.WindowWordLength,...
                dtInfo.WindowFracLength,...
                dtInfo.ProductDataType,...
                dtInfo.ProductWordLength,...
                dtInfo.ProductFracLength,...
                dtInfo.OutputDataType,...
                dtInfo.OutputWordLength,...
                dtInfo.OutputFracLength,...
                dtInfo.RoundingMethod,...
                dtInfo.OverflowAction...
                });
            end
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)

            flag=false;
            switch prop
            case 'Sampling'
                if strcmp(obj.WindowFunction,'Bartlett')||...
                    strcmp(obj.WindowFunction,'Boxcar')||...
                    strcmp(obj.WindowFunction,'Triang')||...
                    strcmp(obj.WindowFunction,'Chebyshev')||...
                    strcmp(obj.WindowFunction,'Kaiser')||...
                    strcmp(obj.WindowFunction,'Taylor')
                    flag=true;
                end
            case 'Beta'
                if strcmp(obj.WindowFunction,'Bartlett')||...
                    strcmp(obj.WindowFunction,'Boxcar')||...
                    strcmp(obj.WindowFunction,'Triang')||...
                    strcmp(obj.WindowFunction,'Chebyshev')||...
                    strcmp(obj.WindowFunction,'Blackman')||...
                    strcmp(obj.WindowFunction,'Hamming')||...
                    strcmp(obj.WindowFunction,'Hann')||...
                    strcmp(obj.WindowFunction,'Hanning')||...
                    strcmp(obj.WindowFunction,'Taylor')
                    flag=true;
                end
            case 'StopbandAttenuation'
                if strcmp(obj.WindowFunction,'Bartlett')||...
                    strcmp(obj.WindowFunction,'Boxcar')||...
                    strcmp(obj.WindowFunction,'Triang')||...
                    strcmp(obj.WindowFunction,'Blackman')||...
                    strcmp(obj.WindowFunction,'Hamming')||...
                    strcmp(obj.WindowFunction,'Hann')||...
                    strcmp(obj.WindowFunction,'Hanning')||...
                    strcmp(obj.WindowFunction,'Kaiser')||...
                    strcmp(obj.WindowFunction,'Taylor')
                    flag=true;
                end
            case{'NumConstantSidelobes','MaximumSidelobeLevel'}
                if strcmp(obj.WindowFunction,'Bartlett')||...
                    strcmp(obj.WindowFunction,'Boxcar')||...
                    strcmp(obj.WindowFunction,'Triang')||...
                    strcmp(obj.WindowFunction,'Blackman')||...
                    strcmp(obj.WindowFunction,'Hamming')||...
                    strcmp(obj.WindowFunction,'Hann')||...
                    strcmp(obj.WindowFunction,'Hanning')||...
                    strcmp(obj.WindowFunction,'Kaiser')||...
                    strcmp(obj.WindowFunction,'Chebyshev')
                    flag=true;
                end
            case{'CustomWindowFunction','Parameters'}
                if strcmp(obj.WindowFunction,'Taylor')
                    flag=true;
                end

            case 'CustomWindowDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.WindowDataType)
                    flag=true;
                end
            case{'RoundingMethod','OverflowAction'}
                if(obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as product')&&...
                    strcmpi(obj.ProductDataType,'Full precision')))
                    flag=true;
                end
            case{'ProductDataType','OutputDataType'}
                if obj.FullPrecisionOverride
                    flag=true;
                end
            case 'CustomProductDataType'
                if(obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as product')&&...
                    strcmpi(obj.ProductDataType,'Full precision'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.ProductDataType))
                    flag=true;
                end
            case 'CustomOutputDataType'
                if(obj.FullPrecisionOverride||...
                    (strcmpi(obj.OutputDataType,'Same as product')&&...
                    strcmpi(obj.ProductDataType,'Full precision'))||...
                    ~matlab.system.isSpecifiedTypeMode(obj.OutputDataType))
                    flag=true;
                end

            end
        end

    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.Window',dsp.Window.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsigops/Window Function';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'WindowFunction'...
            ,'WeightsOutputPort'...
            ,'StopbandAttenuation'...
            ,'Beta'...
            ,'NumConstantSidelobes'...
            ,'MaximumSidelobeLevel'...
            ,'Sampling'
            };
        end

        function props=getDisplayFixedPointPropertiesImpl()
            props={...
            'FullPrecisionOverride',...
            'RoundingMethod','OverflowAction',...
            'WindowDataType','CustomWindowDataType',...
            'ProductDataType','CustomProductDataType',...
            'OutputDataType','CustomOutputDataType'...
            };
        end


        function props=getValueOnlyProperties()
            props={'WindowFunction'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
            if(obj.WeightsOutputPort)
                setPortDataTypeConnection(obj,1,2);
            end
        end
    end
end
