





function[time,data,sigNames,grpNames]=groupSignalGetAll(this)

    grpCnt=this.NumGroups;
    sigCnt=this.Groups(this.ActiveGroup).NumSignals;

    if(sigCnt==1&&grpCnt==1)
        time=this.Groups(grpCnt).Signals(sigCnt).XData;
        data=this.Groups(grpCnt).Signals(sigCnt).YData;
    elseif(sigCnt==1)
        time=cell(1,grpCnt);
        data=cell(1,grpCnt);
        for m=1:grpCnt
            time{m}=this.Groups(m).Signals(sigCnt).XData;
            data{m}=this.Groups(m).Signals(sigCnt).YData;
        end
    else
        time=cell(sigCnt,grpCnt);
        data=cell(sigCnt,grpCnt);
        for m=1:sigCnt
            for n=1:grpCnt
                time{m,n}=this.Groups(n).Signals(m).XData;
                data{m,n}=this.Groups(n).Signals(m).YData;
            end
        end
    end

    grpNames=cell(1,grpCnt);
    for i=1:grpCnt
        grpNames{i}=this.Groups(i).Name;
    end
    sigNames={this.Groups(this.ActiveGroup).Signals.Name};
end