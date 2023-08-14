classdef GammaCorrector<matlab.system.SFunSystem


















































%#function mvipgamma

%#ok<*EMCLS>
%#ok<*EMCA>

    properties(Nontunable)


        Correction='Gamma';







        Gamma=2.2;





        BreakPoint=0.018;





        LinearSegment(1,1)logical=true;
    end

    properties(Constant,Hidden)
        CorrectionSet=matlab.system.StringSet({'Gamma','De-gamma'});
    end

    methods

        function obj=GammaCorrector(varargin)
            coder.allowpcode('plain');
            obj@matlab.system.SFunSystem('mvipgamma');
            setProperties(obj,nargin,varargin{:},'Gamma');
        end

        function set.BreakPoint(obj,value)
            validateattributes(value,{'numeric'},{'scalar','>',0,'<',1},'','BreakPoint');
            obj.BreakPoint=value;
        end
    end

    methods(Hidden)
        function setParameters(obj)

            CorrectionIdx=getIndex(...
            obj.CorrectionSet,obj.Correction);

            obj.compSetParameters({...
            CorrectionIdx,...
            obj.Gamma,...
            double(obj.LinearSegment),...
            obj.BreakPoint...
            });
        end
    end

    methods(Access=protected)

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            if~obj.LinearSegment
                props{end+1}='BreakPoint';
            end
            flag=ismember(prop,props);
        end

    end

    methods(Static,Hidden)
        function props=getDisplayPropertiesImpl()
            props={...
'Correction'...
            ,'Gamma'...
            ,'LinearSegment'...
            ,'BreakPoint'...
            };
        end


        function props=getValueOnlyProperties()
            props={'Gamma'};
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

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='visionconversions/Gamma Correction';
        end
    end

end
