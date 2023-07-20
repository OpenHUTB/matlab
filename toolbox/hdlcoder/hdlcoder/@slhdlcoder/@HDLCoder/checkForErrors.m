function errFound=checkForErrors(this)



    errFound=false;


    models=this.ChecksCatalog.keys();
    for itr=1:numel(models)

        mdlName=models{itr};


        checks=this.ChecksCatalog(mdlName);
        if~isempty(checks)

            if any(strcmpi({checks.level},'error'))
                errFound=true;
                return
            end
        end
    end
end