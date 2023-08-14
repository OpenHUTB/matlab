function out=isPathBasedTestGeneration(options)










    out=(slavteng('feature','PathBasedTestgen')~=0)&&...
    strcmp(options.ModelCoverageObjectives,'EnhancedMCDC')&&...
    ~(strcmp(options.TestgenTarget,'GenCodeModelRef')||...
    strcmp(options.TestgenTarget,'GenCodeTopModel'));
end
