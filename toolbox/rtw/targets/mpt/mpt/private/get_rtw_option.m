function result=get_rtw_option(modelName,optionName)




    result=[];
    o=get_param(modelName,'Object');
    rtwOption=o.RTWOptions;

    b=rtwOption;
    while isempty(b)==0
        [a,b]=strtok(b,' ');
        a=strrep(a,'-a','');
        if strncmp(a,optionName,length(optionName))==1
            [c,d]=strtok(a,'=');
            result=d(2:end);
        end
    end