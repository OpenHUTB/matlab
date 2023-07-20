function out=execute(this,d,varargin)






    if~isempty(this.OldComponent)
        out=execute(this.OldComponent);
    else
        out=[];
    end

    if isa(out,'sgmltag')
        out=java(out,java(d));
    elseif iscell(out)
        out=java(sgmltag(out),java(d));
    end