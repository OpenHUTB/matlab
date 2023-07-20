function[isChanged,returnTimestamp]=figureChanged(hFigure,clientTimestamp)











    isChanged=true;
    returnTimestamp=-1;


    if ishghandle(hFigure)
        drawnow;
        returnTimestamp=get(hFigure,'UpdateToken');
        isChanged=returnTimestamp~=clientTimestamp;
    end