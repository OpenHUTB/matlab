













classdef NormalModeConfiguration<handle
    properties(Hidden=true,Access=private)
        ModelName='';
        Dirty='off';
        OriginalConfigSetName='';
        NewConfigSetName='';
    end



    methods
        function this=NormalModeConfiguration(modelName)
            this.ModelName=modelName;
            this.Dirty=get_param(modelName,'Dirty');

            mdlObj=get_param(modelName,'Object');
            origCs=mdlObj.getActiveConfigSet;
            this.OriginalConfigSetName=origCs.Name;
            while isa(origCs,'Simulink.ConfigSetRef')
                origCs=origCs.getRefConfigSet;
            end
            newCs=origCs.copy();
            iter=0;


            while 1
                newCsName=['Configuration_',num2str(iter)];
                if~isempty(mdlObj.getConfigSet(newCsName))
                    iter=iter+1;
                else
                    break;
                end
            end
            newCs.Name=newCsName;

            this.NewConfigSetName=newCsName;

            mdlObj.attachConfigSet(newCs);
            mdlObj.setActiveConfigSet(newCsName);

            set_param(modelName,'ArrayBoundsChecking','none');
            set_param(modelName,'LoadInitialState','off');
            set_param(modelName,'UnconnectedInputMsg','none');
            set_param(modelName,'UnconnectedOutputMsg','none');
            set_param(modelName,'ModelReferenceVersionMismatchMessage','none');

            set_param(modelName,'Dirty','off');
        end


        function cleanupModel(this)
            mdlObj=get_param(this.ModelName,'Object');
            mdlObj.setActiveConfigSet(this.OriginalConfigSetName);
            mdlObj.detachConfigSet(this.NewConfigSetName);


            set_param(this.ModelName,'Dirty',this.Dirty);
        end
    end
end


