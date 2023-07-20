function checks=checkFILSettings(this)




    checks=struct('path',{},...
    'type',{},...
    'message',{},...
    'level',{},...
    'MessageID',{});

    genFIL=this.getParameter('generatefilblock');
    genCode=this.getCodeModelTBParams;

    if genFIL

        if~hdlcoderui.isedasimlinksinstalled
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=...
            ['HDL Verifier is not available. Make sure HDL Verifier'...
            ,'is licensed and installed for use with FPGA-in-the-Loop.'];
            checks(end).level='Error';
            checks(end).MessageID='hdlcoder:engine:FILRequiresEDASL';
        end


        if~genCode
            checks(end+1).path=this.getStartNodeName;
            checks(end).type='model';
            checks(end).message=...
            ['HDL code generation is required for FPGA-in-the-Loop. '...
            ,'Make sure HDL code is included in "Code generation output".'];
            checks(end).level='Error';
            checks(end).MessageID='hdlcoder:engine:FILRequiresCodeGen';
        end
    end
