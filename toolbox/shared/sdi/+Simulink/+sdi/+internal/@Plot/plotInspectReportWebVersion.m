function plotInspectReportWebVersion(this,hFig)




    if Simulink.sdi.WebClient.appIsConnected('sdi')
        createPlotFromClient(hFig);
    else
        createPlotNoClient(this,hFig);
    end
end


function createPlotFromClient(hFig)
    Simulink.sdi.snapshot('figure',hFig);



    MAX_WIDTH=800;
    MAX_HEIGHT=600;
    FIXED_SCALE_FACTOR=0.8;
    pos=hFig.Position;
    if pos(3)>MAX_WIDTH||pos(4)>MAX_HEIGHT
        pos(3)=pos(3)*FIXED_SCALE_FACTOR;
        pos(4)=pos(4)*FIXED_SCALE_FACTOR;
    end
    if pos(4)>MAX_HEIGHT
        pos(3)=pos(3)*FIXED_SCALE_FACTOR;
        pos(4)=pos(4)*FIXED_SCALE_FACTOR;
    end
    hFig.Position=pos;
end


function createPlotNoClient(~,hFig)


    opts=Simulink.sdi.CustomSnapshot();
    opts.Width=800;
    opts.Height=600;


    MAX_ROWS=8;
    MAX_COLS=8;
    sigIDs=Simulink.sdi.Instance.engine.getAllCheckedSignals();
    numSigs=length(sigIDs);
    if numSigs&&numSigs<=MAX_ROWS
        opts.Rows=numSigs;
    elseif numSigs
        opts.Rows=MAX_ROWS;
        numCols=ceil(numSigs/MAX_ROWS);
        if numCols<MAX_COLS
            opts.Columns=numCols;
        else
            opts.Columns=MAX_COLS;
        end
    end


    row=1;
    col=1;
    for idx=1:numSigs
        opts.plotOnSubPlot(row,col,sigIDs(idx));
        row=row+1;
        if row>MAX_ROWS
            row=1;
            col=col+1;
            if col>MAX_COLS
                col=1;
            end
        end
    end


    opts.snapshot('figure',hFig);
end


