function MathRegisterCompileCheck(block,h)


    appendCompileCheck(h,block,@CollectMathBlockPortDataTypes,@ReplaceMathBlockSqrtFunction);

end
