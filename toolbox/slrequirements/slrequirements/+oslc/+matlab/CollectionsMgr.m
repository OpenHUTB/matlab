classdef CollectionsMgr<handle


    properties(Access=private)
collectionsData
projData
    end

    methods(Static)

        function instance=getInstance()
            persistent mgr;
            if isempty(mgr)
                mgr=oslc.matlab.CollectionsMgr();
                mgr.collectionsData=containers.Map('KeyType','char','ValueType','any');
                mgr.projData=containers.Map('KeyType','char','ValueType','char');
            end
            instance=mgr;
        end

    end

    methods

        function ids=parseCollectionsData(this,projName,rdf)
            collections=regexp(rdf,'<rdfs:member>(.+?)</rdfs:member>','tokens');
            ids=cell(numel(collections),1);
            for i=length(collections):-1:1
                id=this.parseCollectionData(collections{i}{1});
                if id>0
                    this.projData(id)=projName;
                    ids{i}=id;
                else
                    ids(i)=[];
                end
            end
        end


        function[types,names,ids]=getTypesAndNames(this,projName)
            knownIds=this.collectionsData.keys()';
            types=cell(size(knownIds));
            names=cell(size(knownIds));
            ids=cell(size(knownIds));
            for i=numel(knownIds):-1:1
                id=knownIds{i};
                if~strcmp(this.projData(id),projName)

                    names(i)=[];
                    types(i)=[];
                    ids(i)=[];
                else
                    ids{i}=id;
                    names{i}=this.collectionsData(id).title;
                    if this.collectionsData(id).isModule
                        types{i}=oslc.matlab.Constants.Module;
                    else
                        types{i}=oslc.matlab.Constants.Collection;
                    end
                end
            end
        end

        function ids=getCollectionIds(this,projectName)
            ids=this.projData.keys()';
            for i=numel(ids):-1:1
                if~strcmp(this.projData(ids{i}),projectName)
                    ids(i)=[];
                end
            end
        end

    end

    methods(Access=private)

















        function id=parseCollectionData(this,rdfPart)
            matchId=regexp(rdfPart,'>(\d+)</dcterms:identifier>','tokens');
            matchTitle=regexp(rdfPart,'>([^>]+)</dcterms:title>','tokens');
            if isempty(matchId)||isempty(matchTitle)
                id=0;
            else
                id=matchId{1}{1};
                data=struct('id',id,'title',matchTitle{1}{1});
                data.isModule=contains(rdfPart,'#Module"/>');
                this.collectionsData(id)=data;
            end
        end
    end
end

