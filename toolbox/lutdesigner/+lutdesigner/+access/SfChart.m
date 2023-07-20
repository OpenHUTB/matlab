classdef SfChart<lutdesigner.access.System

    properties(Constant)
        Type='sfchart'
    end

    properties(SetAccess=immutable)
Path
    end

    methods
        function this=SfChart(path)
            this.Path=regexprep(path,'\n',' ');
        end

        function tf=isAvailable(this)
            tf=getSimulinkBlockHandle(this.Path)>0&&...
            ~lutdesigner.access.internal.isBlockCommentedOut(this.Path)&&...
            strcmp(get_param(this.Path,'BlockType'),'SubSystem');
        end

        function tf=contains(this,that)
            tf=isequal(this,that)||this.containsByPath(this.Path,that.Path);
        end

        function show(this)
            lutdesigner.access.internal.showBlock(this.Path);
        end
    end
end
