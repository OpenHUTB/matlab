function varargout=simulateModel(this)





    assert(strcmpi(get_param(this.ModelName,'HDLCodeGenStatus'),'Idle'),...
    'HDLCodeGenStatus must be Idle during simulation.');
    mdlName=bdroot(this.ModelName);
    hdldisp(message('hdlcoder:hdldisp:BeginSim',mdlName));



    simCommand=['sim(''',mdlName,''');'];
    varargout={evalin('caller',simCommand)};


