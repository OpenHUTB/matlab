function exploreAction(libCat)






    libCat.Expanded=~libCat.Expanded;

    r=RptgenML.Root;











    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('ListChangedEvent',r.getCurrentComponent);

