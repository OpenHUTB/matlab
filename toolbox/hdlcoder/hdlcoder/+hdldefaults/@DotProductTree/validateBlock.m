function v=validateBlock(this,hC)


    v=[];


    hInSignals=hC.PirInputSignals;

    in1BaseType=getPirSignalBaseType(hInSignals(1).Type);

    in1LeafType=in1BaseType.getLeafType();

    in2BaseType=getPirSignalBaseType(hInSignals(2).Type);

    in2LeafType=in2BaseType.getLeafType();

    if in1BaseType.isComplexType

        if(isprop(in1LeafType,'Signed')&&~in1LeafType.Signed())
            v=[v,hdlvalidatestruct(1,message('hdlcoder:validate:DotProduct_CplxUnsupportedMode',getfullname(hC.SimulinkHandle)))];
        end
    end

    if(this.isInputOrientationMixed(hInSignals))

        v=[v,hdlvalidatestruct(3,message('hdlcoder:validate:DotProduct_MixedVector_UnableToGenerateTestBench',getfullname(hC.SimulinkHandle)))];
    end


    if in1LeafType.isFloatType||in2LeafType.isFloatType
        if targetcodegen.targetCodeGenerationUtils.isNFPMode()

            if in1BaseType.isComplexType||in2BaseType.isComplexType


                v=[v,hdlvalidatestruct(1,message('hdlcommon:nativefloatingpoint:DotProduct_CplxUnsupportedMode',getfullname(hC.SimulinkHandle)))];
            end
        end
    end
end
