

function op=isLibrary(modelName)



    op=isequal(get_param(modelName,'blockDiagramType'),'library')&&...
    isequal(modelName,'simulink_hmi_customizable_blocks');
end
