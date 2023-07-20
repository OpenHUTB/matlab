













classdef DiagnosticDir<handle
    properties(Constant)
        DefaultDirName=tempdir
        Instance=SimBiology.internal.DiagnosticDir
    end

    properties(SetAccess='protected')
        DirName=SimBiology.internal.DiagnosticDir.DefaultDirName
    end


    methods(Static)
        function dirName=get()
            instance=SimBiology.internal.DiagnosticDir.Instance;
            dirName=instance.DirName;
        end

        function[]=set(dirName)
            instance=SimBiology.internal.DiagnosticDir.Instance;
            instance.DirName=dirName;
        end

        function[]=restoreDefault()
            instance=SimBiology.internal.DiagnosticDir.Instance;
            instance.DirName=SimBiology.internal.DiagnosticDir.Instance.DefaultDirName;
        end
    end

    methods(Access=private)

        function obj=DiagnosticDir
        end
    end
end