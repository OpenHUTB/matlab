function[status,ResultDescription,ResultHandles,htmlSource]=...
    verifyCheckPrerequisits(this,CheckObj,NeedSupportLib,...
    ServiceSuccess,ServiceMessage,compileerrormsg,...
    CovCompileStatus,SLDVCompileFailed,htmlSource)




    status=false;
    ResultDescription={};
    ResultHandles={};





    [LicenseSuccess,LicenseMessage]=LicenseTest(CheckObj);
    if~LicenseSuccess
        ME=MException('Simulink:ModelAdvisor:LicenseCheckoutFail',LicenseMessage);
        throw(ME);
    end


    if~ServiceSuccess
        if isa(CheckObj,'ModelAdvisor.Check')
            CheckObj.Success=false;
            CheckObj.ErrorSeverity=100;
        end



        ResultHandles{1}='';
        ResultDescription{1}=['<font color="#FF0000">',ServiceMessage,'</font>'];

        htmlSource=strrep(htmlSource,'<!-- Service Status Flag -->',ServiceMessage);

    elseif~LicenseSuccess

        ResultHandles{1}='';
        ResultDescription{1}=['<font color="#FF0000">',LicenseMessage,'</font>'];

    elseif NeedSupportLib&&~CheckObj.SupportLibrary&&~modeladvisorprivate('modeladvisorutil2','FeatureControl','ForceRunOnLibrary')

        if isa(CheckObj,'ModelAdvisor.Check')
            CheckObj.Success=false;
            CheckObj.ErrorSeverity=100;
        end

        LibraryMessage=DAStudio.message('ModelAdvisor:engine:CheckNotSupportLibrary');

        ResultHandles{1}='';
        ResultDescription{1}=['<font color="#FF0000">',LibraryMessage,'</font>'];

    elseif(strcmpi(CheckObj.CallbackContext,'PostCompile')&&~this.HasCompiled)||...
        (strcmpi(CheckObj.CallbackContext,'PostCompileForCodegen')&&~this.HasCompiledForCodegen)||...
        (strcmpi(CheckObj.CallbackContext,'CGIR')&&~this.HasCGIRed)||...
        (strcmpi(CheckObj.CallbackContext,'Coverage')&&CovCompileStatus==-1)||...
        (strcmpi(CheckObj.CallbackContext,'SLDV')&&SLDVCompileFailed)

        if strcmpi(CheckObj.CallbackContext,'SLDV')
            msg=['<font color="#FF0000">',...
            DAStudio.message('ModelAdvisor:engine:MASLDVErrorOccurredCompile'),...
            '<br /><br />',compileerrormsg,'</font>'];
        else
            msg=['<font color="#FF0000">',...
            DAStudio.message('Simulink:tools:MAErrorOccurredCompile'),...
            '<br /><br />',compileerrormsg,'</font>'];
        end



        if strcmp(CheckObj.CallbackStyle,'StyleOne')
            ResultHandles{1}=msg;
            ResultDescription{1}='';
        else
            ResultHandles{1}='';
            ResultDescription{1}=msg;
        end

        htmlSource=strrep(htmlSource,'<!-- Compile Status Flag -->',ResultDescription{1});

    else
        status=true;
    end


    if strcmpi(CheckObj.CallbackContext,'CGIR')
        [flag,msg]=ModelAdvisor.Common.modelAdvisor_CGIRCheckSetting(bdroot(this.SystemName),true);

        if~flag
            ResultHandles{1}='';
            ResultDescription{1}=msg;
            status=false;
        end
    end


    if~status
        CheckObj.Result={ResultDescription,ResultHandles};
    end
end







function[LicenseSuccess,LicenseMessage]=LicenseTest(checkObj)
    LicenseSuccess=true;
    LicenseMessage='';
    if checkObj.IsCustomCheck
        if~Advisor.Utils.license('checkout','SL_Verification_Validation')
            LicenseMessage=DAStudio.message('Simulink:tools:MAMissVnVLicenseForCustomCheck');
            LicenseSuccess=false;
            return
        end
    end
    if~isempty(checkObj.LicenseName)

        if checkObj.HasANDLicenseComposition

            for licenseIdx=1:length(checkObj.LicenseName)

                if~(strcmp(checkObj.LicenseName{licenseIdx},'Simulink_Code_Inspector'))&&...
                    ~Advisor.Utils.license('checkout',checkObj.LicenseName{licenseIdx})
                    LicenseMessage=DAStudio.message('Simulink:tools:MALicenseCheckoutFail',checkObj.LicenseName{licenseIdx});
                    LicenseSuccess=false;
                    break
                end
            end
        else

            passed=false;

            for licenseIdx=1:length(checkObj.LicenseName)

                if strcmp(checkObj.LicenseName{licenseIdx},'Simulink_Code_Inspector')
                    passed=true;
                    break;

                elseif strcmp(checkObj.LicenseName{licenseIdx},'RTW_Embedded_Coder')
                    passed=Advisor.Utils.license('test',checkObj.LicenseName{licenseIdx});
                    break;
                elseif Advisor.Utils.license('checkout',checkObj.LicenseName{licenseIdx})
                    passed=true;
                    break;
                end
            end

            if~passed




                LicenseMessage=DAStudio.message('Simulink:tools:MALicenseCheckoutFail',checkObj.LicenseName{1});
                LicenseSuccess=false;
            end
        end
    end
end


