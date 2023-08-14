function[verificationResult,simOut]=verify(this,baselineRunName,verificationRunName)

























    this.assertDEValid();


    validateattributes(baselineRunName,{'char'},{'nonempty','row'});
    validateattributes(verificationRunName,{'char'},{'nonempty','row'});


    assert(contains(baselineRunName,this.RunNames),message('SimulinkFixedPoint:autoscaling:runNameNotFound',baselineRunName));


    verificationSettings=DataTypeWorkflow.CollectionSettings;
    shortcut=DataTypeWorkflow.ShortcutManager.DefaultFactoryNames{2};
    verificationSettings.ShortcutToApply=shortcut;
    verificationSettings.RunName=verificationRunName;

    baselineSettings=DataTypeWorkflow.CollectionSettings;
    baselineSettings.RunName=baselineRunName;

    try
        simOut=this.performVerification(baselineSettings,verificationSettings);
    catch e
        throwAsCaller(e)
    end



    verificationRunName=verificationSettings.RunName;
    verificationResult=this.getVerificationResult(verificationRunName);


    verificationResult.overwriteBaselineRunName(baselineRunName);

end
