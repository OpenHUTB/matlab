

function mf0Object=parseMf0File(this,filePath,msgId,content,doRemap)






    mf0Object=[];

    try
        parser=mf.zero.io.XmlParser;
        parser.Model=this.model;
        parser.RemapUuids=doRemap;
        parser.ShouldSkipDanglingReferencesWithinModel=true;
        mf0Object=parser.parseString(content);
    catch ex
        if strcmp(ex.identifier,'mf0:messages:UUIDConflict')






            if~doRemap
                mf0Object=this.parseMf0File(filePath,msgId,content,true);
                return;
            else
                rmiut.warnNoBacktrace('Slvnv:slreq:UuidConflict',filePath);
            end
        elseif strcmp(ex.identifier,'mf0:io:UnderlyingParserProblem')



            rmiut.warnNoBacktrace('Slvnv:slreq:XMLParserError',filePath);








            blackList=[0:8,11,12,14:31];
            idx=ismember(content,blackList);

            if any(idx)

                content(idx)=32;

                try

                    mf0Object=this.parseMf0File(filePath,msgId,content,doRemap);



                    if isa(mf0Object,'slreq.datamodel.RequirementSet')
                        mf0Object.dirty=true;
                    end

                    rmiut.warnNoBacktrace('Slvnv:slreq:XMLParserErrorRecovery',filePath);
                catch ex2




                    rmiut.warnNoBacktrace('Slvnv:slreq:XMLParserErrorNoRecovery',filePath,ex2.message);


                    error(message(msgId,filePath));
                end
            else


                error(message(msgId,filePath));
            end
        else




            error(message(msgId,filePath));
        end
    end
end
