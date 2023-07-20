function checkBinaryInputTypes(this,node)







    if strcmp(node.kind,'CALL')
        in1=node.Right;
        in2=node.Right.Next;
    else
        in1=node.Left;
        in2=node.Right;
    end

    inType1=this.getType(in1);
    inType2=this.getType(in2);

    if~strcmp(node.kind,'MUL')&&...
        ~(inType1.isScalar||inType2.isScalar)&&...
        any(inType1.Dimensions~=inType2.Dimensions)

        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedOperationWithDifferingMatrixSizes',...
        node.tree2str);
    end

    inputNodes=[in1,in2];
    isInputConst=arrayfun(@(x)this.isConst(x),inputNodes);
    if any(isInputConst)



        constDesc=this.getVarDesc(inputNodes(isInputConst));
        nonConstType=this.getType(inputNodes(~isInputConst));
        outType=this.getType(node);

        mixNonConstOutFloat=(nonConstType.isFloat&&outType.isFloat)&&...
        ~strcmp(nonConstType.getMLName,outType.getMLName);
        mixNonConstOutFloatFix=xor(nonConstType.isFloat,outType.isFloat)&&...
        ~outType.isLogical;
        mixFloatConstFix=(nonConstType.isFi||nonConstType.isInt)&&(constDesc.type.isFloat);

        typesAreCompatibleFcn=@(x)all(eq(x,...
        internal.ml2pir.utils.castConstant(x,constDesc.type,nonConstType,node)),'all');

        if mixNonConstOutFloat||mixNonConstOutFloatFix




        elseif mixFloatConstFix
            return;
        elseif all(cellfun(typesAreCompatibleFcn,constDesc.constVal))




            return;
        elseif constDesc.type.isFloat&&nonConstType.isFi


            return;
        elseif constDesc.type.isFloat&&nonConstType.isFloat&&...
            ~(constDesc.type.isHalf||nonConstType.isHalf)





            return;
        end
    end

    logicalInputs=inType1.isLogical||inType2.isLogical;
    mixedFixedFloatInputs=(inType1.isFloat&&~inType2.isFloat)||(~inType1.isFloat&&inType2.isFloat);
    mixedFloatInputs=(inType1.isFloat&&inType2.isFloat)&&~strcmp(inType1.getMLName,inType2.getMLName);

    if logicalInputs&&~inType1.isDimensionsEqual(inType2)
        this.addMessage(node.Left,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedMixedSizeWithLogicalTypes',...
        node.tree2str);
    elseif mixedFixedFloatInputs


        this.addMessage(node.Left,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedOperationWithMixedTypes',...
        node.tree2str,...
        inType1.getMLName,...
        inType2.getMLName);
    elseif mixedFloatInputs

        this.addMessage(node.Left,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:UnsupportedOperationWithMixedFloatTypes',...
        node.tree2str,...
        inType1.getMLName,...
        inType2.getMLName);
    end
end
