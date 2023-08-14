function[status,msg]=generateIR(obj,compMdlH,isMdlRef,buildArgs)






    if nargin<4
        buildArgs=[];
    end

    if nargin<3
        isMdlRef=false;
    end

    if~isMdlRef&&~sldvprivate('isObserverSupportON',obj.mSldvOpts)
        status=false;
        return;
    end

    msg='';

    blockH=[];

    initCovData=[];
    showUI=false;
    filterExistingCov=false;
    reuseTranslationCache=false;

    if nargin<2

        return;
    end


    assert(~isempty(obj.mModelH),'Invalid session');



    status=~((Sldv.SessionState.None==obj.mState)||...
    (Sldv.SessionState.Terminated==obj.mState));
    if~status
        return;
    end


    [testComp,msg]=sldvprivate('mdl_create_testcomponent',compMdlH,blockH,obj.mSldvOpts);
    if~isempty(msg)

        assert(isempty(testComp));
        obj.reportError('Sldv:Setup:TestComp',msg);
        return;
    end



    obj.mSldvToken.setTestComponent(testComp);


    testComp.profileStage('Design Verifier: Translation');
    testComp.getMainProfileLogger().openPhase('Design Verifier: Translation');





    testCompCleanup=onCleanup(@()cleanupTestComponent(obj,compMdlH));




    csLock=Sldv.ConfigSetLock(obj.mModelH);%#ok<NASGU>

    try
        if~isMdlRef


            translationInfo=obj.getObserverTranslationInfo(compMdlH);
        else


            translationInfo.Blocks=[];
            translationInfo.BlockTypes=[];
            translationInfo.StubSFunctions=[];
        end
        sldvTranslator=Sldv.Translator(compMdlH,...
        blockH,...
        obj.mSldvOpts,...
        showUI,...
        initCovData,...
        testComp,...
        filterExistingCov,...
        reuseTranslationCache);

        [status,msg]=sldvTranslator.generateDVIR(obj.mModelH,translationInfo,isMdlRef,buildArgs);
    catch MEx
        status=false;%#ok<NASGU>
        if~isvalid(obj)

            MEx=MException('Sldv:Session:invalidObj',...
            'SLDV Session is no longer valid');
            throw(MEx);
        end
        rethrow(MEx);
    end

    if status

        obj.mTestComp.mergeDesignIR(testComp);
    elseif~isMdlRef



        errMsg=getString(message('Sldv:Observer:IgnoreIncompatObs',getfullname(compMdlH)));
        sldvshareprivate('avtcgirunsupcollect','push',obj.mModelH,'sldv_warning',errMsg,...
        'Sldv:Observer:IgnoreIncompatObs');
        obj.addToIncompatObserverList(compMdlH);
    end
    return;
end

function cleanupTestComponent(obj,compMdlH)
    testCompForCompMdl=obj.mSldvToken.getTestComponent();
    testCompForCompMdl.profileStage('end');
    testCompForCompMdl.getMainProfileLogger.closePhase('Design Verifier: Translation');
    sldvprivate('profile_terminate',testCompForCompMdl,'profileInfoVar',['sldvProfileData_',get_param(compMdlH,'Name')]);
    obj.mSldvToken.setTestComponent(obj.mTestComp);

    delete(testCompForCompMdl);
end
