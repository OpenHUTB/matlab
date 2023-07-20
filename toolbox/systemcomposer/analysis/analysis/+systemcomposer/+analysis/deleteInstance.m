function deleteInstance(archInstance)


    narginchk(1,1);
    if isa(archInstance,'systemcomposer.analysis.ArchitectureInstance')
        systemcomposer.internal.analysis.AnalysisService.deleteInstance(archInstance.getUUID);
    else
        error('systemcomposer:analysis:invalidDeleteArgument',...
        message('SystemArchitecture:Analysis:InvalidDeleteArgument').getString);
    end
end

