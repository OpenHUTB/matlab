function result=actionFILSettings(taskobj)





    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;
    hModel=bdroot(system);
    hdlcoderObj=hdlcoderargs(system);

    sobj=get_param(hModel,'Object');
    configSet=sobj.getActiveConfigSet;
    hObj=gethdlcconfigset(configSet);

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    t1_numRow=0;

    text='';
    try



        rates=hdlcoderObj.PirInstance.getModelSampleTimes;
        clockInputs=hdlget_param(hModel,'ClockInputs');
        if length(unique(rates))>1&&~strcmpi(clockInputs,'Single')
            hObj.getCLI.ClockInputs='Single';
            hdlset_param(hModel,'ClockInputs','Single');
            t1_numRow=t1_numRow+1;
            text=ModelAdvisor.Text(bdroot(system));
            encodedModelName=modeladvisorprivate('HTMLjsencode',bdroot(system),'encode');
            encodedModelName=[encodedModelName{:}];
            text.setHyperlink(['matlab: modeladvisorprivate openCSAndHighlight ',[encodedModelName,' ''',clockInputs,''' ']]);
            t1_colElements{t1_numRow}{1}=text;
            t1_colElements{t1_numRow}{2}='Clock inputs';
            t1_colElements{t1_numRow}{3}=clockInputs;
            t1_colElements{t1_numRow}{4}='Single';
        end


        ninput=length(hdlcoderObj.PirInstance.getTopNetwork.SLInputPorts);
        noutput=length(hdlcoderObj.PirInstance.getTopNetwork.SLOutputPorts);
        hasVectorPort=false;
        for ii=1:ninput
            if isDutInportAtIdxVector(hdlcoderObj.PirInstance,ii)
                hasVectorPort=true;
                break;
            end
        end

        if~hasVectorPort
            for ii=1:noutput
                if isDutOutportAtIdxVector(hdlcoderObj.PirInstance,ii)
                    hasVectorPort=true;
                    break;
                end
            end
        end

        scalarizePorts=hdlget_param(hModel,'ScalarizePorts');
        if strcmpi(scalarizePorts,'off')&&hasVectorPort
            hdlset_param(hModel,'ScalarizePorts','on');
            hObj.getCLI.ScalarizePorts='on';
            t1_numRow=t1_numRow+1;
            text=ModelAdvisor.Text(bdroot(system));
            encodedModelName=modeladvisorprivate('HTMLjsencode',bdroot(system),'encode');
            encodedModelName=[encodedModelName{:}];
            text.setHyperlink(['matlab: modeladvisorprivate openCSAndHighlight ',[encodedModelName,' ''',scalarizePorts,''' ']]);
            t1_colElements{t1_numRow}{1}=text;
            t1_colElements{t1_numRow}{2}='Scalarize ports';
            t1_colElements{t1_numRow}{3}=scalarizePorts;
            t1_colElements{t1_numRow}{4}='on';
        end

        if t1_numRow>0

            t3=drawReportTable(t1_colElements,t1_numRow);
            text=[lb,t3.emitHTML];
        end

    catch me

        result=publishFailedMessage(mdladvObj,me.message);

        return;
    end

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    result=[Passed.emitHTML,text];

end

function t3=drawReportTable(t1_colElements,t1_numRow)

    t3=ModelAdvisor.Table(t1_numRow,4);
    txt=ModelAdvisor.Text('Model Settings for FPGA-in-the-Loop');
    t3.setHeading(txt.emitHTML);
    t3.setHeadingAlign('center');
    t3.setColHeading(1,DAStudio.message('HDLShared:hdldialog:MSGBlock'));
    t3.setColHeading(2,DAStudio.message('HDLShared:hdldialog:MSGSettings'));
    t3.setColHeading(3,DAStudio.message('HDLShared:hdldialog:MSGPrevious'));
    t3.setColHeading(4,DAStudio.message('HDLShared:hdldialog:MSGCurrent'));

    for irow=1:t1_numRow
        t3.setEntry(irow,1,t1_colElements{irow}{1});
        t3.setEntry(irow,2,t1_colElements{irow}{2});
        t3.setEntry(irow,3,t1_colElements{irow}{3});
        t3.setEntry(irow,4,t1_colElements{irow}{4});
    end
end

function isvector=isDutInportAtIdxVector(pir,idx)
    hn=getTopNetwork(pir);
    t=hn.PirInputSignals(idx);
    tInfo=pirgetdatatypeinfo(t.Type);
    isvector=tInfo.isvector;
end

function isvector=isDutOutportAtIdxVector(pir,idx)
    hn=getTopNetwork(pir);
    t=hn.PirOutputSignals(idx);
    tInfo=pirgetdatatypeinfo(t.Type);
    isvector=tInfo.isvector;
end
