




function name=getNameFromCvId(cvid)

    try
        handle=cv('get',cvid,'.handle');
        name='';
        if(handle~=0)
            if cv('get',cvid,'.isa')==cv('get','default','modelcov.isa')||...
                cv('get',cvid,'.origin')==1
                name=get_param(handle,'Name');
            elseif cv('get',cvid,'.origin')==2
                sfid=handle;
                if(sf('get',sfid,'.isa')==sf('get','default','transition.isa'))||...
                    (sf('get',sfid,'.type')==3)
                    name=sf('get',sfid,'.labelString');
                elseif sf('Private','is_eml_fcn',sfid)
                    name=sf('get',sf('get',sfid,'.chart'),'.eml.name');
                elseif sf('Private','is_truth_table_fcn',sfid)
                    chartId=sf('get',sfid,'.chart');
                    if sf('Private','is_truth_table_chart',chartId)
                        sfid=chartId;
                    end
                    name=sf('get',sfid,'.name');
                else
                    name=sf('get',sfid,'.name');
                end
            end
        end
        if isempty(name)

            if cv('get',cvid,'.isa')==0
                name=SlCov.CoverageAPI.getModelcovName(cvid);
            else
                name=cv('GetSlsfName',cvid);
            end
        end
    catch MEx
        rethrow(MEx);
    end










