function saveAnnotation(obj,msg)


    model=msg.build;
    [~,file]=obj.getCodeDataFile(model);

    anno=msg.userData.all;
    save(file,'anno','-mat');



