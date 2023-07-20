function v=validateBlock(this,hC)




    v=hdlvalidatestruct;
    slbh=hC.SimulinkHandle;
    blockname=get_param(slbh,'Name');
    blocklink=hdlhtml.reportingWizard.generateSystemLink(blockname,slbh);


    hInSignals=hC.PirInputSignals;
    hInType=hInSignals(1).Type.getLeafType;

    if hInType.isFloatType()


        inh='Inherit';
        if~(strncmp(get_param(slbh,'StateDataTypeStr'),inh,7)&&...
            strncmp(get_param(slbh,'NumCoefDataTypeStr'),inh,7)&&...
            strncmp(get_param(slbh,'DenCoefDataTypeStr'),inh,7)&&...
            strncmp(get_param(slbh,'NumProductDataTypeStr'),inh,7)&&...
            strncmp(get_param(slbh,'NumCoefDataTypeStr'),inh,7)&&...
            strncmp(get_param(slbh,'DenProductDataTypeStr'),inh,7)&&...
            strncmp(get_param(slbh,'NumAccumDataTypeStr'),inh,7)&&...
            strncmp(get_param(slbh,'DenAccumDataTypeStr'),inh,7)&&...
            strncmp(get_param(slbh,'OutDataTypeStr'),inh,7))
            if(targetcodegen.targetCodeGenerationUtils.isNFPMode())
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcommon:nativefloatingpoint:RequiredInheritedRule',blocklink));
            else
                v(end+1)=hdlvalidatestruct(1,...
                message('hdlcoder:validate:RequiredInheritedRule',blocklink));
            end
            return;
        end
    else

        inhir='Inherit: Inherit via internal rule';
        if strcmpi(get_param(slbh,'NumCoefDataTypeStr'),inhir)||...
            strcmpi(get_param(slbh,'DenCoefDataTypeStr'),inhir)||...
            strcmpi(get_param(slbh,'NumProductDataTypeStr'),inhir)||...
            strcmpi(get_param(slbh,'DenProductDataTypeStr'),inhir)||...
            strcmpi(get_param(slbh,'NumAccumDataTypeStr'),inhir)||...
            strcmpi(get_param(slbh,'DenAccumDataTypeStr'),inhir)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:validate:DTFInheritViaInternalRule',blocklink));
            return;
        end
    end


    tfInfo=this.getBlockInfo(hC);
    if~(strcmp(tfInfo.a0EqualsOne,'on')||abs(double(tfInfo.Denominator(1)))==1)
        m=message('hdlcoder:validate:scalingBya0',blocklink);
        v(end+1)=hdlvalidatestruct(1,...
        m.getString,'hdlcoder:validate:scalingBya0');
    end


    reset_type=get_param(hC.SimulinkHandle,'ExternalReset');
    if(~strcmpi(reset_type,'None'))
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:DTF_ExternalReset_None',reset_type));
    end

    numeratorSource=get_param(hC.SimulinkHandle,'NumeratorSource');
    denominatorSource=get_param(hC.SimulinkHandle,'DenominatorSource');
    initialStatesSource=get_param(hC.SimulinkHandle,'InitialStatesSource');
    if~strcmpi(numeratorSource,'Dialog')||~strcmpi(denominatorSource,'Dialog')||~strcmpi(initialStatesSource,'Dialog')
        v(end+1)=hdlvalidatestruct(1,...
        message('hdlcoder:validate:SourceDialogOnly'));
    end


end




