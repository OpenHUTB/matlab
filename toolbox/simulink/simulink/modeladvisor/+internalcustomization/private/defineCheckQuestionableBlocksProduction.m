function rec=defineCheckQuestionableBlocksProduction()

    rec=ModelAdvisor.internal.EdittimeCheck('mathworks.codegen.PCGSupport');

    rec.Title=DAStudio.message('ModelAdvisor:engine:QB_PR_Title');
    rec.TitleTips=DAStudio.message('ModelAdvisor:engine:QB_PR_TitleTips');
    rec.CSHParameters.MapKey=getMisraCshMapKey();
    rec.CSHParameters.TopicID='MATitlePCGSupport';
    rec.Visible=true;
    rec.Enable=true;
    rec.Value=true;
    rec.Group='Embedded Coder';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    rec.HasANDLicenseComposition=false;
    rec.SupportsEditTime=true;
    rec.LicenseName={'RTW_Embedded_Coder','SL_Verification_Validation'};
    rec.Published=true;

end

function mapKey=getMisraCshMapKey()
    if Advisor.Utils.license('test','RTW_Embedded_Coder')
        mapKey='ma.ecoder';
    elseif Advisor.Utils.license('test','SL_Verification_Validation')
        mapKey='ma.misrac2012';
    else
        mapKey='';

    end
end