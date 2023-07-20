function refreshAndExpandCodeView(modelName)





    if slfeature('IntegratedCodeReport')
        [topHdl,subSys]=coder.internal.getSubSysBuildData(modelName);

        cr=simulinkcoder.internal.Report.getInstance;


        cp=simulinkcoder.internal.CodePerspective.getInstance;
        src=simulinkcoder.internal.util.getSource(modelName);
        studio=src.studio;
        codeReport=cp.getTask('CodeReport');

        if Simulink.ModelReference.ProtectedModel.protectingModel(modelName)
            return;
        end

        if cp.isInPerspective(studio)&&codeReport.isAutoOn(modelName)
            cr.show(studio);
            cr.focus(modelName);
        else
            cr.refresh(modelName);
        end
    end

