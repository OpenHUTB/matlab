function update(obj,text,objectId,uid)














    data=[];

    if nargin<3
        error('Insufficient amount of input args. Must be alteast 3');
    end

    obj.fText=text;
    data.text=text;
    data.objectId=objectId;




    if nargin==4
        data.uid=['~',uid];
    end

    m=slmle.internal.slmlemgr.getInstance;
    m.publish(objectId,'refresh',data);


    prevScript=sf('get',objectId,'state.eml.script');
    newScript=data.text;
    if~strcmp(prevScript,newScript)
        sfprivate('eml_man','model_dirty',objectId);
    end




