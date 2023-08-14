classdef ElementExportData<handle


















    properties(Access=private)

        Element slreportgen.webview.internal.Element
    end

    properties



        IconClass string
    end

    methods
        function this=ElementExportData(element)
            this.Element=element;
        end

        function write(this,writer)






            assert(isa(writer,"slreportgen.webview.JSONWriter"));

            element=this.Element;

            writer.beginObject();

            writer.name("sid");
            writer.value(element.SlProxyObjectID);

            writer.name("rsid");
            writer.value(element.rsid());

            writer.name("name");

            writer.value(element.Name);

            writer.name("label");
            writer.value(element.DisplayLabel);

            writer.name("className");
            writer.value(element.ClassName);

            writer.name("icon");
            writer.value(this.IconClass);

            writer.endObject();
        end
    end
end