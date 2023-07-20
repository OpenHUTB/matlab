function isLocked=isDiagramLocked(this,obj)




    isLocked=strcmp(get_param(pmsl_bdroot(obj.Handle),'Lock'),'on');



