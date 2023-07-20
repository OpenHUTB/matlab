



classdef TemporaryConfigSet<handle
    properties(Transient,SetAccess=private,GetAccess=public)
        ConfigSet=[];
    end

    properties(Transient,SetAccess=private,GetAccess=private)
        Model=[]
        OldConfigSet=[]
CopiedParameters
    end

    methods(Access=public)
        function this=TemporaryConfigSet(model,copiedPrms)
            this.Model=model;
            this.CopiedParameters=copiedPrms;
            this.OldConfigSet=getActiveConfigSet(this.Model);
            cs=this.getRefConfigSet(this.OldConfigSet);


            this.ConfigSet=cs.copy;
            defaultName=Simulink.ModelReference.Conversion.ConfigSet.DefaultConfigSetName;
            this.ConfigSet.Name=Simulink.ModelReference.Conversion.ConfigSet.getUniqueConfigSetName(getConfigSets(this.Model),defaultName);


            attachConfigSet(this.Model,this.ConfigSet);
            setActiveConfigSet(this.Model,this.ConfigSet.Name);
        end

        function delete(this)
            if bdIsLoaded(this.Model)&&~strcmp(this.OldConfigSet.Name,this.ConfigSet.Name)
                modelActions=Simulink.ModelActions(this.Model);
                modelActions.terminate;

                cs=this.getRefConfigSet(this.OldConfigSet);



                [isOk,params]=isequal(this.ConfigSet,cs);
                if~isOk
                    params=intersect(params,this.CopiedParameters);

                    cellfun(@(paramName)set_param(cs,paramName,get_param(this.ConfigSet,paramName)),params);
                end


                setActiveConfigSet(this.Model,this.OldConfigSet.Name);
                detachConfigSet(this.Model,this.ConfigSet.Name);
            end
        end

        function set(this,paramName,paramValue)
            this.ConfigSet.set_param(paramName,paramValue);
        end
    end

    methods(Static,Access=private)
        function refCs=getRefConfigSet(cs)
            if isa(cs,'Simulink.ConfigSetRef')
                refCs=cs.getRefConfigSet;
            else
                refCs=cs;
            end
        end
    end
end
