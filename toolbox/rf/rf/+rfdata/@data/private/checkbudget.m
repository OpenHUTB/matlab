function checkbudget(h,input,freq_cell,power_cell)




    ninput=numel(input);
    paramslist=listparam(h,'budget');
    for ii=1:2:ninput-2
        if~any(strcmpi(input{ii},paramslist));
            error(message('rf:rfdata:data:checkbudget:InValidParamForBudget',input{ii}))
        end
    end
    xtype=xcategory(h,input{end-1});
    if~strcmpi(xtype,'Frequency')
        error(message('rf:rfdata:data:checkbudget:InValidXParamForBudget',input{ii}))
    end
    if~isempty(freq_cell)&&~isempty(freq_cell{1})
        error(message('rf:rfdata:data:checkbudget:VectorFreqNotAllowedForBudget'))
    end
    if~isempty(power_cell)&&~isempty(power_cell{1})
        id=sprintf('rf:%s:checkbudget:VectorPowerNotAllowedForBudget',strrep(class(h),'.',':'));
        error(message('rf:rfdata:data:checkbudget:VectorPowerNotAllowedForBudget'))
    end