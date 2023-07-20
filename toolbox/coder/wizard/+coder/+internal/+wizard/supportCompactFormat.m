function out=supportCompactFormat(system)




    subsys=find_system(system,'BlockType','SubSystem');
    out=true;
    for i=1:length(subsys)
        tmp=subsys{i};
        rtwSystemCode=get_param(tmp,'RTWSystemCode');
        if(strcmp(rtwSystemCode,'Nonreusable function')||strcmp(rtwSystemCode,'Reusable function'))...
            &&~strcmp(get_param(tmp,'RTWFileNameOpts'),'Auto')
            out=false;
        end
    end