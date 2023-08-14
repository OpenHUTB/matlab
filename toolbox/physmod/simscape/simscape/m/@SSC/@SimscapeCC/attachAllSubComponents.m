function attachAllSubComponents(this,doIncrementally)




    if nargin<2
        doIncrementally=false;
    end

    if~doIncrementally

        this.detachAllSubComponents;
    end


    subCCs=this.getSubComponentList;
    for ccInfo=subCCs

        if~strcmp(ccInfo.ProductName,this.getComponentName)&&...
            (~doIncrementally||isempty(this.getComponent(ccInfo.ProductName)))


            try
                eval(['subCC = ',ccInfo.CustomComponent,';']);
            catch
                pm_error('physmod:simscape:simscape:SSC:SimscapeCC:attachAllSubComponents:GenericInstantiationFailure',...
                ccInfo.TabName);
            end

            this.attachComponent(subCC);

        end

    end


    this.ComponentsAttached=true;

