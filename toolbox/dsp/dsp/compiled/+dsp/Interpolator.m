classdef Interpolator<matlab.system.SFunSystem




































































%#function mdspinterp

%#ok<*EMCLS>
%#ok<*EMCA>

    properties








        InterpolationPoints=[1.1,4.8,2.67,1.6,3.2]';
    end

    properties(Nontunable)



        InterpolationPointsSource='Property';


















        Method='Linear';






        FilterHalfLength=3;






        InterpolationPointsPerSample=3;









        Bandwidth=0.5;
    end

    properties(Constant,Hidden)

        InterpolationPointsSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        MethodSet=matlab.system.StringSet({'Linear','FIR'});
    end

    methods
        function obj=Interpolator(varargin)
            coder.allowpcode('plain');
            coder.internal.warning('dsp:system:Interpolator_NotSupported');
            obj@matlab.system.SFunSystem('mdspinterp');
            setProperties(obj,nargin,varargin{:});
            setVarSizeAllowedStatus(obj,false);
        end

    end

    methods(Hidden)
        function setParameters(obj)
            InterpolationPointsSourceIdx=...
            getIndex(obj.InterpolationPointsSourceSet,obj.InterpolationPointsSource);
            MethodIdx=getIndex(obj.MethodSet,obj.Method);
            InvalidInterpPointsActionIdx=1;
            InterpFilter=dspblkinterp('init',false,obj.InterpolationPointsPerSample,...
            obj.FilterHalfLength,obj.Bandwidth);


            obj.compSetParameters({...
            InterpolationPointsSourceIdx,...
            obj.InterpolationPoints,...
            MethodIdx,...
            InterpFilter,...
InvalidInterpPointsActionIdx...
            });
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)

            flag=false;
            switch prop
            case{'FilterHalfLength','InterpolationPointsPerSample','Bandwidth'}
                if strcmp(obj.Method,'Linear')
                    flag=true;
                end
            case 'InterpolationPoints'
                if strcmp(obj.InterpolationPointsSource,'Input port')
                    flag=true;
                end
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspsigops/Interpolation';
        end

        function props=getDisplayPropertiesImpl()
            props={...
            'InterpolationPointsSource',...
            'InterpolationPoints',...
            'Method',...
            'FilterHalfLength',...
            'InterpolationPointsPerSample',...
            'Bandwidth'};
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.InterpolationPoints=1;
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
