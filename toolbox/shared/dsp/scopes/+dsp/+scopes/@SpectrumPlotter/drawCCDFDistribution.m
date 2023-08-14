function drawCCDFDistribution(this,distTable)



    lineCount=0;
    hLines=this.Lines;
    this.YExtents=[0.0001,100];
    this.XExtents=[0,18];

    removeSamplesPerUpdateReadOut(this);
    for indx=1:1
        for jndx=1:numel(distTable)
            lineCount=lineCount+1;
            chanDist=distTable{jndx};
            haveData=size(chanDist,1)>1;

            if haveData
                XData=chanDist(:,1);
                YData=chanDist(:,2);
                this.XExtents=[0,max(this.XExtents(2),XData(end))];
                this.YExtents=[min(this.YExtents(1),YData(end-1)),100];
            end
            if lineCount<=numel(hLines)
                if~haveData
                    set(hLines(lineCount),'XData',[],'YData',[]);
                elseif YData(end-1)==100
                    set(hLines(lineCount),'XData',[-0.1,0,0],'YData',[100,100,realmin]);
                else
                    YData(end)=realmin;
                    set(hLines(lineCount),'XData',XData,'YData',YData);
                end
            end
        end
    end
end
