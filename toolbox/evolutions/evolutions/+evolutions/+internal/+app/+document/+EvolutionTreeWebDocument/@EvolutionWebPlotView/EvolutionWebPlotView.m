classdef EvolutionWebPlotView<handle




    properties(SetAccess=protected)
Document
Syntax
Editor
RootEi
CurrentEi
ActiveEi
SelectedNode
SelectedEdge
EvolutionIdToInfo
EvolutionIdToNode
EventHandler


NodeMap
NodeTable
EdgeTable
Digraph
TreePlot
LayoutInfo
IndexToXY
    end
    properties(Constant)
        SingleXRowNodeFill=.75;
        MultipleXRowNodeFill=.75;
        SingleYRowNodeFill=.5;
        MultipleYRowNodeFill=.5;
    end

    properties(Constant)
        GridRows={'1x'};
        GridColumns={'1x'};
    end

    events(NotifyAccess=?protected)
SelectionChanged
EdgeSelectionChanged
SelectedEdgeChanged
CanvasClicked
NodeClicked
EdgeClicked
NodeDoubleClick
NodeMiddleButtonClick
GetEvolution
UpdateEvolution
CreateEvolution
DeleteEvolution
DeleteEvolutionBranch
OpenEvolutionProperties
    end

    methods
        function this=EvolutionWebPlotView(document)
            this.Document=document;


            this.Syntax=diagram.interface.DiagramSyntax;
            diagramRoot=this.Syntax.root;






            editor=diagram.editor.registry.EditorController(this.Syntax,diagramRoot.uuid,'');
            this.Editor=editor;

            installListeners(this);


            packetChannel=editor.uuid;
            msgChannel=document.AppView.MsgChannel;
            document.Content=struct('packetChannel',packetChannel,'evChannel',msgChannel);


            if document.Debug
                editor.startLogging;
            end
        end
    end

    methods(Hidden)

        function syntax=getSyntax(this)
            syntax=this.Syntax;
        end

    end

    methods(Access=public)

        update(this,rootEvolution,evolutionCreated)
        addNodeStyle(this)

        function enableWidget(~,~,~)
        end

        function layoutView(~)
        end


        resizeCallback(this,~,~)

        recClickedCallback(this,src,evnt)

        getEvolutionCallback(this,src,~)

        createEvolutionCallback(this,src,~)

        updateEvolutionCallback(this,src,~)

        deleteEvolutionCallback(this,src,~)

        deleteEvolutionBranchCallback(this,src,~)


        changeEvolutionName(this,ei)

        changeSelectedAndNotify(this,ei)

        changeSelected(this,varargin)

        setActiveEdited(this)

    end

    methods(Access=protected)
        function installListeners(this)

            selector=this.Editor.getSelection();
            selector.registerSelectionChangeListener(@this.recClickedCallback);



            this.Editor.commandFactory.registerCreateFunction...
            (diagram.editor.command.DeleteCommand.StaticMetaClass,...
            @(cmd)this.customCommand(cmd));

            this.Editor.commandFactory.registerCreateFunction...
            (diagram.editor.command.CutCommand.StaticMetaClass,...
            @(cmd)this.customCommand(cmd));

            this.Editor.commandFactory.registerCreateFunction...
            (diagram.editor.command.CopyMoveCommand.StaticMetaClass,...
            @(cmd)this.customCommand(cmd));

            this.Editor.commandFactory.registerCreateFunction...
            (diagram.editor.command.MoveCommand.StaticMetaClass,...
            @(cmd)this.customCommand(cmd));

        end


        function c=customCommand(this,cmd)
            c=evolutions.internal.app.document.EvolutionTreeWebDocument...
            .WDECustomCommand(cmd,this.Syntax);

        end
    end
end


