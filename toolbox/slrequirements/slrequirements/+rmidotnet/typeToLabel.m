function label=typeToLabel(type,number,parents,isIncluded)





    switch type
    case 'parent'
        children=find(parents==number&isIncluded'>0);
        if~isempty(children)
            if length(children)>3
                children(4:end)=[];
                allnumbers=num2str(children');
                label=['parent for ',strrep(allnumbers,'  ',','),',..'];
            else
                allnumbers=num2str(children');
                label=['parent for ',strrep(allnumbers,'  ',',')];
            end
        else
            label='parent';
        end
    case 'match'
        label='search pattern match:';
    case 'bookmark'
        label='named location in document:';
    otherwise
        label=type;
    end
end
