function forceSysOpen(h)












    if~bdIsLoaded(h.MyModel)
        open_system(h.MyModel);
    end



    h.IsLibrary=strcmp(get_param(h.MyModel,'BlockDiagramType'),'library');
    if h.IsLibrary,
        set_param(h.MyModel,'Lock','off');
    end






    h.CloseSimulink=~bdIsLoaded('simulink');
    if h.CloseSimulink
        load_system('simulink');
    end

end
