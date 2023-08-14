function varargout=toURDF(model)
















































    [systems,compErrs,hasMultibody]=simmechanics.sli.internal.getSystems(model);

    if~isempty(compErrs)
        translationData.HasCompilationError=true;
        translationData.CompilationError=compErrs;
        varargout{1}=[];
        varargout{2}=translationData;
        return;
    end

    if~hasMultibody
        translationData.HasMultibody=false;
        varargout{1}=[];
        varargout{2}=translationData;
        return;
    end

    for idx=1:length(systems)
        [urdfModel,tData]=sm.mli.internal.systemToURDF(systems(idx));
        urdfModels(idx)=urdfModel;
        tData.HasMultibody=true;
        tData.HasCompilationError=false;
        tData.CompilationError=[];
        translationDatas(idx)=tData;
    end

    varargout={};
    if nargout>=1
        varargout{1}=urdfModels;
    end
    if nargout>=2
        varargout{2}=translationDatas;
    end

end
