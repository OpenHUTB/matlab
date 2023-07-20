classdef ModelWorkspace<handle




    properties(Access=private)
        mValSrcMgr;
        mData;
        mSrcObj;
        mDictSys;
        mMdlName;
        mNameMap;
    end


    methods(Static,Access=public)

    end


    methods(Access=public)
        function this=ModelWorkspace(mdlName,valSrcMgr)
            this.mMdlName=mdlName;
            this.mValSrcMgr=valSrcMgr;
            this.mDictSys=get_param(mdlName,'DictionarySystem');
            this.mData=containers.Map;
            this.mNameMap=containers.Map;

            mdlObj=get_param(mdlName,'Object');
            children=mdlObj.getHierarchicalChildren();
            for i=1:numel(children)
                if isa(children(i),'DAStudio.WorkspaceNode')
                    this.mSrcObj=children(i);
                    break;
                end
            end
            [this.mData,this.mNameMap]=this.generateChildren();

        end

        function isOverridden=isValueOverridden(thisObj,slidObj)
            isOverridden=false;
            try
                if isequal(get_param(thisObj.mMdlName,'HasValueManager'),'on')
                    valSrcMgr=get_param(thisObj.mMdlName,'ValueManager');
                    if~isempty(valSrcMgr)
                        effValue=valSrcMgr.getActiveValueThrowError(slidObj.UUID);
                        if~isempty(effValue)
                            isOverridden=true;
                        end
                    end
                end
            catch ME
            end
        end

        function tooltip=getOverriddenTooltip(thisObj,slidProxy,slidObj,propName)
            tooltip='';
            try
                if isequal(get_param(thisObj.mMdlName,'HasValueManager'),'on')
                    valSrcMgr=get_param(thisObj.mMdlName,'ValueManager');
                    if~isempty(valSrcMgr)
                        overlay=valSrcMgr.getEffectiveOverlayThrowError(slidObj.UUID);
                        effectiveOverlay=overlay.getName;
                        if isequal(propName,'Value')
                            defVal=slidProxy.getValue();
                            defaultValue=DAStudio.MxStringConversion.convertToString(defVal);
                            effVal=valSrcMgr.getActiveValueThrowError(slidObj.UUID);
                            effectiveValue=DAStudio.MxStringConversion.convertToString(effVal);

                            tooltip=[effectiveValue,newline...
                            ,DAStudio.message('Simulink:dialog:OverriddenValue',...
                            defaultValue,...
                            effectiveOverlay)];
                        else
                            propVal=slidProxy.getPropValue(propName);
                            tooltip=[propVal,newline...
                            ,DAStudio.message('Simulink:dialog:Overridden',...
                            effectiveOverlay)];
                        end
                    end
                end
            catch
                tooltip=DAStudio.message(ME.message);
            end
        end

        function mfModel=getSourceModel(thisObj)

            mfModel=get_param(thisObj.mMdlName,'ValueSourceMFModel');
        end

        function valSrcMgr=getValueSrcManager(thisObj)
            valSrcMgr=get_param(thisObj.mMdlName,'ValueManager');
        end

        function refreshSources(thisObj)
            valSrcMgr=thisObj.getValueSrcManager();
            try
                valSrcMgr.updateAllOverlayCache();
            catch ME
                errordlg(ME.message,DAStudio.message('sl_valuesrc:messages:ValueSetMgrTitle'));
                rethrow(ME);
            end
            thisObj.refreshValues();
        end

        function icon=getDisplayIcon(thisObj)
            icon=thisObj.mSrcObj.getDisplayIcon();
        end

        function[cols,sortCol]=getColumns(thisObj)
            cols={' ','Name','Value','DataType','Min','Max','Dimensions','Complexity'};
            sortCol='Name';
        end

        function defObj=getDefinitionObj(thisObj,name)
            try
                if~thisObj.mNameMap.isKey(name)

                    [thisObj.mData,thisObj.mNameMap]=thisObj.generateChildren();
                end
                uuid=thisObj.mNameMap(name);
                defObj=thisObj.mData(uuid);
            catch ME
                defObj=[];
            end
        end

        function effObj=getEffectiveObject(thisObj,name,overriddenVal)
            try
                uuid=thisObj.mNameMap(name);
                defObj=thisObj.mData(uuid);
                varObj=defObj.getVariable();
                if~isobject(varObj)
                    mapParams=thisObj.mDictSys.Parameter;
                    objSlid=mapParams.getByKey(name);
                    effObj=sl_valuesrc.internal.slidProxy(objSlid,overriddenVal,thisObj);
                else
                    effObj=defObj;
                end
            catch ME
                effObj=[];
            end
        end

        function value=getValue(thisObj,name)
        end

        function children=getChildren(thisObj,component,tab,userData)
            [thisObj.mData,thisObj.mNameMap]=thisObj.generateChildren();
            values=thisObj.mData.values;
            if~isempty(values)
                for i=1:numel(values)
                    children(i)=values{i};
                end
            else
                children=[];
            end
        end

        function applyChanges(thisObj,objName,objValue)
            bd=get_param(thisObj.mMdlName,'Object');
            wks=bd.getWorkspace;
            wks.assignin(objName,objValue);
            try
                uuid=thisObj.mNameMap(objName);
                row=thisObj.mData(uuid);
                thisObj.mValSrcMgr.updateListRow(row);
            catch
            end
        end

        function refreshValues(thisObj)
            ed=DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent','');
        end

        function buildDir=getBuildDir(thisObj,filename)
            buildDir='';
            [~,~,fileExtension]=fileparts(filename);
            if strcmp(fileExtension,'.cdfx')
                if exist(RTW.getBuildDir(thisObj.mMdlName).BuildDirectory,'dir')~=7
                    DAStudio.error('codedescriptor:core:ModelIsNotBuilt',thisObj.mMdlName);
                end
                buildDir=RTW.getBuildDir(thisObj.mMdlName).BuildDirectory;
            end
        end

        function updateDefinitions(thisObj,eventData,op)
            switch(op)
            case 'mod'
                if thisObj.mData.isKey(eventData.uuid)
                    row=thisObj.mData(eventData.uuid);
                    thisObj.mValSrcMgr.updateListRow(row);
                end
            case 'add'
                thisObj.mValSrcMgr.updateListRow([]);
            case 'del'
                thisObj.mValSrcMgr.updateListRow([]);
            end
        end

        function rtn=cacheUpdateEvent(thisObj,~)

            rtn=true;
        end

        function setValueSrcErrorChecking(thisObj,bEnable)
            bd=get_param(thisObj.mMdlName,'Object');
            wks=bd.getWorkspace;
            wks.valueSourceErrorCheckingInCommandLineAPI=bEnable;
        end

        function rtn=getValueSrcErrorChecking(thisObj)
            bd=get_param(thisObj.mMdlName,'Object');
            wks=bd.getWorkspace;
            rtn=wks.valueSourceErrorCheckingInCommandLineAPI;
        end
    end


    methods(Access=private)
        function[children,nameMap]=generateChildren(thisObj)
            children=containers.Map;
            nameMap=containers.Map;
            bd=get_param(thisObj.mMdlName,'Object');
            wks=bd.getWorkspace;
            valSrcMgr=get_param(thisObj.mMdlName,'ValueManager');
            params=valSrcMgr.getPossibleTunableParamList();
            slidParams=thisObj.mDictSys.Parameter;
            preErrorCheckingFlag=thisObj.getValueSrcErrorChecking();




            thisObj.setValueSrcErrorChecking(false);
            for idxChild=1:numel(params)
                objName=params{idxChild};
                slidObj=slidParams.getByKey(objName);
                nameMap(objName)=slidObj.UUID;
                try
                    wksObj=wks.getVariable(objName);
                    if~isa(wksObj,'Simulink.Parameter')
                        wksObj=valSrcMgr.getDefaultValue(slidObj.UUID);
                    end
                catch me



                    wksObj=valSrcMgr.getDefaultValue(slidObj.UUID);
                end
                if thisObj.mData.isKey(slidObj.UUID)
                    child=thisObj.mData(slidObj.UUID);
                    child.init(slidObj,wksObj);
                    children(slidObj.UUID)=child;
                else
                    children(slidObj.UUID)=sl_valuesrc.internal.slidProxy(slidObj,wksObj,thisObj);
                end
            end
            thisObj.setValueSrcErrorChecking(preErrorCheckingFlag);
        end
    end
end
