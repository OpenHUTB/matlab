function[cmd,args,followUp,dvo,...
    encryptDvo,validate,extKill]=getServerCommand(analyzerObj)




    tc=Sldv.Token.get.getTestComponent;

    try
        [p,cmd,args,followUp,...
        dvo,encryptDvo,...
        validate,extKill]=getServerDetails(analyzerObj);
    catch MEx %#ok<NASGU>
        cmd={};
        args='';
        followUp=0;
        dvo=false;
        encryptDvo=false;
        validate=false;
        extKill='';
        return;
    end


    if(2==slavteng('feature','MockingDvoAnalyzer'))
        args{end+1}=sldvprivate('sldvGetActiveSession',get_param(tc.analysisInfo.designModelH,'Name')).getMockLogPath();
    end

















    if~isempty(p)
        cmd=[p,filesep,cmd];
    end
end

function[p,cmd,args,...
    followUp,dvo,encryptDvo,...
    validate,extKill]=getServerDetails(analyzerObj)

    engines=Sldv.ExternalEngineUtils.getAll;

    name='';
    if 2==slavteng('feature','MockingDvoAnalyzer')
        name='MockingDVOEngine';

        for i=1:length(engines)
            try
                eng=eval(engines{i}.Name);
                if strcmp(eng.Name,name)
                    p=eng.CommandPath;
                    cmd=eng.Command;
                    args=[eng.Command,eng.CommandArguments];



                    followUp=eng.FollowUpStrategy;
                    dvo=eng.UsesDVO;
                    encryptDvo=eng.UsesEncryptedDVO;
                    extResults=eng.AcceptExternalResults;
                    validate=eng.ValidateSatisfiedResults;
                    extKill=eng.ExternalKillCommand;
                    return;
                end
            catch MEx %#ok<NASGU>

            end
        end

    end

    try
        eng=getCmdData();
        p='';
        cmd=getMonitorProcessCommand();
        if(slavteng('feature','MultiProcessEnv')>1)
            args{1}='2';
        else
            args{1}='1';
        end
        args{end+1}=eng.Command;
        args{end+1}='-taskqueue';
        args{end+1}=analyzerObj.getTaskQueueId();
        if 1==slavteng('feature','ResultsPolling')
            args{end+1}='-result_stream';
            args{end+1}=analyzerObj.getResultStreamId();
        end
        dvo=eng.UsesDVO;
        followUp=0;
        encryptDvo=false;
        validate=false;

        extKill='';
        return;
    catch MEx %#ok<NASGU>

    end

    error(message('Sldv:shared:DataUtils:InvalidExternalEngine'))

end

function procCmd=getMonitorProcessCommand()
    if isunix
        executable='dv_process_monitor';
    else
        executable='dv_process_monitor.exe';
    end
    procCmd=fullfile(matlabroot,'bin',computer('arch'),executable);
end


function eng=getCmdData()

    if isunix
        eng.Command=[matlabroot,'/bin/',computer('arch'),'/dvoserver'];
    else
        eng.Command=fullfile(matlabroot,'bin',computer('arch'),'dvoserver.exe');
    end

    eng.UsesDVO=true;

end

function args=getMockDvoServerProducerArgs(analyzerObj,args)

    args{end+1}='--type P';

    args{end+1}='--port';
    port=dv.tasking.ServiceHandler.port();
    args{end+1}=string(port);



    args{end+1}='--resource';
    resourceId=analyzerObj.getResultStream.stringStreamId();
    args{end+1}=string(resourceId);

    args{end+1}='--resourcetype stream';





end


