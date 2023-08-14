function val=getDisplayIcon(h)




    val=h.userData.displayIcon;
    if isempty(val)&&(isa(h.daobject,'DAStudio.Object')||isa(h.daobject,'Simulink.DABaseObject'))


        chart=SigLogSelector.SFChartNode.getSFChartObject(h.daobject);
        if~isempty(chart)
            val=chart.getDisplayIcon;
            h.userData.displayIcon=val;
        end

    end

end
