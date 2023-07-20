function ccList=getSubComponentList(this)













    persistent fCCList;

    if isempty(fCCList)









        configData=SimscapeCC_config;
        theList=configData.SubComponents;
        for j=1:length(theList)
            theList(j).TabName=pm_message(theList(j).TabName_msgid);
            theList(j).TreeName=pm_message(theList(j).TreeName_msgid);
        end





        removeList=[];
        for i=1:length(theList)



            if isempty(dir(which(theList(i).ExistsFcn)))
                removeList(end+1)=i;
            end
        end
        theList(removeList)=[];







        fCCList=theList;

    end

    ccList=fCCList;


