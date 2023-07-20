function toolChainConfiguration=c5500CCEDecorator(data)




    toolChainConfiguration=linkfoundation.xmakefile.decorator.cceDecorator(data);

    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;


    function flags=codeGenLinkerFlagsOverride(h,codeGenFlags,data)
        flags=toolChainConfiguration.PrivateData.BaseCodeGenLinkerFlagsOverride(...
        h,codeGenFlags,data,'C5500');
    end

end