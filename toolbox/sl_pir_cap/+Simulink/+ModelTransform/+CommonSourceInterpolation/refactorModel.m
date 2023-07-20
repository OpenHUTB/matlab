function refactorModelResults=refactorModel(candidateResults,xformedModelName)




    if(isempty(candidateResults)||~isa(candidateResults,'Simulink.ModelTransform.CommonSourceInterpolation.Results')...
        ||~isprop(candidateResults,'Candidates'))
        DAStudio.error('sl_pir_cpp:creator:InvalidCandidateResultObject');
    end
    model2modelObj=candidateResults.ModelTransformerInfo;
    candidates=candidateResults.Candidates;
    if(nargin<2||(nargin==2&&isempty(xformedModelName)))
        xformedModelName='';
        model2modelObj.fInModelXform=true;
    end
    refactorModelResults=[];
    try
        if(~isempty(candidates))
            model2modelObj.refactoring(xformedModelName);
            refactorModelResults=Simulink.ModelTransform.CommonSourceInterpolation.RefactorResults(model2modelObj);
        else
            DAStudio.error('sl_pir_cpp:creator:NoCandidatesToTransform');
        end
    catch exception
        exception.throwAsCaller();
        close_system(commonSrcInterpXformObj.modelNameFullPath);
    end
end
