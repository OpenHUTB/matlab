function tf=isPerspectiveEnabled(this,modelH)






    if isempty(this.perspectiveManager)
        tf=false;
    else
        tf=this.perspectiveManager.getStatus(modelH);
    end
end
