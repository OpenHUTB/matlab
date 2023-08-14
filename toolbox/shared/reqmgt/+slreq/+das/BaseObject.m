classdef BaseObject<handle





    properties

        dataModelObj;

        dataUuid;
        parent;
        childrenCreated;
        children;


        view;
    end

    methods(Access=protected)
        function currentView=getCurrentView(this,dlg)
            if isempty(dlg)||strcmp(dlg,'default')

                currentView=this.view.requirementsEditor;
            else






                currentView=this.view.getCurrentView;
                if dig.isProductInstalled('Simulink')&&is_simulink_loaded&&...
                    (~slreq.utils.isValidView(currentView)||isa(currentView,'slreq.gui.RequirementsEditor')||isa(currentView,'slreq.internal.gui.Editor'))
                    [~,~,currentModelH]=slreq.utils.DAStudioHelper.getCurrentBDHandle();
                    currentView=this.view.getCurrentView(currentModelH);
                end
            end
        end
    end

    methods


        function this=BaseObject(varargin)

            this.dataModelObj=[];
            this.dataUuid='';
            this.parent=[];
            this.children=[];
            this.childrenCreated=true;

            if nargin>=1
                this.dataModelObj=varargin{1};
                if~isempty(this.dataModelObj)
                    this.dataModelObj.setDasObject(this);

                    slreq.utils.assertValid(this.dataModelObj);

                    this.dataUuid=this.dataModelObj.getUuid;
                end
            end


            if nargin==2
                this.parent=varargin{2};
            end



        end



        function delete(this)



            this.detachDataObj();
            this.dataModelObj=slreq.data.DataModelObj.empty();
            this.view=[];


        end

        function update(this)
            for i=1:numel(this.children)
                this.children(i).update();
            end
        end



        function releaseDataObj(this)
            this.dataModelObj=slreq.data.DataModelObj.empty();
        end

        function detachDataObj(this)
            if~isempty(this.dataModelObj)&&isvalid(this.dataModelObj)
                this.dataModelObj.clearDasObject(this);
            end
        end


        function deleteDataModelObj(this)

            slreq.utils.assertValid(this);



            if~isempty(this.dataModelObj)
                this.dataModelObj.delete();
                this.dataModelObj=slreq.data.DataModelObj.empty;
            end
        end

        function ch=getChildren(this,~)
            ch=this.children;
        end

        function ch=getHierarchicalChildren(this)
            ch=this.children;
        end

        function ch=getParent(this)
            ch=this.parent;
        end

        function resolved=resolveSourceSelection(~,selections,~,~)
            resolved={};
            reqData=slreq.data.ReqData.getInstance();
            try
                appmgr=slreq.app.MainManager.getInstance;
                [~,~,currentCanvasModel]=slreq.utils.DAStudioHelper.getCurrentBDHandle;
                spObj=appmgr.getCurrentSpreadSheetObject(currentCanvasModel);


                if isempty(spObj)
                    return;
                end
                for n=1:length(selections)
                    if iscell(selections)

                        selection=selections{n};
                    else
                        selection=selections(n);
                    end










                    if Simulink.harness.internal.sidmap.isObjectOwnedByCUT(selection)
                        try
                            selection=rmisl.harnessToModelRemap(selection);
                        catch Mex %#ok<NASGU>




                        end
                    end


                    if isa(selection,'Stateflow.Object')
                        selectHandle=selection.id;
                        selection=slreq.utils.getRMISLTarget(selectHandle,false,true);
                        if isa(selection,'double')
                            rt=sfroot;
                            selection=rt.idToHandle(selection);
                        end
                    else
                        selectHandle=selection.Handle;
                        selection=slreq.utils.getRMISLTarget(selectHandle,false,true);
                        selection=get(selection,'Object');
                    end

                    if isa(selection,'Simulink.Block')||isa(selection,'Simulink.Annotation')
                        linkInfo=slreq.utils.getRmiStruct(selection.Handle);
                        linkSet=reqData.getLinkSet(linkInfo.artifact);
                    elseif isa(selection,'Stateflow.Object')
                        linkInfo=slreq.utils.getRmiStruct(selection);
                        linkSet=reqData.getLinkSet(linkInfo.artifact);
                    elseif isa(selection,'Simulink.Port')&&sysarch.isZCPort(selection.Handle)
                        linkInfo=slreq.utils.getRmiStruct(selection.Handle);
                        linkSet=reqData.getLinkSet(linkInfo.artifact);
                    else
                        linkSet=[];
                    end
                    if~isempty(linkSet)
                        srcItem=linkSet.getLinkedItem(linkInfo.id);
                        if~isempty(srcItem)
                            links=srcItem.getLinks;
                            for m=1:length(links)
                                link=links(m);
                                dasLink=link.getDasObject();
                                if~isempty(dasLink)
                                    resolved{end+1}=dasLink;%#ok<AGROW>
                                end
                                linkDest=link.dest;

                                if~isempty(linkDest)
                                    dasReq=linkDest.getDasObject();
                                    if~isempty(dasReq)
                                        resolved{end+1}=dasReq;%#ok<AGROW>
                                    end
                                end
                            end
                        end
                    end
                end
            catch ex %#ok<NASGU>

            end
        end

        function addChildObject(this,obj)
            obj.parent=this;
            if isempty(this.children)
                this.children=obj;
            else
                this.children(end+1)=obj;
            end
        end

        function insertChildObject(this,obj)





            if~this.view.viewManager.isVanillaActive
                idx=1;
                for i=1:numel(this.dataModelObj.children)
                    if this.dataModelObj.children(i)==obj.dataModelObj
                        break;
                    end
                    if~isempty(this.dataModelObj.children(i).getDasObject)
                        idx=idx+1;
                    end
                end
            else
                idx=this.dataModelObj.indexOf(obj.dataModelObj);
            end

            this.insertChildObjectAt(obj,idx);
        end

        function insertChildObjectAt(this,obj,newindex)














            obj.parent=this;
            if newindex==1
                this.children=[obj,this.children(1:end)];
            elseif newindex==length(this.children)+1
                this.children=[this.children(1:end),obj];
            else
                this.children=[this.children(1:newindex-1),obj,this.children(newindex:end)];
            end
        end


        function swapChildrenObject(this,srcIndex,dstIndex)



            this.children([srcIndex,dstIndex])=this.children([dstIndex,srcIndex]);
        end


        function remove(this)

            this.parent.removeChildObject(this);


        end

        function nextObj=getNextSelectionObjAfterRemoval(this)


            nextObj=slreq.das.BaseObject.empty;
            isMultiSelection=numel(this)>1;
            if~isMultiSelection
                if~isempty(this.parent)
                    if numel(this.parent.children)==1
                        if isa(this,'slreq.das.Requirement')||isa(this,'slreq.das.Link')
                            nextObj=this.parent;

                        end
                    else
                        index=this.parent.findObjectIndex(this);
                        if index<numel(this.parent.children)
                            nextObj=this.parent.children(index+1);
                        else


                            nextObj=this.parent.children(index-1);
                        end
                    end
                end
            else

                if this.isSiblings


                    commonParent=this(1).parent;
                    if numel(commonParent.children)==numel(this)

                        nextObj=commonParent;
                    else
                        nAllChildren=numel(commonParent.children);
                        nSelection=numel(this);
                        selectedIdx=zeros(1,nSelection);
                        for n=1:nSelection
                            selectedIdx(n)=commonParent.findObjectIndex(this(n));
                        end
                        if~all(diff(sort(selectedIdx))==1)


                            return;
                        end
                        firstIndex=min(selectedIdx);
                        lastIndex=max(selectedIdx);
                        if firstIndex~=1
                            nextObj=commonParent.children(firstIndex-1);
                        elseif nAllChildren>lastIndex
                            nextObj=commonParent.children(lastIndex+1);
                        end
                    end
                else


                end
            end
        end

        function tf=isSiblings(this)


            tf=true;
            nSib=numel(this);
            if nSib<2
                return;
            end
            thisParent=this(1).parent;
            for n=1:nSib
                if thisParent~=this(n).parent
                    tf=false;
                    break;
                end
            end
        end

        function removeChildObject(this,chObj,deep)


            if nargin<3
                deep=true;
            end


            if~isscalar(chObj)
                error(message('Slvnv:slreq:RemoveChildObjectInvalidInput'))
            elseif isnumeric(chObj)

                idx=chObj;
                chObj=this.children(chObj);
            else

                idx=[];
                for n=1:length(this.children)


                    if this.children(n)==chObj
                        idx=n;
                        break;
                    end
                end
                if isempty(idx)

                    return;
                end
            end

            if deep






                objs=chObj.removeDataObject();
                for i=1:length(objs)



                    child=objs{i};
                    child.deleteDataModelObj();
                    child.delete();
                end

            else




                while~isempty(chObj.children)
                    chObj.removeChildObject(1,false);
                end










            end








            if~isempty(idx)
                this.children(idx)=[];
            end

        end

        function clearChildren(this,doDelete)

            for i=1:numel(this.children)


                if~isvalid(this.children(i))
                    continue;
                end
                this.children(i).clearChildren(doDelete);
                if doDelete...
                    &&~isempty(this.children(i).dataModelObj)...
                    &&isvalid(this.children(i).dataModelObj)...
                    &&this.children(i).dataModelObj.getDasObject==this.children(i)

                    this.children(i).dataModelObj.clearDasObject;
                    this.children(i).delete;
                end
            end
            this.children=[];
            this.childrenCreated=false;
        end


        function discardAll(this)

            for i=1:length(this.children)
                childObj=this.children(i);
                childObj.discardAll();
            end
            this.children=[];


            this.delete();

        end


        function index=findObjectIndex(this,obj)

            index=0;



            if isempty(obj)
                return;
            end



            assert(isa(obj,'slreq.das.BaseObject'));
            for i=1:numel(this.children)

                if this.children(i)==obj
                    index=i;
                    break;
                end
            end
        end

        function yesno=isAncestorOf(this,descendantObj)





            yesno=false;
            if~isa(descendantObj,'slreq.das.BaseObject')
                return;
            end
            currentObj=descendantObj;
            while true

                if this==currentObj
                    yesno=true;
                    return;
                end
                currentObj=currentObj.parent;
                if isempty(currentObj.parent)
                    return;
                end
            end
        end

        function notifyViewChange(this,localUpdated)
            if isa(this.view,'slreq.app.MainManager')
                if nargin<2
                    localUpdated=false;
                end
                this.view.update(localUpdated);
            end
        end

        function yesno=isHierarchical(this)
            yesno=~this.childrenCreated||~isempty(this.children);
        end

        function yesno=isHierarchicalChildren(this)
            yesno=~this.childrenCreated||~isempty(this.children);
        end

        function yesno=isValidProperty(this,propName)%#ok<INUSD>
            yesno=true;
        end


        function propValue=getPropValue(this,propName)
            propValue='';





        end


        function setPropValue(this,propName,propValue)





        end

        function icon=getDisplayIcon(this)%#ok<MANU>
            icon=slreq.gui.IconRegistry.instance.folder;
        end

        function label=getDisplayLabel(this)%#ok<MANU>
            label='unknown';
        end

        function tf=isDragAllowed(this)%#ok<MANU>
            tf=false;
        end

        function tf=isDropAllowed(this)%#ok<MANU>
            tf=false;
        end

        function yesno=isReadonlyProperty(this,propName)%#ok<INUSD>


            yesno=false;
        end

        function yesno=isEditableProperty(this,propName)%#ok<INUSD>


            yesno=false;
        end

        function yesno=isEditablePropertyInInspector(this,propName)%#ok<INUSD>


            yesno=false;
        end

        function dlgstruct=getDialogSchema(this,~)%#ok<INUSD>
            dlgstruct.DialogTitle='';
            dlgstruct.EmbeddedButtonSet={''};
            dlgstruct.Items={};
            dlgstruct.DialogMode='Slim';
            dlgstruct.LayoutGrid=[2,1];
            dlgstruct.RowStretch=[0,1];
        end

        function source=getDialogSource(this)

            source=this;
        end


        function name=getDisplayName(this,propName)%#ok<INUSL>

            name=propName;
        end


        function name=getDisplayNameForBuiltin(this,propName)%#ok<INUSL>
            switch propName
            case 'Index'
                name=getString(message('Slvnv:slreq:Index'));
            case 'SID'
                name=getString(message('Slvnv:slreq:SID'));
            case 'Type'
                name=getString(message('Slvnv:slreq:Type'));
            case 'CreatedBy'
                name=getString(message('Slvnv:slreq:CreatedBy'));
            case 'CreatedOn'
                name=getString(message('Slvnv:slreq:CreatedOn'));
            case 'Label'
                name=getString(message('Slvnv:slreq:Label'));
            case 'ModifiedBy'
                name=getString(message('Slvnv:slreq:ModifiedBy'));
            case 'ModifiedOn'
                name=getString(message('Slvnv:slreq:ModifiedOn'));
            case 'SynchronizedOn'
                name=getString(message('Slvnv:slreq:RefreshedOn'));
            case 'Filepath'
                name=getString(message('Slvnv:slreq:Filepath'));
            case 'Description'
                name=getString(message('Slvnv:slreq:Description'));
            case 'Destination'
                name=getString(message('Slvnv:slreq:Destination'));
            case 'Id'
                name=getString(message('Slvnv:slreq:ItemIndex'));
            case 'IdPrefix'
                name=getString(message('Slvnv:slreq:IndexPrefix'));
            case 'IdDelimiter'
                name=getString(message('Slvnv:slreq:IndexDelimiter'));
            case 'Source'
                name=getString(message('Slvnv:slreq:Source'));
            case 'Summary'
                name=getString(message('Slvnv:slreq:Summary'));
            case 'CustomID'
                name=getString(message('Slvnv:slreq:CustomID'));
            case 'Revision'
                name=getString(message('Slvnv:slreq:Revision'));
            case 'Artifact'
                name=getString(message('Slvnv:slreq:Artifact'));
            case 'isHierarchicalJustification'
                name=getString(message('Slvnv:slreq:HierarchicalJustification'));
            otherwise
                name=propName;
            end
        end

        function type=getPropertyWidgetType(this,propName)%#ok<INUSD>





            if ismember(propName,{'Description','Rationale'})





                if isa(this,'slreq.das.Requirement')
                    type='webbrowser';
                else
                    type='editarea';
                end
            else
                type='edit';
            end
        end


        function out=getAvailableAttributes(this)



            buildinAttr={};
            customAttr={};
            switch class(this.children)
            case 'slreq.das.RequirementSet'
                buildinAttr=slreq.utils.getBuiltinAttributeList('req');
                customAttr=slreq.utils.getCustomAttributeList(this.children);
            case 'slreq.das.LinkSet'
                buildinAttr=slreq.utils.getBuiltinAttributeList('link');
                customAttr=slreq.utils.getCustomAttributeList(this.children);

            end
            out=[buildinAttr,customAttr];
        end
    end

    methods(Access=protected)
        function objs=removeDataObject(this)%#ok<STOUT,MANU>


        end

        function reparentWrappedMFObjectUnder(this,parentDasObj)%#ok<INUSD>


        end
    end

    methods

        function out=getPropertySchema(this)
            out=this;
        end
        function tabview=supportTabView(~)
            tabview=false;
        end

        function name=getObjectType(this)
            switch class(this)
            case 'slreq.das.RequirementSet'
                name=getString(message('Slvnv:slreq:RequirementSet'));
            case 'slreq.das.LinkSet'
                name=getString(message('Slvnv:slreq:LinkSet'));
            case{'slreq.das.ReqRoot','slreq.das.LinkRoot'}

                name='';
            otherwise
                name=class(this);
            end
        end

        function s=getObjectName(obj)%#ok<MANU>
            s='';
        end

        function mode=rootNodeViewMode(this,rootProp)
            mode='Undefined';
            if isempty(rootProp)||strcmp(rootProp,'Simulink:Model:Properties')
                mode='SlimDialogView';
            end
        end

        function subprops=subProperties(~,prop)
            subprops={};
            if isempty(prop)
                subprops{1}='Simulink:Model:Properties';
            end
        end

        function label=propertyDisplayLabel(~,prop)
            label=prop;
            if strcmp(prop,'Simulink:Model:Properties')
                label=getString(message('Slvnv:slreq:Details'));
            end
        end




        function updatePropertyInspector(this,changeEvent)%#ok<INUSD>










            dlgs=DAStudio.ToolRoot.getOpenDialogs(this);
            slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(dlgs);

            dlg=DAStudio.ToolRoot.getOpenDialogs();

            tagsToRefresh={'Simulink:Model:Info','slim_annotation_dlg','Simulink:Dialog:Info'};

            for n=1:length(dlg)
                if any(strcmp(dlg(n).dialogTag,tagsToRefresh))
                    slreq.internal.gui.ViewForDDGDlg.refreshDDGDialogs(dlg(n));
                end
            end

        end

    end
end
