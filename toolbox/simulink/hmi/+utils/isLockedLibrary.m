


function op=isLockedLibrary(modelName)

    op=isequal(get_param(modelName,'blockDiagramType'),'library')&&...
    isequal(get_param(modelName,'Lock'),'on');
end