function[ssRefDiagramHandles,ssRefDiagramNames]=getLoadedSSRefFromModel(modelName)




    ssRefDiagramHandles=slInternal('getChildSubsystemBDs',modelName);
    if isempty(ssRefDiagramHandles)


        ssRefDiagramHandles=[];
    end
    if nargout>1
        ssRefDiagramNames=getfullname(ssRefDiagramHandles);
        if length(ssRefDiagramHandles)==1
            ssRefDiagramNames={ssRefDiagramNames};
        end
    end

end