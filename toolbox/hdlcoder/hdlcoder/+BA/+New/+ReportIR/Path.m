classdef Path<BA.New.ReportIR.PrettyPrintable

    properties(GetAccess=private,SetAccess=private)
components
delays
metadata
    end

    methods
        function this=Path(components,delays,metadata)
            import BA.New.Util;

            this.components=Util.safecast2cell(components);
            this.delays=Util.safecast2cell(delays);
            this.metadata=containers.Map(keys(metadata),values(metadata));
        end

        function comps=getComponents(this)
            import BA.New.Util;
            comps=Util.safecast2cell(this.components);
        end

        function delays=getDelays(this)
            import BA.New.Util;
            delays=cell2mat(this.delays);
        end

        function metadata=getMetadata(this)
            metadata=containers.Map(keys(this.metadata),values(this.metadata));
        end

        function prettyPrint(this,indentWidth,indentLevel)
        end
    end

    methods(Access=private)
        function checkRep(this)
            assert(true);
        end
    end
end
