function[ResultDescription,ResultDetails]=CheckNumericCompensationCoSimSetting(system)





    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckNumericCompensationCoSimSetting');



    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationCheckTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);




    if(strcmpi(get_param(model,'StopTime'),'inf'))
        msgId='perfAdvId:InfStopTime';
        msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InfiniteStopTime');
        Exception=MException(msgId,msg);
        throwAsCaller(Exception);
    end




    sfcnBlocks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','off','BlockType','S-Function');
    CandidateBlocks={};

    for i=1:length(sfcnBlocks)
        if IsGTBlock(sfcnBlocks{i})

            CandidateBlocks=[CandidateBlocks;sfcnBlocks{i}];
        end
    end


    try
        evalc([model,'([],[],[],''compile'')']);
    catch ME
        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setCheckErrorSeverity(1);
        mdladvObj.setActionEnable(false);

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
        return;
    end
    engineInterfaceObj=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    compileObj=onCleanup(@()evalc([model,'([],[],[],''term'')']));






    CandidateInputPorts=[];
    UserSpecifiedInputPorts=[];

    for i=1:length(CandidateBlocks)
        b=CandidateBlocks{i};
        rto=get_param(b,'RuntimeObject');
        p=get_param(b,'PortHandles');


        if(iscell(rto.SampleTimes)||...
            rto.SampleTimes(1)<=0)
            continue;
        end

        for j=1:length(p.Inport)
            pi=p.Inport(j);

            if strcmp(get_param(pi,'CompiledPortDataType'),'double')&&...
                get_param(pi,'CompiledPortComplexSignal')==0&&...
                rto.InputPort(get_param(pi,'PortNumber')).DirectFeedthrough==0&&...
                get_param(pi,'CompiledPortFrameData')==0&&...
                (true)

                v=get_param(pi,'CoSimSignalCompensationMode');
                if startsWith(v,'Auto')
                    if~any(arrayfun(@(x)isequal(x,struct('block',b,'port',j,'param',v)),CandidateInputPorts))
                        CandidateInputPorts(end+1).block=b;
                        CandidateInputPorts(end).port=j;
                        CandidateInputPorts(end).param=v;
                    end
                else
                    if~any(arrayfun(@(x)isequal(x,struct('block',b,'port',j,'param',v)),UserSpecifiedInputPorts))
                        UserSpecifiedInputPorts(end+1).block=b;
                        UserSpecifiedInputPorts(end).port=j;
                        UserSpecifiedInputPorts(end).param=v;
                    end
                end
            end
        end

        for j=1:length(p.Outport)
            po=p.Outport(j);

            dstPortMatrix=getActualDst(b,j);

            if isempty(dstPortMatrix)
                continue;
            end

            dstPorts=[];
            dstBlocks={};

            for k=1:size(dstPortMatrix,1)
                if ishandle(dstPortMatrix(k,1))
                    dstPorts=[dstPorts;dstPortMatrix(k,1)];
                    dstBlocks=[dstBlocks;get_param(dstPortMatrix(k,1),'Parent')];
                end
            end

            for k=1:length(dstBlocks)
                if strcmp(get_param(dstPorts(k),'PortType'),'inport')==0
                    continue;
                end

                rto2=get_param(dstBlocks{k},'RuntimeObject');


                if(iscell(rto2.SampleTimes)||...
                    rto2.SampleTimes(1)<=0)
                    continue;
                end

                pi=dstPorts(k);

                if strcmp(get_param(pi,'CompiledPortDataType'),'double')&&...
                    get_param(pi,'CompiledPortComplexSignal')==0&&...
                    rto2.InputPort(get_param(pi,'PortNumber')).DirectFeedthrough==0&&...
                    get_param(pi,'CompiledPortFrameData')==0&&...
                    (any(strcmp(CandidateBlocks,dstBlocks{k}))||...
                    strcmp(get_param(pi,'CoSimSignalIsContinuousQuantity'),'on'))

                    v=get_param(pi,'CoSimSignalCompensationMode');
                    if startsWith(v,'Auto')
                        if~any(arrayfun(@(x)isequal(x,struct('block',dstBlocks{k},'port',get_param(pi,'PortNumber'),'param',v)),CandidateInputPorts))
                            CandidateInputPorts(end+1).block=dstBlocks{k};
                            CandidateInputPorts(end).port=get_param(pi,'PortNumber');
                            CandidateInputPorts(end).param=v;
                        end
                    else
                        if~any(arrayfun(@(x)isequal(x,struct('block',dstBlocks{k},'port',get_param(pi,'PortNumber'),'param',v)),UserSpecifiedInputPorts))
                            UserSpecifiedInputPorts(end+1).block=dstBlocks{k};
                            UserSpecifiedInputPorts(end).port=get_param(pi,'PortNumber');
                            UserSpecifiedInputPorts(end).param=v;
                        end
                    end
                end
            end
        end
    end

    compileObj.delete;
    engineInterfaceObj.delete;

    mdladvObj.UserData.candidateInputPorts=CandidateInputPorts;



    Pass=isempty(CandidateInputPorts);


    result_paragraph=ModelAdvisor.Paragraph;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});

    Warned=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Warning'),{'bold','warn'});


    mdladvObj.setCheckResultStatus(Pass);

    if isempty(CandidateBlocks)
        result_paragraph.addItem(Passed);
    elseif isempty(CandidateInputPorts)
        result_paragraph.addItem(Passed);
    else
        result_paragraph.addItem(Warned);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationCheckWarning',num2str(length(CandidateBlocks))));
        result_paragraph.addItem(result_text);


        title=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationInputPortEnabledDisabled');
        h1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationBlockName');
        h2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationInputPort');
        h3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:CoSimNumericalCompensationCurrentSetting');
        CombinedInputPorts=[UserSpecifiedInputPorts,CandidateInputPorts];
        table=cell(length(CombinedInputPorts),3);
        for i=1:length(CombinedInputPorts)
            table{i,1}=mdladvObj.getHiliteHyperlink(CombinedInputPorts(i).block);
            table{i,2}=num2str(CombinedInputPorts(i).port);
            table{i,3}=CombinedInputPorts(i).param;
        end
        heading={h1,h2,h3};
        resultTable=utilDrawReportTable(table,title,{},heading);
        result_paragraph.addItem(resultTable.emitHTML);


        mdladvObj.setCheckErrorSeverity(0);


        utilRunFix(mdladvObj,currentCheck,Pass);
    end


    ResultDetails{end+1}='';
    ResultDescription{end+1}=result_paragraph;


















    function retVal=IsGTBlock(block)
        mask=Simulink.Mask.get(block);
        if isempty(mask)||~startsWith(mask.Type,'GT-SUITE')
            retVal=false;
        else
            retVal=true;
        end



