function[sfObjs,SFCharts]=sfFindSys(system,FollowLinks,LookUnderMasks,sfFindArgs,filterCommented)
































    if nargin<5
        filterCommented=false;
    end


    sfObjs=[];
    rt=sfroot;



    SFCharts=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'Regexp','on','FollowLinks',FollowLinks,'LookUnderMasks',LookUnderMasks,'SFBlockType','(MATLAB Function|Chart|State Transition Table)');


    SFChartsFilterd=FilterSFCharts(SFCharts,FollowLinks,LookUnderMasks);


    SFCharts=cellfun(@(x)rt.idToHandle(sf('Private','block2chart',x)),SFCharts,'UniformOutput',false);


    if~isempty(SFChartsFilterd)

        sfChartObjs=cellfun(@(x)rt.idToHandle(sf('Private','block2chart',x)),SFChartsFilterd,'UniformOutput',false);


        sfChartObjs=sfChartObjs(cellfun(@(x)~isempty(x),sfChartObjs));
        if~isempty(sfChartObjs)
            sfObjs=cellfun(@(x)find(x,sfFindArgs),sfChartObjs,'UniformOutput',false);

            sfObjs=vertcat(cellfun(@(x)num2cell(x),sfObjs,'UniformOutput',false));
            sfObjs=vertcat(sfObjs{:});
        end
    end
    sfObjs=FilterCommentedObjects(sfObjs,filterCommented);
    if~isempty(sfObjs)

        [~,u_ind,~]=unique(cellfun(@(x)x.Id,sfObjs));
        sfObjs=sfObjs(u_ind);
    end
end


function sfObjs=FilterCommentedObjects(sfObjs,filterCommented)


    Flags=true(1,length(sfObjs));
    for i=1:length(sfObjs)
        if filterCommented&&~isa(sfObjs{i},'Stateflow.Chart')&&ismethod(sfObjs{i},'isCommented')&&sfObjs{i}.isCommented
            Flags(i)=false;
        end
    end
    sfObjs=sfObjs(Flags);
end


function charts=FilterSFCharts(charts,followLinks,lookUnderMask)

    switch lookUnderMask
    case 'none'
        charts=charts(hasMask(charts)==0);
    case 'graphical'
        charts=charts(hasMask(charts)~=2);
    case 'functional'
        charts=charts(hasMask(charts)~=1);
    end

    if strcmp(followLinks,'off')


        charts=charts(cellfun(@(x)~x.isLinked,get_param(charts,'object')));
    end
end

function res=hasMask(charts)
    res=zeros(1,length(charts));
    for i=1:length(charts)
        if Stateflow.SLUtils.isChildOfStateflowBlock(get_param(charts{i},'Handle'))
            res(i)=0;
        else
            res(i)=hasmask(charts{i});
        end
    end
end
