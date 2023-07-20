function[status,res,msg]=generateCompatibilityResults(obj)




    modelH=obj.mModelToCheckCompatH;

    sldvshareprivate('avtcgirunsupcollect','cleanSynthesized',modelH);

    switch(obj.mCompatStatus)
    case Sldv.CompatStatus.DV_COMPAT_COMPATIBLE
        status=true;
        res=obj.compatibleMsg();
        msg=sldvshareprivate('avtcgirunsupdialog',modelH);

    case Sldv.CompatStatus.DV_COMPAT_PARTIALLY_SUPPORTED
        status=strcmp(obj.mTestComp.activeSettings.AutomaticStubbing,'on');
        res=obj.partiallySupportedMsg();
        msg=sldvshareprivate('avtcgirunsupdialog',modelH);

    otherwise
        status=false;
        if obj.mShowUI
            obj.mTestComp.progressUI.finalized=true;
            obj.mTestComp.progressUI.refreshLogArea();
        end
        res=obj.unsupportedMsg();
        sldvshareprivate('avtcgirunsupcollect','push',modelH,'simulink',...
        getString(message('Sldv:Setup:FailedInitialize',res)),'SLDV:Compatibility:Generic');
        msg=sldvshareprivate('avtcgirunsupdialog',modelH,obj.mShowUI);
    end
end
