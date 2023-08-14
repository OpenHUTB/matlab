function[hostBasedTarget,toolchainInfo]=isHostBasedTarget(model)








    try
        [~,toolchainInfo]=rtwprivate('getCompilerForModel',model);
    catch e %#ok<NASGU>






        toolchainInfo=[];
    end
    hostBasedTarget=coder.internal.isHostBasedCompiler(toolchainInfo);
end