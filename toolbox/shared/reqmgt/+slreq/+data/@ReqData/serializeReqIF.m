
function[xml,imageFiles]=serializeReqIF(this,mfReqIf)






    xml=[];
    imageFiles=[];

    if isa(mfReqIf,'slreq.reqif.ReqIf')



        reqifData=slreq.reqif.ReqIfData(this.model);
        xml=reqifData.serialize(mfReqIf,'REQIF');
        imageFiles=reqifData.imageFiles.toArray;


        reqifData.destroy();
    end
end