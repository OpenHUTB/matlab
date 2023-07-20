classdef OneCoderAppContext<dig.CustomContext



    properties
studio
listeners
    end

    methods
        function obj=OneCoderAppContext(app,st)
            obj@dig.CustomContext(app);
            obj.studio=st;
            obj.setupListener();

            disp(['create ',obj.Name]);
        end

        function delete(obj)
            disp(['delete ',obj.Name]);
        end

        function setupListener(obj)
            modelHandle=obj.studio.App.blockDiagramHandle;
            obj.listeners={};


            bd=get_param(modelHandle,'Object');
            p=findprop(bd,'CodeGenBehavior');
            obj.listeners{end+1}=handle.listener(bd,p,'PropertyPostSet',...
            @obj.upateTypeChain);


            obj.listeners{end+1}=configset.ParamListener(modelHandle,'GenCodeOnly',...
            @obj.updateTypeChain);



            obj.listeners{end+1}=configset.ParamListener(modelHandle,'SystemTargetFile',...
            @obj.updateTypeChain);
            obj.listeners{end+1}=configset.ParamListener(modelHandle,'TargetLang',...
            @obj.updateTypeChain);
            obj.listeners{end+1}=configset.ParamListener(modelHandle,'CodeInterfacePackaging',...
            @obj.updateTypeChain);
        end

        function enableListener(obj,bool)
            for i=1:length(obj.listeners)
                l=obj.listeners{i};
                if isa(l,'configset.ParamListener')
                    l.Enabled=bool;
                else
                    if bool
                        l.Enabled='on';
                    else
                        l.Enabled='off';
                    end
                end
            end
        end

        function openApp(obj)

            obj.updateTypeChain();

            st=obj.studio;
            contextManager=st.App.getAppContextManager;
            contextManager.activateApp(obj);
            ts=st.getToolStrip;
            ts.ActiveTab=obj.DefaultTabName;


            cp=simulinkcoder.internal.CodePerspective.getInstance;
            if cp.isAvailable(st)
                cp.open(st);
            end
        end

        function closeApp(obj)
            st=obj.studio;
            contextManager=st.App.getAppContextManager;
            contextManager.deactivateApp(obj.Name);


            cp=simulinkcoder.internal.CodePerspective.getInstance;
            cp.close(obj.studio);
        end

        function updateTypeChain(obj,varargin)
            typeChain=coder.internal.toolstrip.util.getTypeChain(obj.studio);
            obj.TypeChain=typeChain;
        end
    end

    methods(Static)
        function toggleCoderApp(cbinfo)
            c=dig.Configuration.get();
            app=c.getApp('OneCoderApp');
            if isempty(app)
                return;
            end

            studio=cbinfo.studio;
            ed=cbinfo.EventData;

            if isempty(ed)
                status=true;
            elseif isnumeric(ed)||islogical(ed)
                status=ed;
            elseif ischar(ed)
                status=true;
            end

            contextManager=studio.App.getAppContextManager;
            customContext=contextManager.getCustomContext(app.name);

            if status
                if isempty(customContext)
                    contextProvider=app.contextProvider;
                    customContext=feval(contextProvider,app,studio);
                end
                customContext.openApp();
            else
                customContext.closeApp();
                delete(customContext);
            end
        end
    end
end
