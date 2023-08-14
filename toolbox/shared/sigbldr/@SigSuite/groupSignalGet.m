






function[time,data,sigNames,grpNames]=groupSignalGet(this,signal,group)

    if(~ischar(signal)&&~isnumeric(signal))||...
        isempty(signal)
        DAStudio.error('Sigbldr:sigsuite:StringOrNumericSignalGroup','SIGNAL');
    end
    if(~ischar(group)&&~isnumeric(group))||...
        isempty(group)
        DAStudio.error('Sigbldr:sigsuite:StringOrNumericSignalGroup','GROUP');
    end


    [signalIdx,groupIdx]=groupSignalIndexCheck(this,signal,group,'SG');

    if(length(signalIdx)==1&&length(groupIdx)==1)
        time=this.Groups(groupIdx).Signals(signalIdx).XData;
        data=this.Groups(groupIdx).Signals(signalIdx).YData;
        sigNames=this.Groups(groupIdx).Signals(signalIdx).Name;
        grpNames=this.Groups(groupIdx).Name;
    else
        sigCnt=length(signalIdx);
        grpCnt=length(groupIdx);
        time=cell(sigCnt,grpCnt);
        data=cell(sigCnt,grpCnt);
        sigNames=cell(sigCnt,grpCnt);
        grpNames=cell(sigCnt,grpCnt);
        for gidx=1:grpCnt
            m=groupIdx(gidx);
            for sidx=1:sigCnt
                n=signalIdx(sidx);


                time(sidx,gidx)={this.Groups(m).Signals(n).XData};
                data(sidx,gidx)={this.Groups(m).Signals(n).YData};
                sigNames(sidx,gidx)={this.Groups(m).Signals(n).Name};
                grpNames(sidx,gidx)={this.Groups(m).Name};
            end
        end
    end
end