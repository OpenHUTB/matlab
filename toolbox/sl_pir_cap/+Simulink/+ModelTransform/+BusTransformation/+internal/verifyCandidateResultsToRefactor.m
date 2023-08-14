function verifyCandidateResultsToRefactor(identificationResult)




    if~isa(identificationResult,'Simulink.ModelTransform.BusTransformation.Result')
        DAStudio.error('sl_m2m_edittime:messages:InvalidBusXformResultsObject');
    end

    if isempty(identificationResult.BusHierarchies)
        DAStudio.error('sl_m2m_edittime:messages:EmptyBusXformResultsObject');
    end
end


