








function aggregateResults(this,varargin)



    if this.MultiMode
        if~isempty(varargin)
            compIDs=varargin{1};


            [compIDs,results]=this.TaskManager.aggregateResults(compIDs);
        else

            [compIDs,results]=this.TaskManager.aggregateResults();
        end



        for n=1:length(compIDs)
            this.ComponentManager.setProperty(compIDs{n},'NumFailures',results{n}(1));
            this.ComponentManager.setProperty(compIDs{n},'NumWarnings',results{n}(2));
        end
    end
end