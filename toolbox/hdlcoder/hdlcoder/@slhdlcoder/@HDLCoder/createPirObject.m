function p=createPirObject(this,modelName)




    narginchk(2,2);



    p=pir(modelName);
    this.initPir(p);
    this.PirInstance=p;

end
