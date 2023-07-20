function dialog_param=HtoIL_derive_params(dialog_param_name,math_expression,params,dialog_unit_expression,evaluate)
























    math_expression=strrep(math_expression,' ','');
    math_expression=strrep(math_expression,'++','+');
    math_expression=strrep(math_expression,'--','+');
    math_expression=strrep(math_expression,'+-','-');
    math_expression=strrep(math_expression,'-+','-');


    [terms,operators]=split(math_expression,{'+','-'});
    if isempty(terms{1})

        terms(1)=[];
    end
    if length(operators)<length(terms)

        operators=[{''};operators];
    end



    term_units=get_term_units(params,terms);



    dialog_unit_expression=strrep(dialog_unit_expression,' ','');
    dialog_unit=get_term_units(params,{dialog_unit_expression});
    dialog_param.unit=dialog_unit{1};


    num_terms=length(terms);
    term_cfs=cell(num_terms,1);
    for i=1:length(terms)
        C=simscape.Value(1,term_units{i})/simscape.Value(1,dialog_unit{1});
        cf=value(C,'1');
        if cf==1
            term_cfs{i}='';
        else
            term_cfs{i}=[num2str(cf),'*'];
        end
    end



    for i=1:num_terms
        term=terms{i};
        [term_params,term_operators]=split(term,{'*','/'});
        for j=1:length(term_params)
            if isfield(params,term_params{j})
                term_param_value=params.(term_params{j}).base;
            else
                term_param_value=term_params{j};
            end
            if j==1
                term_with_parenth=['(',term_param_value,')'];
            else
                term_with_parenth=[term_with_parenth,term_operators{j-1},'(',term_param_value,')'];
            end
        end
        terms_with_parenth{i}=term_with_parenth;
    end




    for i=1:num_terms
        if i==1
            dialog_param.base=[operators{i},term_cfs{i},terms_with_parenth{i}];
        else
            dialog_param.base=[dialog_param.base,' ',operators{i},' ',term_cfs{i},terms_with_parenth{i}];
        end
    end



    if evaluate
        dialog_param_numeric_value=str2num(dialog_param.base);
        if~isnan(dialog_param_numeric_value)
            dialog_param.base=num2str(dialog_param_numeric_value);
        else
            evaluate=0;
        end
    end


    if~evaluate

        dialog_param.base=strrep(dialog_param.base,'(1)*','');
        dialog_param.base=strrep(dialog_param.base,'*(1)','');
    end



    conf='runtime';
    [params_in_expression,~]=split(math_expression,{'+','-','*','/'});
    if isempty(params_in_expression{1})

        params_in_expression(1)=[];
    end
    for i=1:length(params_in_expression)

        if isfield(params,params_in_expression{i})&&~strcmp('runtime',params.(params_in_expression{i}).conf)
            conf='compiletime';
        end
    end
    dialog_param.conf=conf;



    dialog_param.name=dialog_param_name;

end



function term_units=get_term_units(params,terms)






    num_terms=length(terms);
    term_units=cell(num_terms,1);
    for i=1:num_terms
        term=terms{i};
        [term_params,term_operator]=split(term,{'*','/'});

        for j=1:length(term_params)

            if isfield(params,term_params{j})
                term_param_unit=simscape.Unit(params.(term_params{j}).unit);
            else
                term_param_unit=simscape.Unit(1);
            end

            if j==1
                term_unit=term_param_unit;
            elseif string(term_operator{j-1})=="*"
                term_unit=term_unit*term_param_unit;
            else
                assert(string(term_operator{j-1})=="/");
                term_unit=term_unit/term_param_unit;
            end
        end
        term_units{i}=char(term_unit);
    end

end
