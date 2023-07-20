function fig=compositeplot(h,defaulttag)





    if isempty(get(h,'S_Parameters'))&&~hasnoisereference(h)...
        &&~haspowerreference(h)
        if isempty(h.Block)
            errHole=sprintf('%s:',h.Name);
        else
            errHole='This block';
        end
        error(message('rfblks:rfbbequiv:data:compositeplot:EmptyData',...
        errHole));
    end


    set(h,'CompositePlot',true,'NeedReset',false);


    if isempty(defaulttag)
        fig=figure('NumberTitle','off','Name',h.Block);
    else
        fig=findobj('Tag',defaulttag);
        if isempty(fig)
            fig=figure('NumberTitle','off','Name',h.Block);
        end
        fig=fig(1);
        figure(fig);
        clf;
    end
    info=datainfo(h);

    switch info
    case 'All Data'
        subplot(2,2,1);plot(h,'S12','S21','db');legend('hide')
        subplot(2,2,2);polar(h,'S11','S22');legend('hide')
        subplot(2,2,3);plot(h,'Pout','dBm');legend('hide')
        subplot(2,2,4);smith(h,'S11','S22','z');legend('hide')
    case 'Power Data with Network Parameters'
        subplot(2,2,1);plot(h,'S12','S21','db');legend('hide')
        subplot(2,2,2);polar(h,'S11','S22');legend('hide')
        subplot(2,2,3);plot(h,'Pout','dBm');legend('hide')
        subplot(2,2,4);smith(h,'S11','S22','z');legend('hide')
    case 'Power Data with Noise Data'
        subplot(2,1,1);plot(h,'Pout','dBm');legend('hide')
        subplot(2,1,2);plot(h,'Phase','Angle (degrees)');legend('hide')
    case 'Network Parameters With Noise Data'
        subplot(2,2,1);plot(h,'S12','S21','db');legend('hide')
        subplot(2,2,2);polar(h,'S11','S22');legend('hide')
        subplot(2,2,3);plot(h,'S12','S21','Angle (degrees)');legend('hide')
        subplot(2,2,4);smith(h,'S11','S22','z');legend('hide')
    case 'Power Data Only'
        subplot(2,1,1);plot(h,'Pout','dBm');legend('hide')
        subplot(2,1,2);plot(h,'Phase','Angle (degrees)');legend('hide')
    case 'Network Parameters Only'
        subplot(2,2,1);plot(h,'S12','S21','db');legend('hide')
        subplot(2,2,2);polar(h,'S11','S22');legend('hide')
        subplot(2,2,3);plot(h,'S12','S21','Angle (degrees)');legend('hide')
        subplot(2,2,4);smith(h,'S11','S22','z');legend('hide')
    case 'Noise Data Only'
        subplot(2,1,1);plot(h,'FMIN','dB');legend('hide')
        subplot(2,1,2);plot(h,'GAMMAOPT','Angle (degrees)');legend('hide')
    end


    name=get(fig,'Name');
    if isempty(name)||~ishold
        name=h.Block;
    end
    if~isempty(name)
        set(fig,'Name',name);
    else
        set(fig,'Name',gcb);
    end


    set(h,'CompositePlot',false,'NeedReset',true);