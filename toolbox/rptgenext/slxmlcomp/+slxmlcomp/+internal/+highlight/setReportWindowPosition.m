function success=setReportWindowPosition(report,position)



















    persistent alreadyMoved;

    if isempty(report)
        success=0;
        return
    end


    if ismember(report.hashCode,alreadyMoved)
        success=-1;
        return
    else
        alreadyMoved=[alreadyMoved;report.hashCode];
    end

    desktop=com.mathworks.mde.desk.MLDesktop.getInstanceNoCreate();



    javaMethodEDT('setClientDocked',desktop,report,false);


    rootPane=javaMethodEDT('getRootPane',report);
    frame=javaMethodEDT('getParent',rootPane);

    x=position(1);
    y=position(2);
    width=position(3);
    height=position(4);

    javaMethodEDT('setLocation',frame,x,y);
    javaMethodEDT('setSize',frame,width,height);

    success=1;
end

