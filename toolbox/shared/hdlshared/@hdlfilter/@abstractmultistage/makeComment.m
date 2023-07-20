function makeComment(this,filterobj)






    baseMakeComment(this,filterobj);

    for n=1:length(this.Stage)
        baseMakeComment(this.Stage(n),filterobj.Stage(n));
    end


