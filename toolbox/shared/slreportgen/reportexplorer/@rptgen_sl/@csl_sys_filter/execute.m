function out=execute(this,d,varargin)






    if this.isTrue
        out=this.runChildren;
    else
        out=createComment(d,'Filter: skipped system');
    end