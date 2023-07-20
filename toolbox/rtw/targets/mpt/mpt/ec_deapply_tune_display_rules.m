function ec_deapply_tune_display_rules(modelName)









    ecMasterDisplayTuneRuleList=rtwprivate('rtwattic','AtticData','ecMasterDisplayTuneRuleList');





    for i=1:length(ecMasterDisplayTuneRuleList)
        try
            set_data_info(ecMasterDisplayTuneRuleList{i},'StorageClass','Custom',modelName);
        catch
        end
    end

