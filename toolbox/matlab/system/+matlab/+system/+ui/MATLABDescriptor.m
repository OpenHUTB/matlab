classdef MATLABDescriptor<matlab.system.ui.PlatformDescriptor




    properties(SetAccess=protected)
        SystemObject;
        DialogProperties;
    end

    methods(Hidden)
        function obj=MATLABDescriptor(sysobj)
            mlock;

            if nargin>0
                try
                    if ischar(sysobj)
                        systemName=sysobj;
                    else
                        systemName=class(sysobj);
                        if matlab.system.isSystemObject(sysobj)
                            ipws=matlab.system.internal.InactiveWarningSuppressor(sysobj);%#ok<NASGU> stack guard
                        end
                    end
                    groups=matlab.system.display.internal.Memoizer.getPropertyGroups(systemName);
                    dialogProps=matlab.system.ui.getPropertyList(systemName,groups,...
                    'SetDescription',true);
                    for propInd=1:numel(dialogProps)
                        property=dialogProps(propInd);
                        propName=property.Name;
                        if~isprop(sysobj,propName)
                            continue;
                        end
                        propMap.(propName)=property;
                    end
                    obj.DialogProperties=propMap;
                catch e %#ok<NASGU>
                end

                obj.SystemObject=sysobj;
            end
        end

        function name=getSystemObjectName(obj)
            name=class(obj.SystemObject);
        end

        function groups=getPropertyGroups(~,varargin)
            groups=matlab.system.display.internal.Memoizer.getPropertyGroups(varargin{:});
        end

        function sysObj=getActionSystemObjectInstance(obj,~,~)
            sysObj=obj.SystemObject;
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
            'MatlabIcon.png');
        end

        function prompt=getPropertyPrompt(obj,propName)
            property=obj.DialogProperties.(propName);
            prompt=property.Description;
            if~property.IsLogical&&~matlab.system.ui.isMessageID(prompt)
                prompt=[prompt,':'];
            end
        end

        function v=getSourceCodeLinkText(~)
            v=message('MATLAB:system:openInEditor').getString;
        end

        function v=getAutoSectionTitle(~)
            v=message('MATLAB:system:matlabAutoSectionTitle').getString;
        end

        function v=getAutoSectionGroupTitle(~)
            v=message('MATLAB:system:matlabAutoSectionGroupTitle').getString;
        end

        function setPropertyValue(obj,propName,propValue)



            try
                property=obj.DialogProperties.(propName);
                if property.IsStringSet
                    vals=getStringSetValues(obj,property);
                    propValue=vals{propValue+1};
                elseif property.IsEnumeration
                    activeMembers=property.StringSetValues;
                    if property.IsEnumerationDynamic
                        activeIdx=getActiveEnumerationMemberIndices(obj.SystemObject,propName);
                        activeMembers=activeMembers(activeIdx);
                    end
                    propValue=activeMembers{propValue+1};
                elseif~property.IsLogical&&~property.IsStringLiteral&&isempty(property.StaticRange)
                    propValue=eval(['[',propValue,']']);
                end
                property.setValue(obj.SystemObject,propValue);
            catch e
                err=matlab.system.ui.DialogManager.removeHyperlinks(e.message);
                errordlg(err,message('MATLAB:system:DialogErrorSettingProperty').getString);
            end
        end

        function val=getPropertyValue(obj,propName,~)
            property=obj.DialogProperties.(propName);
            val=property.getValue(obj.SystemObject);
            if~property.IsLogical&&~property.IsStringSet&&~property.IsStringLiteral
                val=matlab.system.internal.toExpression(val,'Split',false);
            end
        end

        function setSystemObjectPropertyValue(obj,propName,propValue)
            obj.setPropertyValue(propName,propValue);
        end

        function vals=getStringSetValues(obj,property)


            propName=property.Name;
            if~property.IsMustBeMember&&~property.IsEnumeration
                propStringSet=obj.SystemObject.([propName,'Set']);
                vals=propStringSet.getAllowedValues;
                if isstring(vals)
                    vals=vals.cellstr;
                end
            else
                vals=property.StringSetValues;
            end
        end

        function flag=isPropertyVisible(obj,propName)
            property=obj.DialogProperties.(propName);
            flag=property.isVisible(obj.SystemObject);
        end

        function flag=isPropertyEnabled(obj,propName)
            property=obj.DialogProperties.(propName);
            flag=~(property.IsReadOnly||(obj.SystemObject.isLocked&&property.IsNontunable));
        end

        function val=isCalledFromBlockParameters(~)
            val=false;
        end

        function[fcnName,fcnArgs]=getHelpFunction(~,system)
            fcnName='doc';
            fcnArgs={system};
        end

        function isImmediate=isPropertySetImmediate(~)
            isImmediate=true;
        end
    end
end
