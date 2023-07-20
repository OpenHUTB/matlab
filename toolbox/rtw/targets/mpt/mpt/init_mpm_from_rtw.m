function status=init_mpm_from_rtw(modelName,templateList)












    ecac=rtwprivate('rtwattic','AtticData','ecac');
    configSetHandle=getActiveConfigSet(modelName);

    status=[];
    ecac.formatFlag=0;
    ecac.filterFileName=' ';
    ecac.filterSymbol=' ';
    ecac.filterType=' ';
    ecac.templateList=templateList;
    mpmResult=[];
    mpmResult.modelName=modelName;
    rtwprivate('rtwattic','AtticData','mpmResult',mpmResult);


    customComment.customCommentEnable=get_param(configSetHandle,'EnableCustomComments');
    customComment.customCommentScript=get_param(configSetHandle,'CustomCommentsFcn');

    if isempty(customComment.customCommentScript)==0
        if exist(customComment.customCommentScript)~=2
            customComment.customCommentEnable=0;
        end
    else
        customComment.customCommentEnable=0;
    end
    ecac.customComment=customComment;

    rtwprivate('rtwattic','AtticData','ecac',ecac);
    mpt_basic_analysis_init(modelName);
    ecac=rtwprivate('rtwattic','AtticData','ecac');
    ecac.ZeroExternalMemoryAtStartup=get_rtw_option(modelName,'ZeroExternalMemoryAtStartup');
    rtwprivate('rtwattic','AtticData','ecac',ecac);







