function click=getClickType(hFig)






















    clickType=get(hFig,'SelectionType');

    switch clickType

    case 'normal'
        altPressed=strcmp(get(hFig,'CurrentModifier'),'alt');
        if isempty(altPressed)
            click='left';
        else
            click='alt';
        end

    case 'alt'
        ctrlPressed=strcmp(get(hFig,'CurrentModifier'),'control');
        if isempty(ctrlPressed)
            click='right';
        else
            click='ctrl';
        end

    case 'extend'
        shiftPressed=strcmp(get(hFig,'CurrentModifier'),'shift');
        if isempty(shiftPressed)
            click='middle';
        else
            click='shift';
        end

    case 'open'
        click='double';

    end

end