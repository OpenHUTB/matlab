function index=getActiveTab(this)





    compList=this.getSubComponentList;
    currentTab=this.SelectedTab;

    index=find(strcmp({compList.TabName},currentTab));

    if isempty(index)



        index=0;
    else


        if length(index)>1
            pm_error('physmod:simscape:simscape:SSC:SimscapeCC:getActiveTab:RepeatedProductEntries',...
            currentTab,this.getComponentName);
            index=1;
        end


        index=index-1;
    end

