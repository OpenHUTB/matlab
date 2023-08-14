classdef Report<handle




    properties(Hidden,Access=private)
        SelectedSystemToScale=''
    end

    properties(Hidden)
        SetupInfo=[]
        RestorePointInfo=[]
        CheckInfo=[]
        SUDBoundary=[]
        ConvertInfo=[]
        VerifyInfo=[]
    end

    methods
        function report=Report(selectedSystemToScale)
            report.SelectedSystemToScale=selectedSystemToScale;
        end
    end

end


