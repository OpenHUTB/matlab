




function pollOnCondition(continuationCondition)

    while~continuationCondition()

        wait();
    end

end


function wait()

    waitTime=0.3;

    pause(waitTime);
    drawnow();

end