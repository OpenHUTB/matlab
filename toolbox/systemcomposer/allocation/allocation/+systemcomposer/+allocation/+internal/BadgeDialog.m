classdef BadgeDialog<handle













    properties(Access=private)
elemHdl
isSource
hierarchyPaths
toDelete
    end

    properties(Dependent)
topModelName
elemType
    end

    methods
        function this=BadgeDialog(blkHdl,hierarchyPaths,isSource)
            this.elemHdl=blkHdl;
            this.isSource=isSource;
            this.hierarchyPaths=hierarchyPaths;
            this.toDelete=containers.Map('KeyType','char','ValueType','any');
        end

        function schema=getDialogSchema(this)

            allocData=this.getAllocationData();
            groups={};
            dlgItems=[];

            for idx=1:length(allocData)
                data=allocData(idx);
                items={};

                scenarioName=[data.allocSetName,' / ',data.allocScenarioName];

                allocDir.Type='text';
                allocDir.Tag=['group_',num2str(idx),'_allocDirText'];
                if this.isSource
                    allocDir.Name=DAStudio.message('SystemArchitecture:studio:AllocatedTo');
                else
                    allocDir.Name=DAStudio.message('SystemArchitecture:studio:AllocatedFrom');
                end
                allocDir.RowSpan=[1,1];
                allocDir.ColSpan=[1,2];
                items{end+1}=allocDir;%#ok<*AGROW> 

                mdl=this.getAllocModel(data.allocSetName,~this.isSource);
                elems=cellfun(@(x)mdl.findElement(x),data.otherEndElements,'uniformoutput',false);
                targets=cellfun(@(x)getQualifiedName(x),elems,'uniformoutput',false);

                for t=1:length(targets)
                    target=targets{t};
                    elem=elems{t};
                    key=[scenarioName,' : ',target];
                    isDeleted=isKey(this.toDelete,key);

                    icon.Type='image';
                    icon.Tag=['group_',num2str(idx),'_iconImage_',num2str(t)];
                    icon.FilePath=getIconPath(elem);
                    icon.RowSpan=[t+1,t+1];
                    icon.ColSpan=[1,1];
                    items{end+1}=icon;

                    targetlink=[];
                    targetlink.Type='hyperlink';
                    targetlink.Tag=['group_',num2str(idx),'_hyperlink_',num2str(t)];
                    targetlink.Name=target;
                    targetlink.Source=this;
                    if isDeleted
                        targetlink.ForegroundColor=[100,100,100];
                        targetlink.Italic=1;
                    end
                    targetlink.ObjectMethod='navigateToTarget';
                    targetlink.MethodArgs={elem};
                    targetlink.ArgDataTypes={'mxArray'};
                    targetlink.RowSpan=[t+1,t+1];
                    targetlink.ColSpan=[2,2];
                    items{end+1}=targetlink;

                    if~isDeleted
                        delIcon.Type='image';
                        delIcon.Tag=['group_',num2str(idx),'_delIcon_',num2str(t)];
                        delIcon.FilePath=getIconPath('delete');
                        delIcon.RowSpan=[t+1,t+1];
                        delIcon.ColSpan=[3,3];
                        delIcon.Source=this;
                        delIcon.ObjectMethod='handleClickDeleteAllocation';
                        delIcon.MethodArgs={data.allocSetName,data.allocScenarioName,target,elem};
                        delIcon.ArgDataTypes={'char','char','char','mxArray'};
                        delIcon.DialogRefresh=true;
                        items{end+1}=delIcon;
                    else
                        delTxt.Type='text';
                        delTxt.Tag=['group_',num2str(idx),'_delTxt_',num2str(t)];
                        delTxt.Name=DAStudio.message('SystemArchitecture:studio:ToDelete');
                        delTxt.Italic=1;
                        delTxt.ForegroundColor=[100,100,100];
                        delTxt.RowSpan=[t+1,t+1];
                        delTxt.ColSpan=[3,3];
                        items{end+1}=delTxt;
                    end
                end

                group.Type='group';
                group.Tag=['group_',num2str(idx)];
                group.Items=items;
                group.Name=scenarioName;
                group.LayoutGrid=[t+2,3];
                group.RowStretch=[zeros(1,t+1),1];
                group.ColStretch=[0,1,0];
                group.RowSpan=[idx,idx];
                group.ColSpan=[1,4];

                groups{end+1}=group;
            end

            if~isempty(keys(this.toDelete))
                cancelDeleteLink.Type='hyperlink';
                cancelDeleteLink.Tag='cancelDelete_hyperlink';
                cancelDeleteLink.Name=DAStudio.message('SystemArchitecture:studio:CancelDelete');
                cancelDeleteLink.Italic=1;
                cancelDeleteLink.Alignment=4;
                cancelDeleteLink.Source=this;
                cancelDeleteLink.ObjectMethod='handleCancelDelete';
                cancelDeleteLink.MethodArgs={};
                cancelDeleteLink.ArgDataTypes={};
                cancelDeleteLink.DialogRefresh=true;
                cancelDeleteLink.RowSpan=[idx+1,idx+1];
                cancelDeleteLink.ColSpan=[2,2];

                sep.Type='text';
                sep.Name='|';
                sep.Alignment=4;
                sep.RowSpan=[idx+1,idx+1];
                sep.ColSpan=[3,3];

                confirmDeleteLink.Type='hyperlink';
                confirmDeleteLink.Tag='confirmDelete_hyperlink';
                confirmDeleteLink.Name=DAStudio.message('SystemArchitecture:studio:ConfirmDelete');
                confirmDeleteLink.Italic=1;
                confirmDeleteLink.Source=this;
                confirmDeleteLink.ObjectMethod='handleConfirmDelete';
                confirmDeleteLink.MethodArgs={};
                confirmDeleteLink.ArgDataTypes={};
                confirmDeleteLink.DialogRefresh=true;
                confirmDeleteLink.RowSpan=[idx+1,idx+1];
                confirmDeleteLink.ColSpan=[4,4];

                dlgItems=[groups,cancelDeleteLink,sep,confirmDeleteLink];
            else
                dlgItems=groups;
            end

            if isempty(dlgItems)
                txtNoAlloc.Type='text';
                txtNoAlloc.Tag='NoAllocText';
                txtNoAlloc.Name=DAStudio.message('SystemArchitecture:studio:NoAllocationsForThisElement');
                dlgItems={txtNoAlloc};
                idx=0;
            end

            schema.DialogTitle='';
            schema.Items=dlgItems;
            schema.DialogTag='system_composer_allocation_badge_dialog';
            schema.Source=this;
            schema.Transient=true;
            schema.DialogStyle='frameless';
            schema.ExplicitShow=true;
            schema.StandaloneButtonSet={''};
            schema.LayoutGrid=[idx+1,4];
            schema.RowStretch=[zeros(1,idx),1];
            schema.ColStretch=[1,1,0,1];
        end

        function show(this)


            dlg=DAStudio.Dialog(this);
            width=dlg.position(3);
            height=dlg.position(4);

            [posx,posy]=getPosition(this.elemHdl);
            dlg.position=[posx,posy,width,height];
            dlg.show();
        end

        function data=getAllocationData(this)



            app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(...
            get_param(this.topModelName,'handle'));
            data=app.getAllocationDataForElement(...
            this.elemHdl,this.elemType,this.hierarchyPaths,this.isSource);
        end

        function navigateToTarget(~,elem)

            systemcomposer.internal.selectElementInComposition(elem);
            if~isa(elem,'systemcomposer.architecture.model.design.Architecture')
                hdl=systemcomposer.utils.getSimulinkPeer(elem);
                if hdl==-1

                    elemWrapper=systemcomposer.internal.getWrapperForImpl(elem);
                    elemWrapper=systemcomposer.internal.getSourceElementForRedefinedElement(elemWrapper);
                    elem=elemWrapper.getImpl();
                    hdl=systemcomposer.utils.getSimulinkPeer(elem);
                end


            end
        end

        function handleClickDeleteAllocation(this,allocSetName,scenarioName,targetName,elem)



            key=[allocSetName,' / ',scenarioName,' : ',targetName];

            allocSet=systemcomposer.allocation.AllocationSet.find(allocSetName);
            scenario=allocSet.getScenario(scenarioName);

            thisElemImpl=systemcomposer.utils.getArchitecturePeer(this.elemHdl);
            thisElem=systemcomposer.internal.getWrapperForImpl(thisElemImpl);
            src=systemcomposer.internal.resolveElementInHierarchy(thisElem,this.topModelName,this.hierarchyPaths);
            dst=systemcomposer.internal.getWrapperForImpl(elem);
            if this.isSource
                alloc=scenario.getAllocation(src,dst);
            else
                alloc=scenario.getAllocation(dst,src);
            end

            this.toDelete(key)=alloc;
        end

        function handleCancelDelete(this)
            items=keys(this.toDelete);
            this.toDelete.remove(items);
        end

        function handleConfirmDelete(this)
            items=values(this.toDelete);
            for idx=1:length(items)
                destroy(items{idx});
            end
            k=keys(this.toDelete);
            this.toDelete.remove(k);
        end

        function val=get.topModelName(this)
            if isempty(this.hierarchyPaths)
                val=get_param(bdroot(this.elemHdl),'name');
            else
                top=this.hierarchyPaths{1};
                val=strtok(top,'/');
            end
        end

        function val=get.elemType(this)
            et=get_param(this.elemHdl,'type');
            switch lower(et)
            case 'block'
                bt=get_param(this.elemHdl,'BlockType');
                switch lower(bt)
                case{'inport','outport','pmioport'}
                    val='architectureport';
                otherwise
                    val='component';
                end
            case 'port'
                val='port';
            case 'line'
                val='connector';
            case 'blockdiagram'
                val='architecture';
            otherwise
                assert(false,'unexpected element type');
            end
        end

        function mdl=getAllocModel(~,allocSetName,isSource)
            allocSet=systemcomposer.allocation.AllocationSet.find(allocSetName);
            assert(~isempty(allocSet));
            allocSetImpl=allocSet.getImpl();
            if isSource
                modelName=allocSetImpl.p_SourceModel.p_ModelURI;
            else
                modelName=allocSetImpl.p_TargetModel.p_ModelURI;
            end
            mdlObj=systemcomposer.loadModel(modelName);
            mdl=mf.zero.getModel(mdlObj.getImpl());
        end
    end

end





function[posx,posy]=getPosition(blockH)

    port_geom=get_param(blockH,'position');
    if length(port_geom)<3
        [posx,posy]=getScreenPosition(port_geom);
    else
        [posx,posy]=getScreenPosition(port_geom([3,2]));
    end
end


function[posx,posy]=getScreenPosition(startPt)


    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
    canvas=allStudios(1).App.getActiveEditor.getCanvas;
    canvas_geom=canvas.GlobalPosition;
    anchor_pos=canvas.scenePointToViewPoint(startPt)/GLUE2.Util.getDpiScale;
    posx=canvas_geom(1)+anchor_pos(1)+10;
    posy=canvas_geom(2)+anchor_pos(2)+5;

end


function fqn=getQualifiedName(elem)



    if isa(elem,'systemcomposer.architecture.model.design.BaseConnector')
        parent=elem.p_Architecture;
        if isempty(parent)

            parent=elem.p_Component;
        end
        fqn=[parent.getQualifiedName(),'/',elem.getName()];
    else
        fqn=elem.getQualifiedName();
    end
end


function p=getIconPath(elem)

    p='';
    if ischar(elem)
        switch elem
        case 'delete'
            p=fullfile(matlabroot,'toolbox','systemcomposer','allocation','allocation','+systemcomposer','+allocation','+internal','resources','delete.png');
        end
    elseif isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
        p=fullfile(matlabroot,'toolbox','systemcomposer','allocation','allocation','+systemcomposer','+allocation','+internal','resources','component16.png');
    elseif isa(elem,'systemcomposer.architecture.model.design.Port')
        p=fullfile(matlabroot,'toolbox','systemcomposer','allocation','allocation','+systemcomposer','+allocation','+internal','resources','port16.png');
    elseif isa(elem,'systemcomposer.architecture.model.design.BaseConnector')
        p=fullfile(matlabroot,'toolbox','systemcomposer','allocation','allocation','+systemcomposer','+allocation','+internal','resources','connector16.png');
    elseif isa(elem,'systemcomposer.architecture.model.design.Architecture')
        p=fullfile(matlabroot,'toolbox','systemcomposer','allocation','allocation','+systemcomposer','+allocation','+internal','resources','architecture16.png');
    end
    assert(~isempty(p));
end

