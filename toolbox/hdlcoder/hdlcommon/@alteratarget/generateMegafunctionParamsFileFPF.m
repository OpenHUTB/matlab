function ipgArgs=generateMegafunctionParamsFileFPF(typeStr,fpFunction,fpSpecificArgs,megafunctionModule,latencyFreq,isFreqDriven,mnemonic,deviceInfo)






    synthTool=hdlgetparameter('SynthesisTool');
    if strcmpi(synthTool,'Intel Quartus Pro')
        ipgArgs=' --output-directory=. --component-name=altera_fp_functions --component-param=gen_enable=true --component-param=report_resources_to_xml=1';
    else
        ipgArgs=' --output-dir=. --file-set=QUARTUS_SYNTH --component-name=altera_fp_functions  --component-param=gen_enable=true --component-param=report_resources_to_xml=1';
    end

    deviceFamily=deviceInfo{1};
    if strcmpi(synthTool,'Intel Quartus Pro')
        ipgArgs=sprintf('%s --family=DEVICE_FAMILY="%s"',ipgArgs,deviceFamily);
    else
        ipgArgs=sprintf('%s --system-info=DEVICE_FAMILY="%s"',ipgArgs,deviceFamily);
    end
    if(isempty(deviceFamily))
        warning(message('hdlcommon:targetcodegen:DeviceNotSpecified'));
    end
    if(isempty(strfind(lower(typeStr),'double')))
        assert(~isempty(strfind(lower(typeStr),'single')));
        fpFormat='single';
    else
        fpFormat='double';
    end
    ipgArgs=sprintf('%s --component-param=fp_format=%s',ipgArgs,fpFormat);


    ipgArgs=sprintf('%s --component-param=function_family=ALL --component-param=ALL_function=%s %s',ipgArgs,alteratarget.getFPFunction(fpFunction,mnemonic),fpSpecificArgs);


    ipgArgs=sprintf('%s --output-name=%s',ipgArgs,megafunctionModule);
    if(~isFreqDriven)
        ipgArgs=sprintf('%s --component-param=performance_goal=latency --component-param=latency_target=%d',ipgArgs,latencyFreq);
    else
        ipgArgs=sprintf('%s --component-param=performance_goal=frequency --component-param=frequency_target=%d',ipgArgs,latencyFreq);
    end


    extraArgs=targetcodegen.targetCodeGenerationUtils.getExtraArgs(alteratarget.getOpInCLI(fpFunction),typeStr);
    if(~isempty(extraArgs))
        extraArgPVs=extractArgsFromString(extraArgs);
        existingArgPVs=extractArgsFromString(ipgArgs);
        existingArgPVs=applyArgPV(existingArgPVs,extraArgPVs);
        ipgArgs=dumpArgsToString(existingArgPVs);
    end
end

function ipgArgs=dumpArgsToString(argPVs)

    ipgArgs='';
    params=argPVs.keys;
    for i=1:length(params)
        ipgArgs=sprintf('%s %s%s',ipgArgs,params{i},argPVs(params{i}));
    end
end

function argPVs=extractArgsFromString(argStr)

    argPVs=containers.Map('KeyType','char','ValueType','any');

    pvStrs=regexp(argStr,'(?<=^|\s+)(--.*?)(?=\s+--|$)','tokens');
    for i=1:length(pvStrs)
        pvStr=pvStrs{i}{:};
        loc=regexp(pvStr,'=((?:".*"*)|[^=]*)$');
        argPVs(pvStr(1:loc))=pvStr(loc+1:end);
    end
end

function existingArgPVs=applyArgPV(existingArgPVs,extraArgPV)
    extraParams=extraArgPV.keys;
    for i=1:length(extraParams)
        existingArgPVs(extraParams{i})=extraArgPV(extraParams{i});
    end
end


