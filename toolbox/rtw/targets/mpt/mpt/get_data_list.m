function packInfo=get_data_list(modelName)





    ecac=rtwprivate('rtwattic','AtticData','ecac');

    actualSource=ecac.line_s_d.actualSource;
    lineInfo=ecac.line_s_d.lineInfo;

    packInfo.var=[];
    packInfo.param=[];
    wsListStruct=get_param(modelName,'ReferencedWSVars');

    for i=1:length(wsListStruct)
        name=wsListStruct(i).Name;
        if length(name)>0
            packInfo.param{end+1}=name;
        end
    end
    packInfo.param=unique(packInfo.param);

    packInfo.var=actualSource.name;