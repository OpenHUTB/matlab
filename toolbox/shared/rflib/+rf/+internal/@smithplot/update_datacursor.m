function update_datacursor(p,datapoint,track,Nd_pre)


    pdata=getAllDatasets(p);
    Nd_post=numel(pdata);
    hline=p.hDataLine;
    for datasetIndex=track
        if~isempty(datapoint)
            if~isempty(datapoint{datasetIndex})&&...
                ~ischar(datapoint{datasetIndex})
                set(hline(datasetIndex),...
                'UserData',datapoint{datasetIndex});
            else
                linesinfo=p.currentlineinfo('','','',[],...
                '','','','','','');
                set(hline(datasetIndex),...
                'UserData',linesinfo);
            end
        end
    end

    for datasetIndex=Nd_pre+1:Nd_post
        if iscell(p.Frequency)
            xdata=cell2mat(p.Frequency(datasetIndex));
        else
            xdata=p.Frequency;
        end
        if isempty(xdata)
            linesinfo=p.currentlineinfo('','','',[],...
            '','','','','','');
            set(hline(datasetIndex),...
            'UserData',linesinfo);
        else
            [xdata,~,U]=engunits(xdata);
            xunit=strcat(U,'Hz');
            linesinfo=p.currentlineinfo('','','Freq',xdata,...
            xunit,'None','','','','');
            set(p.hDataLine(datasetIndex),'UserData',linesinfo);
        end
    end

end