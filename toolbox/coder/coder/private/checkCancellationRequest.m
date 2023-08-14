function cancelled=checkCancellationRequest(project)



    cancelled=false;
    if~isempty(project.CodeGenWrapper)&&project.CodeGenWrapper.isCancelled
        cancelled=true;
        if~project.BuildCancelled
            project.BuildCancelled=true;
            error(message('Coder:buildProcess:cancelledByUser'));
        end
    end