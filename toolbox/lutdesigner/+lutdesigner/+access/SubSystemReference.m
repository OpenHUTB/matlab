classdef SubSystemReference<lutdesigner.access.System

    properties(Constant)
        Type='subsystemReference'
    end

    properties(SetAccess=immutable)
Path
    end

    methods
        function this=SubSystemReference(path)
            this.Path=regexprep(path,'\n',' ');
        end

        function tf=isAvailable(this)
            tf=getSimulinkBlockHandle(this.Path)>0&&...
            ~lutdesigner.access.internal.isBlockCommentedOut(this.Path)&&...
            strcmp(get_param(this.Path,'BlockType'),'SubSystem')&&...
            ~isempty(get_param(this.Path,'ReferencedSubsystem'));
        end

        function tf=contains(this,that)
            tf=isequal(this,that)||this.containsByPath(this.Path,that.Path);
        end

        function show(this)
            lutdesigner.access.internal.showBlock(this.Path);
        end
    end
end
