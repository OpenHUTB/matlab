function activateConfigSet(this,blockDiagram)






    newSimscapeCC=this.getConfigSet(blockDiagram);
    oldSimscapeCC=this.modelRegistry.getAndClearPreswitchCC(blockDiagram);



    if~(isempty(oldSimscapeCC)||isempty(newSimscapeCC))



        oldMode=this.getConfigSetEditingMode(oldSimscapeCC);
        newMode=this.getConfigSetEditingMode(newSimscapeCC);


        this.switchEditingMode(blockDiagram,oldMode,newMode);

    else




        this.modelRegistry.createModelEntry(blockDiagram);

    end




