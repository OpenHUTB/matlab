classdef(Sealed)EntityAutoscalersInterface<handle

    properties(SetAccess=protected)


        AutoscalerMap=containers.Map

AutoscalersCell
    end

    properties(Constant,Access=private)
        xmlFilePath='fxptinfo.xml';
    end

    methods(Access=private)

        function this=EntityAutoscalersInterface
        end
    end
    methods(Static)

        function singleObject=getInterface()
            persistent localObject;




            if isempty(localObject)||~isvalid(localObject)
                localObject=SimulinkFixedPoint.EntityAutoscalersInterface;
                localObject.initialize(localObject.xmlFilePath);
            end


            singleObject=localObject;
        end

    end

    methods(Access=public)
        autoscaler=getAutoscaler(this,blockObj)
        delete(this)
    end

    methods(Access=public,Hidden)
        initialize(this,filePath)
        clearMaps(this)
        key=getXMLKeyForBlock(this,blockObj)
        key=getGeneralBlockKey(this,blockObj)
        key=getMATLABSystemBlockKey(this,blockObj)
        key=getSFunctionBlockKey(this,blockObj)
        allEntityAutoscalersCell=getEntityAutoscalerNames(this)
    end
end