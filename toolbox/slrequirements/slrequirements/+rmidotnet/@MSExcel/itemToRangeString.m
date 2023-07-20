function rangeString=itemToRangeString(item,option)

    if~ischar(option)

        first=option(1);
        last=option(end);
        option='cols';
    end

    switch option
    case 'first'
        top=item.address(1);
        bottom=top;
        left=item.address(2);
        right=left;
    case 'last'
        bottom=item.address(1)+item.range(1)-1;
        top=bottom;
        right=item.address(2)+item.range(2)-1;
        left=right;
    case 'cols'
        top=item.address(1);
        bottom=item.address(1)+item.range(1)-1;
        left=first;
        right=last;
    otherwise
        top=item.address(1);
        bottom=item.address(1)+item.range(1)-1;
        left=item.address(2);
        right=item.address(2)+item.range(2)-1;
    end

    rangeString=sprintf('%s%d:%s%d',...
    rmiut.xlsColNumToName(left),top,...
    rmiut.xlsColNumToName(right),bottom);
end
