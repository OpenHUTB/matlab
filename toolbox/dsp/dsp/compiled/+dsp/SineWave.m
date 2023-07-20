classdef SineWave<matlab.system.SFunSystem


















































































%#function mdspsine2

    properties







        Amplitude=1;
    end
    properties(Nontunable)







        Frequency=100;






        PhaseOffset=0;











        Method='Trigonometric function';







        TableOptimization='Speed';



        SampleRate=1000;




        SamplesPerFrame=1;



        OutputDataType='double';







        CustomOutputDataType=numerictype([],16);




        ComplexOutput(1,1)logical=false;
    end

    properties(Constant,Hidden,Nontunable)
        MethodSet=matlab.system.StringSet({...
        'Trigonometric function',...
        'Table lookup',...
        'Differential'});
        TableOptimizationSet=matlab.system.StringSet({'Speed','Memory'});
        OutputDataTypeSet=matlab.system.StringSet({...
        'double',...
        'single',...
'Custom'...
        });
    end

    methods

        function obj=SineWave(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mdspsine2');
            setProperties(obj,nargin,varargin{:},'Amplitude','Frequency','PhaseOffset');
        end

        function set.Amplitude(obj,val)
            coder.internal.errorIf(strcmp(obj.Method,'Table lookup')&&isLocked(obj),...
            'dsp:system:SineWave:AmplitudeNonTunable');%#ok
            obj.Amplitude=val;
        end

        function set.CustomOutputDataType(obj,val)
            validateCustomDataType(obj,'CustomOutputDataType',val,...
            {'AUTOSIGNED','ALLOWFLOAT'});
            obj.CustomOutputDataType=val;
        end
    end

    methods(Hidden)
        function setParameters(obj)
            MethodIdx=getIndex(...
            obj.MethodSet,obj.Method);
            TableOptimizationIdx=getIndex(...
            obj.TableOptimizationSet,obj.TableOptimization);

            dtInfo=getSourceDataTypeInfo(obj,abs(obj.Amplitude));

            obj.compSetParameters({...
            obj.Amplitude,...
            obj.Frequency,...
            obj.PhaseOffset,...
            1,...
            1+double(obj.ComplexOutput),...
            MethodIdx,...
            1./obj.SampleRate,...
            obj.SamplesPerFrame,...
            1,...
            TableOptimizationIdx,...
            1,...
            0,...
            1,...
            dtInfo.Id,...
            dtInfo.WordLength,...
            dtInfo.FractionLength,...
            });
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            switch prop
            case 'TableOptimization'
                if~strcmp(obj.Method,'Table lookup')
                    flag=true;
                end
            case 'CustomOutputDataType'
                if~matlab.system.isSpecifiedTypeMode(obj.OutputDataType)
                    flag=true;
                end
            end
        end





    end

    methods(Static)
        function helpFixedPoint






            matlab.system.dispFixptHelp('dsp.SineWave',...
            dsp.SineWave.getDisplayFixedPointPropertiesImpl);
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsrcs4/Sine Wave';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'Amplitude'...
            ,'Frequency'...
            ,'PhaseOffset'...
            ,'ComplexOutput'...
            ,'Method'...
            ,'TableOptimization'...
            ,'SampleRate'...
            ,'SamplesPerFrame'...
            ,'OutputDataType'...
            };
        end
        function props=getDisplayFixedPointPropertiesImpl()
            props={'CustomOutputDataType'};
        end


        function props=getValueOnlyProperties()
            props={'Amplitude','Frequency','PhaseOffset'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Amplitude=0;
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function S=saveObjectImpl(obj)
            props=[dsp.SineWave.getDisplayPropertiesImpl...
            ,dsp.SineWave.getDisplayFixedPointPropertiesImpl];
            for ii=1:length(props)
                S.(props{ii})=obj.(props{ii});
            end
        end
    end
end


