function toolChainConfiguration=c5500CCSDecorator(data)




    toolChainConfiguration=linkfoundation.xmakefile.decorator.ccsDecorator(data);

    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;


    function flags=codeGenLinkerFlagsOverride(h,codeGenFlags,data)
        flags=toolChainConfiguration.PrivateData.BaseCodeGenLinkerFlagsOverride(...
        h,codeGenFlags,data,'C5500');
    end


end