classdef(Sealed)GeneratedConfigsRow<handle





    properties(Constant)
        InvalidStr='Invalid';
    end

    properties(Access=private)
        SerialNum(1,1)int32=0;

        IsSelected(1,1)logical=true;

        ValidityStatus(1,:)char='';

        Configuration;

        GeneratedCfgsSrc slvariants.internal.manager.ui.configgen.GeneratedConfigsSource;
    end



    methods
        function obj=GeneratedConfigsRow(idx,config,validityStatus,generatedCfgsSrc)
            if nargin==0
                return;
            end

            obj.SerialNum=idx;
            obj.Configuration=config;
            obj.ValidityStatus=validityStatus;

            obj.IsSelected=double(~isequal(validityStatus,obj.InvalidStr));
            obj.GeneratedCfgsSrc=generatedCfgsSrc;
        end

        function isSelected=getIsSelected(obj)
            isSelected=obj.IsSelected;
        end

        function config=getConfiguration(obj)
            config=obj.Configuration;
        end

        function label=getDisplayLabel(obj)
            label=obj.Configuration.Name;
        end

        function propValue=getPropValue(obj,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            switch propName
            case VMgrConstants.Name
                propValue=obj.Configuration.Name;
            case VMgrConstants.SelectCol
                propValue=num2str(obj.IsSelected);
            case VMgrConstants.SerialNum
                propValue=num2str(obj.SerialNum);
            case VMgrConstants.AutoGenConfigValidityStatus
                propValue=obj.ValidityStatus;
            otherwise

                if ismember(propName,obj.getCtrlVarNames())
                    propValue=obj.getCtrlVarValue(propName);
                end
            end
        end

        function setPropValue(obj,propName,val)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            switch propName
            case VMgrConstants.SelectCol
                obj.IsSelected=str2double(val);
                obj.GeneratedCfgsSrc.enableOrDisableAddSelectedButton();
            case VMgrConstants.Name
                success=obj.GeneratedCfgsSrc.changeConfigName(obj.Configuration.Name,val);
                if success

                    obj.Configuration.Name=val;
                end
            end

        end

        function propType=getPropDataType(~,propName)
            propType='string';
            if~strcmp(propName,slvariants.internal.manager.ui.config.VMgrConstants.SelectCol)
                return;
            end
            propType='bool';
        end



        function flag=isValidProperty(obj,propName)

            import slvariants.internal.manager.ui.config.VMgrConstants;
            if ismember(propName,{VMgrConstants.Name...
                ,VMgrConstants.SelectCol...
                ,VMgrConstants.SerialNum...
                ,VMgrConstants.AutoGenConfigValidityStatus})
                flag=true;
            else
                flag=ismember(propName,obj.getCtrlVarNames());
            end
        end

        function flag=isEditableProperty(~,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            flag=ismember(propName,{VMgrConstants.Name...
            ,VMgrConstants.SelectCol});
        end

        function flag=isReadonlyProperty(~,propName)
            import slvariants.internal.manager.ui.config.VMgrConstants;
            flag=~ismember(propName,{VMgrConstants.Name...
            ,VMgrConstants.SelectCol});
        end

        function getPropertyStyle(obj,~,propertyStyle)
            if isequal(obj.ValidityStatus,obj.InvalidStr)
                propertyStyle.BackgroundColor=[1,0.60,0.60];
            else
                propertyStyle.BackgroundColor=[0.75,0.90,0.70];
            end
        end
    end

    methods(Access=private)

        function ctrlVarNames=getCtrlVarNames(obj)
            ctrlVars=obj.Configuration.ControlVariables;
            ctrlVarNames{1,numel(ctrlVars)}='';
            for idx=1:numel(ctrlVars)
                ctrlVarNames{idx}=ctrlVars(idx).Name;
            end
        end


        function value=getCtrlVarValue(obj,ctrlVarName)
            value='Unknown';
            ctrlVars=obj.Configuration.ControlVariables;
            for idx=1:numel(ctrlVars)
                if isequal(ctrlVarName,ctrlVars(idx).Name)
                    val=ctrlVars(idx).Value;
                    if isa(val,'Simulink.VariantControl')
                        val=val.Value;
                    end
                    if isa(val,'Simulink.Parameter')
                        val=val.Value;
                    end



                    value=slvariants.internal.config.utils.iNum2Str(val,false);
                    break;
                end
            end
        end
    end
end
