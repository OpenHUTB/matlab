function deactivateConfigSet(this,blockDiagram)




    oldSimscapeCC=this.getConfigSet(blockDiagram);



    this.modelRegistry.setPreswitchCC(blockDiagram,oldSimscapeCC);



