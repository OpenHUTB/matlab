function varargout=hdlcurrentdriver(arg)












    mlock;

    persistent HDLCoderInstance;

    if nargin==1
        HDLCoderInstance=arg;
        varargout={};
    else
        varargout={HDLCoderInstance};
    end


