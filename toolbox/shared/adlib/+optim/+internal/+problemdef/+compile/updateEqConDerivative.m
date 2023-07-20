function probStruct=updateEqConDerivative(probStruct,eqcon,derivativeFlag)








    if strncmpi(probStruct.(derivativeFlag),"auto",4)


        nLabelCon=numel(eqcon);
        nCon=0;
        for i=1:nLabelCon
            nCon=nCon+numel(eqcon{i});
            if~getSupportsAD(eqcon{i})
                probStruct.(derivativeFlag)="finite-differences";
                break
            end
        end


        switch probStruct.(derivativeFlag)
        case 'auto'
            if nCon>=probStruct.NumVars
                probStruct.(derivativeFlag)="forward-AD";
            else
                probStruct.(derivativeFlag)="reverse-AD";
            end
        case 'auto-reverse'
            probStruct.(derivativeFlag)="reverse-AD";
        case 'auto-forward'
            probStruct.(derivativeFlag)="forward-AD";
        end

    end



