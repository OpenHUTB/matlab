function showDialog(viewer,latch)




    function close(data)
        release(latch,data.AllFilesSaved);
    end

    if isempty(viewer)
        release(latch,false);
    else
        addlistener(viewer,"Close",@(~,data)close(data));
        viewer.show();
    end

end
