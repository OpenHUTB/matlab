


classdef CriticalPath
    properties(GetAccess=private,SetAccess=private)
components
metadata
    end

    methods

        function this=CriticalPath(components,metadata)
            import BA.New.Util;
            this.components=Util.safecast2cell(components);
            this.metadata=metadata;
        end

        function comps=getComponents(this)
            comps=[this.components{:}];
        end

        function metadata=getMetadata(this)
            metadata=containers.Map(keys(this.metadata),values(this.metadata));
        end
    end
end
