function v=validateBlock(this,hC)







    v=hdlvalidatestruct;

    if isa(hC,'hdlcoder.sysobj_comp')
        return;
    end

    insignals=hC.PirInputSignals;
    dinType=insignals(1).Type;
    dinBType=dinType.getLeafType;

    blockInfo=getBlockInfo(this,hC);











    if(~blockInfo.isSupportedTrellis)

        v(end+1)=hdlvalidatestruct(1,...
        message('comm:hdl:ConvEncoder:validateBlock:poly2trellis'));
    else
        k=blockInfo.k;
        n=blockInfo.n;
        clength=blockInfo.clength;


        if(((k>=2)&&(n>3))||n>7||n<2)
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ConvEncoder:validateBlock:coderate'));
        else



            msg=dsphdlshared.validation.getMultiSymbolValidationMessage(...
            hC.PirInputSignals(1),k);

            v(end+1)=baseValidateVectorPortLength(this,hC.PirInputSignals(1),...
            k,msg);
        end

        if(min(clength)<3)||(max(clength)>9)

            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ConvEncoder:validateBlock:constraintlength'));
        end

        if strfind(blockInfo.opMode,'Truncated')

            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ConvEncoder:validateBlock:truncatedmode'));
        end


        if strfind(blockInfo.opMode,'Terminate')

            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ConvEncoder:validateBlock:terminatedmode'));
        end



        if dinBType.isDoubleType||dinBType.isSingleType||...
            ~((dinBType.signed==0)&&(dinBType.WordLength==1)&&(dinBType.FractionLength==0))
            v(end+1)=hdlvalidatestruct(1,...
            message('comm:hdl:ConvEncoder:validateBlock:datatypeunsupported'));
        end


        if blockInfo.hasResetPort
            resetType=insignals(2).Type;
            if~(resetType.isBooleanType)
                v(end+1)=hdlvalidatestruct(1,...
                message('comm:hdl:ConvEncoder:validateBlock:resetttypeunsupported'));
            end

            if~blockInfo.DelayedResetAction
                v(end+1)=hdlvalidatestruct(1,...
                message('comm:hdl:ConvEncoder:validateBlock:resetmodeunsupported'));
            end
        end
    end

