
function updateTimerMessage(obj)




    if obj.isCalledFromVM()
        return;
    end

    if obj.VerboseFlag
        timeElapsed=toc;
        fprintf('%s',['(',num2str(timeElapsed),' seconds)',newline]);
        tic;
    end

end
