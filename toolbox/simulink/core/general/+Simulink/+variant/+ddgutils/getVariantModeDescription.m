function desc=getVariantModeDescription(VCMode,VAT)




    switch VCMode
    case 'label'
        tag='Label_desc';
    case 'sim codegen switching'
        if strcmp(VAT,'update diagram')
            tag='simcodegen_UpdateDiagram_desc';
        else
            tag='simcodegen_UpdateDiagramAAC_desc';
        end
    otherwise
        if strcmp(VAT,'update diagram')
            tag='Exp_UpdateDiagram_desc';
        elseif strcmp(VAT,'update diagram analyze all choices')
            tag='Exp_UpdateDiagramAAC_desc';
        elseif strcmp(VAT,'code compile')
            tag='Exp_CodeCompileTime_desc';
        elseif strcmp(VAT,'startup')
            tag='Exp_startup_desc';
        elseif slfeature('InheritVAT')&&strcmp(VAT,'inherit from Simulink.VariantControl')
            tag='Exp_inherit_desc';
        end
    end

    desc=message(['Simulink:Variants:',tag]).getString();

end
