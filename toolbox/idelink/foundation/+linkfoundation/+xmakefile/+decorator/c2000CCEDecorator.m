function toolChainConfiguration=c2000CCEDecorator(data)




    toolChainConfiguration=linkfoundation.xmakefile.decorator.cceDecorator(data);

    toolChainConfiguration.CodeGenLinkerFlagsOverride=@codeGenLinkerFlagsOverride;


    function flags=codeGenLinkerFlagsOverride(h,codeGenFlags,data)
        flags=toolChainConfiguration.PrivateData.BaseCodeGenLinkerFlagsOverride(...
        h,codeGenFlags,data,'C2000');
    end

end