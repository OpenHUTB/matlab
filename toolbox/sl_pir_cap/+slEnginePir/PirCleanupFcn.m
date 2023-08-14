function PirCleanupFcn(aPIRs)%#ok
    p=pir;
    for idx=1:length(aPIRs)
        p.destroyPirCtx([aPIRs{idx}]);
    end
end