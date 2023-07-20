function toolChainConfiguration=c5500CCEv5Decorator(data)




    toolChainConfiguration=linkfoundation.xmakefile.decorator.ccev5Decorator(data);

    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;


    function flags=codeGenLinkerFlagsOverride(h,codeGenFlags,data)
        flags=toolChainConfiguration.PrivateData.BaseCodeGenLinkerFlagsOverride(...
        h,codeGenFlags,data,'C5500');
    end

end