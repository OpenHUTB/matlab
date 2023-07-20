classdef InterfaceEditorServer





    properties(Access=private)
        contextName;
        context;
        selectionContext;
        sourceName;
        mf0Model;
        isModelContext;
        piCatalog;
        dd;
        studioTag;
    end

    methods(Static)
        function varargout=executeMethod(contextName,context,studioTag,selectionContext,methodName,varargin)
            server=systemcomposer.internal.InterfaceEditorServer(contextName,...
            context,studioTag,selectionContext);


            methodFcn=str2func(methodName);
            [varargout{1:nargout}]=methodFcn(server,varargin{:});
        end
    end

    methods(Access=private)
        function obj=InterfaceEditorServer(contextName,context,studioTag,selectionContext)
            obj.contextName=contextName;
            obj.context=context;
            obj.studioTag=studioTag;
            obj.selectionContext=selectionContext;
            if~isempty(studioTag)
                activeStudio=DAS.Studio.getStudio(studioTag);
                contextModelName=get_param(activeStudio.App.getActiveEditor.blockDiagramHandle,'Name');
                zcModel=systemcomposer.arch.Model(contextModelName);
                obj.mf0Model=mf.zero.getModel(zcModel.getImpl);
            else
                dictContextName=contextName;
                if~isempty(selectionContext)&&~strcmpi(context,'Model')
                    dictContextName=strrep(selectionContext,'.sldd','');
                end
                [obj.sourceName,obj.isModelContext,obj.piCatalog,obj.dd,reopenedSLDD]=systemcomposer.internal.getDictionaryInfo(dictContextName,context);
                obj.mf0Model=mf.zero.getModel(obj.piCatalog);
                if(reopenedSLDD)

                    allStudios=DAS.Studio.getAllStudiosSortedByMostRecentlyActive;
                    assert(numel(allStudios)>0);
                    studio=allStudios(1);
                    bdH=studio.App.blockDiagramHandle;
                    Simulink.SystemArchitecture.internal.ApplicationManager.refreshInterfaceEditorURL(...
                    bdH,get_param(bdH,'Name'),[contextName,'.sldd']);
                end
            end
        end

        function varargout=execInterfaceEditorMethod(this,methodName,errorMsgId,varargin)
            methodFcn=str2func(['systemcomposer.InterfaceEditor.',methodName]);
            try
                [varargout{1:nargout}]=methodFcn(this.contextName,this.context,varargin{:});
            catch ME
                if~isempty(errorMsgId)


                    error(message(['SystemArchitecture:InterfaceEditor:',errorMsgId]));
                end
                rethrow(ME);
            end
        end

        function openPropertyInspector(this,selectedObjUUID,parentObjUUID,bringToFront,varargin)
            systemcomposer.InterfaceEditor.OpenPropertyInspector(...
            this.contextName,this.context,this.studioTag,...
            selectedObjUUID,parentObjUUID,bringToFront,varargin{:});
        end
        function contextName=getContextName(this)




            if isempty(this.selectionContext)||this.isModelContext
                contextName=this.contextName;
                return;
            end
            contextName=strrep(this.selectionContext,'.sldd','');
        end

        function openHelp(~)
            helpview(fullfile(docroot,'systemcomposer','helptargets.map'),'interfaceeditortool');
        end
    end
end


