classdef AntennaCADModel<cad.CADModel





    properties
FeedStack
        FeedIDVal=0;
LoadStack
        LoadIDVal=0;
FeedFactory
    end

    methods
        function self=AntennaCADModel(ShapeFactoryObject,OperationFactoryObj,FeedFactoryObj)
            self@cad.CADModel(ShapeFactoryObject,OperationFactoryObj);
            self.FeedFactory=FeedFactoryObj;
        end

    end
end

