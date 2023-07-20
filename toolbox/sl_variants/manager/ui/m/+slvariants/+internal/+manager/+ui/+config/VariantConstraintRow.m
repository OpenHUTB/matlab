classdef VariantConstraintRow<handle






    properties
        VarConstrSSSrc(1,1)slvariants.internal.manager.ui.config.VariantConstraintSource;

        Name(1,:)char='';

        VarConstrIdx(1,1)double=-1;
    end

    methods(Hidden)

        function obj=VariantConstraintRow(aVarConstrSrc,aConstrName,aConstrIdx)
            if nargin==0
                return;
            end
            obj.VarConstrSSSrc=aVarConstrSrc;
            obj.Name=aConstrName;
            obj.VarConstrIdx=aConstrIdx;
        end

        function flag=isValidProperty(~,propName)

            validProps={
            slvariants.internal.manager.ui.config.VMgrConstants.Name
            slvariants.internal.manager.ui.config.VMgrConstants.Constraint
            slvariants.internal.manager.ui.config.VMgrConstants.Description
            };
            flag=ismember(propName,validProps);
        end

        function flag=isReadonlyProperty(obj,~)
            flag=~obj.VarConstrSSSrc.DialogSchema.StatusFlagForWidgets;
        end

        function val=getPropValue(obj,propName)


            val='';
            if isempty(obj.Name)
                return;
            end
            varConfigs=obj.VarConstrSSSrc.VariantConfigs;
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.Name
                val=obj.Name;
            case slvariants.internal.manager.ui.config.VMgrConstants.Constraint
                val=varConfigs.getGlobalConstraintCondition(obj.Name);
            case slvariants.internal.manager.ui.config.VMgrConstants.Description
                val=varConfigs.getGlobalConstraintDescription(obj.Name);
            end
        end

        function setPropValue(obj,propName,propVal)


            if isempty(obj.Name)
                return;
            end
            varConfigs=obj.VarConstrSSSrc.VariantConfigs;
            switch propName
            case slvariants.internal.manager.ui.config.VMgrConstants.Name
                if~obj.isValidName(propVal)
                    return;
                end


                varConfigs.setGlobalConstraintName(obj.Name,propVal);
                obj.VarConstrSSSrc.DialogSchema.setCacheObjDirtyFlag();
                obj.Name=propVal;

            case slvariants.internal.manager.ui.config.VMgrConstants.Constraint
                if~obj.isValidCondition(propVal)
                    return;
                end



                varConfigs.setGlobalConstraintCondition(obj.Name,propVal);
                obj.VarConstrSSSrc.DialogSchema.setCacheObjDirtyFlag();

            case slvariants.internal.manager.ui.config.VMgrConstants.Description


                varConfigs.setGlobalConstraintDescription(obj.Name,propVal);
                obj.VarConstrSSSrc.DialogSchema.setCacheObjDirtyFlag();
            end
        end

        function status=isValidName(obj,constrName)
            status=false;
            if isempty(constrName)
                slvariants.internal.manager.ui.util.createErrorDialog(...
                constrName,'Simulink:VariantManagerUI:MessageEmptyconstraintname');
                return;
            end
            if~slvariants.internal.manager.ui.config.isValidConstrName(obj,constrName)
                slvariants.internal.manager.ui.util.createErrorDialog(...
                constrName,'Simulink:VariantManagerUI:MessageInvalidconstraintname');
                return;
            end
            status=true;
        end

        function status=isValidCondition(~,constrCondition)
            status=~isempty(constrCondition);
            if~status
                slvariants.internal.manager.ui.util.createErrorDialog(...
                constrCondition,'Simulink:VariantManagerUI:MessageEmptyconstraintvalue');
            end
        end
    end

end


