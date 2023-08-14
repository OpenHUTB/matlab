classdef SimulinkPreviewDescriptor<matlab.system.ui.PlatformDescriptor




    properties(SetAccess=protected)
        SystemObject;
        DialogProperties;
        SystemObjectError;
    end

    methods(Hidden)
        function obj=SimulinkPreviewDescriptor(sysobj)
            mlock;

            ipws=matlab.system.internal.InactiveWarningSuppressor(sysobj);

            try

                systemName=class(sysobj);
                groups=matlab.system.display.internal.Memoizer.getBlockPropertyGroups(systemName);
                dialogProps=matlab.system.ui.getPropertyList(systemName,groups,...
                'SetDescription',true);
                propMap=struct();
                for propInd=1:numel(dialogProps)
                    property=dialogProps(propInd);
                    propName=property.Name;


                    if property.UseClassDefault
                        property.setDefault(sysobj);
                    else
                        property.setValue(sysobj,dialogToObjectValue(obj,property,property.Default));
                    end

                    propMap.(propName)=struct('Object',property,...
                    'DialogValue',propertyToDialogValue(property,property.Default),...
                    'PropertySetError',[]);
                end

                obj.DialogProperties=propMap;
            catch e
                obj.SystemObjectError=e;
            end
            obj.SystemObject=sysobj;
        end

        function newObj=regenerate(obj,newSysObj)
            newObj=matlab.system.ui.SimulinkPreviewDescriptor(newSysObj);




            propsOld=obj.DialogProperties;
            propsNew=newObj.DialogProperties;
            if~isempty(propsOld)
                propNames=fieldnames(propsOld);
                for k=1:numel(propNames)
                    propName=propNames{k};

                    if isfield(propsNew,propName)
                        try
                            setDialogValueOnProperty(newObj,propName,propsOld.(propName).DialogValue);
                        catch

                            err=propsOld.(propName).PropertySetError;
                            if~isempty(err)
                                newObj.DialogProperties.(propName).PropertySetError=err;
                            end
                        end
                    end
                end
            end
        end

        function preview=isPreview(~)
            preview=true;
        end

        function name=getSystemObjectName(obj)
            name=class(obj.SystemObject);
        end

        function groups=getPropertyGroups(~,varargin)
            groups=matlab.system.display.internal.Memoizer.getBlockPropertyGroups(varargin{:});
        end

        function sysObj=getActionSystemObjectInstance(obj,~,~)
            sysObj=obj.SystemObject;
            sysObj.setExecPlatformIndex(true);
        end

        function[activeIndex,valueIndex]=getActiveEnumerationMembersAndValueIndex(obj,property)
            activeIndex=getActiveEnumerationMemberIndices(obj.SystemObject,property.Name);
            allMembers=enumeration(property.EnumerationName);
            activeMembers=allMembers(activeIndex);
            valueIndex=find(activeMembers==obj.SystemObject.(property.Name));
        end

        function systemHandle=getSystemHandle(obj)
            systemHandle=obj.SystemObject;
        end

        function iconpath=getDisplayIconPath(~)
            iconpath=fullfile('toolbox','shared','dastudio','resources',...
            'SimulinkModelIcon.png');
        end

        function errMsg=getDialogErrorMessage(obj,e)
            if~isempty(obj.SystemObjectError)
                errMsg=obj.SystemObjectError.message;
            else
                errMsg=e.message;
            end
        end

        function prompt=getPropertyPrompt(obj,propName)
            property=obj.DialogProperties.(propName).Object;
            prompt=property.Description;
            if~property.IsLogical&&~matlab.system.ui.isMessageID(prompt)
                prompt=[prompt,':'];
            end
        end

        function v=getSourceCodeLinkText(~)
            v=message('SystemBlock:MATLABSystem:SystemBlockSourceCodeLinkText').getString;
        end

        function v=getAutoSectionTitle(~)
            v=message('SystemBlock:MATLABSystem:SystemBlockDialogAutoSectionTitle').getString;
        end

        function v=getAutoSectionGroupTitle(~)
            v=message('SystemBlock:MATLABSystem:SystemBlockDialogAutoSectionGroupTitle').getString;
        end

        function v=getFiSettingsPanelTitle(~)
            v=message('SystemBlock:MATLABSystem:SystemBlockDialogFiPanelTitle').getString;
        end

        function setDialogValueOnProperty(obj,propName,propValue)
            obj.DialogProperties.(propName).DialogValue=propValue;
            property=obj.DialogProperties.(propName).Object;
            property.setValue(obj.SystemObject,dialogToObjectValue(obj,property,propValue));
        end

        function setPropertyValue(obj,propName,propValue)




            try
                metaclass(obj.SystemObject);
            catch
                return;
            end



            try
                setDialogValueOnProperty(obj,propName,propValue);
                obj.DialogProperties.(propName).PropertySetError=[];
            catch e
                obj.DialogProperties.(propName).PropertySetError=e;
            end
        end

        function validatePropertyValuesSet(obj)



            props=obj.DialogProperties;
            if~isempty(props)
                propNames=fieldnames(props);
                for k=1:numel(propNames)
                    propName=propNames{k};
                    err=props.(propName).PropertySetError;
                    if~isempty(err)
                        rethrow(err);
                    end
                end
            end
        end

        function setSystemObjectPropertyValue(obj,propName,propValue)
            obj.setPropertyValue(propName,propValue);
        end

        function val=getPropertyValue(obj,propName,~)
            val=obj.DialogProperties.(propName).DialogValue;
        end

        function vals=getStringSetValues(~,property)
            vals=matlab.system.ui.ParamUtils.stringSetValuesToDialogValues(...
            property.BlockParameterName,property.StringSetValues);
        end

        function flag=isPropertyVisible(obj,propName)
            property=obj.DialogProperties.(propName).Object;
            flag=property.isVisible(obj.SystemObject);
        end

        function flag=isPropertyEnabled(obj,propName)
            property=obj.DialogProperties.(propName).Object;
            flag=~(property.IsReadOnly||(obj.SystemObject.isLocked&&property.IsNontunable));




            if flag&&strcmp(propName,'InputFimath')
                flag=getPropertyValue(obj,'BlockDefaultFimath',false)==1;
            end
        end

        function val=isCalledFromBlockParameters(~)
            val=false;
        end

        function[fcnName,fcnArgs]=getHelpFunction(~,system)
            fcnName='doc';
            fcnArgs={system};
        end

        function isImmediate=isPropertySetImmediate(~)
            isImmediate=false;
        end

        function propValue=dialogToObjectValue(obj,property,propValue)

            if property.IsStringSet&&isnumeric(propValue)
                vals=property.StringSetValues;
                propValue=vals{propValue+1};
            elseif property.IsEnumeration&&isnumeric(propValue)
                activeMembers=property.StringSetValues;
                if property.IsEnumerationDynamic
                    activeIdx=getActiveEnumerationMemberIndices(obj.SystemObject,property.Name);
                    activeMembers=activeMembers(activeIdx);
                end

                propValue=activeMembers{propValue+1};
            elseif~property.IsLogical&&~property.IsStringSet&&~property.IsStringLiteral

                propValue=evalin('base',['[',propValue,']']);
            elseif property.IsLogical
                if strcmp(propValue,'on')
                    propValue=true;
                elseif strcmp(propValue,'off')
                    propValue=false;
                end
            end
        end
    end
end

function val=propertyToDialogValue(property,val)


    if property.IsLogical
        val=strcmp(val,'on');
    elseif strcmp(property.Name,'BlockDefaultFimath')

        val=matlab.system.ui.ParamUtils.paramValueToDialogIndex('BlockDefaultFimath',val);
    end
end
