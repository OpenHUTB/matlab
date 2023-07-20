function addComponentParameters(obj,comp)





    maps={'EnglishNameMap','ParentGroupMap',...
    'WidgetGroupMap','GroupObjectMap'};

    for i=1:length(maps)
        loc_mergeMap(obj.(maps{i}),comp.(maps{i}),i==4);
    end

    obj.TopLevelPanes=[obj.TopLevelPanes,comp.TopLevelPanes];
    obj.FeatureSet=[obj.FeatureSet,comp.FeatureSet];
end

function loc_mergeMap(dest,source,skipTopPanes)
    k=source.keys;
    for i=1:length(k)
        if skipTopPanes




            g=source(k{i});
            if strcmp(g.Type,'pane')&&length(g.Children)==1&&...
                strcmp(g.Children{1}.Type,'pane')
                continue;
            end
        end
        if~dest.isKey(k{i})
            dest(k{i})=source(k{i});
        end
    end
end


