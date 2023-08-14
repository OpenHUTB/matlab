function hdlserializepir(this,p)
    if this.getParameter('savepirtoscript')
        mdlName=p.ModelName;
        filename=[mdlName,'_serialized.m'];
        psrl=SerializePir(p,filename);
        psrl.doit();
        hdldisp(message('hdlcoder:hdldisp:SerializePirCreated',hdlgetfilelink(filename)));
    end
end
