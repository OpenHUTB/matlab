function out=getExecutionInformation(targetName)

    tg=slrealtime;

    if~(tg.isConnected)
        error(message('stm:realtime:UnableToConnectToTarget',targetName));
    end
    out.messages={};
    out.errorOrLog={};
    ExecInfo=tg.get('ModelStatus');

    ExecTime=message('stm:realtime:ExecTime',num2str(ExecInfo.ExecTime));
    out.messages{end+1}=ExecTime.getString();
    out.errorOrLog{end+1}=false;
    for i=1:length(ExecInfo.TETInfo)
        AvgTET=message('stm:realtime:AvgTET',num2str(ExecInfo.TETInfo(i).TETAvg));
        out.messages{end+1}=AvgTET.getString();
        out.errorOrLog{end+1}=false;
        MaxTET=message('stm:realtime:MaxTET',num2str(ExecInfo.TETInfo(i).TETMax));
        out.messages{end+1}=MaxTET.getString();
        out.errorOrLog{end+1}=false;
        MinTET=message('stm:realtime:MinTET',num2str(ExecInfo.TETInfo(i).TETMin));
        out.messages{end+1}=MinTET.getString();
        out.errorOrLog{end+1}=false;
    end









end

