classdef Report<handle




    properties(Hidden,Access=private)
        SelectedSystemToScale=''
    end

    properties(Hidden)
        SetupInfo=[]
        HardwareSetting=[]
        DiagnosticSetting=[]
        UnsupportedConstruct=[]
        DesignRange=[]
        SUDBoundary=[]
        RestorePoint=[]
    end

    methods
        function report=Report(selectedSystemToScale)
            report.SelectedSystemToScale=selectedSystemToScale;
        end
    end

end


