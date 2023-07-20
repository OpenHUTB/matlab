

classdef ExclusionEditorBase<handle
    properties(Constant)
        cDialogTag='ExclusionEditor';
    end
    properties(Access=public)
        storeInSLX=true;
        exclusions=[];
        unsavedChanges=false;
        fileName='';
    end

    properties(Access=public)
        activeTabIndex=0;
        allPropMap=[];
        exclusionState=[];
        tableIdxMap=[];
        fDialogHandle=[];
        fModelName='';
        eventListener=[];

        defaultExclusionState=[];
        defaultTableIdxMap=[];
        defaultExclusionFile='';
        setExclusionFileFlag=false;
        browseDlg=[];
    end

    methods(Access=public,Hidden=true)
        [success,msg]=ApplyExclusionChange(aObj,action);
        apply(aObj,fileName);
        tabChangeExclusionCallback(hDlg,~,index);
        CloseCB(aObj);
        removeExclusionCallback(aObj,dlg);
    end

    methods(Static=true,Hidden=true)
        map=ModelToDialogMap();
    end

    methods(Static=true)
        function tag=getDialogTag(mdlName)
            tag=['',mdlName];
        end





        function exclusionEditor=findExistingDlg(modelName)
            tr=DAStudio.ToolRoot;
            dlgs=tr.getOpenDialogs;
            dialogTag=ModelAdvisor.ExclusionEditorBase.getDialogTag(modelName);
            exclusionEditor=[];

            for idx=1:numel(dlgs)
                if strcmp(dlgs(idx).dialogTag,dialogTag)
                    dlg=dlgs(idx);
                    exclusionEditor=dlg.getSource;
                    try
                        fName=get_param(bdroot(modelName),'MAModelExclusionFile');
                        if~strcmpi(exclusionEditor.fModelName,get_param(modelName,'name'))||...
                            (~isempty(fName)&&~strcmpi(exclusionEditor.fileName,fName))
                            exclusionEditor=[];
                        end
                    catch MEx %#ok<NASGU>
                        exclusionEditor=[];
                    end

                    break;
                end
            end
        end
    end
    methods(Abstract)
        dirtyEditor(aObj);
        propMap=getProperties(this,ssid,sel);
        dlg=getDialogSchema(aObj);
        data=getExclusionsdialogSchema(aObj);
        data=getExclusionState(aObj);
        [addChecksIDs,addCheckNames,removeChecks]=updatePropsForChecks(this,prop,ssid);
        setPropDefaults(aObj);
        [status]=postApply(this);
    end
    methods(Access=public)
        show(aObj);
        save(this,varargin);
        setEventHandler(obj);
        loadDefaultExclusions(this,fileName);
        CloseExclusionEditor(aObj);
        browseForExclusionFile(this);
        exclusionRemoveCallback(this);
        setExclusionFile(this);
        applyExclusionFileChange(this,newFile);
        exclusionFileBrowseCallback(this,newFile);
        changeExclusionFile(aObj);
        refreshExclusions(this,varargin);
        status=load(this);
        writeToFile(this,exList);
        editExclusionCallback(aObj,dlg);



        function obj=ExclusionEditorBase(aModelName)
            if ischar(aModelName)&&~isempty(aModelName)
                obj.fModelName=aModelName;
            else
                DAStudio.error('Slci:slci:ModelNameMustBeString')
            end
            obj.fileName=get_param(bdroot(aModelName),'MAModelExclusionFile');
            if~isempty(obj.fileName)||~obj.isSLX
                obj.storeInSLX=false;
            else
                obj.fileName=obj.getSlxPartFilePath;
            end
            obj.defaultExclusionFile=ModelAdvisor.getDefaultExclusionFile;
            obj.allPropMap=containers.Map('KeyType','char','ValueType','any');
            obj.tableIdxMap=containers.Map('KeyType','double','ValueType','any');
            obj.exclusionState=containers.Map('KeyType','char','ValueType','any');
            obj.defaultTableIdxMap=containers.Map('KeyType','double','ValueType','any');
            obj.defaultExclusionState=containers.Map('KeyType','char','ValueType','any');
            setEventHandler(obj);
            obj.load();


            if~isempty(obj.defaultExclusionFile)&&exist(obj.defaultExclusionFile,'file')~=0
                info=dir(obj.defaultExclusionFile);

                if info.bytes>168
                    obj.loadDefaultExclusions(instance.defaultExclusionFile);
                end
            end
        end
        function path=getSlxPartFilePath(this)
            if~this.isSLX
                path='';
            else
                path=Simulink.slx.getUnpackedFileNameForPart(this.fModelName,...
                this.getSlxPartName);
            end
        end
        function partName=getSlxPartName(~)
            partName='/advisor/exclusions.xml';
        end


        function storeInSLXcb(this)
            this.storeInSLX=~this.storeInSLX;
            if this.storeInSLX
                this.fileName=this.getSlxPartFilePath;
            else
                this.fileName=get_param(bdroot(this.fModelName),'MAModelExclusionFile');
            end
        end

        function showCheckSelectionGUI(this,cbinfo)
            checkSelectionGUI=ModelAdvisor.CheckSelector.getInstance(this.fModelName,cbinfo);
            checkSelectionGUI.show;
        end

        function flag=isSLX(this)
            [~,fName,ext]=fileparts(get_param(bdroot(this.fModelName),'filename'));
            if isempty(fName)
                flag=true;
            else
                flag=strcmp(ext,'.slx');
            end
        end




        function res=isExcludedByProp(this,prop)

            res=this.exclusionState.isKey(this.getPropKey(prop))&&...
            this.checkIDMatch(prop);
        end




        function res=checkIDMatch(this,prop)

            exclusionstateprop=this.exclusionState(this.getPropKey(prop));
            res=true;
            if strcmp(exclusionstateprop.checkIDs{1},'All Checks')
                return;
            end
            for i=1:length(prop)
                match=false;
                for j=1:length(exclusionstateprop.checkIDs)
                    if strcmpi(prop.checkIDs{i},exclusionstateprop.checkIDs{j})
                        match=true;
                    end
                end
                if~match
                    res=false;
                    break;
                end
            end
        end




        function key=addExclusionPropToState(this,prop,~)
            key=this.getPropKey(prop);
            if this.exclusionState.isKey(key)
                temp=this.exclusionState(key);
                if~strcmpi(temp.checkIDs{1},'All Checks')
                    for i=1:length(prop.checkIDs)
                        if strcmpi(prop.checkIDs{i},'All Checks')||...
                            strcmpi(prop.checkIDs{i},'.*')
                            temp.checkIDs{1}=prop.checkIDs{i};
                            break;
                        else
                            temp.checkIDs{end+1}=prop.checkIDs{i};
                        end
                    end
                end
                this.exclusionState(key)=temp;
            else

                prop.idx=length(this.exclusionState.keys);
                this.exclusionState(key)=prop;
            end
            dirtyEditor(this);
        end

        function key=addExclusionPropToDefaultState(this,prop,~)
            key=this.getPropKey(prop);
            this.defaultExclusionState(key)=prop;
            dirtyEditor(this);
        end

        function removeExclusionByProp(this,prop,mdl)
            if mdl
                this.removePropFromMap(this.exclusionState,prop);
            else
                this.removePropFromMap(this.defaultExclusionState,prop);
            end
            dirtyEditor(this);
        end

        function out=getUnsavedChanges(aObj)
            out=aObj.unsavedChanges;
        end

        function setUnsavedChanges(aObj,flag)
            aObj.unsavedChanges=flag;
        end

        function key=getPropKey(this,prop)
            key=[prop.value,'_',prop.Type];
        end

        function map=removePropFromMap(this,map,prop)
            key=this.getPropKey(prop);
            if map.isKey(key)
                map.remove(key);
            end
        end

        function text=getPropertyRationale(~,prop)
            text=sprintf(prop.propDesc,prop.name);
        end

        function text=getRationale(~,prop)
            text=sprintf(prop.rationale,prop.name);
        end

        function prop=getPropSchema(this,id)
            prop='';
            if this.allPropMap.isKey(id)
                prop=this.allPropMap(id);
            end
        end

        function out=getModelName(aObj)
            out=aObj.fModelName;
        end

        function setActiveTab(aObj,index)
            aObj.activeTabIndex=index;
        end

        function setFileName(aObj,fname)
            aObj.fileName=fname;
        end

        function out=getFileNameToDisplay(aObj)
            if~isempty(aObj.fileName)
                out=aObj.fileName;
            else
                out='<untitled.xml>';
            end
        end

        function[blkList,excludeInfoList]=getBlocksExcluded(aObj,checkID)
            blkList={};
            excludeInfoList={};
            state=aObj.getExclusionState;
            numExclusions=size(state,1);
            if ischar(checkID)
                checkID={checkID};
            end
            for i=1:numExclusions
                if~strcmpi(state{i,4},'All checks')&&ismember(state{i,4},checkID)
                    continue;
                end
                infoTable=ModelAdvisor.Table(1,4);
                infoTable.setColHeading(1,DAStudio.message('ModelAdvisor:engine:ExclusionRationale'));
                infoTable.setColHeading(2,DAStudio.message('ModelAdvisor:engine:ExclusionType'));
                infoTable.setColHeading(3,DAStudio.message('ModelAdvisor:engine:ExclusionValue'));
                infoTable.setColHeading(4,DAStudio.message('ModelAdvisor:engine:ExclusionCheckIDs'));
                infoTable.setEntry(1,1,['&nbsp;',state{i,1},'&nbsp;']);
                infoTable.setEntry(1,2,['&nbsp;',state{i,2},'&nbsp;']);
                infoTable.setEntry(1,3,['&nbsp;',state{i,3},'&nbsp;']);
                infoTable.setEntry(1,4,['&nbsp;',state{i,4},'&nbsp;']);
                excludeMsg=infoTable.emitHTML;
                try
                    switch state{i,2}
                    case 'Block'
                        blkList{end+1}=Simulink.ID.getSID(state{i,3});
                        excludeInfoList{end+1}=excludeMsg;
                    case 'BlockType'


                        blks=find_system(aObj.fModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'blocktype',state{i,3});
                        if~isempty(blks)
                            blkList=[blkList;Simulink.ID.getSID(blks)];
                            for blkcnt=1:length(blks)
                                excludeInfoList{end+1}=excludeMsg;
                            end
                        end
                    case 'Subsystem'
                        blks=find_system(state{i,3});
                        for j=1:length(blks)
                            blkList{end+1}=Simulink.ID.getSID(blks{j});
                            for blkcnt=1:length(blks)
                                excludeInfoList{end+1}=excludeMsg;
                            end
                        end
                    case 'MaskType'


                        masks=find_system(aObj.fModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'masktype',state{i,3});
                        for j=1:length(masks)


                            blks=find_system(masks{j},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all');
                            for k=1:length(blks)
                                blkList{end+1}=Simulink.ID.getSID(blks{k});
                                excludeInfoList{end+1}=excludeMsg;
                            end
                        end
                    case 'Library'


                        libBlks=find_system(aObj.fModelName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'referenceblock',state{i,3});
                        for j=1:length(libBlks)


                            blks=find_system(libBlks{j},'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'followlinks','on');
                            for k=1:length(blks)
                                blkList{end+1}=Simulink.ID.getSID(blks{k});
                                excludeInfoList{end+1}=excludeMsg;
                            end
                        end
                    end
                catch
                    continue;
                end
            end
        end

        function out=getExclusions(aObj)
            out=aObj.exclusions;
        end

        function exclusions=setExclusions(aObj,tExclusions)
            aObj.exclusions=tExclusions;
        end

    end
end


