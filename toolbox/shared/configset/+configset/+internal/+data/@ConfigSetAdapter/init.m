function init(obj)




    obj.fPropListener={};

    obj.modelInfo=obj.getModelInfo();

    obj.setupRefListener();


    cs=obj.getCS;


    obj.setupTLC(cs);


    obj.setupListener(cs);

    obj.serviceOn=true;

