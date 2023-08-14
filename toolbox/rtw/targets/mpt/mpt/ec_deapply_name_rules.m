function ec_deapply_name_rules(modelName)










    ecMasterNamingRuleList=rtwprivate('rtwattic','AtticData','ecMasterNamingRuleList');





    for i=1:length(ecMasterNamingRuleList)
        name=ecMasterNamingRuleList{i};
        obj=evalinGlobalScope(modelName,name);


        package=(isa(obj,'mpt.Signal'))|(isa(obj,'mpt.Parameter'));
        cmd=[name,'.CoderInfo.Identifier = '];
        revisedName='';
        try
            if package==1
                set_data_info(name,'Identifier',revisedName,modelName);
                set_data_info(name,'AliasFromNamingRule',false,modelName);
            else
                cmd=[cmd,'''',revisedName,'''',';'];
                evalinGlobalScope(modelName,cmd);
                ecMasterNamingRuleList{end+1}=name;
            end

        catch
        end
    end

