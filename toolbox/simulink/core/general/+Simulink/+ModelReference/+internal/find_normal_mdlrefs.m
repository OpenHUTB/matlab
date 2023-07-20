function refModels=find_normal_mdlrefs(varargin)





    [~,~,aGraph]=find_mdlrefs(varargin{:});
    b=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
    result=b.analyze(aGraph,'OnlyNormal','IncludeTopModel',true);

    refModels={};





    if~isempty(result)
        refModels=[result.RefModel(2:end);result.RefModel(1)];
    end
end
