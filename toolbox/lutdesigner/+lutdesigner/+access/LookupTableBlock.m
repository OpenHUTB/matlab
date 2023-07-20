classdef LookupTableBlock<lutdesigner.access.Access

    properties(Constant)
        Type='lookupTableBlock'
    end

    properties(SetAccess=immutable)
Path
    end

    methods
        function this=LookupTableBlock(path)
            this.Path=regexprep(path,'\n',' ');
        end

        function tf=isAvailable(this)
            tf=getSimulinkBlockHandle(this.Path)>0&&...
            ~lutdesigner.access.internal.isBlockCommentedOut(this.Path)&&...
            lutdesigner.lutfinder.LookupTableFinder.isLookupTableBlock(this.Path);
        end

        function tf=contains(this,that)
            tf=isequal(this,that)||(strcmp(that.Type,'lookupTableControl')&&this.containsByPath(this.Path,that.Path));
        end

        function show(this)
            lutdesigner.access.internal.showBlock(this.Path);
        end
    end

    methods
        function dataProxy=getDataProxy(this)
            dataProxy=lutdesigner.lutfinder.LookupTableFinder.getLookupTableBlockDataProxy(char(this.Path));
        end

        function accessDescs=getSubAccessDescs(this)
            accessDescs=lutdesigner.access.internal.getLookupTableControlAccessDescs(this);
        end
    end
end
