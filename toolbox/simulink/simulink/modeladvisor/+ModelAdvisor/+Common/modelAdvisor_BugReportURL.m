function url=modelAdvisor_BugReportURL(prodName,prodCode,pageNum,keywords)









    ver=['R',version('-release')];


    testMode=modeladvisorprivate('modeladvisorutil2','FeatureControl','test');
    if testMode
        ver='R2013a';
        tlink=modeladvisorprivate('modeladvisorutil2','FeatureControl','BugReportLink');
    end



    switch prodName
    case 'Embedded Coder'
        productID='EC';
    case 'Simulink Verification and Validation'
        productID='VV';
    case 'Simulink Check'
        productID='VV';
    case 'Simulink Coverage'
        productID='CV';
    case 'Simulink Design Verifier'
        productID='DV';
    case 'IEC Certification Kit'
        productID='IE';
    case 'Simulink PLC Coder'
        productID='PL';
    case 'DO Qualification Kit'
        productID='DO';
    case 'Simulink Code Inspector'
        productID='CI';
    case 'Simulink Report Generator'
        productID='SR';
    case 'Polyspace Bug Finder'
        productID='BD';
    case 'Polyspace Code Prover'
        productID='CD';
    case 'Polyspace Bug Finder Server'
        productID='BS';
    case 'Polyspace Code Prover Server'
        productID='CS';
    case 'Simulink Test'
        productID='SZ';
    case 'Simulink Requirements'
        productID='RQ';
    case 'Simulink'
        productID='SL';
    case 'AUTOSAR Blockset'
        productID='AS';
    case 'HDL Coder'
        productID='HD';
    case 'Requirements Toolbox'
        productID='RQ';
    end


    link='https://www.mathworks.com/support/bugreports/feed/';

    if testMode
        link=tlink;
    end

    if strcmp(prodCode,'EC')
        url=[link,ver,'/',productID,'?page=',num2str(pageNum),'&keyword=',keywords];
    else
        url=[link,ver,'/',productID,'?page=',num2str(pageNum)];
    end

