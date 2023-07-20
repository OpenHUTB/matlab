classdef AddGeneratorDialog<handle





    properties(SetAccess='private')
Panel
    end

    methods(Static=true)
        function dialog=get()
            persistent localObj;
            if isempty(localObj)||~isvalid(localObj)
                localObj=Simulink.scopes.AddGeneratorDialog();
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

        function show(input,varargin)
            dialog=Simulink.scopes.AddGeneratorDialog.get();

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
            dialog=Simulink.scopes.AddGeneratorDialog.get();
            dialog.Panel.hide();
        end

        function widgetlist=generate(~)

            generatorLibraries=Simulink.scopes.SigScopeMgr.getViewersAndGenerators('siggen');

            actions={};
            widgets={};

            for cat=1:numel(generatorLibraries)
                items={};
                for view=1:numel(generatorLibraries{cat}.children)
                    actions{end+1}=Simulink.scopes.AddGeneratorDialog.createAction(generatorLibraries{cat}.children{view});
                    items{end+1}=Simulink.scopes.AddGeneratorDialog.createItem(generatorLibraries{cat}.children{view}.tag);
                end
                widgets{end+1}=Simulink.scopes.AddGeneratorDialog.createCategory(generatorLibraries{cat},items);
            end

            widgetlist.widgets=widgets;
            widgetlist.actions=actions;
        end

        function category=createCategory(categoryInfo,children)


            category.Name=['generator',categoryInfo.label,'Category'];
            category.Label=categoryInfo.label;
            category.Children=children;
            category.metaClass=dig.model.GalleryCategory.StaticMetaClass;
        end

        function action=createAction(actionInfo)

            action.name=['show',actionInfo.tag,'Action'];
            action.text=actionInfo.label;
            icon_fn=regexprep(actionInfo.label,' ','_');
            action.icon=dig.makeImageURI(fullfile('toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','siggen',[icon_fn,'_24.png']));
            if isempty(action.icon)
                action.icon=dig.makeImageURI(fullfile('toolbox','shared','spcuilib','slscopes','resources','SigScopeMgr','siggen','Sine_Wave_24.png'));
            end
            action.optInPreventSpamExecute=true;
            action.enabled=true;
            action.callback.functionName='Simulink.scopes.AddGeneratorDialog.generatorActionCallback';
            action.callback.userdata=actionInfo.ioType;
            action.callback.metaClass=dig.model.Callback.StaticMetaClass;
            action.metaClass=dig.model.Action.StaticMetaClass;
        end

        function item=createItem(actionLabel)


            item.Name=['show',actionLabel,'Item'];
            item.ActionId=['addGeneratorDialog:show',actionLabel,'Action'];
            item.ToolType='GalleryItem';
            item.metaClass=dig.model.Tool.StaticMetaClass;
        end

        function generatorActionCallback(generatorName,cbinfo)




            IOType=Simulink.iomanager.IOType.findIOType(generatorName);

            if~isempty(IOType)

                Simulink.scopes.AddGeneratorDialog.createGeneratorsUserData(cbinfo,IOType);

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

        function createGeneratorsUserData(cbinfo,IOType)


            cbinfo.userdata.IOType='siggen';


            cbinfo.userdata.modelH=cbinfo.model.handle;
            cbinfo.userdata.viewerpath=char(IOType.getFullpath());




            obj=SLStudio.Utils.getOneMenuTarget(cbinfo);

            if SLStudio.Utils.objectIsValidPort(obj)
                if strcmpi(obj.type,'In Port')
                    cbinfo.userdata.portH=obj.handle;
                else
                    block=SLStudio.Utils.getSigGenSourceBlock(obj);
                    ports=get_param(block,'PortHandles');
                    cbinfo.userdata.portH=ports.Inport;
                end
            else



                l=SLStudio.Utils.getSingleSelectedLine(cbinfo);
                if SLStudio.Utils.objectIsValidLine(l)
                    assert(~SLStudio.Utils.isConnectionLineSelected(cbinfo),...
                    'Cannot add Generator');
                    destPort=SLStudio.Utils.getLineDestPorts(l);


                    if~isempty(destPort)
                        cbinfo.userdata.portH=destPort.handle;
                    end
                end
            end


            cbinfo.userdata.axis=1;
        end
    end

    methods(Access='private')
        function dialog=AddGeneratorDialog()
            dialog.Panel=dig.GalleryPanel('addGeneratorDialog');
            dialog.Panel.Title=getString(message('Spcuilib:scopes:AddGeneratorMenuSLToolstrip'));
            if ispc||ismac
                dialog.Panel.Transient=true;
            else
                dialog.Panel.Modal=true;
                dialog.Panel.DismissOnExecute=true;
            end
        end
    end
end