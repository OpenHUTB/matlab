function sfComponent=getSFComponent_hisl_0070(blocks,opt)

    sfComponent=[];
    SFCharts=blocks(arrayfun(@(x)Advisor.Utils.isSFChart(blocks(x)),(1:length(blocks))));


    SFCharts=Advisor.Utils.Utils_hisl_0070.FilterSFCharts(SFCharts,opt.lookUnderMask,opt.followLinks);
    if~isempty(SFCharts)
        rt=sfroot;
        sfChartObjs=arrayfun(@(x)rt.idToHandle(sfprivate('block2chart',x)),SFCharts,'UniformOutput',false);




        sfFilter=rmisf.sfisa('isaFilter');
        if opt.link2ContainerOnly
            sfObjs=cellfun(@(x)find(x,[sfFilter(1:20),sfFilter(24:end)]),sfChartObjs,'UniformOutput',false);
        else
            sfObjs=cellfun(@(x)find(x,sfFilter),sfChartObjs,'UniformOutput',false);
        end

        sfObjs=vertcat(cellfun(@(x)num2cell(x),sfObjs,'UniformOutput',false));
        sfComponent=vertcat(sfObjs{:});
    end

end