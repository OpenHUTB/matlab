function toggleAnnotation(obj,bool)



    obj.review=bool;
    data=[];
    data.flag=bool;
    obj.publish('toggleAnnotation',data);
