classdef PolarAxesAccessor<matlab.plottools.service.accessor.BaseAxesAccessor



    methods
        function obj=PolarAxesAccessor()
            obj=obj@matlab.plottools.service.accessor.BaseAxesAccessor();
        end

        function id=getIdentifier(~)
            id='matlab.graphics.axis.PolarAxes';
        end
    end


    methods(Access='protected')
        function result=supportsGrid(obj)
            result=matlab.graphics.internal.supportsGesture(obj.ReferenceObject,'grid');
        end

        function result=supportsRGrid(~)
            result=true;
        end

        function result=supportsThetaGrid(~)
            result=true;
        end
    end


    methods(Access='protected')
        function result=getGrid(obj)
            result='off';

            if strcmpi(obj.ReferenceObject.RGrid,'on')&&...
                strcmpi(obj.ReferenceObject.ThetaGrid,'on')
                result='on';
            end
        end

        function result=getRGrid(obj)
            result=obj.ReferenceObject.RGrid;
        end

        function result=getThetaGrid(obj)
            result=obj.ReferenceObject.ThetaGrid;
        end
    end


    methods(Access='protected')
        function setGrid(obj,value)
            obj.ReferenceObject.RGrid=value;
            obj.ReferenceObject.ThetaGrid=value;
        end

        function setRGrid(obj,value)
            obj.ReferenceObject.RGrid=value;

            if obj.ReferenceObject.RGrid==matlab.lang.OnOffSwitchState.on
                obj.ReferenceObject.ThetaGrid=matlab.lang.OnOffSwitchState.off;
            end
        end

        function setThetaGrid(obj,value)
            obj.ReferenceObject.ThetaGrid=value;

            if obj.ReferenceObject.ThetaGrid==matlab.lang.OnOffSwitchState.on
                obj.ReferenceObject.RGrid=matlab.lang.OnOffSwitchState.off;
            end
        end
    end
end

