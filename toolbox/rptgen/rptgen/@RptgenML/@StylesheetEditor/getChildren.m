function c=getChildren(this)







    c=[];

    if~isempty(this.JavaHandle)
        try
            c=getParamsLibrary(RptgenML.StylesheetRoot,this,'-asynchronous');
            if isa(c,'RptgenML.Library')
                c=c.getChildren;
            end
        catch ME
            warning(ME.identifier,ME.message);
        end
    end
