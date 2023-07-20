classdef ModelRefSILPILOverrideCache<handle




    properties(Access=private)
TopModel
IsSILPILOverride
    end

    methods(Access=private)
        function this=ModelRefSILPILOverrideCache()
            this.TopModel=[];
            this.IsSILPILOverride=false;
        end

        function setup(this,topModel)
            this.TopModel=topModel;
            this.IsSILPILOverride=strcmp(get_param(topModel,...
            'ModelRefSimModeOverrideType'),'SilPil');
        end

        function delete(~)
        end
    end

    methods(Access=public)
        function result=getOverride(this)
            result=this.IsSILPILOverride;
        end

        function result=getTopModel(this)
            result=this.TopModel;
        end
    end

    methods(Static)
        function result=getInstance(type)
            persistent theInstance;

            switch(type)
            case 'create'
                if isempty(theInstance)
                    theInstance=Simulink.ModelReference.internal.ModelRefSILPILOverrideCache();
                end
            case 'delete'
                if~isempty(theInstance)
                    theInstance.delete();
                    theInstance=[];
                end
            otherwise

            end
            result=theInstance;
        end

        function setTopModel(topModel)
            obj=Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.getInstance('create');
            obj.setup(topModel);
        end

        function cleanup()
            Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.getInstance('delete');
        end

        function result=isOverride()
            obj=Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.getInstance('');
            if isempty(obj)
                result=false;
            else
                result=obj.getOverride();
            end
        end

        function attachOverride(model)
            obj=Simulink.ModelReference.internal.ModelRefSILPILOverrideCache.getInstance('');
            if isempty(obj)
                return;
            else
                slInternal('attachModelRefSimModeOverride',obj.getTopModel(),model);
            end
        end
    end

end
