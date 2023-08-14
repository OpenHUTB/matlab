function latencies=getHwfpLatency(targetFrequency,deviceInfo,baseType)
%#codegen



    coder.allowpcode('plain');
    if(nargin<3)
        baseType='SINGLE';
    end
    altMegaFunctionName='xx';

    ipInfo(1).fpFunction=alteratarget.AddSub;
    ipInfo(1).mnemonic='ADD';
    ipInfo(1).fpSpecificArgs='';
    ipInfo(1).name='Sum';

    ipInfo(end+1).fpFunction=alteratarget.Mul;
    ipInfo(end).mnemonic='MUL';
    ipInfo(end).fpSpecificArgs='';
    ipInfo(end).name='Prod';

    ipInfo(end+1).fpFunction=alteratarget.Relop;
    ipInfo(end).mnemonic='GT';
    ipInfo(end).fpSpecificArgs='--component-param=compare_type=GT';
    ipInfo(end).name='Cmp';

    ipInfo(end+1).fpFunction=alteratarget.MultAdd;
    ipInfo(end).mnemonic='MULT_ADD';
    ipInfo(end).fpSpecificArgs='';
    ipInfo(end).name='MAD';

    ipInfo(end+1).fpFunction=alteratarget.Div;
    ipInfo(end).mnemonic='DIV';
    ipInfo(end).fpSpecificArgs='';
    ipInfo(end).name='Divide';

    ipInfo(end+1).fpFunction=alteratarget.Log;
    ipInfo(end).mnemonic='LOG';
    ipInfo(end).fpSpecificArgs='';
    ipInfo(end).name='Log';

    ipInfo(end+1).fpFunction=alteratarget.Exp;
    ipInfo(end).mnemonic='EXP';
    ipInfo(end).fpSpecificArgs='';
    ipInfo(end).name='Exp';

    latencies=struct('name',{},'latency',{});
    for i=1:length(ipInfo)
        l=getLatency(baseType,altMegaFunctionName,deviceInfo,targetFrequency,ipInfo(i).fpFunction,ipInfo(i).mnemonic,ipInfo(i).fpSpecificArgs);
        latencies(i).latency=l;
        latencies(i).name=ipInfo(i).name;
    end

    latencies(end+1).latency=4;
    latencies(end).name='Fixdt_0_16_0_To_Single';
end


function latency=getLatency(baseType,altMegaFunctionName,deviceInfo,targetFrequency,fpFunction,mnemonic,fpSpecificArgs)
    isFreqDriven=true;
    numOfInst=1;
    dryRun=true;
    ipgArgs=alteratarget.generateMegafunctionParamsFileFPF(baseType,fpFunction,fpSpecificArgs,altMegaFunctionName,targetFrequency,isFreqDriven,mnemonic,deviceInfo);
    status=alteratarget.generateMegafunctionFPF([],altMegaFunctionName,ipgArgs,targetFrequency,isFreqDriven,numOfInst,dryRun,deviceInfo);
    assert(status.status==0);
    latency=status.achievedLatency;
end















