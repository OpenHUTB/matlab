function[mfReqSet,isNewlyLoaded]=locateRequirementSet(this,storedUri,refPath,loadReferencedReqsets,embeddedPath)






    if nargin<4

        loadReferencedReqsets=true;
    end
    if nargin<5
        embeddedPath=[];
    end



    isNewlyLoaded=false;


    if isempty(embeddedPath)
        mfReqSet=this.findRequirementSet(storedUri);
    else
        mfReqSet=this.findRequirementSet(embeddedPath);
    end
    if~isempty(mfReqSet)
        return;
    end

    if~loadReferencedReqsets










        return;
    end





    reqSetLocator=slreq.uri.ReqSetLocator.getInstance();
    reqSetPath=reqSetLocator.findReqSetFile(storedUri,refPath);
    if isempty(reqSetPath)
        return;
    end


    if~isempty(reqSetPath)
        try
            if~isempty(embeddedPath)
                load_system(reqSetPath);
                dataReqSet=this.getReqSet(embeddedPath);
            else
                dataReqSet=this.loadReqSet(reqSetPath);
            end
            mfReqSet=dataReqSet.getModelObj();
            isNewlyLoaded=true;
        catch ex %#ok<NASGU>

            rmiut.warnNoBacktrace('Slvnv:slreq:InvalidCorruptSLREQXFile',reqSetPath);
        end
    end
end


