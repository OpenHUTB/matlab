classdef ViewFinder<mlreportgen.finder.Finder























    properties(Constant,Hidden)
        InvalidPropertyNames={};
    end

    properties(Access=private)
ViewObj
        ViewList=[]
        ViewCount{mustBeInteger}=0
        NextViewIndex{mustBeInteger}=0
        IsIterating{mlreportgen.report.validators.mustBeLogical}=false
    end

    properties



        DiagramType="Default";
    end

    methods(Static,Access=private,Hidden)


        function snapshot=createViewSnapshot(this,view)
            import mlreportgen.dom.*
            switch this.DiagramType
            case "Default"
                type=view.getImpl.p_DiagramOptions;
                filepathForComponentDiagramSnapshot=fullfile([view.Name,'_default.png']);
                if type.p_DiagramType=="COMPONENT"
                    systemcomposer.internal.editor.Printer.takeScreenshotForView(view,filepathForComponentDiagramSnapshot,'DiagramType','ComponentDiagram');
                elseif type.p_DiagramType=="HIERARCHY"
                    systemcomposer.internal.editor.Printer.takeScreenshotForView(view,filepathForComponentDiagramSnapshot,'DiagramType','ComponentHierarchy');
                end
                imgObjForCompDiagram=mlreportgen.report.FormalImage(filepathForComponentDiagramSnapshot);
                imgObjForCompDiagram.Caption="View";
                snapshot=imgObjForCompDiagram;
            case "Component Diagram"
                filepathForComponentDiagramSnapshot=fullfile([view.Name,'_CD.png']);
                systemcomposer.internal.editor.Printer.takeScreenshotForView(view,filepathForComponentDiagramSnapshot,'DiagramType','ComponentDiagram');
                imgObjForCompDiagram=mlreportgen.report.FormalImage(filepathForComponentDiagramSnapshot);
                imgObjForCompDiagram.Caption="Component Diagram View";
                snapshot=imgObjForCompDiagram;
            case "Component Hierarchy"
                filepathForComponentHierarchySnapshot=fullfile([view.Name,'_CH.png']);
                systemcomposer.internal.editor.Printer.takeScreenshotForView(view,filepathForComponentHierarchySnapshot,'DiagramType','ComponentHierarchy')
                imgObjForCompHierarchy=mlreportgen.report.FormalImage(filepathForComponentHierarchySnapshot);
                imgObjForCompHierarchy.Caption="Component Hierarchy View";
                snapshot=imgObjForCompHierarchy;
            end
        end












        function viewStruct=createViewStruct(this,view)
            viewStruct.obj=view.UUID;
            viewStruct.Name=view.Name;
            if isempty(view.Description)
                viewStruct.Description="-";
            else
                viewStruct.Description=view.Description;
            end
            if isempty(view.Select)
                viewStruct.Select="-";
            else
                viewStruct.Select=view.Select.stringify;
            end
            if isempty(view.GroupBy)
                viewStruct.GroupBy="-";
            else
                viewStruct.GroupBy=view.GroupBy;
            end
            if isempty(view.Root.Elements)
                viewStruct.Elements=[];
            else
                viewStruct.Elements=view.Root.Elements;
            end
            if isempty(view.Root.SubGroups)
                viewStruct.SubGroups=[];
            else
                viewStruct.SubGroups=view.Root.SubGroups;
            end
            snapshot=systemcomposer.rptgen.finder.ViewFinder.createViewSnapshot(this,view);
            viewStruct.SnapShot=snapshot;
            viewStruct.Color=view.Color;
        end
    end

    methods(Hidden)


        function results=getResultsArrayFromStruct(this,viewsInformation)
            n=numel(viewsInformation);
            results=mlreportgen.finder.Result.empty(0,n);
            for i=1:n
                temp=viewsInformation(i);
                results(i)=systemcomposer.rptgen.finder.ViewResult(temp.obj);
                results(i).Name=temp.Name;
                results(i).Description=temp.Description;
                results(i).Select=temp.Select;
                results(i).GroupBy=temp.GroupBy;
                results(i).Elements=temp.Elements;
                results(i).SubGroups=temp.SubGroups;
                results(i).Snapshot=temp.SnapShot;
                results(i).Color=temp.Color;
            end
            this.ViewList=results;
            this.ViewCount=numel(results);

        end

        function results=findViewsInModel(this)
            viewsInformation=[];
            modelHandle=load_system(this.Container);
            isARM=Simulink.internal.isArchitectureModel(modelHandle,"AUTOSARArchitecture");
            if(isARM)
                model=systemcomposer.arch.Model(modelHandle);
            else
                model=systemcomposer.loadModel(this.Container);
            end
            views=model.Views;
            numel=length(views);
            for i=1:numel
                viewsInformation=[viewsInformation,systemcomposer.rptgen.finder.ViewFinder.createViewStruct(this,views(i))];%#ok<*AGROW> 
            end
            results=getResultsArrayFromStruct(this,viewsInformation);
        end

        function results=helper(this)
            results=findViewsInModel(this);
        end
    end

    methods
        function this=ViewFinder(varargin)
            this@mlreportgen.finder.Finder(varargin{:});
            reset(this);
        end

        function results=find(this)










            results=findViewsInModel(this);
        end

        function tf=hasNext(this)





















            if this.IsIterating
                if this.NextViewIndex<=this.ViewCount
                    tf=true;
                else
                    tf=false;
                end
            else
                helper(this);
                if this.ViewCount>0
                    this.NextViewIndex=1;
                    this.IsIterating=true;
                    tf=true;
                else
                    tf=false;
                end
            end
        end

        function result=next(this)













            if hasNext(this)

                result=this.ViewList(this.NextViewIndex);

                this.NextViewIndex=this.NextViewIndex+1;
            else
                result=systemcomposer.rptgen.finder.ViewResult.empty();
            end
        end
    end

    methods(Access=protected)
        function reset(this)






            this.IsIterating=false;
            this.ViewCount=0;
            this.ViewList=[];
            this.NextViewIndex=0;
        end

        function tf=isIterating(this)






            tf=this.IsIterating;
        end
    end
end