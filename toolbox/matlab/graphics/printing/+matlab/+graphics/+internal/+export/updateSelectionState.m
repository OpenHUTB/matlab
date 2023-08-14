function pj=updateSelectionState(pj,state)




    switch(state)
    case 'remove'

        pj.temp.PreviousSelection=findall(pj.Handles{1},'Selected','on');
        setSelected(pj.temp.PreviousSelection,'off')
        pj.temp.test.SelectionState='set';
    case 'restore'
        if isfield(pj.temp,'PreviousSelection')
            setSelected(pj.temp.PreviousSelection,'on')
            pj.temp=rmfield(pj.temp,'PreviousSelection');
            pj.temp.test.SelectionState='restore';
        end
    end
end

function setSelected(objs,onoff)
    for i=1:length(objs)
        if isprop(objs(i),'Selected_I')
            set(objs(i),'Selected_I',onoff)
        else
            set(objs(i),'Selected',onoff)
        end
    end
end
