function status=verifyLoaded(model)











    try

        dirty=get_param(model,'dirty');
        status=dirty;
    catch ME %#ok<NASGU>

        load_system(model);
        status='notloaded';
    end
end
