function match_type=variablesEqual(x1,x2)










    match_type='no';
    try
        if sameTypeName(x1,x2)
            if isEqualImpl(x1,x2)
                match_type='yes';
            elseif iscell(x1)


                match_type=i_compare_cell(x1,x2);
            elseif isstruct(x1)




                if isequal(fieldnames(x1),fieldnames(x2))
                    match_type=i_compare_udd(x1,x2);
                end
            elseif isa(x1,'handle.handle')




                match_type=i_compare_udd(x1,x2);
            elseif isa(x1,'function_handle')



                if strcmp(func2str(x1),func2str(x2))
                    match_type='yes';
                end
            end
        else


            if isnumeric(x1)
                if isequaln(x1,x2)
                    match_type='classesdiffer';
                end
            end
        end
    catch E %#ok<NASGU>

        return;
    end
end

function bool=sameTypeName(x,y)
    import comparisons.internal.variableClass;

    xTypeName=variableClass(x);
    yTypeName=variableClass(y);
    bool=strcmp(xTypeName,yTypeName);
end

function bool=isEqualImpl(x,y)


    equalToX=matlab.unittest.constraints.IsEqualTo(x);
    bool=equalToX.satisfiedBy(y);
end

function match_type=i_compare_udd(x1,x2)
    match_type='no';
    if isequal(size(x1),size(x2))
        if numel(x1)==1



            match_type=i_compare_udd_scalar(x1,x2);
        else
            for i=1:numel(x1)
                if~strcmp(i_compare_udd_scalar(x1(i),x2(i)),'yes')

                    return;
                end
            end
            match_type='yes';
        end
    end
end

function match_type=i_compare_cell(x1,x2)
    match_type='no';
    if isequal(size(x1),size(x2))
        for i=1:numel(x1)
            if~strcmp(comparisons.internal.variablesEqual(x1{i},x2{i}),'yes')

                return;
            end
        end
        match_type='yes';
    end
end

function match_type=i_compare_udd_scalar(x1,x2)
    match_type='no';
    s1=struct(x1);
    s2=struct(x2);
    f=fieldnames(s1);




    for k=1:numel(f)
        if~strcmp(comparisons.internal.variablesEqual(s1.(f{k}),s2.(f{k})),'yes')

            return;
        end
    end
    match_type='yes';
end
