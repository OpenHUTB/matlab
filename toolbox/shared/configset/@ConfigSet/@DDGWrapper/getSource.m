function out=getSource(obj)


    out=obj.dialog.getSource;
    if isa(out,'configset.dialog.HTMLView')
        out=out.Source.getCS;
    end
