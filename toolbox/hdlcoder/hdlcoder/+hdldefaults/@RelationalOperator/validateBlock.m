function[v]=validateBlock(this,hC)









    v=hdlvalidatestruct;

    Status=1;

    op=getBlockInfo(this,hC);


    in=hC.PirInputPorts(1).Signal;
    [~,~,isSingleType,isDoubleType,isHalfType]=targetmapping.isValidDataType(in.Type);



    switch op
    case{'isNaN','isInf','isFinite'}
        if~targetcodegen.targetCodeGenerationUtils.isNFPMode()
            v(end+1)=hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:RelopFuncUnsupported',op));
        end

        if~(isSingleType||isDoubleType||isHalfType)
            v(end+1)=hdlvalidatestruct(Status,message('hdlcoder:validate:UnsupportedRelOpMode',op));
        end
    end

    in1signal=hC.PirInputPorts(1).Signal;
    if(targetcodegen.targetCodeGenerationUtils.isAlteraMode()||targetcodegen.targetCodeGenerationUtils.isXilinxMode())&&in1signal.Type.isMatrix
        v=hdlvalidatestruct(1,...
        message('hdlcommon:targetcodegen:UnsupportedMatrixTypesTargetcodegen'));
    end

end
