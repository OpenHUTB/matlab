function lDeclarationsSite=extractProfilingDeclaration(lHeaderFiles)







    lDeclarationsSite=[];
    for i=1:length(lHeaderFiles)
        filename=lHeaderFiles{i};
        cnt=fileread(filename);
        if contains(cnt,Simulink.ExecTimeTraceabilityProbes.DeclarationsPlaceholderSymbol)
            lDeclarationsSite=filename;
            break;
        end
    end
    assert(~isempty(lDeclarationsSite),...
    'Header file not found to declare the profiling API');

end
