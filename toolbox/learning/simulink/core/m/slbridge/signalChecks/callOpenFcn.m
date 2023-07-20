

function callOpenFcn(~,~,~)



    graderType=SignalCheckUtils.getGraderType(gcb);

    switch graderType
    case 'mlsignal'
        SignalMATLABCheck.openFcn();
    case 'mlmodel'
        ModelMATLABCheck.openFcn();
    case 'signal'
        SignalAssessment.openFcn();
    case 'sfmodel'
        ModelStateflowCheck.openFcn();
    otherwise



    end

end
