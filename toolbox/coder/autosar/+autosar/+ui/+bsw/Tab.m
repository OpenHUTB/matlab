classdef(Abstract)Tab




    methods(Abstract)
        text=getTab(h)
    end

    methods(Sealed,Static,Access=protected)
        function isDem=isDem(h)
            bswCompPath=getfullname(h.getBlock().Handle);
            isDem=strcmp(autosar.bsw.ServiceComponent.getBswCompType(bswCompPath),'Dem');
        end
    end
end
