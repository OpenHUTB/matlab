classdef LocalMaximaFinder<matlab.system.SFunSystem









































































%#function mvipfindlocalmax

%#ok<*EMCLS>
%#ok<*EMCA>

    properties





        Threshold=10;
    end

    properties(Nontunable)



        MaximumNumLocalMaxima=2;




        NeighborhoodSize=[5,7];



        ThresholdSource='Property';



        IndexDataType='uint32';






        HoughMatrixInput(1,1)logical=false;
    end

    properties(Constant,Hidden)
        ThresholdSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
        IndexDataTypeSet=matlab.system.StringSet(...
        {'double','single','uint8','uint16','uint32'});
    end

    methods

        function obj=LocalMaximaFinder(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipfindlocalmax');
            setProperties(obj,nargin,varargin{:},'MaximumNumLocalMaxima','NeighborhoodSize');
        end
    end

    methods(Hidden)
        function setParameters(obj)
            ThresholdSourceIdx=getIndex(...
            obj.ThresholdSourceSet,obj.ThresholdSource);
            IndexDataTypeIdx=getIndex(...
            obj.IndexDataTypeSet,obj.IndexDataType);

            obj.compSetParameters({...
            obj.MaximumNumLocalMaxima,...
            3,...
            ThresholdSourceIdx,...
            obj.Threshold,...
            obj.NeighborhoodSize,...
            double(obj.HoughMatrixInput),...
            IndexDataTypeIdx,...
            1,...
IndexDataTypeIdx...
            });
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            if strcmp(obj.ThresholdSource,'Input port')
                props={'Threshold'};
            else
                props={};
            end
            flag=ismember(prop,props);
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'MaximumNumLocalMaxima'...
            ,'NeighborhoodSize'...
            ,'ThresholdSource'...
            ,'Threshold'...
            ,'HoughMatrixInput'...
            ,'IndexDataType'...
            };
        end



        function tunePropsMap=getTunablePropertiesMap()
            tunePropsMap.Threshold=3;
        end


        function props=getValueOnlyProperties()
            props={'MaximumNumLocalMaxima','NeighborhoodSize'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)

            if isInputFloatingPoint(obj,1)
                setPortDataTypeConnection(obj,1,1);
            end
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionstatistics/Find Local Maxima';
        end
    end
end
