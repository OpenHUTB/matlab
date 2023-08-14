classdef ReqLinkBase<slreq.das.BaseObject&matlab.mixin.Heterogeneous






    properties(Dependent)
CreatedBy
CreatedOn
ModifiedBy
ModifiedOn
Revision
    end

    properties
        IsSleeping;
    end

    methods
        function this=ReqLinkBase(varargin)
            this@slreq.das.BaseObject(varargin{:});
            this.IsSleeping=false;
        end

        function value=get.CreatedBy(this)
            value='';
            if~isempty(this.dataModelObj)
                value=this.dataModelObj.createdBy;
            end
        end

        function value=get.CreatedOn(this)
            value='';
            if~isempty(this.dataModelObj)
                value=this.dataModelObj.createdOn;
            end
        end

        function value=get.ModifiedBy(this)
            value='';
            if~isempty(this.dataModelObj)
                value=this.dataModelObj.modifiedBy;
            end
        end

        function value=get.ModifiedOn(this)
            value='';
            if~isempty(this.dataModelObj)
                value=this.dataModelObj.modifiedOn;
            end
        end

        function value=get.Revision(this)
            value='';
            if~isempty(this.dataModelObj)
                value=this.dataModelObj.revision;
            end
        end

        function items=getBaseContextMenuItems(~,caller)




            mgr=slreq.app.MainManager.getInstance;

            template=struct('name','','tag','','callback','',...
            'accel','','enabled','on','on','off',...
            'toggleaction','off','visible','on','items',[],'type','menuitem');

            openEditor=template;
            openEditor.name=getString(message('Slvnv:slreq:ShowInRequirementEditor'));
            openEditor.tag='ReqLink:BaseOpenEditor';
            openEditor.callback='slreq.das.ReqLinkBase.openEditor';
            openEditor.accel='';


            selectColumns=template;
            cView=mgr.getCurrentView();
            isValidView=slreq.utils.isValidView(cView);
            if strcmp(caller,'standalone')
                openEditor.visible='off';
                selectColumns.visible='on';


                editorname='#?#standalonecontext#?#';
            else
                selectColumns.visible='on';
                try
                    editorname=getfullname(bdroot(caller));
                catch ex %#ok<NASGU>
                    editorname='#?#standalone#?#';
                end
            end

            selectColumns.name=getString(message('Slvnv:slreq:CustomAttributesDotDotDot'));
            selectColumns.tag='ReqLink:BaseColumnSelector';


            selectColumns.callback=['slreq.gui.ColumnSelector.show(''',editorname,''')'];


            showComment=template;
            showComment.name=getString(message('Slvnv:slreq:Comments'));
            showComment.tag='ReqLink:BaseShowComment';
            showComment.callback=['slreq.app.CallbackHandler.toggleCommentDisplay(''',editorname,''')'];
            showComment.accel='';
            showComment.toggleaction='on';
            showComment.on=locOnOff(isValidView&&cView.displayComment);

            showImplementationStatus=template;
            showImplementationStatus.name=getString(message('Slvnv:slreq:ImplementationStatus'));
            showImplementationStatus.tag='ReqLink:BaseShowImplementationStatus';
            showImplementationStatus.callback=['slreq.app.CallbackHandler.toggleImplementationStatus(''',editorname,''')'];
            showImplementationStatus.accel='';
            showImplementationStatus.toggleaction='on';
            showImplementationStatus.on=locOnOff(isValidView&&cView.displayImplementationStatus);


            showVerificationStatus=template;
            showVerificationStatus.name=getString(message('Slvnv:slreq:VerificationStatus'));
            showVerificationStatus.tag='ReqLink:BaseShowVerificationStatus';
            showVerificationStatus.callback=['slreq.app.CallbackHandler.toggleVerificationStatus(''',editorname,''')'];
            showVerificationStatus.accel='';
            showVerificationStatus.toggleaction='on';
            showVerificationStatus.on=locOnOff(isValidView&&cView.displayVerificationStatus);


            showChangeInformation=template;
            showChangeInformation.name=getString(message('Slvnv:slreq:ChangeInformation'));
            showChangeInformation.tag='ReqLink:BaseShowChangeInformation';
            showChangeInformation.callback=['slreq.app.CallbackHandler.toggleChangeInformation(''',editorname,''')'];
            showChangeInformation.accel='';
            showChangeInformation.toggleaction='on';
            showChangeInformation.on=locOnOff(isValidView&&cView.displayChangeInformation);


            if isValidView&&~cView.isReqView
                showImplementationStatus.visible='off';
                showVerificationStatus.visible='off';
            end

            dispSubmenu=template;
            dispSubmenu.name=getString(message('Slvnv:slreq:Display'));
            dispSubmenu.tag='ReqLink:DisplaySubmenu';
            dispSubmenu.type='submenu';
            dispSubmenu.items=[showComment,...
            showImplementationStatus,...
            showVerificationStatus];

            if strcmp(caller,'standalone')
                try
                    items={[dispSubmenu,selectColumns]};
                    return;
                catch ex %#ok<NASGU>
                end
            else


                showComment.accel='';
                showImplementationStatus.accel='';
                showVerificationStatus.accel='';
                showChangeInformation.accel='';

                selectColumns.accel='';
                openEditor.accel='';
                items={[showComment,...
                showImplementationStatus,...
                showVerificationStatus,...
                showChangeInformation],selectColumns,openEditor};
            end

            function tf=locOnOff(tf)
                if tf
                    tf='on';
                else
                    tf='off';
                end
            end
        end
    end

    methods(Access=protected)
        function doUpdate(this,createFunc)
            if~this.childrenCreated
                return;
            end

            mode=this.view.viewManager.getCurrentView.displayMode;

            dataChildren=this.dataModelObj.children;
            newChildren=[];
            dasToKeep=true(size(dataChildren));
            for i=1:numel(dataChildren)
                switch mode
                case slreq.gui.View.FULL
                case slreq.gui.View.FULL_FLAT
                case slreq.gui.View.FILTERED_ONLY
                    dObj=dataChildren(i);
                    dasObj=dObj.getDasObject;
                    if isempty(dasObj)||i>numel(this.children)||dasObj~=this.children(i)
                        dasObj=createFunc(this,dObj);
                    end
                    if isempty(newChildren)
                        newChildren=dasObj;
                    else
                        newChildren(end+1)=dasObj;
                    end
                    this.children(i).doUpdate(createFunc);
                    if~(dObj.isFilteredIn||dObj.isFilteredParent)
                        dasToKeep(i)=false;
                    end
                case slreq.gui.View.FLAT_FILTERED_ONLY
                end
            end
            this.children=newChildren(dasToKeep);
        end
    end

    methods(Static)
        function openEditor()
            mgr=slreq.app.MainManager.getInstance;
            currentObj=mgr.getCurrentObject;
            mgr.openRequirementsEditor();
            view=mgr.requirementsEditor;
            view.setSelectedObject(currentObj);
            if ispc
                reqmgt('winFocus',getString(message('Slvnv:slreq:RequirementsEditor')));
            end
        end
    end
end
