function updateChecks(this,blkpath,type,msgobj,level)








    if isa(msgobj,'MException')
        msgstr=msgobj.message;
        msgID=msgobj.identifier;
    else
        msgstr=msgobj.getString;
        msgID=msgobj.Identifier;
    end



    FEChecks=struct();
    FEChecks.path=blkpath;
    FEChecks.type=type;
    FEChecks.message=msgstr;
    FEChecks.level=level;
    FEChecks.MessageID=msgID;

    hdlDrv=this.HDLCoder;
    hdlDrv.updateChecksCatalog(this.hPir.ModelName,FEChecks);


