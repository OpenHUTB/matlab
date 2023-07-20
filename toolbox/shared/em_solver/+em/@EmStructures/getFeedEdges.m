function feededge=getFeedEdges(obj,p,metalbasis)




    metalbasisEdges=metalbasis.Edges;
    k=strfind(obj.MesherStruct.Mesh.FeedType,'multiedge');
    if iscell(k)
        multiedgedobj=any(cell2mat(k));
    else
        multiedgedobj=k;
    end

    if multiedgedobj
        if isa(obj,'planeWaveExcitation')
            obj=obj.Element;
        end
        if isa(obj,'conformalArray')||isa(obj,'installedAntenna')

            numelem=size(obj.ElementPosition,1);
            feededgetemp_1=cell([1,numelem]);
            if~isscalar(obj.Element)
                offset=0;
                for i=1:numel(obj.Element)
                    numfeeds=size(obj.Element{i}.FeedLocation,1);
                    if strcmpi(obj.Element{i}.MesherStruct.Mesh.FeedType,'multiedge')
                        feededgetemp=getFeedingEdges(obj.Element{i},metalbasisEdges,...
                        obj.FeedLocation(offset+1:offset+numfeeds,:)',p);
                    else
                        feededgetemp=em.EmStructures.feeding_edge(p,metalbasisEdges,...
                        obj.FeedLocation(offset+1:offset+numfeeds,:),...
                        obj.MesherStruct.Mesh.FeedType{i});
                    end
                    offset=offset+size(obj.Element{i}.FeedLocation,1);
                    feededgetemp_1{i}=feededgetemp;
                end
            elseif isscalar(obj.Element)

                if~isa(obj.Element,'em.Array')
                    numelem=size(obj.ElementPosition,1);
                    feededgetemp_1=cell([1,numelem]);
                    offset=0;
                    for m=1:size(obj.ElementPosition,1)
                        numfeeds=size(obj.Element.FeedLocation,1);
                        feededgetemp_1{m}=getFeedingEdges(obj.Element,metalbasisEdges,...
                        obj.FeedLocation(offset+1:offset+numfeeds,:)',p);
                    end
                else

                    feededgetemp_1{1}=getFeedingEdges(obj.Element,metalbasisEdges,...
                    obj.FeedLocation',p);
                end
            end
            numrows=cell2mat(cellfun(@(x)size(x,1),feededgetemp_1,'UniformOutput',false));
            maxnumrows=max(numrows);
            for i=1:numel(numrows)
                if size(feededgetemp_1{i},1)<=maxnumrows
                    feededgetemp_1{i}=[feededgetemp_1{i};...
                    zeros(maxnumrows-numrows(i),size(feededgetemp_1{i},2))];
                end
            end
            feededge=cell2mat(feededgetemp_1);
        else
            feededge=getFeedingEdges(obj,metalbasisEdges,...
            obj.FeedLocation',p);
        end
    else
        if isprop(obj,'Element')
            feededge=em.EmStructures.feeding_edge(p,metalbasis.Edges,...
            obj.FeedLocation,obj.MesherStruct.Mesh.FeedType,obj.Element);
        elseif(isa(obj,'em.BackingStructure')||isa(obj,'em.ParabolicAntenna'))...
            &&em.internal.checkLRCArray(obj.Exciter)

            feededge=em.EmStructures.feeding_edge(p,metalbasis.Edges,...
            obj.FeedLocation,obj.MesherStruct.Mesh.FeedType,obj.Exciter.Element);
        else
            feededge=em.EmStructures.feeding_edge(p,metalbasis.Edges,...
            obj.FeedLocation,obj.MesherStruct.Mesh.FeedType);
        end
    end
end
