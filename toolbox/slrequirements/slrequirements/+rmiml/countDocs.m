function[docs,sys,counts]=countDocs(srcKey)


    docs={};
    sys={};
    counts=[];
    if rmiml.hasLinks(srcKey)

        [docs,items,sys]=slreq.getLinkedItems(srcKey,true);
        for i=1:length(docs)
            counts(i)=countLinks(items{i});%#ok<AGROW>
        end

    end
end

function numLinks=countLinks(linkData)
    numLinks=0;
    for i=1:size(linkData,1)
        numLinks=numLinks+linkData{i,2};
    end
end