function flag=isSystemObject(arg)






%#codegen
    coder.allowpcode('plain');

    flag=isa(arg,'matlab.system.SystemImpl')||isa(arg,'matlab.system.coder.System');
end


