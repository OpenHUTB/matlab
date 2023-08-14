classdef ValueSrcManager<handle




    properties(Constant)
    end

    properties(Access=private)
        mWin=[];
        mSrcListCmpt;
        mSrcListObj;
        mMainListCmpt;
        mMainListObj;
        mDetailsCmpt;
        mDetailsObj;
        mSourceList;
mModelCloseListeners
    end


    methods(Static,Access=private)


    end
    methods(Static,Access=public)

        function hWin=launch(srcName)
            hWin=[];
            persistent vsm;
            if slfeature('MWSValueSource')>0
                if isempty(vsm)
                    vsm=sl_valuesrc.ValueSrcManager();
                end
                if nargin<1
                    srcName='';
                end
                hWin=vsm.show(srcName);
            end
        end

    end

    methods(Access=public)

        function close(thisObj)
            if~isvalid(thisObj.mMainListCmpt)||~isvalid(thisObj.mWin)
                thisObj.mWin.delete();
            else
                thisObj.mWin.close();
                thisObj.mWin.delete();
            end
        end

        function doCreate(thisObj)
            thisObj.mSrcListObj.doCreate();
        end

        function doDuplicate(thisObj)
        end

        function doDelete(thisObj)
            thisObj.mSrcListObj.doDelete();
        end

        function doRemoveEntry(thisObj)
            thisObj.mMainListObj.doRemoveEntry();
        end

        function doAddSource(thisObj)
            thisObj.mSrcListObj.addSource();
        end

        function doRemoveSource(thisObj)
            thisObj.mSrcListObj.delSource();
        end

        function doTopPriority(thisObj)
            thisObj.mSrcListObj.topPriority();
        end

        function doIncrPriority(thisObj)
            thisObj.mSrcListObj.incrPriority();
        end

        function doDecrPriority(thisObj)
            thisObj.mSrcListObj.decrPriority();
        end

        function doRefreshSource(thisObj)
            thisObj.mSrcListObj.refreshSources();
        end

        function handleSourceChange(thisObj,src,selection)
            if~isempty(thisObj.mWin)&&isvalid(thisObj.mWin)&&...
                isvalid(thisObj.mSrcListCmpt)&&...
                isvalid(thisObj.mMainListCmpt)&&...
                isvalid(thisObj.mDetailsCmpt)
                thisObj.mMainListObj.doSourceChange(src,selection);
                thisObj.mSrcListObj.setSelected(selection);

                thisObj.mDetailsObj.setSelected(selection);

                contextObj=thisObj.mWin.getContextObject;
                contextObj.setSelected(selection);
                thisObj.adjustToolstrip(selection);
            end
        end

        function adjustToolstrip(thisObj,selection)


            if~isempty(selection)&&any(ismember(methods(selection{1}),'adjustToolstrip'))
                st=thisObj.mWin.getStudio();
                toolstrip=st.getToolStrip();
                selection{1}.adjustToolstrip(toolstrip,selection);
            end
        end

        function adjustToolstripAction(thisObj,action)

            selection=thisObj.mSrcListObj.getSelected();

            if isequal(numel(selection),1)
                if any(ismember(methods(selection{1}),'adjustToolstripAction'))
                    selection{1}.adjustToolstripAction(action);
                end
            end
        end

        function r=handleListSelectionChange(thisObj,src,selection)
            if thisObj.mMainListObj.setSelected(selection)

                contextObj=thisObj.mWin.getContextObject;
                contextObj.setSelected(selection);

                thisObj.mDetailsObj.setSelected(selection);
            end
        end

        function r=refreshSources(thisObj)
            thisObj.mSrcListObj.refreshList();
        end

        function updateListRow(thisObj,listrow)
            if isempty(listrow)
                thisObj.mMainListCmpt.update
            else
                if isvalid(thisObj.mMainListCmpt)
                    thisObj.mMainListCmpt.update(listrow);
                end
                thisObj.mDetailsObj.refresh(listrow);
            end
        end

        function updateDetails(thisObj,obj)
            if~isempty(obj)
                thisObj.mDetailsObj.refresh(obj);
            end
        end

        function syncEventListeners(thisObj,listSourceNames,listSourceObjs)

            keys=thisObj.mSourceList.keys;
            for j=1:numel(keys)
                if~any(ismember(listSourceNames,keys{j}))
                    thisObj.removeListeners(keys{j},thisObj.mSourceList(keys{j}));
                end
            end

            for i=1:numel(listSourceNames)
                if~thisObj.mSourceList.isKey(listSourceNames{i})||...
                    ~isequal(thisObj.mSourceList(listSourceNames{i}),listSourceObjs{i})
                    thisObj.addListeners(listSourceNames{i},listSourceObjs{i});
                end
            end
        end

    end

    methods(Access=private)

        function this=ValueSrcManager()
            this.mSourceList=containers.Map;
            this.mModelCloseListeners=containers.Map;
            constructUI(this);
        end

        function hWin=show(thisObj,srcName)

            if isempty(thisObj.mWin)||~isvalid(thisObj.mMainListCmpt)
                thisObj.constructUI();
            end
            if~isempty(srcName)
                thisObj.mSrcListObj.selectSource(srcName);
            end
            thisObj.mWin.show;
            hWin=thisObj.mWin;
        end

        function updateWindow(thisObj)
            confObj=studio.WindowConfiguration;
            confObj=thisObj.setWindowTitle(confObj);
            thisObj.mWin.updateConfiguration(confObj);
        end

        function constructUI(thisObj)
            if~isempty(thisObj.mWin)&&isvalid(thisObj.mWin)
                thisObj.mWin.delete();
            end

            confObj=thisObj.initToolstrip();
            confObj=thisObj.setWindowTitle(confObj);
            thisObj.mWin=studio.Window(confObj);

            contextObj=thisObj.mWin.getContextObject;
            contextObj.setController(thisObj);

            thisObj.initSrcPane();
            thisObj.initMainList();

            thisObj.initDetailsPane();

            thisObj.mMainListCmpt.onSelectionChange=@(src,selection)thisObj.handleListSelectionChange(src,selection);

        end

        function confObj=setWindowTitle(thisObj,confObj)
            title=message('sl_valuesrc:messages:ValueSetMgrTitle').getString;

            confObj.Title=title;
            confObj.Icon=fullfile(matlabroot,'toolbox','simulink','sl_valuesrc','+sl_valuesrc','valuesrcPlugin','resources','icons','ValueSetMgr.png');
        end

        function initSrcPane(thisObj)
            thisObj.mSrcListCmpt=GLUE2.DDGComponent('SourceList');
            thisObj.mSrcListCmpt.HideTitle=true;
            thisObj.mSrcListCmpt.UserMoveable=false;
            thisObj.mSrcListCmpt.UserClosable=false;
            thisObj.mSrcListCmpt.AllowMinimize=false;
            thisObj.mWin.addComponent(thisObj.mSrcListCmpt,'left');
            fcnSelect=@(src,selection)thisObj.handleSourceChange(src,selection);
            thisObj.mSrcListObj=sl_valuesrc.internal.SourceList(thisObj.mSrcListCmpt,fcnSelect,thisObj);
            thisObj.mSrcListCmpt.updateSource(thisObj.mSrcListObj);
        end

        function initMainList(thisObj)
            thisObj.mMainListCmpt=GLUE2.SpreadSheetComponent('ValueSrcMainList');
            thisObj.mWin.addComponent(thisObj.mMainListCmpt,'center');
            thisObj.mMainListObj=sl_valuesrc.internal.MainList(thisObj.mMainListCmpt);
        end

        function initDetailsPane(thisObj)
            title=message('sl_valuesrc:messages:DetailsPaneTitle').getString;
            thisObj.mDetailsCmpt=GLUE2.DDGComponent(title);
            thisObj.mDetailsCmpt.UserClosable=false;
            thisObj.mDetailsCmpt.AllowMinimize=false;
            thisObj.mWin.addComponent(thisObj.mDetailsCmpt,'right');

            thisObj.mDetailsObj=sl_valuesrc.internal.DetailsPane(thisObj.mDetailsCmpt);
            thisObj.mDetailsCmpt.updateSource(thisObj.mDetailsObj);
        end

        function confObj=initToolstrip(thisObj)
            confObj=studio.WindowConfiguration;
            confObj.ToolstripConfigurationName='sl_valuesrc';
            confObj.ToolstripConfigurationPath=fullfile(matlabroot,'toolbox','simulink','sl_valuesrc','+sl_valuesrc','valuesrcPlugin');
            confObj.ToolstripName='valuesrcManagerToolstrip';
            tsPath=fullfile(matlabroot,'toolbox','simulink','sl_valuesrc','+sl_valuesrc','valuesrcPlugin');


            addpath(tsPath);


            confObj.ToolstripContext='sl_valuesrc.ValueSrcMgrContext';
        end

        function addListeners(thisObj,sourceName,sourceObj)
            thisObj.mSourceList(sourceName)=sourceObj;
            type=class(sourceObj);
            if isequal(type,'Simulink.BlockDiagram')
                thisObj.mModelCloseListeners(sourceName)=Simulink.listener(sourceObj,'CloseEvent',...
                @(src,eventData)thisObj.modelCloseListener(src,eventData));
                valueManager=get_param(sourceName,'ValueManager');
                valueManager.parameterAddEvent.registerHandler(@(~,eventData)thisObj.updateDefinitions(eventData,sourceName,'add'));
                valueManager.parameterModifyEvent.registerHandler(@(~,eventData)thisObj.updateDefinitions(eventData,sourceName,'mod'));
                valueManager.parameterDeleteEvent.registerHandler(@(~,eventData)thisObj.updateDefinitions(eventData,sourceName,'del'));
                valueManager.parameterDefinitionListUpdateEvent.registerHandler(@(~,eventData)thisObj.updateDefinitions(eventData,sourceName,'add'));
                valueManager.cacheUpdateEvent.registerHandler(@(src,eventData)thisObj.cacheUpdateEvent(eventData,sourceName));
            end
        end

        function removeListeners(thisObj,sourceName,sourceObj)
            type=class(sourceObj);
            if isequal(type,'Simulink.BlockDiagram')
                try
                    thisObj.mModelCloseListeners.remove(sourceName);
                catch
                end
            end
            thisObj.mSourceList.remove(sourceName);
        end

        function updateDefinitions(thisObj,eventData,sourceName,op)
            if~isempty(thisObj.mWin)&&isvalid(thisObj.mWin)&&isvalid(thisObj.mSrcListCmpt)
                thisObj.mSrcListObj.updateDefinitions(eventData,sourceName,op);
            end
        end

        function cacheUpdateEvent(thisObj,eventData,sourceName)
            if~isempty(thisObj.mWin)&&isvalid(thisObj.mWin)&&isvalid(thisObj.mSrcListCmpt)
                thisObj.mSrcListObj.cacheUpdateEvent(eventData,sourceName);
            end
        end

        function modelCloseListener(thisObj,src,event)
            if~isempty(thisObj.mWin)&&isvalid(thisObj.mWin)&&isvalid(thisObj.mSrcListCmpt)
                thisObj.mSrcListObj.modelCloseListener(src,event);
            end
            thisObj.removeListeners(src.Name,src);
        end

    end

end
