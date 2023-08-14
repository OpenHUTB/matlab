classdef(Abstract)BaseWebScopeView<handle







    properties(Abstract)

        ScopeTitle(1,1)string
    end

    properties(Abstract,Constant)

        ScopeName(1,1)string
    end

    properties(Access=protected,Abstract,Constant)

        ScopeIconFile(1,1)string
    end

    properties(SetAccess=protected)

        ScopeContainer;

        ScopeTerminatedListener;

        ScopePropertyChangedListener;

ScopeUpdateToolstripListener

        ScopeMessageHandler;

        ScopeURL;

        ScopeTabGroups;

        ScopeTabs;

        ScopeDocumentGroups;

        ScopeFigureDocument;

        ScopeUIHTMLWidget;
    end

    properties(Constant,Access=protected)
        ScopeIconsFilePath=fullfile(toolboxdir('shared/dsp/webscopes'),'dspwebscopesutils','js','images');
        ProductName="DSP System Toolbox";
    end



    methods

        function this=BaseWebScopeView(hMessage,url)
            this.ScopeMessageHandler=hMessage;
            this.ScopeURL=url;
            createContainer(this);
            createWidgets(this);
            this.ScopePropertyChangedListener=event.listener(hMessage,'PropertyChanged',@this.onScopePropertyChanged);
        end

        function delete(this)
            delete(this.ScopeTerminatedListener);
            delete(getContainer(this));
        end

        function show(this)
            scopeContainer=getContainer(this);
            scopeContainer.Visible=true;
            scopeContainer.bringToFront();
        end

        function hide(this)
            scopeContainer=getContainer(this);
            scopeContainer.Visible=false;
        end

        function close(this)
            close(this.ScopeContainer);
        end

        function c=getContainer(this)
            c=this.ScopeContainer;
        end

        function fig=getFigure(this)
            fig=this.ScopeFigureDocument.Figure;
        end

        function flag=isContainerValid(this)
            import matlab.ui.container.internal.appcontainer.*;
            scopeContainer=getContainer(this);
            flag=~isempty(scopeContainer)&&isvalid(scopeContainer)...
            &&(scopeContainer.State~=AppState.TERMINATED);
        end

        function flag=isVisible(this)
            scopeContainer=getContainer(this);
            flag=isContainerValid(this)&&scopeContainer.Visible;
        end

        function setBusy(this,flag)
            scopeContainer=getContainer(this);
            scopeContainer.Busy=flag;
            drawnow;
        end

        function flag=isBusy(this)
            scopeContainer=getContainer(this);
            flag=scopeContainer.Busy;
        end

        function setName(this,name)
            scopeContainer=getContainer(this);
            scopeContainer.Title=name;
        end

        function setPosition(this,pos)
            scopeContainer=getContainer(this);
            scopeContainer.WindowBounds=pos;
        end

        function setContexts(this,contexts)
            scopeContainer=getContainer(this);
            scopeContainer.Contexts=contexts;
        end

        function setActiveContexts(this,contexts)
            scopeContainer=getContainer(this);
            scopeContainer.ActiveContexts=contexts;
        end
    end



    methods(Access=protected)

        function createContainer(this)
            scopeOptions.Tag=this.ScopeName+"_"+this.ScopeMessageHandler.Specification.Name;
            scopeOptions.Title=this.ScopeTitle;
            scopeOptions.Product=this.ProductName;
            scopeOptions.Scope=this.ScopeTitle;
            scopeOptions.WindowBounds=utils.getDefaultWebWindowPosition([800,530]);
            scopeOptions.ToolstripCollapsed=true;
            scopeOptions.ToolstripEnabled=true;
            scopeOptions.ShowSingleDocumentTab=false;
            scopeOptions.UserDocumentTilingEnabled=false;
            scopeOptions.CanCloseFcn=@(varargin)canScopeCloseCallback(this);



            scopeOptions.Icon=this.ScopeIconFile;
            this.ScopeContainer=matlab.ui.container.internal.AppContainer(scopeOptions);

            this.ScopeTerminatedListener=addlistener(this.ScopeContainer,...
            'StateChanged',@this.onScopeStateChanged);
        end

        function createWidgets(this)
            buildToolstrip(this);
            buildQuickAccessBar(this);
            buildPanels(this);
            buildDocuments(this);
            buildStatusBar(this);
        end

        function buildToolstrip(~)

        end

        function buildQuickAccessBar(~)

        end

        function buildPanels(~)

        end

        function buildDocuments(~)

        end

        function buildStatusBar(~)

        end

        function onScopeStateChanged(this,~,~)

            import matlab.ui.container.internal.appcontainer.*
            scopeContainer=getContainer(this);
            if isvalid(scopeContainer)
                switch(scopeContainer.State)
                case AppState.TERMINATED
                    close(this);
                case AppState.RUNNING
                    updateToolstrip(this,this.ScopeTabs);
                end
            end
        end

        function onScopePropertyChanged(this,~,~)
            updateToolstrip(this,this.ScopeTabs);
        end

        function tabGroup=createTabGroup(this,tag,contextual)

            tabGroup=matlab.ui.internal.toolstrip.TabGroup();
            tabGroup.Tag=this.ScopeName+tag+"TabGroup";
            tabGroup.Contextual=contextual;
            this.ScopeTabGroups=[this.ScopeTabGroups,tabGroup];
        end

        function docGroup=createDocumentGroup(this,tag)


            options.Tag=this.ScopeName+tag+"DocumentGroup";
            options.Title="Figures";
            docGroup=matlab.ui.internal.FigureDocumentGroup(options);
            this.ScopeDocumentGroups=[this.ScopeDocumentGroups,docGroup];
        end

        function figDocument=createFigureDocument(this,tag)
            figOptions.Title=this.ScopeTitle;
            figOptions.Tag=this.ScopeName+tag+"FigureDocument";
            figOptions.Maximizable=false;
            figDocument=matlab.ui.internal.FigureDocument(figOptions);
            this.ScopeFigureDocument=figDocument;
        end

        function add(this,widget)

            scopeContainer=getContainer(this);
            scopeContainer.add(widget);
        end

        function addDocument(this,docGroupTag,document)

            document.DocumentGroupTag=docGroupTag;
            add(this,document);
        end

        function removeDocument(this,docGroupTag,docTag)

            if this.hasDocument(docGroupTag,docTag)
                closeDocument(getContainer(this),docGroupTag,docTag);
            end
        end

        function val=hasDocument(this,docGroupTag,docTag)

            val=hasDocument(getContainer(this),docGroupTag,docTag);
        end

        function flag=canScopeCloseCallback(this)
            flag=false;
            hide(this);
        end

        function contexts=getContexts(~)

            contexts={};
        end

        function activeContexts=getActiveContexts(~)

            activeContexts=[];
        end
    end
end
