function[X,Y]=match_end_points(UD,grpNo)







    sigCnt=UD.sbobj.Groups(1).NumSignals;
    X=cell(1,sigCnt);
    Y=cell(1,sigCnt);


    newEndPoint=UD.sbobj.Groups(grpNo).Signals(1).XData(end);
    for sidx=2:sigCnt
        if(UD.sbobj.Groups(grpNo).Signals(sidx).XData(end)>newEndPoint)
            newEndPoint=UD.sbobj.Groups(grpNo).Signals(sidx).XData(end);
        end
    end
    for sidx=1:sigCnt
        if(UD.sbobj.Groups(grpNo).Signals(sidx).XData(end)~=newEndPoint)
            [X{sidx},Y{sidx}]=update_time_data(UD.sbobj.Groups(grpNo).Signals(sidx).XData(1),...
            UD.sbobj.Groups(grpNo).Signals(sidx).XData(end),...
            UD.common.minTime,...
            newEndPoint,...
            UD.sbobj.Groups(grpNo).Signals(sidx).XData,...
            UD.sbobj.Groups(grpNo).Signals(sidx).YData);
        else
            X{sidx}=UD.sbobj.Groups(grpNo).Signals(sidx).XData;
            Y{sidx}=UD.sbobj.Groups(grpNo).Signals(sidx).YData;
        end
    end
end




