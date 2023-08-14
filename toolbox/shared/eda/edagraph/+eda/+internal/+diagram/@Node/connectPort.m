function connectPort(this,varargin)







    arg=this.componentArg(varargin);
    comp=arg.Component;


    arg=rmfield(arg,'Component');

    argFields=fields(arg);
    for i=1:length(argFields)

        portName=comp.findPortName(argFields{i});
        signal=arg.(argFields{i});


        arg=rmfield(arg,argFields{i});
        arg.(portName)=signal;
    end


    this.setSignalSrcDst(arg);
end

