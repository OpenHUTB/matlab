function varargout=plot(psObj)























    h.Figure=figure(...
    'Name','Pulse Sequence',...
    'NumberTitle','off',...
    'WindowStyle','docked');


    h.Axes(1)=subplot(5,1,1:3);
    h.Axes(2)=subplot(5,1,4);
    h.Axes(3)=subplot(5,1,5);

    for idx=1:numel(h.Axes)
        hold(h.Axes(idx),'on')
    end



    for idx=1:numel(psObj)


        h.Line(1,idx)=plot(h.Axes(1),psObj(idx).Time/3600,psObj(idx).Voltage);


        h.Line(2,idx)=plot(h.Axes(2),psObj(idx).Time/3600,psObj(idx).Current);


        h.Line(3,idx)=plot(h.Axes(3),psObj(idx).Time/3600,psObj(idx).SOC);

    end





    ylabel(h.Axes(1),'Voltage')
    ylabel(h.Axes(2),'Current (A)')
    ylabel(h.Axes(3),'SOC')

    xlabel(h.Axes(end),'Time (hours)')


    linkaxes(h.Axes,'x');


    for idx=1:numel(h.Axes)


        axis(h.Axes(idx),'tight')


        grid(h.Axes(idx),'on')

    end


    if numel(psObj)>1

        mObj=[psObj.MetaData];
        Names={mObj.Name};
        legend(h.Axes(1),Names,'Location','best','Interpreter','none')
    else
        title(h.Axes(1),psObj.MetaData.Name,'Interpreter','none');
    end



    if nargout
        varargout{1}=h;
    end