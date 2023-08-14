

function mfObject=loadMapping(this,xmlFile)






    content=slreq.utils.readFromXML(xmlFile);

    mfObject=[];

    try
        parser=mf.zero.io.XmlParser;
        parser.Model=this.model;

        parser.RemapUuids=true;
        mfObject=parser.parseString(content);
    catch ex

    end



end
