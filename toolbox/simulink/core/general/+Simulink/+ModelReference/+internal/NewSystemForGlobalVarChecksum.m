classdef NewSystemForGlobalVarChecksum<handle








    properties(Access=private)
        modelName;
        configSet;
    end


    methods(Access=private)

        function this=NewSystemForGlobalVarChecksum()

            this.modelName=this.loc_getModelNameForNewSystem();
            new_system(this.modelName,'Model');

            this.configSet=getActiveConfigSet(this.modelName);
            this.configSet.switchTarget('ert.tlc',[]);
            this.configSet.set_param('StrictBusMsg','ErrorLevel1');
            this.configSet.set_param('ParameterDowncastMsg','none');
            this.configSet.set_param('ParameterUnderflowMsg','none');
            this.configSet.set_param('ParameterTunabilityLossMsg','none');
            this.configSet.set_param('ParameterOverflowMsg','none');
            this.configSet.set_param('ParameterPrecisionLossMsg','none');
        end


        function delete(obj)
            close_system(obj.modelName,0);
        end


        function modelName=loc_getModelNameForNewSystem(~)
            [~,modelName]=fileparts(tempname);
            modelRefNameObj=Simulink.ModelReference.Conversion.NameUtils;
            dataAccessor=Simulink.data.DataAccessor.createWithNoContext();
            startIndex=0;
            modelName=modelRefNameObj.getValidModelNameForBase(modelName,32,dataAccessor,startIndex);
        end
    end


    methods(Access=public)

        function result=getModelName(obj)
            result=obj.modelName;
        end


        function result=getConfigSet(obj)
            result=obj.configSet;
        end
    end


    methods(Static)






        function result=getInstance(type)
            persistent theInstance;


            switch(type)
            case 'create'

                if isempty(theInstance)
                    theInstance=Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum;
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



        function result=getInstanceModel()
            obj=Simulink.ModelReference.internal.NewSystemForGlobalVarChecksum.getInstance('');
            if isempty(obj)
                result=[];
            else
                result=obj.getModelName;
            end
        end

    end

end

