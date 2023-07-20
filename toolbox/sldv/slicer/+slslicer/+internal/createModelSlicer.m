function obj=createModelSlicer()




    if slfeature('NewSlicerBackend')
        obj=DFGEquationsIR.ModelSlicer;
    else
        obj=DFGIR.ModelSlicer;
    end
end
