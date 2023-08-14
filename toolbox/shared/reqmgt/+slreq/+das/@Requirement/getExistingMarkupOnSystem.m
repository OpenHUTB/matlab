function markup=getExistingMarkupOnSystem(this,sys)








    markup=slreq.das.Markup.empty();
    allMarkups=this.Markups();
    sysPath=getfullname(sys);
    for n=1:length(allMarkups)
        if strcmp(sysPath,allMarkups(n).SystemPath)
            markup=allMarkups(n);
            return;
        end
    end
end
