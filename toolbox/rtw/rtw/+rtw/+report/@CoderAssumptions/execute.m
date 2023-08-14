function execute(obj)





    obj.AddSectionNumber=false;
    obj.AddSectionShrinkButton=false;
    obj.AddSectionToToc=false;


    codeDesc=coder.getCodeDescriptor(obj.BuildDir,247362);
    assumptions=codeDesc.getMF0FullModel.CoderAssumptions;


    msg=Advisor.Text(DAStudio.message('RTW:report:CoderAssumptionsIntro'));
    pIntro=Advisor.Paragraph;
    pIntro.addItem(msg);
    obj.IntroductionContent=pIntro;


    obj.addLanguageConfiguration(assumptions);


    obj.addLanguageStandard(assumptions);


    obj.addFloatingPointNumbers(assumptions);

end
