function deletetree(this)






    this.detach;


    if isa(this.MAObj,'Simulink.ModelAdvisor')
        IDCellArray=getAllChildrenID(this);
        newConfigUICellArray={};
        ConfigUICellArray=this.MAObj.ConfigUICellArray;
        for i=1:length(ConfigUICellArray)
            if~ismember(ConfigUICellArray{i}.ID,IDCellArray)
                newConfigUICellArray{end+1}=ConfigUICellArray{i};%#ok<AGROW>
            else


            end
        end
        this.MAObj.ConfigUICellArray=newConfigUICellArray;
        this.delete;
    end

    function ID=getAllChildrenID(this)
        ID={this.ID};
        for i=1:length(this.ChildrenObj)
            ID=[ID,getAllChildrenID(this.ChildrenObj{i})];%#ok<AGROW>
        end
