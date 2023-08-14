classdef PlatformDescriptor<handle




    properties(Constant)
        SystemMap=matlab.system.ui.SystemMap;
        SystemNameMap=matlab.system.ui.SystemNameMap;
    end

    methods(Access=protected)
        function obj=PlatformDescriptor

        end
    end

    methods
        function icon=getDialogIcon(~)%#ok<STOUT>
        end

        function str=getPlatformMsgEndString(~)
            str='.';
        end

        function id=getDialogIdentifier(~)
            id='';
        end

        function dialogTitle=getDialogTitle(obj)
            dialogTitle=getSystemObjectName(obj);
        end

        function errMsg=getDialogErrorMessage(~,e)
            errMsg=e.message;
        end

        function preview=isPreview(~)
            preview=false;
        end

        function validatePropertyValuesSet(~)

        end
    end

    methods(Abstract)
        getDisplayIconPath(obj)
        getHelpFunction(obj,systemName)
        getSystemObjectName(obj)
        getActionSystemObjectInstance(obj,action,actionData)
        [activeIndex,valueIndex]=getActiveEnumerationMembersAndValueIndex(obj,property)
        getSystemHandle(obj)
        setPropertyValue(obj,propName,propValue)
        getPropertyValue(obj,propName)
        setSystemObjectPropertyValue(obj,propName,propValue)
        isPropertyVisible(obj,propName)
        isPropertyEnabled(obj,propName)
        isPropertySetImmediate(obj)
        getSourceCodeLinkText(obj)
        getAutoSectionTitle(obj)
        getAutoSectionGroupTitle(obj)
        getPropertyGroups(obj,varargin)
    end

    methods(Static)
        function actionCache=getActionCache(action,actionTag,systemHandle)


            if isKey(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle)
                actionMap=getKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle);
            else
                actionMap=containers.Map;
                setKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle,actionMap);


                setKeyValue(matlab.system.ui.PlatformDescriptor.SystemNameMap,systemHandle,actionMap);
            end


            if isKey(actionMap,actionTag)
                actionCache=actionMap(actionTag);
            else
                actionData=matlab.system.display.ActionData(systemHandle);
                actionCache=struct('Action',action,'ActionData',actionData);
                actionMap(actionTag)=actionCache;%#ok<NASGU>
            end
        end

        function updateActionCache(action,actionTag,systemHandle)
            if isKey(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle)
                actionMap=getKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle);
                if isKey(actionMap,actionTag)
                    actionCache=actionMap(actionTag);
                    actionCache.Action=action;
                    actionMap(actionTag)=actionCache;%#ok<NASGU>
                end
            end
        end

        function registerActionCache(action,actionTag,systemHandle)


            if isKey(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle)
                actionMap=getKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle);
            else
                actionMap=containers.Map;
                setKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle,actionMap);


                setKeyValue(matlab.system.ui.PlatformDescriptor.SystemNameMap,systemHandle,actionMap);
            end


            if isKey(actionMap,actionTag)
                actionCache=actionMap(actionTag);
                actionCache.Action=action;
            else
                actionData=matlab.system.display.ActionData(systemHandle);
                actionCache=struct('Action',action,'ActionData',actionData);
            end
            actionMap(actionTag)=actionCache;%#ok<NASGU>
        end

        function actionCache=findActionCache(actionTag,systemHandle)





            actionCache=[];


            if isKey(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle)
                actionMap=getKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle);
                actionCache=actionMap(actionTag);
                return;
            end

            if isKey(matlab.system.ui.PlatformDescriptor.SystemNameMap,systemHandle)
                actionMap=getKeyValue(matlab.system.ui.PlatformDescriptor.SystemNameMap,systemHandle);
                mapKeys=keys(actionMap);
                mapValues=values(actionMap);
                newActionMap=containers.Map;
                for i=1:length(actionMap)
                    newActionTag=mapKeys{i};
                    newAction=mapValues{i}.Action;
                    newActionData=matlab.system.display.ActionData(systemHandle);
                    newActionCache=struct('Action',newAction,'ActionData',newActionData);
                    newActionMap(newActionTag)=newActionCache;
                end
                setKeyValue(matlab.system.ui.PlatformDescriptor.SystemMap,systemHandle,newActionMap);
                actionCache=newActionMap(actionTag);
            end
        end
    end
end
