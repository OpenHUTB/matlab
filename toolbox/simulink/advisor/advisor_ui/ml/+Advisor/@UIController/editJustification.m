function result=editJustification(this,instanceId,RDId,message)

    deleteJustification(this,instanceId,RDId);
    result=justify(this,instanceId,RDId,message);
end