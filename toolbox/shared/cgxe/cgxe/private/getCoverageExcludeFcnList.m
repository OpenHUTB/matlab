function fcnExcludeList=getCoverageExcludeFcnList(sysObjName)
    includeList={'step','stepImpl','output','outputImpl','update','updateImpl'};
    metaObj=meta.class.fromName(sysObjName);
    fcnExcludeList={};
    for i=1:numel(metaObj.SuperclassList)
        if~isempty(regexp(metaObj.SuperclassList(i).Name,'^matlab\.','once'))

            fcnExcludeList=[fcnExcludeList,{metaObj.SuperclassList(i).MethodList.Name}];%#ok<AGROW>
        else
            fcnExcludeList=[fcnExcludeList,getCoverageExcludeFcnList(metaObj.SuperclassList(i).Name)];%#ok<AGROW>
        end
    end
    fcnExcludeList=setdiff(fcnExcludeList,includeList);
end
