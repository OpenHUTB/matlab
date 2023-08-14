classdef PropertyContainer<hgsetget&dynamicprops







    properties(SetAccess=protected,GetAccess=protected,Hidden)
        PerformingGet=false;
PreGetListeners
PreSetListeners
    end

    properties(SetAccess=protected,GetAccess=protected,Hidden)
        InternalPropertyContainer=[];
    end

    methods(Access=public)


































        function pInfo=propinfo(obj,propertyName,cached)
            if nargin==1
                propertyNames=properties(obj);
                [~,iS]=sort(lower(propertyNames));
                props=propertyNames(iS);
                for pp=1:length(props)
                    pInfo.(props{pp})=propinfo(obj,props{pp});
                end
            else

                if iscell(propertyName)
                else
                    prop=getProperty(obj,propertyName);

                    try
                        if~(nargin==3&&cached)
                            get(obj,propertyName);
                        end
                    catch


                    end
                    pInfo.Type=prop.Type;

                    switch prop.Type
                    case 'integer'
                        if prop.IntLowerBound==intmin('int32')&&prop.IntUpperBound==intmax('int32')||...
                            prop.IntLowerBound==intmin('int64')&&prop.IntUpperBound==intmax('int64')
                            pInfo.Constraint='none';
                            pInfo.ConstraintValue=[];
                        else
                            pInfo.Constraint='bounded';
                            pInfo.ConstraintValue=[prop.IntLowerBound,prop.IntUpperBound];
                        end

                        if prop.StorageType==4
                            pInfo.DefaultValue=prop.IntDefault;

                        else
                            pInfo.DefaultValue=prop.IntArrayDefault;
                        end

                    case 'string'
                        pInfo.Constraint='none';
                        pInfo.ConstraintValue=[];
                        pInfo.DefaultValue=prop.StringDefault;
                    case 'enum'
                        pInfo.Constraint='enum';
                        pInfo.Type='string';
                        pInfo.ConstraintValue=prop.EnumAllowedStrings;
                        pInfo.DefaultValue=prop.EnumDefault;
                    case 'double'
                        if all(isinf([prop.DoubleLowerBound,prop.DoubleUpperBound]))
                            pInfo.Constraint='none';
                        else
                            pInfo.Constraint='bounded';
                        end
                        pInfo.ConstraintValue=[prop.DoubleLowerBound,prop.DoubleUpperBound];
                        if prop.StorageType==2
                            pInfo.DefaultValue=prop.DoubleDefault;
                        else
                            pInfo.DefaultValue=prop.DoubleArrayDefault;
                        end

                    otherwise
                        pInfo.Constraint='none';
                        pInfo.ConstraintValue=[];
                        pInfo.DefaultValue=[];
                    end
                    pInfo.ReadOnly=prop.ReadOnly;
                    pInfo.DeviceSpecific=prop.DeviceSpecific;
                    pInfo.Accessible=prop.Accessible;
                end
            end
        end

    end

    methods(Hidden)
        function commands(obj)
            pc=obj.InternalPropertyContainer;
            cmds={};
            for pp=1:length(pc.Properties)
                if strcmp(pc.Properties(pp).Type,'command')
                    cmds{end+1}=pc.Properties(pp).Name;%#ok<AGROW>
                end
            end
            fprintf('  Available Commands:\n\n')
            for cc=1:length(cmds)
                fprintf('    %s\n',cmds{cc});
            end
        end

        function performCommand(obj,commandName)
            pc=obj.InternalPropertyContainer;


            for pp=1:length(pc.Properties)
                if strcmp(pc.Properties(pp).Name,commandName)&&...
                    strcmp(pc.Properties(pp).Type,'command')
                    pc.Properties(pp).performCommand();
                    return;
                end
            end
            error('imaq:propertyContainer:invalidCommand','Invalid command specified.');
        end

    end

    methods(Access=protected)






        function prop=addDynamicProp(obj,property)
            prop=addprop(obj,property.Name);
























            if strcmp(property.ReadOnly,'always')
                prop.SetAccess='protected';
                prop.SetObservable=false;
                prop.AbortSet=false;
            else
                prop.SetObservable=true;
                prop.AbortSet=true;
            end



            if strcmp(property.Visibility,'invisible')
                prop.Hidden=true;
            end


            prop.GetMethod=obj.createDynamicPropertyGetter(property.Name);
            prop.SetMethod=obj.createDynamicPropertySetter(property.Name);


        end


        function h=createDynamicPropertySetter(obj,propertyName)%#ok<INUSL>
            h=@propertySetter;
            function propertySetter(obj,value)
                try
                    if obj.PerformingGet==false
                        obj.setValueOnProperty(propertyName,value);
                    else
                        obj.(propertyName)=value;
                    end
                catch ME
                    throwAsCaller(ME);
                end
            end
        end

    end
    methods(Abstract)
        setValueOnProperty(obj,propertyName,value)
        getProperty(obj,propertyName)
    end
end
