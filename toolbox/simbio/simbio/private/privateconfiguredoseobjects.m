











function doseObjects=privateconfiguredoseobjects(compiledModelMap,doseObjects)
    for i=1:size(doseObjects,1)
        for j=1:size(doseObjects,2)
            doseObjects(i,j).TargetName=compiledModelMap.Dosed(j).PartiallyQualifiedName;
            if~isempty(compiledModelMap.ZeroOrderDurationParameter{j})
                doseObjects(i,j).DurationParameterName=compiledModelMap.ZeroOrderDurationParameter{j}.Name;
            end
            if~isempty(compiledModelMap.LagParameter{j})
                doseObjects(i,j).LagParameterName=compiledModelMap.LagParameter{j}.Name;
            end
        end
    end
end