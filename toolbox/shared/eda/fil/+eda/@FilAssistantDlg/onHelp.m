function onHelp(this,~)




    switch(this.StepID)
    case 1
        docID='filWizard_HdwOptions';
    case 2
        docID='filWizard_SrcFiles';
    case 3
        docID='filWizard_DUTPorts';
    case 4
        docID='filWizard_OutputTypes';
    case 5
        docID='filWizard_BldOptions';
    end
    if this.Tool==1
        docID=[docID,'_Block'];
    end

    helpview(fullfile(docroot,'toolbox','hdlverifier','helptargets.map'),docID);
