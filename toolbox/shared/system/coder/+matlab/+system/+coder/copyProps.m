function copyProps(cobj,robj)




%#codegen

    [~,~,props]=coder.const(@eml_try_catch,'matlab.system.coder.System.matlabCodegenPublicProperties',class(robj));
    N=coder.const(length(props));

    ipwsR=matlab.system.internal.InactiveWarningSuppressor(robj);
    ipwsC=matlab.system.internal.InactiveWarningSuppressor(cobj);

    for ix=coder.unroll(1:N)
        propName=coder.const(props{ix});
        cobj.(propName)=coder.const(robj.(propName));
    end

end
