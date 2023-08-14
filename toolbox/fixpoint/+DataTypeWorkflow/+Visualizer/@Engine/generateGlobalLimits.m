function generateGlobalLimits(this)




    if~isempty(this.TableData)
        allYLimits=[this.YLimits{:}];
        this.GlobalYLimits=[min(allYLimits),max(allYLimits)];

        this.computeYLimitsForVisualization();
    end
end
