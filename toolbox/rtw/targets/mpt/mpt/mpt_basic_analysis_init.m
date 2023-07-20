function mpt_basic_analysis_init(modelName)





    ecac=rtwprivate('rtwattic','AtticData','ecac');


    if exist('get_global_comments')==2
        globalComments=get_global_comments(modelName);
    else
        globalComments=[];
    end
    ecac.globalComments=globalComments;

    rtwprivate('rtwattic','AtticData','ecac',ecac);
