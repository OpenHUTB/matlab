classdef(Hidden=true)StyleFactory<handle
    properties
        Name='';
    end

    methods(Static,Hidden=true)
        function ReportObj=creator(reportStyle)
            ReportObj=feval(reportStyle);
        end













    end

    methods(Abstract)

        html=generateReport(this,Object);
    end










end
