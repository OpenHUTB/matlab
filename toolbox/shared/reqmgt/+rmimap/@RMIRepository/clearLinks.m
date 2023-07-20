function clearLinks(this,elt,deleteIncoming)%#ok<INUSL>







    links=elt.dependeeLinks;
    linkList={};

    for lk=1:links.size
        linkList{end+1}=links.at(lk);%#ok<*AGROW>
    end


    for lk=1:length(linkList)
        link=linkList{lk};
        link.data.destroy;
        link.destroy;
    end

    if deleteIncoming

        links=elt.dependentLinks;
        linkList={};
        for lk=1:links.size
            linkList{end+1}=links.at(lk);%#ok<*AGROW>
        end
        for lk=1:length(linkList)
            link=linkList{lk};
            link.data.destroy;
            link.destroy;
        end
    end
end


