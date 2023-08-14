function[value,msg]=license_AdvisorEditTimeCheckingMenu(type)%#ok<INUSD>



    msg='';
    mp=ModelAdvisor.Preferences;
    value=Advisor.Utils.license('test','SL_Verification_Validation')&&mp.ShowEdittimeviewInMACE;

end