function sections=findParentsByLabel(labels)



    sections=cell(length(labels),2);
    sections(1,:)={labels{1},-1};
    for i=2:length(labels)
        thisLabel=labels{i};
        found=false;
        for j=i-1:-1:1
            if~isempty(strfind(thisLabel,labels{j}))
                sections(i,:)={thisLabel,j};
                found=true;
                break;
            end
        end
        if~found
            sections(i,:)={thisLabel,-1};
        end
    end
end
