function pos=getJavaReportPosition(leftModel,rightModel)




    pos=[];
    if~isempty(leftModel)&&~isempty(rightModel)
        [~,leftModelName,~]=fileparts(leftModel);
        [~,rightModelName,~]=fileparts(rightModel);

        desktop=com.mathworks.mde.desk.MLDesktop.getInstanceNoCreate;
        report=xmlcomp.internal.getReportWindow(leftModelName,rightModelName);
        if~isempty(report)&&~desktop.isClientDocked(report)

            rootpane=awtinvoke(report,'getRootPane()');
            frame=awtinvoke(rootpane,'getParent()');
            size=awtinvoke(frame,'getSize()');
            loc=awtinvoke(frame,'getLocation()');

            pos=double([loc.x,loc.y,size.width,size.height]);
        end
    end
end
