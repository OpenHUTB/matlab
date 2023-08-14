classdef ModelBlock<lutdesigner.access.Access

    properties(Constant)
        Type='modelBlock'
    end

    properties(SetAccess=immutable)
Path
    end

    methods
        function this=ModelBlock(path)
            this.Path=regexprep(path,'\n',' ');
        end

        function tf=isAvailable(this)
            tf=getSimulinkBlockHandle(this.Path)>0&&...
            ~lutdesigner.access.internal.isBlockCommentedOut(this.Path)&&...
            strcmp(get_param(this.Path,'BlockType'),'ModelReference');
        end

        function tf=contains(this,that)
            tf=isequal(this,that)||(strcmp(that.Type,'lookupTableControl')&&this.containsByPath(this.Path,that.Path));
        end

        function show(this)
            lutdesigner.access.internal.showBlock(this.Path);
        end
    end

    methods
        function accessDescs=getSubAccessDescs(this)
            accessDescs=lutdesigner.access.internal.getLookupTableControlAccessDescs(this);
        end
    end
end
