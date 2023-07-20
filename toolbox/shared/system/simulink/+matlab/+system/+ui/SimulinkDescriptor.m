classdef SimulinkDescriptor<matlab.system.ui.PlatformDescriptor




    properties(SetAccess=protected)
        BlockHandle;
    end

    methods(Hidden)

        function obj=SimulinkDescriptor(blockHandle)
            mlock;
            if nargin>0
                obj.BlockHandle=blockHandle;
            end
        end

        function name=getSystemObjectName(obj)
            name=get_param(obj.BlockHandle,'System');


            if strcmp(name,'<Enter System Class Name>')||strcmp(name,'MATLAB_System')
                name='';
            end
        end

        function groups=getPropertyGroups(~,varargin)
            groups=matlab.system.display.internal.Memoizer.getBlockPropertyGroups(varargin{:});
        end

        function sysObj=getActionSystemObjectInstance(obj,action,actionData)
            sysObj=matlab.system.ui.SimulinkDescriptor.getBlockActionSystemObjectInstance(...
            obj.BlockHandle,getSystemObjectName(obj),action,actionData);
        end

        function[activeIndex,valueIndex]=getActiveEnumerationMembersAndValueIndex(obj,property)













            assert(property.IsEnumerationDynamic);


            values=struct();

            propertyListFcn=str2func(property.EnumerationName+".propertiesAffectingVisibility");
            propertyList=cellstr(propertyListFcn());

            maskObject=matlab.system.ui.SimulinkDescriptor.getBlockMaskObject(obj.BlockHandle);
            adapter=matlab.system.ui.Adapter(getSystemObjectName(obj));

            for n=1:numel(propertyList)
                paramName=propertyList{n};
                maskParam=getParameter(maskObject,paramName);
                paramValue=maskParam.Value;

                if strcmp(maskParam.Type,'checkbox')
                    paramValue=strcmp(paramValue,'on');
                end





                values=adapter.set(values,paramName,paramValue);
            end

            activeMembersFcn=str2func(property.EnumerationName+".activeMembers");
            activeMembers=activeMembersFcn(values);
            allMembers=enumeration(property.EnumerationName);
            [~,~,activeIndex]=intersect(activeMembers,allMembers,'stable');

            enumParam=getParameter(maskObject,property.Name);
            valueIndex=find(strcmp(enumParam.TypeOptions,enumParam.Value));

            activeIndex=activeIndex(:);
            valueIndex=valueIndex(:);
        end

        function systemHandle=getSystemHandle(obj)
            systemHandle=obj.BlockHandle;
        end

        function maskObject=getMaskObject(obj)
            maskObject=matlab.system.ui.SimulinkDescriptor.getBlockMaskObject(obj.BlockHandle);
        end

        function iconpath=getDisplayIconPath(~)
            iconpath=fullfile('toolbox','shared','dastudio','resources',...
            'SimulinkModelIcon.png');
        end

        function v=getSourceCodeLinkText(~)
            v=message('SystemBlock:MATLABSystem:SystemBlockSourceCodeLinkText').getString;
        end

        function v=getAutoSectionTitle(~)
            v=message('SystemBlock:MATLABSystem:SystemBlockDialogAutoSectionTitle').getString;
        end


        function v=getFiSettingsPanelTitle(~)

            v=message('SystemBlock:MATLABSystem:SystemBlockDialogFiPanelTitle').getString;
        end

        function v=getAutoSectionGroupTitle(~)
            v=message('SystemBlock:MATLABSystem:SystemBlockDialogAutoSectionGroupTitle').getString;
        end

        function val=getPropertyValue(obj,paramName,isLogicalProp)
            val=get_param(obj.BlockHandle,paramName);

            if isLogicalProp
                val=strcmp(val,'on');
            else



                val=matlab.system.ui.ParamUtils.paramValueToDialogIndex(paramName,val);
            end
        end

        function prompt=getPropertyPrompt(obj,paramName)
            param=matlab.system.ui.SimulinkDescriptor.getBlockMaskParameter(obj.BlockHandle,paramName);
            prompt=param.Prompt;
        end

        function setPropertyValue(~,~,~)
        end

        function setSystemObjectPropertyValue(obj,paramName,paramValue)


            wOrig=warning('off','MATLAB:system:nonRelevantProperty');
            wOC=onCleanup(@()warning(wOrig));

            set_param(obj.BlockHandle,paramName,paramValue);
        end

        function vals=getStringSetValues(~,property)
            if property.IsLocalizedStringSet
                vals=property.LocalizedStringSetValues;
            else
                vals=matlab.system.ui.ParamUtils.stringSetValuesToDialogValues(...
                property.BlockParameterName,property.StringSetValues);
            end
        end

        function flag=isPropertyVisible(obj,paramName)
            param=matlab.system.ui.SimulinkDescriptor.getBlockMaskParameter(obj.BlockHandle,paramName);
            flag=~isempty(param)&&strcmp(param.Visible,'on');
        end

        function flag=isPropertyEnabled(obj,paramName)
            param=matlab.system.ui.SimulinkDescriptor.getBlockMaskParameter(obj.BlockHandle,paramName);
            flag=~isempty(param)&&param.isEnabledOnDialog;
        end

        function updateWidgetLabelVisibilities(obj,dlg)
            maskObject=getMaskObject(obj);
            for param=maskObject.Parameters
                labelWidgetTag=[param.Name,'Label'];
                dlg.setVisible(labelWidgetTag,strcmp(param.Visible,'on'));
            end
        end

        function val=isCalledFromBlockParameters(obj)
            val=strcmp(get_param(obj.BlockHandle,'BlockParametersCall'),'on');
        end

        function[fcnName,fcnArgs]=getHelpFunction(obj,~)
            fcnName='slhelp';
            fcnArgs={obj.BlockHandle};
        end

        function id=getDialogIdentifier(obj)
            id=fullfile(get(obj.BlockHandle,'Path'),get(obj.BlockHandle,'Name'));
        end

        function isImmediate=isPropertySetImmediate(~)
            isImmediate=false;
        end
    end

    methods(Static)
        function sysObj=getBlockActionSystemObjectInstance(hBlock,systemName,action,actionData)


            sysObj=feval(systemName);
            sysObj.setExecPlatformIndex(true);



            adapter=matlab.system.ui.Adapter(systemName);
            maskObject=matlab.system.ui.SimulinkDescriptor.getBlockMaskObject(hBlock);

            ipws=matlab.system.internal.InactiveWarningSuppressor(sysObj);

            for param=maskObject.Parameters
                if strcmp(param.ReadOnly,'off')
                    paramName=param.Name;
                    v=get_param(hBlock,paramName);
                    if strcmp(param.Type,'checkbox')
                        v=strcmp(v,'on');
                    end
                    isUDTInheritString=strncmp(param.Type,'unidt',5)&&strncmp(v,'Inherit:',8);
                    if~isUDTInheritString&&strcmp(param.Evaluate,'on')
                        try
                            v=slResolve(v,hBlock);
                        catch resolveErr
                            resolveErrorFcn=action.PropertyResolveErrorFcn;
                            if~isempty(resolveErrorFcn)
                                err=MException(message('SystemBlock:MATLABSystem:SystemBlockInstanceUnresolvableExpression',paramName,v));
                                err=addCause(err,resolveErr);
                                resolveErrorFcn(actionData,err,paramName);
                            end
                            continue;
                        end
                    end
                    adapter.set(sysObj,paramName,v);
                end
            end
        end

        function maskObject=getBlockMaskObject(hBlock)
            maskObject=Simulink.Mask.get(hBlock);




            if~isempty(maskObject.BaseMask)
                maskObject=maskObject.BaseMask;
            end
        end

        function maskParameter=getBlockMaskParameter(hBlock,paramName)
            maskObject=matlab.system.ui.SimulinkDescriptor.getBlockMaskObject(hBlock);
            maskParameter=maskObject.getParameter(paramName);
        end
    end
end
