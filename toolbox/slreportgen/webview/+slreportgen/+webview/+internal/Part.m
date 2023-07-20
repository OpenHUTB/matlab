classdef Part<handle






















    properties(SetAccess=private)

RootDiagram





Diagrams
    end

    properties
        ExportData slreportgen.webview.internal.PartExportData
    end

    methods(Access=?slreportgen.webview.internal.ModelBuilder)
        function this=Part(model)
            this.RootDiagram=model.RootDiagram;
            this.Diagrams=model.Diagrams;

            for i=1:numel(this.Diagrams)
                this.Diagrams(i).setPart(this);
            end
        end
    end
end
