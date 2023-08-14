function checks=performFloatingPointTargetChecks(this)


    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});


    if(targetcodegen.targetCodeGenerationUtils.isALTERAFPFUNCTIONSMode())
        tl=this.getParameter('target_language');
        if(~strcmpi(tl,'vhdl'))
            msg=message('hdlcoder:validate:TargetAlteraFPFunctionsVHDLOnly');
            checks(1).path=this.getStartNodeName;
            checks(1).type='model';
            checks(1).message=msg.getString;
            checks(1).level='error';
            checks(1).MessageID=msg.Identifier;
        end
    end
    if(targetcodegen.targetCodeGenerationUtils.isXilinxMode())
        deviceDetails=hdlgetdeviceinfo;
        if(isempty(deviceDetails{1})||isempty(deviceDetails{2})||isempty(deviceDetails{3})||isempty(deviceDetails{4}))
            msg=message('hdlcoder:validate:TargetXilinxDeviceInfoMissing');
            checks(1).path=this.getStartNodeName;
            checks(1).type='model';
            checks(1).message=msg.getString;
            checks(1).level='error';
            checks(1).MessageID=msg.Identifier;
        end
    end
    if(targetcodegen.targetCodeGenerationUtils.isALTFPMode())
        deviceDetails=hdlgetdeviceinfo;
        if(isempty(deviceDetails{1}))
            msg=message('hdlcoder:validate:TargetAlteraDeviceInfoMissing');
            checks(1).path=this.getStartNodeName;
            checks(1).type='model';
            checks(1).message=msg.getString;
            checks(1).level='error';
            checks(1).MessageID=msg.Identifier;
        end
    end
end