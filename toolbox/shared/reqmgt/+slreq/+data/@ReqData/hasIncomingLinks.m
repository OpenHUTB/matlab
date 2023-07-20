function tf=hasIncomingLinks(this,reqSetObj)







    tf=false;
    reqSet=this.getModelObj(reqSetObj);
    reqs=reqSet.items.toArray;
    for n=1:length(reqs)
        req=reqs(n);
        if req.references.Size>0
            refs=req.references.toArray;


            for m=1:length(refs)
                if~strcmp(refs(m).link.source.artifact.artifactUri,req.requirementSet.filepath)

                    tf=true;
                    return;
                end
            end
        end
    end
end
