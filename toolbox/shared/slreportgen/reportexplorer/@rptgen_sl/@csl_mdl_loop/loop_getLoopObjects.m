function hList=loop_getLoopObjects(this)







    hList={};
    allOpt=this.LoopList;
    for i=1:length(allOpt)
        hList=[hList;allOpt(i).getModelNames];%#ok
    end


    [~,i]=unique(hList,'first');
    hList=hList(sort(i));
