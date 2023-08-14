classdef(ConstructOnLoad,Hidden)MorphBase<matlab.system.SFunSystem






%#function mvipmorphop

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)








        NeighborhoodSource='Property';
    end

    properties(Constant,Hidden)
        NeighborhoodSourceSet=dsp.CommonSets.getSet('PropertyOrInputPort');
    end

    properties(Abstract,Nontunable)

        Neighborhood;
    end

    properties(Abstract,Hidden,Nontunable)

        MorphOperation;
    end

    methods

        function obj=MorphBase(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipmorphop');
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Hidden)
        function setParameters(obj)
            NeighborhoodSourceIdx=getIndex(...
            obj.NeighborhoodSourceSet,obj.NeighborhoodSource);
            [nhood,nhdims]=strel2nhood(obj.Neighborhood);
            obj.compSetParameters({obj.MorphOperation,...
            NeighborhoodSourceIdx,nhood,nhdims});
        end
    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={'NeighborhoodSource','Neighborhood'};
        end
        function y=hasEmptyGeneratedTerminateFcn()




            y=true;
        end
    end

    methods(Access=protected)
        function flag=isInactivePropertyImpl(obj,prop)
            if strcmp(obj.NeighborhoodSource,'Input port')
                props={'Neighborhood'};
            else
                props={};
            end
            flag=ismember(prop,props);
        end
    end

    methods(Access=protected)
        function setPortDataTypeConnections(obj)
            setPortDataTypeConnection(obj,1,1);
        end
    end

end

