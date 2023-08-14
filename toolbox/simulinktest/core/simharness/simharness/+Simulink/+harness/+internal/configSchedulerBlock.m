function configSchedulerBlock(bd,blkPath,ioInfo,blkType)




    try
        rt=sfroot;
        machine=rt.find('-isa','Stateflow.Machine','Name',bd);
        if strcmp(blkType,'StateflowChart')
            isSFC=true;
        else
            isSFC=false;
        end
        if strcmp(blkType,'TestSeq')
            isTSB=true;
        else
            isTSB=false;
        end

        currentStartPos=120;

        if isTSB
            blkUDD=machine.find('-isa','Stateflow.ReactiveTestingTableChart','Path',blkPath);
        elseif isSFC
            blkUDD=machine.find('-isa','Stateflow.Chart','Path',blkPath);

            state1=Stateflow.State(blkUDD);
            state1.Name='State_1';
        else
            blkUDD=machine.find('-isa','Stateflow.EMChart','Path',blkPath);
            clearIO(blkUDD,blkPath);
        end

        nInput=length(ioInfo.Input);
        nOutput=length(ioInfo.Output);
        isUnifiedScheduler=ioInfo.createUnifiedScheduler;

        triggeredFcnCaller=struct('inputIdx',[],'inputName','');
        triggeredFcnCount=1;
        argIns={};
        argOuts={};
        for i=1:nInput
            if~isTSB&&~isSFC&&ioInfo.isSLDVCompatible








                triggeredFcnCaller.inputIdx=i;
                triggeredFcnCaller.inputName=ioInfo.Input{i}.name;
            else
                d=addInput(blkUDD,ioInfo.Input{i});
                argIns{end+1}=d.Name;%#ok<AGROW>
            end
        end


        dataValStruct=[];
        fcnValStruct=[];
        initValStruct=[];
        resetValStruct=[];
        termValStruct=[];
        fcnValStructAsync=[];

        for i=1:nOutput
            d=addOutput(blkUDD,ioInfo.Output{i});

            Simulink.harness.internal.configTSData(d,ioInfo.Output{i});
            valStruct=Simulink.harness.internal.constructTSInitValStruct(d,ioInfo.Output{i},blkPath);
            if strcmp(ioInfo.Output{i}.dataType,'fcn_call')
                if isUnifiedScheduler

                    if strcmp(ioInfo.Output{i}.modelEventType,'Initialize')
                        initValStruct=[initValStruct,valStruct];%#ok
                    elseif strcmp(ioInfo.Output{i}.modelEventType,'Reset')
                        resetValStruct=[resetValStruct,valStruct];%#ok
                    elseif strcmp(ioInfo.Output{i}.modelEventType,'Terminate')
                        termValStruct=[termValStruct,valStruct];%#ok
                    else

                        valStruct.taskID=ioInfo.Output{i}.taskID;
                        valStruct.rate=ioInfo.Output{i}.rate;
                        if valStruct.rate>0||(~isTSB&&~isSFC)
                            fcnValStruct=[fcnValStruct,valStruct];%#ok
                        else
                            fcnValStructAsync=[fcnValStructAsync,valStruct];%#ok
                        end
                    end
                else
                    valStruct.taskID=ioInfo.Output{i}.taskID;
                    valStruct.rate=ioInfo.Output{i}.rate;
                    if valStruct.rate>0||(~isTSB&&~isSFC)
                        fcnValStruct=[fcnValStruct,valStruct];%#ok
                    else
                        fcnValStructAsync=[fcnValStructAsync,valStruct];%#ok
                    end
                end
            else
                dataValStruct=[dataValStruct,valStruct];%#ok
                argOuts{end+1}=d.Name;%#ok<AGROW>
            end
        end


        runStr='';

        if~isempty(dataValStruct)
            runStr='\n%% Initialize data outputs. \n';
            initValues=Simulink.harness.internal.constructTSInitValStatements(dataValStruct);
            runStr=strcat(runStr,strjoin(initValues,'\n'));
            runStr=strrep(runStr,'%','%%');
        end


        if~isempty(fcnValStruct)


            [~,ii]=sort([fcnValStruct.taskID]);
            fcnValStruct=fcnValStruct(ii);

            fcnCallStr='';
            len=length(fcnValStruct);
            for j=1:len
                rateStr=num2str(fcnValStruct(j).rate);
                if isfield(fcnValStruct(j),'rate')&&fcnValStruct(j).rate>1

                    if isTSB||isSFC
                        rhs=['if t == 0 || every(',rateStr,', tick)\n\tsend(',fcnValStruct(j).name,');\nend'];
                    else
                        rhs=['if mod(t, int32(',rateStr,')) == 0\n\t',fcnValStruct(j).name,'();\nend'];
                    end
                elseif isfield(fcnValStruct(j),'rate')&&fcnValStruct(j).rate>0
                    if isTSB||isSFC
                        rhs=strcat('send(',fcnValStruct(j).name,');');
                    else
                        rhs=strcat(fcnValStruct(j).name,'();');
                    end
                else
                    if isTSB||isSFC

                    else
                        if ioInfo.isSLDVCompatible
                            rhs=strcat("call",fcnValStruct(j).name," = ",triggeredFcnCaller.inputName,"(",num2str(triggeredFcnCount),");\n");
                            rhs=strcat(rhs,"\nif call",fcnValStruct(j).name,"\n\t",fcnValStruct(j).name,"();\nend");
                            triggeredFcnCount=triggeredFcnCount+1;
                        else
                            rhs=['call',fcnValStruct(j).name,' = false;\nif call',fcnValStruct(j).name,' == true\n\t',fcnValStruct(j).name,'();\nend'];
                        end
                    end
                end
                fcnCallStr=strcat(fcnCallStr,'\n\n',rhs);
            end

            fcnCallStr=strrep(fcnCallStr,'%','%%');


            runStr=strcat(runStr,'\n',fcnCallStr);
        end


        if~isUnifiedScheduler
            [str,argIns,argOuts]=generateSLFunctionCalls(blkUDD,blkPath,ioInfo,(isTSB||isSFC),argIns,argOuts,...
            triggeredFcnCaller,triggeredFcnCount);
            runStr=strcat(runStr,'\n',str);
        end


        if~isempty(initValStruct)
            initStr='\n%% Call Initialization task.\n';
            if isTSB||isSFC
                initValues=['if t == 0\n\tsend(',initValStruct.name,');\nend\n'];
            else
                initValues=['if t == int32(0)\n\t',initValStruct.name,'();\nend\n'];
            end
            initStr=strcat(initStr,initValues);
            initStr=strrep(initStr,'%','%%');


            initAndRunStr=strcat(initStr,runStr);


            if isTSB
                sltest.testsequence.editStep(blkPath,'step_1','Name','Run','Action',sprintf(initAndRunStr));
            elseif isSFC
                state1=blkUDD.find('-isa','Stateflow.State','Name','State_1');
                state1.Name='Run';
                nameInitAndRunStr=strcat('Run',initAndRunStr);
                state1.LabelString=sprintf(nameInitAndRunStr);
                currentStartPos=setStateSize(state1,currentStartPos);
                dt=Stateflow.Transition(blkUDD);
                dt.Destination=state1;
                dt.DestinationOClock=0;
                xsource=state1.Position(1)+state1.Position(3)/2;
                ysource=state1.Position(2)-30;
                dt.SourceEndPoint=[xsource,ysource];
                dt.MidPoint=[xsource,ysource+15];
            else
                timeInit='persistent t;\nif isempty(t)\n\tt = int32(0);\nend\n';
                MLScript=strcat(timeInit,'\n',initAndRunStr);
            end

        else

            if isTSB
                sltest.testsequence.editStep(blkPath,'step_1','Name','Run','Action',sprintf(runStr));
            elseif isSFC
                state1=blkUDD.find('-isa','Stateflow.State','Name','State_1');
                state1.Name='Run';
                nameAndRunStr=strcat('Run',runStr);
                state1.LabelString=sprintf(nameAndRunStr);
                currentStartPos=setStateSize(state1,currentStartPos);
                dt=Stateflow.Transition(blkUDD);
                dt.Destination=state1;
                dt.DestinationOClock=0;
                xsource=state1.Position(1)+state1.Position(3)/2;
                ysource=state1.Position(2)-30;
                dt.SourceEndPoint=[xsource,ysource];
                dt.MidPoint=[xsource,ysource+15];
            else
                timeInit='persistent t;\nif isempty(t)\n\tt = int32(0);\nend\n';
                MLScript=strcat(timeInit,'\n',runStr);
            end
        end


        fcnCallStepStr='';
        if~isempty(fcnValStructAsync)
            fcnCallStepStr='\n%% Call Asynchronous FunctionCall Subsystems.\n\n%%';


            [~,ii]=sort([fcnValStructAsync.taskID]);
            fcnValStructAsync=fcnValStructAsync(ii);

            len=length(fcnValStructAsync);
            for j=1:len
                if isTSB||isSFC
                    rhs=['send(',fcnValStructAsync(j).name,');'];
                    fcnCallStepStr=strcat(fcnCallStepStr,'\n',rhs);
                else

                end
            end
            fcnCallStepStr=strrep(fcnCallStepStr,'%','%%');
        end

        if~isempty(ioInfo.SlEvents)
            len=length(ioInfo.SlEvents);

            for i=1:len
                if isTSB||isSFC
                    rhs=['send(',ioInfo.SlEvents{i},');'];
                    fcnCallStepStr=strcat(fcnCallStepStr,'\n',rhs);
                else

                end
            end
        end


        if isUnifiedScheduler
            [slfcnStr,argIns,argOuts]=generateSLFunctionCalls(blkUDD,blkPath,ioInfo,(isTSB||isSFC),argIns,argOuts,...
            triggeredFcnCaller,triggeredFcnCount);
            if~isempty(slfcnStr)
                fcnCallStepStr=strcat(fcnCallStepStr,'\n',slfcnStr);
            end
        end

        if~isempty(fcnCallStepStr)

            if isTSB
                sltest.testsequence.addStep(blkPath,'AsyncFunctionCalls','Action',sprintf(fcnCallStepStr));
            elseif isSFC
                state2=Stateflow.State(blkUDD);
                state2.Name='AsyncFunctionCalls';
                nameAndFcnCallStepStr=strcat('AsyncFunctionCalls',fcnCallStepStr);
                state2.LabelString=sprintf(nameAndFcnCallStepStr);
                currentStartPos=setStateSize(state2,currentStartPos);
            else
                MLScript=strcat(MLScript,'\n',fcnCallStepStr);
            end
        end


        if~isempty(resetValStruct)
            for i=1:length(resetValStruct)
                if isTSB||isSFC

                    resetStr='\n%% Call Reset task.\n%% Add transitions to this step as required.\n';
                    initValues=['send(',resetValStruct(i).name,');'];
                    resetStr=strcat(resetStr,initValues,'\n');
                    resetStr=strrep(resetStr,'%','%%');
                    if isTSB
                        sltest.testsequence.addStep(blkPath,resetValStruct(i).name,'Action',sprintf(resetStr));
                        sltest.testsequence.addTransition(blkPath,resetValStruct(i).name,'true','Run');
                    else
                        state3=Stateflow.State(blkUDD);
                        state3.Name=resetValStruct(i).name;
                        nameAndResetStr=strcat(state3.Name,resetStr);
                        state3.LabelString=sprintf(nameAndResetStr);
                        currentStartPos=setStateSize(state3,currentStartPos);
                        tState3To1=Stateflow.Transition(blkUDD);
                        tState3To1.Source=state3;
                        tState3To1.Destination=blkUDD.find('-isa','Stateflow.State','Name','Run');
                        tState3To1.LabelString='[true]';
                    end
                else
                    resetStr=['\n%% Call Reset task : ',resetValStruct(i).name,'.\ncall',resetValStruct(i).name,' = false;\n'];
                    resetStr=strcat(resetStr,'if call',resetValStruct(i).name,' == true\n\t',resetValStruct(i).name,'();\nend\n');
                    MLScript=strcat(MLScript,'\n',resetStr);
                end
            end
        end


        if~isempty(termValStruct)

            if isTSB||isSFC
                termStr='\n%% Call Terminate task.\n%% Add transitions to this step as required.\n';
                termStr=[termStr,'send(',termValStruct.name,');'];
                if isTSB
                    sltest.testsequence.addStep(blkPath,'Terminate','Action',sprintf(termStr));
                else
                    state4=Stateflow.State(blkUDD);
                    state4.Name='Terminate';
                    nameAndTermStr=strcat('Terminate',termStr);
                    state4.LabelString=sprintf(nameAndTermStr);
                    currentStartPos=setStateSize(state4,currentStartPos);%#ok<NASGU>
                end
            else
                termStr=['\n%% Call Terminate task.\ncall',termValStruct.name,' = false;\n'];
                termStr=[termStr,'if call',termValStruct.name,' == true\n\t',termValStruct.name,'();\nend\n'];
                MLScript=strcat(MLScript,'\n',termStr);
            end
        end




        if~isempty(triggeredFcnCaller.inputIdx)
            d=addInput(blkUDD,ioInfo.Input{triggeredFcnCaller.inputIdx});
            argIns{end+1}=d.Name;
        end

        if~isTSB&&~isSFC
            timeIncr='\n\nt = t + int32(1);\n\nend';
            MLScript=strcat(MLScript,timeIncr);
            if isempty(argOuts)
                header='function Run(';
            elseif length(argOuts)==1
                header=['function ',argOuts{1},' = Run('];
            else
                header=['function [',strjoin(argOuts,','),'] = Run('];
            end
            if isempty(argIns)
                header=[header,')\n\n'];
            elseif length(argIns)==1
                header=[header,argIns{1},')\n\n'];
            else
                header=[header,strjoin(argIns,','),')\n\n'];
            end
            if~ioInfo.rebuild
                MLScript=strcat(header,MLScript);
                blkUDD.script=sprintf(MLScript);
            end
        end

    catch ME
        if strcmp(ME.identifier,'SL_SERVICES:utils:CNTRL_C_INTERRUPTION')
            throw(ME);
        else
            Simulink.harness.internal.warn(ME);
        end
    end

end

function d=addInput(tsUDD,sigInfo)
    if sigInfo.isMessage
        d=Stateflow.Message(tsUDD);
    else
        d=Stateflow.Data(tsUDD);
    end
    d.Scope='Input';
    d.Name=sigInfo.name;
    Simulink.harness.internal.configTSData(d,sigInfo);
end

function d=addOutput(tsUDD,sigInfo)
    isFcnCall=strcmp(sigInfo.dataType,'fcn_call');
    if sigInfo.isMessage
        d=Stateflow.Message(tsUDD);
    elseif isFcnCall
        d=Stateflow.createEvent(tsUDD,"FunctionCall");
    else
        d=Stateflow.Data(tsUDD);
    end
    d.Name=sigInfo.name;
    Simulink.harness.internal.configTSData(d,sigInfo);
    if~isFcnCall
        d.Scope='Output';
    end
end

function d=addLocal(tsUDD,sigInfo)
    d=Stateflow.Data(tsUDD);
    d.Scope='Local';
    d.Name=sigInfo.name;
    Simulink.harness.internal.configTSData(d,sigInfo);
end

function[LblStr,argIns,argOuts]=generateSLFunctionCalls(tsUDD,blkPath,ioInfo,isTSB,argIns,argOuts,...
    triggeredFcnCaller,triggeredFcnCount)

    LblStr='';
    nSlFcns=length(ioInfo.SlFcns);
    localArgMode=ioInfo.mode;

    if nSlFcns==0
        return;
    end

    if ioInfo.createUnifiedScheduler
        LblStr='\n%% Call reachable Simulink Functions.\n%%';
    end

    for i=1:nSlFcns
        if ioInfo.createUnifiedScheduler
            LblStr=strcat(LblStr,['\n%% Call Global function : ',ioInfo.SlFcns{i}.functionName,'\n']);
        else
            LblStr=strcat(LblStr,['\n%% Call Simulink function : ',ioInfo.SlFcns{i}.functionName,'\n']);
        end

        argInList='';
        argInitStr='';
        nArgIn=length(ioInfo.SlFcns{i}.inputs);
        for j=1:nArgIn
            if localArgMode==false
                d=addInput(tsUDD,ioInfo.SlFcns{i}.inputs{j});
                argIns{end+1}=d.Name;%#ok<AGROW>
            else
                d=addLocal(tsUDD,ioInfo.SlFcns{i}.inputs{j});


                initValStruct=Simulink.harness.internal.constructTSInitValStruct(d,...
                ioInfo.SlFcns{i}.inputs{j},...
                blkPath);
                initValues=Simulink.harness.internal.constructTSInitValStatements(initValStruct);

                initStr=strjoin(initValues,'\n');
                initStr=strrep(initStr,'%','%%');
                LblStr=strcat(LblStr,initStr,'\n');

            end
            if j<nArgIn
                argInList=strcat(argInList,d.Name,',');
            else
                argInList=strcat(argInList,d.Name);
            end
        end

        argOutList='';
        nArgOut=length(ioInfo.SlFcns{i}.outputs);
        for j=1:nArgOut
            if localArgMode==false
                d=addOutput(tsUDD,ioInfo.SlFcns{i}.outputs{j});
                argOuts{end+1}=d.Name;%#ok<AGROW>
            else
                d=addLocal(tsUDD,ioInfo.SlFcns{i}.outputs{j});
            end

            if j<nArgOut
                argOutList=strcat(argOutList,d.Name,',');
            else
                argOutList=strcat(argOutList,d.Name);
            end
            if~isTSB
                Simulink.harness.internal.configTSData(d,ioInfo.SlFcns{i}.outputs{j});
                valStruct=Simulink.harness.internal.constructTSInitValStruct(d,ioInfo.SlFcns{i}.outputs{j},blkPath);
                initValues=Simulink.harness.internal.constructTSInitValStatements(valStruct);
                for l=1:length(initValues)
                    argInitStr=strcat(argInitStr,'\n',initValues{l});
                end
                argInitStr=strrep(argInitStr,'%','%%');
            end
        end

        if nArgOut>1
            argOutList=strcat('[',argOutList,'] = ');
        elseif nArgOut>0
            argOutList=strcat(argOutList,' = ');
        end

        if isTSB
            fcnStr=strcat(argOutList,ioInfo.SlFcns{i}.functionName,'(',argInList,');\n\n');

        else
            if ioInfo.isSLDVCompatible

                triggeredInportElementIdx=i+triggeredFcnCount-1;
                fcnStr=strcat("call",ioInfo.SlFcns{i}.functionName," = ",triggeredFcnCaller.inputName,"(",num2str(triggeredInportElementIdx),");\n");
                if~isempty(argInitStr)
                    fcnStr=strcat(fcnStr,argInitStr);
                end
                fcnStr=strcat(fcnStr,"\nif call",ioInfo.SlFcns{i}.functionName,"\n");
                fcnStr=strcat(fcnStr,"\t",argOutList,ioInfo.SlFcns{i}.functionName,"(",argInList,");\nend\n");
            else
                fcnStr=['call',ioInfo.SlFcns{i}.functionName,' = false;'];
                if~isempty(argInitStr)
                    fcnStr=strcat(fcnStr,argInitStr);
                end
                fcnStr=strcat(fcnStr,'\nif call',ioInfo.SlFcns{i}.functionName,' == true\n');
                fcnStr=strcat(fcnStr,'\t',argOutList,ioInfo.SlFcns{i}.functionName,'(',argInList,');\nend\n');
            end
        end
        LblStr=strcat(LblStr,fcnStr);
    end

end

function clearIO(blkUDD,blkPath)
    chartID=sfprivate('block2chart',blkPath);
    chartH=idToHandle(sfroot,chartID);
    d=chartH.find('-isa','Stateflow.FunctionCall');
    for i=1:length(d)
        d(i).delete;
    end

    for i=1:length(blkUDD.Inputs)
        blkUDD.Inputs(1).delete;
    end

    for i=1:length(blkUDD.Outputs)
        blkUDD.Outputs(1).delete;
    end

end

function currentStartPos=setStateSize(stateUddH,currentStartPos)
    m3i=StateflowDI.Util.getDiagramElement(stateUddH.Id);
    m=m3i.temporaryObject;
    width=m.labelSize(1)+10;
    if width<200
        width=200;
    end
    height=m.labelSize(2)+10;
    if height<100
        height=100;
    end
    stateUddH.Position(1)=80;
    stateUddH.Position(2)=currentStartPos;
    stateUddH.Position(3)=width;
    stateUddH.Position(4)=height;
    currentStartPos=currentStartPos+height+50;
end


