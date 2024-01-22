function ok=testFeature(feature)

    ok=builtin('license','test',feature);

    ok=logical(ok);
    if(ok&&strcmpi('distrib_computing_toolbox',feature))
        ok=matlab.internal.parallel.isPCTInstalled;
    end
end

