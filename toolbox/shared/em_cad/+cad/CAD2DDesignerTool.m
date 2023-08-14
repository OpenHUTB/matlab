classdef CAD2DDesignerTool<handle




    properties
App

View
Model
Controller


TabGroup
CadDesignTab
FigureDocumentGroup

TreeDocument

CanvasDocument

PropertiesDocument
    end
    methods

        function self=CAD2DDesignerTool()
            import matlab.ui.container.internal.AppContainer;
            import matlab.ui.internal.toolstrip.*;
            import matlab.ui.internal.*;





            self.App=AppContainer();

            self.TabGroup=TabGroup();
            self.TabGroup.Tag='CAD2DDesign';
            self.App.add(self.TabGroup);

            self.CadDesignTab=cad.CADDesignTab(self.TabGroup);

            group=FigureDocumentGroup();
            group.Title="Cad2DDesigner";
            group.Tag="FigureDocumentGroup";
            self.App.add(group);
            self.FigureDocumentGroup=group;

            generateNewSessionView(self)



            self.App.Visible=true;
            addViewModelAndController(self)
        end

        function generateNewSessionView(self)
            import matlab.ui.internal.*;



            documentOptions.Title="Tree";
            documentOptions.Tag="TreeView";

            documentOptions.DocumentGroupTag="FigureDocumentGroup";
            document=FigureDocument(documentOptions);
            self.App.add(document);
            self.TreeDocument=document;

            documentOptions.Title="Canvas";
            documentOptions.Tag="Canvas";

            documentOptions.DocumentGroupTag="FigureDocumentGroup";
            document=FigureDocument(documentOptions);
            self.App.add(document);
            self.CanvasDocument=document;

            documentOptions.Title="Properties";
            documentOptions.Tag="Properties";

            documentOptions.DocumentGroupTag="FigureDocumentGroup";
            document=FigureDocument(documentOptions);
            self.App.add(document);
            self.PropertiesDocument=document;

        end

        function addViewModelAndController(self)
            self.View=[cad.Cad2DCanvas(self.CanvasDocument.Figure),...
            cad.TreeNodeView(self.TreeDocument.Figure)];
            sf=cad.ShapeFactory;
            of=cad.OperationsFactory;
            self.Model=cad.CADModel(sf,of);
            self.Controller=cad.Controller(self.View,self.Model);
        end
    end
end
