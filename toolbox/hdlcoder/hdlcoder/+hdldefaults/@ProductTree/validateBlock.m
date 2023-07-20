function v=validateBlock(this,hC)



    v=this.validateProductBlock(hC);



    vstructs=this.validateMaskParams(hC);


    v=horzcat(v,vstructs);


    v=[v,this.validateDSPStyle(hC)];
