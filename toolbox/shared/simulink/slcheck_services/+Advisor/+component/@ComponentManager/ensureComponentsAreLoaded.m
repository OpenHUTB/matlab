





function ensureComponentsAreLoaded(this,instID)

    instObj=this.getComponent(instID);

    if isa(instObj,'Advisor.component.filebased.Model')&&...
        ~bdIsLoaded(instObj.ID)
        load_system(instObj.ID);
    end

    childrenInst=this.getChildNodes(instID);

    for n=1:length(childrenInst)

        if isa(childrenInst(n),'Advisor.component.filebased.FileBasedInstance')
            this.ensureComponentsAreLoaded(childrenInst(n).ID);
        end
    end
end