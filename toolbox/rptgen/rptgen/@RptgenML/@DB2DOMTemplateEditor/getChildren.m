function c=getChildren(this)




    try
        c=this.getTemplateLibrary('-asynchronous');
        if isa(c,'RptgenML.Library')
            c=c.getChildren;
        end
    catch ME
        c=[];
        warning(ME.identifier,ME.message);
    end


