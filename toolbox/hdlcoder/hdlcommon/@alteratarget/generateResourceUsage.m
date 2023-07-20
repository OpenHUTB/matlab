function resourceUsage=generateResourceUsage(megafunctionModule,megafunctionParamsFile,megafunctionName)



    resourceUsage=[];
    if~hdlgetparameter('resourceReport')
        return;
    end

    deviceDetails=hdlgetdeviceinfo;


    cmd=sprintf('clearbox %s DEVICE_FAMILY="%s" -f "%s" -resc_count',...
    megafunctionModule,...
    deviceDetails{1},...
    megafunctionParamsFile);

    try
        hdldisp(message('hdlcoder:hdldisp:AlteraResourceStats',megafunctionName));

        [status,result]=system(cmd);
        if status==0
            resourceUsage=strrep(result,'Resource count for the function is ','');
        end
        hdldisp(message('hdlcoder:hdldisp:Done'));
    catch me
        rethrow(me);
    end


