function update(obj,text,objectId)




    if nargin<3
        error('Insufficient amount of input args. Must be alteast 3');
    end

    data.text=text;

    data.objectId=objectId;
    obj.publish(objectId,'refresh',data);




