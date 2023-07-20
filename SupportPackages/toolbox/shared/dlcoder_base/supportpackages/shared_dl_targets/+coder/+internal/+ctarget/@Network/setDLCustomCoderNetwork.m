
















%#codegen
%#internal



function obj=setDLCustomCoderNetwork(obj,dltNetwork,networkInfo,networkName)



    if~coder.target('MATLAB')

        eml_allow_mx_inputs;
    end

    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(dltNetwork,networkInfo,networkName)





    customCoderNet=coder.internal.getprop_if_defined(obj.DLCustomCoderNetwork);
    if coder.const(isempty(customCoderNet))




        buildContext=eml_option('CodegenBuildContext');

        obj.DLCustomCoderNetwork=coder.const(@feval,'coder.internal.ctarget.CustomCoderNetwork',...
        dltNetwork,networkName,networkInfo,buildContext);

    end

end
