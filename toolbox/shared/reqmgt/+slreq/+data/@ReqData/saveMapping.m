


function out=saveMapping(this,mapping,filepath)






    out=true;

    serializer=mf.zero.io.XmlSerializer;
    serializer.serializeToFile(mapping,filepath);



end