function E=selectDevice(id)
    ;%#ok undocumented



    try
        feval('_gpu_selectDevice',id);
        E=[];
    catch E
    end
end
