classdef AddViewerDialog<handle





    properties(SetAccess='private')
Panel
    end

    methods(Static=true)
        function dialog=get()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=Simulink.scopes.AddViewerDialog();
            end
            dialog=localObj;
        end

        function callOrigin=setgetCallOrigin(data)
            persistent localObj;
            if nargin
                localObj=data;
            end
            callOrigin=localObj;
        end

        function disableForLineMultiSelect(cbinfo,action)
            l=SLStudio.Utils.getSingleSelectedLine(cbinfo);
            if isempty(l)
                action.enabled=false;
            end
        end

        function show(input,varargin)
            dialog=Simulink.scopes.AddViewerDialog.get();

            pos=[100,100];
            if isa(input,'dig.CallbackInfo')
                context=input.Context;
                rect=input.studio.getStudioPosition();
                dialogRect=dialog.Panel.getPosition();
                pos=rect(1:2)+0.5*[rect(3:4)-dialogRect(3:4)];
            elseif isa(input,'dig.Context')
                context=input;
            else
                error(getString(message('Spcuilib:scopes:NoContextOrCbInfo')));
            end

            if nargin>1&&varargin{1}==1
                Simulink.scopes.AddViewerDialog.setgetCallOrigin(1);
            else
                Simulink.scopes.AddViewerDialog.setgetCallOrigin(0);
            end

            dialog.Panel.getActionService().Context=context;
            dialog.Panel.moveTo(pos);
            dialog.Panel.show();
        end

        function hide()
            dialog=Simulink.scopes.AddViewerDialog.get();
            dialog.Panel.hide();
        end

        function widgetlist=generate(~)

            viewerLibraries=Simulink.scopes.SigScopeMgr.getViewersAndGenerators('viewer');

            actions={};
            widgets={};

            for cat=1:numel(viewerLibraries)
                items={};
                for view=1:numel(viewerLibraries{cat}.children)
                    if strcmp(viewerLibraries{cat}.children{view}.ioType,'MPlay')
                        continue;
                    end
                    actions{end+1}=Simulink.scopes.AddViewerDialog.createAction(viewerLibraries{cat}.children{view});
                    items{end+1}=Simulink.scopes.AddViewerDialog.createItem(viewerLibraries{cat}.children{view}.tag);
                end
                widgets{end+1}=Simulink.scopes.AddViewerDialog.createCategory(viewerLibraries{cat},items);
            end

            widgetlist.widgets=widgets;
            widgetlist.actions=actions;
        end

        function category=createCategory(categoryInfo,children)


            category.Name=['viewer',categoryInfo.label,'Category'];
            category.Label=categoryInfo.label;
            category.Children=children;
            category.metaClass=dig.model.GalleryCategory.StaticMetaClass;
        end

        function action=createAction(actionInfo)

            action.name=['show',actionInfo.tag,'Action'];
            action.text=actionInfo.label;

            icon_fn=regexprep(actionInfo.label,' ','_');
            action.icon=dig.makeImageURI(fullfile('toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','viewer',[icon_fn,'_24.png']));
            if isempty(action.icon)
                action.icon=dig.makeImageURI(fullfile('toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','viewer','Scope_24.png'));
            end
            action.optInPreventSpamExecute=true;
            action.enabled=true;
            action.callback.functionName='Simulink.scopes.AddViewerDialog.viewerActionCallback';
            action.callback.userdata=actionInfo.ioType;
            action.callback.metaClass=dig.model.Callback.StaticMetaClass;
            action.metaClass=dig.model.Action.StaticMetaClass;
        end

        function item=createItem(actionLabel)


            item.Name=['show',actionLabel,'Item'];
            item.ActionId=['addViewerDialog:show',actionLabel,'Action'];
            item.ToolType='GalleryItem';
            item.metaClass=dig.model.Tool.StaticMetaClass;
        end

        function viewerActionCallback(viewerName,cbinfo)




            IOType=Simulink.iomanager.IOType.findIOType(viewerName);

            if~isempty(IOType)

                Simulink.scopes.AddViewerDialog.createViewerUserData(cbinfo,IOType);




                callOrigin=Simulink.scopes.AddViewerDialog.setgetCallOrigin();
                if callOrigin==1
                    Simulink.scopes.SignalActions.CreateIOBlock(cbinfo);
                    Simulink.scopes.SigScopeMgr.updateSSMFromRightClickContextMenu(cbinfo);
                else
                    if isfield(cbinfo.userdata,'portH')


                        Simulink.scopes.SignalActions.CreateAndConnectIOBlock(cbinfo);
                    end
                end
            end
        end

        function createViewerUserData(cbinfo,IOType)


            cbinfo.userdata.IOType='viewer';


            cbinfo.userdata.modelH=cbinfo.model.handle;
            cbinfo.userdata.viewerpath=char(IOType.getFullpath());




            l=SLStudio.Utils.getSingleSelectedLine(cbinfo);
            if SLStudio.Utils.objectIsValidLine(l)
                assert(~SLStudio.Utils.isConnectionLineSelected(cbinfo),...
                'Cannot add Viewer');
                srcPort=SLStudio.Utils.getLineSourcePort(l);
                cbinfo.userdata.portH=srcPort.handle;
            end


            cbinfo.userdata.axis=1;
        end
    end

    methods(Access='private')
        function dialog=AddViewerDialog()
            dialog.Panel=dig.GalleryPanel('addViewerDialog');
            dialog.Panel.Title=getString(message('Spcuilib:scopes:AddViewerMenuSLToolstrip'));
            if ispc||ismac
                dialog.Panel.Transient=true;
            else
                dialog.Panel.Modal=true;
                dialog.Panel.DismissOnExecute=true;
            end
        end
    end
end