function v=validateBlock(~,hC)%#ok<INUSD>


    v=hdlvalidatestruct;






    if~targetcodegen.targetCodeGenerationUtils.isFloatingPointMode
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:TargetCodeGenInvalidFloatTypeCast'));
    end


