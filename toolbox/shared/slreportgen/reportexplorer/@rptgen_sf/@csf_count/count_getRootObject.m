function rootObj=count_getRootObject(~)




    adSF=rptgen_sf.appdata_sf;
    [rootObj,objType]=getContextObject(adSF);%#ok<NASGU>











    if~isempty(rootObj)
        charts=find(rootObj,'-isa','Stateflow.Chart');
        if isempty(charts)
            rootObj={};
        end
    end

