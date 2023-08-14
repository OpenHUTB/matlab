classdef FunctionSchema<swarch.internal.propertyinspector.SoftwareElementPropertySchema




    properties(Access=private)
RootMFModel
    end

    methods
        function this=FunctionSchema(studio,rootFunc)
            this=this@swarch.internal.propertyinspector.SoftwareElementPropertySchema(studio,rootFunc);
            this.RootMFModel=mf.zero.Model.empty;


            protoMFModel=mf.zero.getModel(this.PrototypableZCModel);
            rootMFModel=mf.zero.getModel(rootFunc);
            if protoMFModel~=rootMFModel


                this.RootMFModel=rootMFModel;
                this.RootMFModel.addObservingListener(this.RefreshPIListener);
            end
        end

        function delete(this)
            if~isempty(this.RootMFModel)&&isvalid(this.RootMFModel)
                this.RootMFModel.removeListener(this.RefreshPIListener);
            end
        end

        function typeStr=getObjectType(this)
            switch this.getPrototypable().type
            case systemcomposer.architecture.model.swarch.FunctionType.OSFunction
                typeStr='Function';
            case systemcomposer.architecture.model.swarch.FunctionType.Initialize
                typeStr='Initialize Function';
            case systemcomposer.architecture.model.swarch.FunctionType.Reset
                typeStr='Reset Function';
            case systemcomposer.architecture.model.swarch.FunctionType.Terminate
                typeStr='Terminate Function';
            end
        end

        function setPrototypableName(this,value)



            swarch.utils.setFunctionAndRootInportBlockName(this.ElementImpl,value);
        end

        function name=getPrototypableName(this)
            name=this.ElementImpl.getName();
        end
    end

    methods(Access=protected)
        function functionElem=getPrototypable(this)
            functionElem=swarch.utils.getPrototypableFunction(this.ElementImpl);
        end
    end
end
