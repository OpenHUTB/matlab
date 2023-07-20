function checks=validate(this,dut,genRTLTB)


    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});


    mdlName=this.ModelConnection.ModelName;
    stopTime=get_param(mdlName,'StopTime');
    if strcmpi(stopTime,'inf')
        checks(end+1).path=mdlName;
        checks(end).type='model';
        checks(end).message='Cannot generate testbench with ''Inf'' as simulation stop time.';
        checks(end).level='Error';
        checks(end).MessageID='hdlcoder:engine:toomuchdataerror';
    end


    if isempty(this.InportSrc)&&isempty(this.OutportSnk)
        checks(end+1).path=dut.getStartNodeName;
        checks(end).type='model';
        checks(end).message='Cannot generate testbench without input and output data.';
        checks(end).level='Error';
        checks(end).MessageID='hdlcoder:engine:nodataerror';
    end



    gp=pir;

    gp.deleteUnusedClockRates;
    rates=gp.getDutSampleTimes;

    if genRTLTB
        check=slhdlcoder.solverCheck(dut,rates,'Error',this.CachedSingleTaskRateTransMsg,true);
        for i=1:length(check)
            checks(end+1)=check(i);%#ok
        end
    end
end
