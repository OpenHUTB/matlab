function controlName=getUniqueControlName(this)








    [allControlNames,~]=this.getAllControlNamesAndTypes([]);
    while 1
        controlName=[this.ControlPrefix,num2str(this.ControlCntr)];
        this.ControlCntr=this.ControlCntr+1;

        if~any(strcmp(controlName,allControlNames))
            break;
        end
    end
end
