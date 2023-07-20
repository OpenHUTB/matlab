function title=utilTaskTitle(order,titleStr,taskLvlOne,taskLvlTwo,taskLvlThree)




    if(order)
        if nargin<4
            title=sprintf('%d. %s',taskLvlOne,titleStr);
        elseif nargin<5
            title=sprintf('%d.%d. %s',taskLvlOne,taskLvlTwo,titleStr);
        else
            title=sprintf('%d.%d.%d. %s',taskLvlOne,taskLvlTwo,taskLvlThree,titleStr);
        end
    else
        title=titleStr;
    end
