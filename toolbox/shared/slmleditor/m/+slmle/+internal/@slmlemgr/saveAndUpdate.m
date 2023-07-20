function updatedText=saveAndUpdate(obj,text,objectId)




    data=[];

    if nargin<3
        error('Insufficient amount of input args. Must be alteast 3');
    end

    data.objectId=objectId;

    try
        slmle.internal.object2Data(objectId,'setScript',text);



        data.text=slmle.internal.object2Data(objectId,'getScript');
    catch ME
        data.error=ME.message;
    end

    updatedText=data.text;


    if~strcmp(data.text,text)
        obj.update(updatedText,objectId);
    end


    modelName=bdroot(slmle.internal.object2Data(objectId,'getChartName'));
    if strcmpi(get_param(modelName,'dirty'),'on')
        set_param(modelName,'dirty','off');
    end


