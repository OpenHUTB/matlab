function checkReference(obj,propVal)


    tempref=obj.Reference;

    if iscell(obj.Reference)
        numelempos=size(obj.ElementPosition,1);
        if numelempos<numel(tempref)
            value1=num2str(numel(tempref,1));
            value2=num2str(numelempos);
            error(message('antenna:antennaerrors:NotEnoughArrayElementPosition',...
            'Reference',value1,value2));





        end
    end






    referenceAsFeed=strcmpi('feed',tempref);
    if iscolumn(referenceAsFeed)
        referenceAsFeed=referenceAsFeed';
    end
    if any(referenceAsFeed)
        isaBackingStructureAntenna=cellfun(@(x)isa(x,'em.BackingStructure'),propVal)&referenceAsFeed;
        isSubstrate=cellfun(@(x)isprop(x,'Substrate')&&~isequal(x.Substrate.('EpsilonR'),ones(size(x.Substrate.('EpsilonR')))),propVal(isaBackingStructureAntenna),'UniformOutput',false);
        isSubstrate=cell2mat(isSubstrate);
        if any(isSubstrate)
            error(message('antenna:antennaerrors:ReferenceAsFeedNotAllowed'));
        end
    end

end