function toolChainConfiguration=c2000CCSDecorator(data)




    toolChainConfiguration=linkfoundation.xmakefile.decorator.ccsDecorator(data);

    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;


    function flags=codeGenLinkerFlagsOverride(h,codeGenFlags,data)
        flags=toolChainConfiguration.PrivateData.BaseCodeGenLinkerFlagsOverride(...
        h,codeGenFlags,data,'C2000');
    end

end