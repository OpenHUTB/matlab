function candidateResults=identifyCandidates(modelNameFullPath,skipLibBlocks)
    [filePath,modelName,~]=fileparts(modelNameFullPath);
    if isempty(modelNameFullPath)||isempty(modelName)
        DAStudio.error('sl_pir_cpp:creator:EmptyModelName');
    end

    if(nargin<2||(nargin==2&&isempty(skipLibBlocks)))
        skipLibBlocks=0;
    end
    candidateResults=[];
    try

        slEnginePir.util.loadBlockDiagramIfNotLoaded(modelNameFullPath);
        m2mObj=slEnginePir.m2m_CommonSourceInterpolation(modelName);
        m2mObj.fOpenXformModel=false;
        m2mObj.fSkipLinkedBlks=skipLibBlocks;
        m2mObj.fModelFilepath=filePath;
        m2mObj.identify();
        candidateResults=Simulink.ModelTransform.CommonSourceInterpolation.Results(m2mObj);
    catch exception
        exception.throwAsCaller();
        close_system(obj.modelNameFullPath);
    end
end
