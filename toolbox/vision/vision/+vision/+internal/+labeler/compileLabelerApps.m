function compileLabelerApps(flag)











    if isdeployed
        s=settings;

        if flag
            s.vision.labeler.CompileLabelingApps.TemporaryValue=true;
            s.matlab.ui.figure.DockFigureInDeployment.TemporaryValue=true;
        else
            s.vision.labeler.CompileLabelingApps.TemporaryValue=false;
            s.matlab.ui.figure.DockFigureInDeployment.TemporaryValue=false;
        end
    end

end