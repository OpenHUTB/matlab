function slxHandlesSuspend(suspend)




    if~is_simulink_loaded
        return
    end

    if suspend
        command='release_file_handles';
    else
        command='acquire_file_handles';
    end
    slgcInternal(command)

end
