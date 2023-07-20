classdef(Hidden)DataTypeProperty<matlab.system.display.internal.Property




    properties(Hidden,SetAccess=protected)
        IsRoundingMethod=false;
        IsOverflowAction=false;
        IsDataType=false;
        IsDesignMin=false;
        IsDesignMax=false;
        IsLockScale=false;
        DataTypeSet;
    end

    properties
        Prefix;
    end

    properties(Access=private)
        pValue=[];
        pAssociatedDataTypePropertyName='';
        pIsSimplifiedInterface=false;
    end

    methods
        function obj=DataTypeProperty(name,varargin)


            defaultLabel=regexp(name,'(\w+)DataType','tokens','once');
            if~isempty(defaultLabel)
                defaultLabel=defaultLabel{1};
            else
                defaultLabel=name;
            end
            p=inputParser;
            p.KeepUnmatched=true;
            p.addParameter('Prefix',defaultLabel);
            p.addParameter('Description',defaultLabel);
            p.parse(varargin{:});
            results=p.Results;


            args={};
            unmatched=fieldnames(p.Unmatched);
            for k=1:numel(unmatched)
                unmatchedParam=unmatched{k};
                args=[args,unmatchedParam,p.Unmatched.(unmatchedParam)];%#ok<AGROW>
            end
            obj@matlab.system.display.internal.Property(name,args{:});

            obj.Prefix=results.Prefix;
            obj.Description=results.Description;
        end

        function v=isDataTypeProperty(~)
            v=true;
        end
    end

    methods(Hidden)
        function obj=setAttributes(obj,metaProperties)


            if obj.AttributesSet
                return;
            end

            setAttributes@matlab.system.display.internal.Property(obj,metaProperties);

            if strcmp(obj.Name,'RoundingMethod')
                obj.IsRoundingMethod=true;
                obj.Description='Rounding mode';
                obj.pBlockParameterName='roundingMode';
            elseif strcmp(obj.Name,'OverflowAction')
                obj.IsOverflowAction=true;
                obj.IsLogical=true;
                obj.Description='Saturate on integer overflow';
                obj.pBlockParameterName='overflowMode';
            elseif strcmp(obj.Name,'FullPrecisionOverride')
                obj.IsGraphical=false;
                obj.UseClassDefault=false;
                obj.Default='off';



            else
                allPropNames={metaProperties.Name};
                propName=obj.Name;

                dataTypeSetProperty=metaProperties(strcmp(allPropNames,[propName,'Set']));
                if~isempty(dataTypeSetProperty)&&dataTypeSetProperty.HasDefault&&isa(dataTypeSetProperty.DefaultValue,'matlab.system.internal.DataTypeSet')

                    obj.IsDataType=true;
                    obj.IsStringSet=false;
                    obj.DataTypeSet=dataTypeSetProperty.DefaultValue;
                    obj.pBlockParameterName=[obj.Prefix,'DataTypeStr'];
                    obj.pIsSimplifiedInterface=~strcmp(obj.DataTypeSet.Compatibility,'Legacy');
                elseif strncmp(propName,'Custom',6)

                    obj.IsObjectDisplayOnly=true;
                end
            end
        end

        function setIsDesignMin(obj,dtPropName,dtSet)

            if obj.IsDesignMin
                return;
            end

            obj.IsDesignMin=true;
            obj.IsFacade=true;
            obj.pBlockParameterName=[obj.Prefix,'Min'];
            obj.DataTypeSet=dtSet;
            obj.UseClassDefault=false;
            obj.Default='[]';
            obj.pAssociatedDataTypePropertyName=dtPropName;
        end

        function setIsDesignMax(obj,dtPropName,dtSet)

            if obj.IsDesignMax
                return;
            end

            obj.IsDesignMax=true;
            obj.IsFacade=true;
            obj.pBlockParameterName=[obj.Prefix,'Max'];
            obj.DataTypeSet=dtSet;
            obj.UseClassDefault=false;
            obj.Default='[]';
            obj.pAssociatedDataTypePropertyName=dtPropName;
        end

        function setIsLockScale(obj)

            if obj.IsLockScale
                return;
            end

            obj.IsLockScale=true;
            obj.IsFacade=true;
            obj.IsNontunable=true;
            obj.Description=message('dspshared:FixptDialog:lockAgnstChanges').getString;
            obj.pBlockParameterName='LockScale';
            obj.IsLogical=true;
            obj.UseClassDefault=false;
            obj.Default='off';
        end

        function v=getValue(obj,sysObj)


            if obj.IsLockScale||obj.IsDesignMin||obj.IsDesignMax
                v=obj.pValue;
                return;
            end

            if obj.IsOverflowAction
                v=strcmp(get(sysObj,'OverflowAction'),'Saturate');
            elseif obj.IsDataType
                dtPropertyName=obj.Name;
                dtPropertyValue=sysObj.(dtPropertyName);
                if obj.pIsSimplifiedInterface
                    v=matlab.system.display.internal.DataTypeProperty.dataTypeToUdt(dtPropertyValue);
                elseif strcmp(dtPropertyValue,'Custom')
                    v=matlab.system.display.internal.DataTypeProperty.dataTypeToUdt(sysObj.(['Custom',dtPropertyName]));
                else
                    v=matlab.system.display.internal.DataTypeProperty.dataTypeToUdt(dtPropertyValue);
                end
            else
                v=getValue@matlab.system.display.internal.Property(obj,sysObj);
            end
        end

        function sysObj=setValue(obj,sysObj,v)


            if obj.IsLockScale||obj.IsDesignMin||obj.IsDesignMax
                obj.pValue=v;
                return;
            end

            if obj.IsOverflowAction
                if v
                    set(sysObj,'OverflowAction','Saturate');
                else
                    set(sysObj,'OverflowAction','Wrap');
                end
            elseif obj.IsDataType
                dtPropertyName=obj.Name;
                dt=matlab.system.display.internal.DataTypeProperty.udtToDataType(v);
                if obj.pIsSimplifiedInterface||ischar(dt)
                    sysObj.(dtPropertyName)=dt;
                else
                    sysObj.(dtPropertyName)='Custom';
                    sysObj.(['Custom',dtPropertyName])=dt;
                end
            else
                setValue@matlab.system.display.internal.Property(obj,sysObj,v);
            end
        end

        function v=isVisible(obj,sysObj)

            if obj.IsLockScale
                v=true;
            elseif obj.IsDesignMin||obj.IsDesignMax
                v=~sysObj.isInactiveProperty(obj.pAssociatedDataTypePropertyName);
            elseif obj.IsOverflowAction
                v=~sysObj.isInactiveProperty('OverflowAction');
            elseif obj.IsRoundingMethod
                v=~sysObj.isInactiveProperty('RoundingMethod');
            else
                v=isVisible@matlab.system.display.internal.Property(obj,sysObj);
            end
        end

        function addParameterValue(obj,sysObj,builder)

            if obj.IsRoundingMethod
                builder.addStringParameterValue('RoundingMethod',sysObj.RoundingMethod);
            elseif obj.IsOverflowAction
                builder.addStringParameterValue('OverflowAction',sysObj.OverflowAction);
            elseif obj.pIsSimplifiedInterface
                dtPropertyName=obj.Name;
                dt=sysObj.(dtPropertyName);

                if ischar(dt)
                    builder.addStringParameterValue(dtPropertyName,dt);
                else
                    builder.addLiteralParameterValue(dtPropertyName,dt.tostring);
                end
            elseif obj.IsDataType
                dtPropertyName=obj.Name;
                dt=sysObj.(dtPropertyName);
                builder.addStringParameterValue(dtPropertyName,dt);
                if strcmp(dt,'Custom')
                    customDT=sysObj.(['Custom',dtPropertyName]);
                    builder.addLiteralParameterValue(['Custom',dtPropertyName],customDT.tostring);
                end
            else
                addParameterValue@matlab.system.display.internal.Property(obj,sysObj,builder);
            end
        end

        function setDefault(obj,sysObj)


            if obj.DefaultSet
                return;
            end

            if~obj.UseClassDefault
                if obj.IsLogical
                    obj.pValue=strcmp(obj.Default,'on');
                elseif obj.IsStringSet
                    obj.pValue=obj.Default;
                else
                    obj.pValue=eval(obj.Default);
                end
                return;
            end

            propValue=sysObj.(obj.Name);
            obj.pValue=propValue;

            if obj.IsLogical


                if obj.IsOverflowAction
                    propValue=strcmp(propValue,'Saturate');
                end
                if isempty(propValue)||~propValue
                    obj.Default='off';
                else
                    obj.Default='on';
                end

            elseif obj.IsStringSet


                if isempty(propValue)
                    obj.Default=obj.StringSetValues{1};
                else
                    obj.Default=char(propValue);
                end

            elseif obj.IsDataType

                dtPropertyName=obj.Name;
                dtPropertyValue=propValue;
                if obj.pIsSimplifiedInterface
                    obj.Default=matlab.system.display.internal.DataTypeProperty.dataTypeToUdt(dtPropertyValue);
                elseif strcmp(dtPropertyValue,'Custom')
                    obj.Default=matlab.system.display.internal.DataTypeProperty.dataTypeToUdt(sysObj.(['Custom',dtPropertyName]));
                else
                    obj.Default=matlab.system.display.internal.DataTypeProperty.dataTypeToUdt(dtPropertyValue);
                end

            else
                setDefault@matlab.system.display.internal.Property(obj,sysObj);
            end
        end
    end

    methods(Hidden,Static)
        function udt=dataTypeToUdt(dt)
            if isstring(dt)&&isscalar(dt)
                dt=char(dt);
            end
            if ischar(dt)
                switch dt
                case{'Full precision','Internal rule'}
                    udt='Inherit: Inherit via internal rule';
                case 'Same as product'
                    udt='Inherit: Same as product output';
                otherwise
                    udt=['Inherit: ',dt];
                end
            else
                udt=strrep(dt.tostring,'numerictype','fixdt');
                udt=strrep(udt,'true','1');
                udt=strrep(udt,'false','0');
            end
        end

        function dt=udtToDataType(udt)
            if isstring(udt)&&isscalar(udt)
                udt=char(udt);
            end
            if ischar(udt)
                switch udt
                case 'Inherit: Inherit via internal rule'
                    dt='Full precision';
                case 'Inherit: Same as product output'
                    dt='Same as product';
                otherwise
                    dt=strrep(udt,'Inherit: ','');
                end
            else
                dt=eval(strrep(udt.tostring,'fixdt','numerictype'));
            end
        end
    end
end

