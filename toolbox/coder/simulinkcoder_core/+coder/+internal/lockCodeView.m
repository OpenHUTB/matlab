function[topHdl,subSys]=lockCodeView(modelName)




    if slfeature('IntegratedCodeReport')
        [topHdl,subSys]=coder.internal.getSubSysBuildData(modelName);
        cr=simulinkcoder.internal.Report.getInstance;
        cr.lock(topHdl,subSys);
    end

