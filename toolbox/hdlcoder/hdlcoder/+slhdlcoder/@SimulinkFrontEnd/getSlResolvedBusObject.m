
function busObj=getSlResolvedBusObject(busName,slbh)




    busObj=slResolve(busName,slbh);
    if~isa(busObj,'Simulink.Bus')


        blockParent=get_param(slbh,'parent');
        busObj=slResolve(busName,blockParent,'variable','startAboveMask');
        if~isa(busObj,'Simulink.Bus')

            busObj=slResolve(busName,slbh,'expression','base');
            if~isa(busObj,'Simulink.Bus')

                busObj=[];
            end
        end
    end

end

