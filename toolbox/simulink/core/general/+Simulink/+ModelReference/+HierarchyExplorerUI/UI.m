classdef UI<matlab.mixin.SetGet&matlab.mixin.Copyable




    properties

        m_editor=[];


        m_dialog=[];


        m_panelH=[];


        m_root=[];


        m_proxy=[];


        m_listeners=[];


        m_ready=false;


        m_showObservers=false;


        m_addAccelChildren=false;
    end

    methods(Abstract)


        applySelection(this)


        newNode=createNode(this,modelName,blockName,normalMode,proxy)


        val=getInstructions(this)


        title=getTitle(this)


        tag=getUITag(this)


        launchHelp(this)


        setInitialSelectedNodes(this)

    end

    methods

        function this=UI()
        end

        function show(this)
            this.m_editor.show;
        end

        function setDialog(this,dialog)
            this.m_dialog=dialog;
        end

    end

    methods(Hidden)



        function doInitialization(this,modelH,varargin)

            panelH=[];
            if length(varargin)==1
                panelH=varargin{1};
            end

            try
                modelName=get_param(modelH,'name');
                load_system(modelName);

                this.m_ready=false;
                this.m_panelH=panelH;
                this.m_proxy=Simulink.ModelReference.HierarchyExplorerUI.DialogProxy(this,this.getInstructions(),this.getUITag());

                this.m_root=this.createNode(modelName,'',true,this.m_proxy);
                this.m_editor=this.createExplorer(this.m_root);

                l1=handle.listener(this.m_editor,'MEPostClosed',{@loc_destroyCallback,this});
                this.addListener(l1);

                this.createTreeFromRoot();

                this.show;

                this.makeReady();
            catch me

                if(~isvalid(this))
                    newME=MException('Simulink:modelReference:HierarchyExplorerClosedWhenNotReady',...
                    '%s',...
                    DAStudio.message('Simulink:modelReference:HierarchyExplorerClosedWhenNotReady'));
                    newME=newME.addCause(me);
                    throw(newME);
                else
                    this.destroy();
                    rethrow(me);
                end
            end


        end


        function e=createExplorer(this,root)
            e=DAStudio.Explorer(root,this.getTitle());
            e.Title=this.getTitle();
            e.Icon=fullfile(matlabroot,'toolbox','shared','dastudio','resources','SimulinkRoot.png');
            e.setTreeTitle('');
            e.allowWholeRowDblClick=false;
            e.showContentsOf(false);
            e.showDialogView(true);
            e.showListView(false);

            am=DAStudio.ActionManager;
            am.initializeClient(e);
        end




        function createTreeFromRoot(this)
            this.addModel(this.m_root);
            this.setInitialSelectedNodes();


            dialog=this.m_editor.getDialog;
            tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Apply'];
            dialog.setEnabled(tag,false);

            this.m_root.expandChildren;
        end






        function addModel(this,parentNode)
            mdlMap=containers.Map('KeyType','char','ValueType','any');
            mdlMap(parentNode.getMapKey())=parentNode;
            hierarchy={};

            addAllChildren(this,parentNode,mdlMap,hierarchy);
        end




        function[mdlMap,newNode]=addInstance(this,modelBlock,parentNode,mdlMap,normal,isObserver)
            if isObserver
                modelName=get_param(modelBlock,'ObserverModelName');
            else
                modelName=get_param(modelBlock,'ModelName');
            end

            try
                load_system(modelName);
            catch ME
                topmodel=this.m_root.m_modelName;
                dialogTitle=this.getTitle();

                id='Simulink:modelReference:HierarchyExplorerCouldNotLoadModel';
                msg=DAStudio.message(id,dialogTitle,topmodel,modelName);

                newE=MException(id,msg);
                newE=newE.addCause(ME);
                throw(newE);
            end

            newNode=this.createNode(modelName,modelBlock,normal,this.m_proxy);
            mdlMap(newNode.getMapKey())=newNode;
            parentNode.addToHierarchy(newNode);
        end




        function addListener(this,listener)
            if(isempty(this.m_listeners))
                this.m_listeners{1}=listener;
            else
                this.m_listeners{end+1}=listener;
            end
        end




        function closeCallback(this,tag)
            tag=tag(length(Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase())+1:end);

            switch tag
            case 'Apply'
                loc_doApply(this);

            case 'Refresh'
                loc_doRefresh(this);

            case 'OK'
                loc_doOK(this);

            case 'Cancel'
                loc_doCancel(this);

            case 'Help'
                loc_doHelp(this);

            case 'Hidden_Destroy'
                this.destroy();
            end
        end




        function destroy(this)


            this.m_editor.hide;
            this.m_editor.delete;
            this.m_root.destroy;
            this.delete;
        end




        function makeReady(this)
            this.m_ready=true;

            this.m_editor.setStatusMessage(DAStudio.message('Simulink:modelReference:HierarchyExplorerReadyStatusMessage'));


            dialog=this.m_editor.getDialog;

            tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Refresh'];
            dialog.setEnabled(tag,true);

            tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'OK'];
            dialog.setEnabled(tag,true);

            tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Cancel'];
            dialog.setEnabled(tag,true);
        end




        function makeUnready(this,statusMessage)
            this.m_ready=false;

            this.m_editor.setStatusMessage(statusMessage);


            dialog=this.m_editor.getDialog;

            tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Refresh'];
            dialog.setEnabled(tag,false);

            tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'OK'];
            dialog.setEnabled(tag,false);

            tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Cancel'];
            dialog.setEnabled(tag,false);
        end

    end


    methods(Static)


        function tag=getUITagBase()
            tag='MdlRefHierarchy_UI_';
        end

    end

end




function mdlMap=addAllChildren(this,parentNode,mdlMap,hierarchy)
    parentName=parentNode.m_modelName;
    parentKey=parentNode.getMapKey();

    if(ismember(parentName,hierarchy))
        withColon=cellfun(@(x)[x,':'],hierarchy,'UniformOutput',false);
        cyclePath=[withColon{:},parentName];

        DAStudio.error('Simulink:modelReference:CycleNotAllowed',...
        hierarchy{1},...
        cyclePath);
    else
        hierarchy{end+1}=parentName;
    end

    [~,mdlblocks]=find_mdlrefs(parentName,...
    'AllLevels',false,...
    'IncludeProtectedModels',false,'MatchFilter',@Simulink.match.allVariants);

    observer_blocks=[];
    if this.m_showObservers


        observer_blocks=find_system(parentName,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','ObserverReference');
    end


    ind_protected=strcmp(get_param(mdlblocks,'ProtectedModel'),'on');
    mdlblocks=mdlblocks(~ind_protected);

    ind_normal=strcmp(get_param(mdlblocks,'SimulationMode'),'Normal');
    ind_accel=strcmp(get_param(mdlblocks,'SimulationMode'),'Accelerator');
    ind_other=~(ind_normal|ind_accel);

    normal_blocks=mdlblocks(ind_normal);
    accel_blocks=mdlblocks(ind_accel);
    other_blocks=mdlblocks(ind_other);

    all_blocks=getSortedBlockStruct(normal_blocks,accel_blocks,other_blocks,observer_blocks);
    childrenToAdd=[];

    addNormalChildrenOnly=false;











    for i=1:length(all_blocks)
        block=all_blocks(i).block;
        normal=all_blocks(i).normal;
        accel=all_blocks(i).accel;
        isObserver=all_blocks(i).observer;

        [mdlMap,handle]=this.addInstance(block,parentNode,mdlMap,normal,isObserver);
        if((addNormalChildrenOnly&&normal)||...
            (~addNormalChildrenOnly&&~accel)||...
            (~addNormalChildrenOnly&&accel&&this.m_addAccelChildren))&&~isempty(handle)
            if(isempty(childrenToAdd))
                childrenToAdd=handle;
            else
                childrenToAdd(end+1)=handle;%#ok<AGROW>
            end
        end
    end

    for idx=1:length(childrenToAdd)
        addAllChildren(this,childrenToAdd(idx),mdlMap,hierarchy);
    end
end




function blocks=getSortedBlockStruct(normal_blocks,accel_blocks,other_blocks,observer_blocks)
    modelBlocks=[normal_blocks;accel_blocks;other_blocks;observer_blocks];
    if(isempty(modelBlocks))
        blocks={};
        return;
    end

    blocks=struct('block',modelBlocks,...
    'normal',num2cell([true(length(normal_blocks),1);...
    false(length(accel_blocks),1);...
    false(length(other_blocks),1);...
    false(length(observer_blocks),1)]),...
    'accel',num2cell([false(length(normal_blocks),1);...
    true(length(accel_blocks),1);...
    false(length(other_blocks),1);...
    false(length(observer_blocks),1)]),...
    'observer',num2cell([false(length(normal_blocks),1);...
    false(length(accel_blocks),1);...
    false(length(other_blocks),1);...
    true(length(observer_blocks),1)]));
    modelNames=modelBlocks;
    obsInd=[blocks.observer];
    modelNames(~obsInd)=get_param(modelBlocks(~obsInd),'ModelName');
    modelNames(obsInd)=get_param(modelBlocks(obsInd),'ObserverModelName');









    longestModelName=max(cellfun(@length,modelNames));

    normalizedModelNames=cellfun(@(x)[x,blanks(longestModelName+1-length(x))],modelNames,'UniformOutput',false);

    keys=cellfun(@(x,y)[x,y],normalizedModelNames,modelBlocks,...
    'UniformOutput',false);

    [~,indexes]=sort(keys);

    blocks=blocks(indexes);
end



function loc_doRefresh(this)
    hasUnappliedChanges=loc_hasUnappliedChanges(this);

    if(hasUnappliedChanges)
        modelName=this.m_root.m_modelName;

        title=DAStudio.message('Simulink:modelReference:HierarchyExplorerUnappliedChangesTitle');
        message=DAStudio.message('Simulink:modelReference:HierarchyExplorerRefreshWithUnappliedChangesMessage',modelName);
        apply=DAStudio.message('Simulink:modelReference:HierarchyExplorerUnappliedChangesApplyButton');
        doNotApply=DAStudio.message('Simulink:modelReference:HierarchyExplorerUnappliedChangesDoNotApplyButton');
        cancel=DAStudio.message('Simulink:modelReference:HierarchyExplorerUnappliedChangesCancelButton');

        choice=questdlg(message,title,apply,doNotApply,cancel,cancel);

        switch choice
        case cancel
            return;

        case apply
            loc_doApply(this);

        case doNotApply

        end
    end

    try
        this.makeUnready(DAStudio.message('Simulink:modelReference:HierarchyExplorerRefreshingStatusMessage'));


        modelName=this.m_root.m_modelName;


        newRoot=this.createNode(modelName,'',true,this.m_proxy);


        oldRoot=this.m_root;


        this.m_root=newRoot;
        this.m_editor.setRoot(this.m_root);


        oldRoot.destroy();


        this.createTreeFromRoot();


        this.makeReady();
    catch me


        if(isvalid(this))

            newRoot=this.createNode(modelName,'',true,this.m_proxy);


            oldRoot=this.m_root;


            this.m_root=newRoot;
            this.m_editor.setRoot(this.m_root);

            if(isvalid(oldRoot))
                oldRoot.destroy();
            end

            this.makeReady();

            rethrow(me);
        end
    end
end



function loc_doApply(this)
    this.applySelection();


    dialog=this.m_editor.getDialog;
    tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Apply'];
    dialog.setEnabled(tag,false);
end




function loc_doOK(this)
    if(loc_hasUnappliedChanges(this))
        this.applySelection();
    end

    this.destroy();
end



function loc_doCancel(this)
    this.destroy();
end



function loc_doHelp(this)
    this.launchHelp();
end


function loc_destroyCallback(~,~,this)
    if(isvalid(this))
        this.destroy();
    end
end


function unappliedChanges=loc_hasUnappliedChanges(this)
    dialog=this.m_editor.getDialog;
    tag=[Simulink.ModelReference.HierarchyExplorerUI.UI.getUITagBase(),'Apply'];
    unappliedChanges=dialog.isEnabled(tag);
end
