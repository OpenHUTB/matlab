function runTimeInputs=genRuntimeInputsFromCodegenInputs(compileTimeInputs)

    runTimeInputs=compileTimeInputs;
    coderConstantMask=cellfun(@(x)isa(x,'coder.Type')&&isa(x,'coder.Constant'),runTimeInputs);

    if all(~coderConstantMask)
        return
    end

    runTimeInputs(coderConstantMask)=cellfun(@(x)x.Value,compileTimeInputs(coderConstantMask),'UniformOutput',false);
end
