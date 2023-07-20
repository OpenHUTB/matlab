classdef CoderAppContext<dig.CustomContext





    properties(SetObservable=true)
        ShowCalAttributes=true

        PropertyTriggers={
'model:SystemTargetFile'
'model:TargetLang'
'model:CodeInterfacePackaging'
'model:GenCodeOnly'
'model:EmbeddedCoderDictionary'
'model:CodeGenBehavior'
'model:PlatformDefinition'
'editor:model:SystemTargetFile'
'editor:model:TargetLang'
'editor:model:CodeInterfacePackaging'
'editor:model:GenCodeOnly'
'editor:model:EmbeddedCoderDictionary'
'editor:model:CodeGenBehavior'
'editor:model:PlatformDefinition'
'editor:model:Name'
        }
    end

    properties(SetAccess=public)
OrigTypeChain
GenCodeContext
OutputTypeContext
LayoutContext
ASAP2CDFGenContext
CalContext
CGBContext
CGBStatusContext
SDPContext
PlatformContext
DeployContext
CodeForContext
FPContext
CodeInterfaceContext
ModelH
studio
registerCallbackId
    end

    methods
        function obj=CoderAppContext(app,cbinfo)


            obj@dig.CustomContext(app);
            obj.studio=cbinfo.studio;
            obj.ModelH=cbinfo.model.Handle;
            obj.OrigTypeChain=obj.TypeChain;
            obj.updateTypeChain();
        end

        function onPropertyChanged(obj,propName,value,context)
            obj.updateTypeChain();
        end

        function updateTypeChain(obj)
            obj.updateGenCodeContext();
            obj.updateLayoutContext();


            if slfeature('SDPToolStrip')>0
                mdl=obj.studio.App.getActiveEditor.blockDiagramHandle;
                obj.CGBContext='CodeGenBehavior';
                obj.CGBStatusContext=coder.internal.toolstrip.util.getCodeGenBehaviorContext(mdl);
            end

            obj.refreshContext();
        end

        function refreshContext(obj)
            typeChain=[{'libraryContext',obj.GenCodeContext,obj.OutputTypeContext,obj.LayoutContext},obj.OrigTypeChain];




            [isErtCompliant,isErtCpp]=Simulink.CodeMapping.isErtCompliant(obj.ModelH);
            if isErtCompliant&&(Simulink.CodeMapping.isAutosarAdaptiveSTF(obj.ModelH)||~isErtCpp)
                typeChain{end+1}='ASAP2CDFExportContext';

            else
                [isGrtCompliant,isGrtCpp]=Simulink.CodeMapping.isGrtCompliant(obj.ModelH);
                if isGrtCompliant&&~isGrtCpp
                    typeChain{end+1}='ASAP2CDFExportContext';
                end
            end

            if~isempty(obj.CalContext)
                typeChain{end+1}=obj.CalContext;
            else
                typeChain{end+1}='CalibrationContext';
            end

            if~isempty(obj.CGBContext)
                typeChain{end+1}=obj.CGBContext;
            end
            if~isempty(obj.SDPContext)
                typeChain{end+1}=obj.SDPContext;
            end
            if~isempty(obj.FPContext)
                typeChain{end+1}='FCPlatform';
            end
            if~isempty(obj.PlatformContext)
                typeChain{end+1}=obj.PlatformContext;
            end
            if~isempty(obj.CGBStatusContext)
                typeChain{end+1}=obj.CGBStatusContext;
            end
            if~isempty(obj.DeployContext)
                typeChain{end+1}=obj.DeployContext;
            end
            if~isempty(obj.CodeForContext)
                typeChain{end+1}=obj.CodeForContext;
            end
            if~isempty(obj.CodeInterfaceContext)
                typeChain{end+1}=obj.CodeInterfaceContext;
            end

            obj.TypeChain=typeChain;
        end

        function updateLayoutContext(obj)
            cp=simulinkcoder.internal.CodePerspective.getInstance;
            [app,~,lang]=cp.getInfo(obj.ModelH);
            obj.LayoutContext=[app,'_',lang,'_Context'];
        end

        function updateGenCodeContext(obj)
            isGenCodeOnly=strcmpi(get_param(obj.ModelH,'GenCodeOnly'),'on');
            if isGenCodeOnly
                obj.GenCodeContext='generateCodeOnlyContext';
            else
                obj.GenCodeContext='generateCodeAndBuildContext';
            end
        end

        function preOpen(obj,cbinfo)

        end
        function postOpen(obj,cbinfo)

        end
    end

    methods(Abstract)

        guardAppName=getGuardAppName(obj)
        checkoutLicense(obj)
    end

    methods



        function ok=openGuard(obj,cbinfo)


            studio=cbinfo.studio;
            ed=cbinfo.EventData;

            if ischar(ed)&&strcmp(ed,'nonblocking')
                blocking=false;
            else
                blocking=true;
            end

            guardAppName=getGuardAppName(obj);
            ok=simulinkcoder.internal.util.openGuard(studio,guardAppName,blocking);
        end

        function openApp(obj,cbinfo,app,contextManager,customContext)

            ok=obj.openGuard(cbinfo);

            if ok

                coder.internal.toolstrip.CoderAppContext.flushOtherCoderApps(contextManager,app.name);


                obj.checkoutLicense();


                studio=cbinfo.studio;


                obj.preOpen(cbinfo);


                contextManager.activateApp(customContext);
                ts=studio.getToolStrip;
                ts.ActiveTab=customContext.DefaultTabName;
                customContext.updateTypeChain;


                cp=simulinkcoder.internal.CodePerspective.getInstance;
                if cp.isAvailable(studio)
                    cp.open(studio);
                end


                obj.postOpen(cbinfo);
            end
        end
    end

    methods(Static)
        function flushOtherCoderApps(contextManager,currentApp)


            c=dig.Configuration.get();
            otherApps=c.getApps();
            for i=1:length(otherApps)
                otherApp=otherApps{i};
                if~isempty(otherApp)...
                    &&strcmp(otherApp.defaultTabName,'coderAppTab')...
                    &&~strcmp(otherApp.name,currentApp)

                    contextManager.deactivateApp(otherApp.name);
                end
            end
        end

        function toggleCoderApp(cbinfo,appName,~)
            studio=cbinfo.studio;
            ed=cbinfo.EventData;

            if isempty(ed)
                st=true;
            elseif isnumeric(ed)||islogical(ed)
                st=ed;
            elseif ischar(ed)
                st=true;
            end

            c=dig.Configuration.get();
            app=c.getApp(appName);

            if~isempty(app)
                contextManager=studio.App.getAppContextManager;
                customContext=contextManager.getCustomContext(app.name);

                if st
                    if isempty(customContext)
                        contextProvider=app.contextProvider;
                        customContext=feval(contextProvider,app,cbinfo);
                    end
                    customContext.openApp(cbinfo,app,contextManager,customContext);
                else
                    contextManager.deactivateApp(app.name);
                    cp=simulinkcoder.internal.CodePerspective.getInstance;
                    cp.close(studio);
                end
            end
        end
    end
end


