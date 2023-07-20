function coeffSourceNames=getCoefficientPropertyNames(~,blkObj)






    filterType=blkObj.TypePopup;
    coeffSourceNames=[];
    switch(filterType)
    case 'IIR (all poles)'
        filterStructure=blkObj.AllPoleFiltStruct;
        if contains(filterStructure,'Direct')
            coeffSourceNames=struct('ParamName','DenCoeffs','PathItem','Coefficients');
        elseif contains(filterStructure,'Lattice')
            coeffSourceNames=struct('ParamName','LatticeCoeffs','PathItem','Coefficients');
        end

    case 'IIR (poles & zeros)'
        filterStructure=blkObj.IIRFiltStruct;
        if contains(filterStructure,'Direct')
            coeffSourceNames=struct('ParamName','NumCoeffs','PathItem','Numerator coefficients');
            coeffSourceNames(2)=struct('ParamName','DenCoeffs','PathItem','Denominator coefficients');
        elseif contains(filterStructure,'Biquad')
            coeffSourceNames=struct('ParamName','BiQuadCoeffs','PathItem','Coefficients');
        end

    case 'FIR (all zeros)'
        filterStructure=blkObj.FIRFiltStruct;
        if contains(filterStructure,'Direct')
            coeffSourceNames=struct('ParamName','DenCoeffs','PathItem','Coefficients');
        elseif contains(filterStructure,'Lattice')
            coeffSourceNames=struct('ParamName','LatticeCoeffs','PathItem','Coefficients');
        end
    end
end


