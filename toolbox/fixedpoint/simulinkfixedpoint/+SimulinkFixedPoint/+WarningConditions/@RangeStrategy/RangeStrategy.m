classdef(Abstract)RangeStrategy<handle













    properties(SetAccess=protected)
containerInfo
    end

    methods(Access=public)
        function this=RangeStrategy(object)



            this.getContainerInfo(object);
        end

        function flag=isConditionActive(this)
            flag=false;


            if~isempty(this.containerInfo)
                flag=this.containerInfo.containerType==SimulinkFixedPoint.AutoscalerDataTypes.FixedPoint;
            end
        end
    end

    methods(Abstract,Access=public)
        containerInfo=getContainerInfo(this,object)
        [rangesMin,rangesMax]=getRanges(this,object)
    end

end

