function str=get_sf_class(isa,id)






    persistent sfClassNames;
    persistent sfClassIsa;
    persistent sfStateTypes;
    persistent functionTypeIdx;

    if isempty(sfClassNames)
        sfClassIsa=[sf('get','default','machine.isa')...
        ,sf('get','default','chart.isa')...
        ,sf('get','default','state.isa')...
        ,sf('get','default','transition.isa')...
        ,sf('get','default','junction.isa')...
        ,sf('get','default','port.isa')...
        ,sf('get','default','data.isa')...
        ,sf('get','default','event.isa')...
        ,sf('get','default','target.isa')...
        ,sf('get','default','note.isa')...
        ,sf('get','default','script.isa')];

        sfClassNames={'Machine',...
        'Chart',...
        'State',...
        'Transition',...
        'Junction',...
        'Port',...
        'Data',...
        'Event',...
        'Target',...
        'Note',...
        'external eM Function'};

        sfStateTypes={'State','State','Function','Box'};
        functionTypeIdx=find(strcmp(sfStateTypes,'Function'));
    end

    if nargin>1&&isa==sf('get','default','state.isa')&&~isempty(id)
        sfId=cv('get',id,'slsfobj.handle');
        type=sf('get',sfId,'state.type');
        if isempty(type)
            str='State';
        else
            type=type+1;
            str=sfStateTypes{type};

            if type==functionTypeIdx
                if sf('Private','is_truth_table_fcn',sfId)
                    str='Truth Table';
                elseif sf('Private','is_eml_fcn',sfId)
                    str='MATLAB Function';
                end
            end
        end
    elseif isa==-99
        chartId=sfprivate('block2chart',cv('get',id,'slsfobj.handle'));
        if sf('Private','is_eml_chart',chartId)
            str='MATLAB Function';
        elseif sf('Private','is_truth_table_chart',chartId)
            str='Truth Table';
        elseif Stateflow.STT.StateEventTableMan.isStateEventTableChart(chartId)
            str='State Transition Table';
        end
    else
        str=sfClassNames{isa==sfClassIsa};
    end
