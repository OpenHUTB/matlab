classdef DiagramExportData<handle


























    properties(SetAccess=private)

        Diagram slreportgen.webview.internal.Diagram
    end

    properties

        ID uint64




        IconClass string



        SVG string



        Thumbnail string




        Notes struct




        SystemView string






        OptionalViews struct




        SameAsElement logical=false






        IsPartOfExportHierarchy logical
    end

    methods
        function this=DiagramExportData(diagram)
            this.Diagram=diagram;
        end

        function write(this,writer)




            assert(isa(writer,"slreportgen.webview.JSONWriter"));

            diagram=this.Diagram;

            writer.beginObject();

            writer.name("hid");
            writer.value(this.ID);

            writer.name("sid");
            writer.value(diagram.SID);

            writer.name("esid");
            if isempty(diagram.ESID)
                writer.value("");
            else
                writer.value(diagram.ESID);
            end

            writer.name("parent");
            if~isempty(diagram.Parent)
                writer.value(diagram.Parent.ExportData.ID);
            else
                writer.value(0);
            end

            writer.name("children");
            writer.beginArray();
            children=diagram.Children;
            for i=1:numel(children)
                child=children(i);
                if child.ExportData.IsPartOfExportHierarchy
                    writer.value(child.ExportData.ID);
                end
            end
            writer.endArray()

            writer.name("name");

            writer.value(diagram.Name);

            writer.name("fullname");
            writer.value(diagram.path());


            writer.name("label");
            writer.value(diagram.DisplayLabel);

            writer.name("className");
            writer.value(diagram.ClassName);

            writer.name("icon");
            writer.value(this.IconClass);

            writer.name("svg");
            writer.value(this.SVG);

            writer.name("thumbnail");
            writer.value(this.Thumbnail);

            if~isempty(this.Notes)
                writer.name("notes");
                writer.value(this.Notes);
            end

            writer.name("elements");
            writer.beginArray();
            if diagram.Selected
                elements=diagram.elements();
                for j=1:numel(elements)
                    elements(j).ExportData.write(writer);
                end
            end
            writer.endArray();

            writer.name("sysViewURL");
            writer.value(this.SystemView);

            if~isempty(this.OptionalViews)
                writer.name("optViewURLs");
                viewIDs=fieldnames(this.OptionalViews);
                nViews=numel(viewIDs);
                writer.beginObject();
                for i=1:nViews
                    viewID=viewIDs{i};
                    writer.name(viewID);
                    writer.value(this.OptionalViews.(viewID));
                end
                writer.endObject();
            end


            writer.name("sameAsElement");
            writer.value(this.SameAsElement);

            writer.endObject();
        end
    end
end
