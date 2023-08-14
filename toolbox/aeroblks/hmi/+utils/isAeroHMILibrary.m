function op=isAeroHMILibrary(modelName)






    op=isequal(get_param(modelName,'blockDiagramType'),'library')&&...
    isequal(modelName,'aerolibhmi');
end
