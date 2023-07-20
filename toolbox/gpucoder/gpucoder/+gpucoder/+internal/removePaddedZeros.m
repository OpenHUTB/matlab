function[top,bottom,left,right]=removePaddedZeros(mask)




















    if isempty(mask)
        top=0;
        bottom=0;
        left=0;
        right=0;
        return;
    end


    anchorPoint=floor((size(mask)+1)/2);


    for i=1:anchorPoint(1)
        if sum(mask(i,:))~=0
            break;
        end
    end
    top=i-1;


    for i=1:anchorPoint(2)
        if sum(mask(:,i))~=0
            break;
        end
    end
    left=i-1;


    for i=size(mask,1):-1:anchorPoint(1)
        if sum(mask(i,:))~=0
            break;
        end
    end
    bottom=size(mask,1)-i;


    for i=size(mask,2):-1:anchorPoint(2)
        if sum(mask(:,i))~=0
            break;
        end
    end
    right=size(mask,2)-i;
