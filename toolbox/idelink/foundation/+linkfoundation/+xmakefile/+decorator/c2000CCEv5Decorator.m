function toolChainConfiguration=c2000CCEv5Decorator(data)




    toolChainConfiguration=linkfoundation.xmakefile.decorator.ccev5Decorator(data);

    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;


    function flags=codeGenLinkerFlagsOverride(h,codeGenFlags,data)
        flags=toolChainConfiguration.PrivateData.BaseCodeGenLinkerFlagsOverride(...
        h,codeGenFlags,data,'C2000');
    end

end