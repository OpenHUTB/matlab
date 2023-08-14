function diffs=vardiff(fcn1,fcn2,subsref1,subsref2)












    var1_org=eval(fcn1);
    var2_org=eval(fcn2);



    var1=var1_org;
    var2=var2_org;



    if nargin>2&&~isempty(subsref1)
        [var1,subsref1]=i_do_subsref(var1,subsref1);
    end
    if nargin>3&&~isempty(subsref2)
        [var2,subsref2]=i_do_subsref(var2,subsref2);
    end

    diffs=i_vardiff(var1,var2);

    s1=i_get_summaries({var1});
    diffs.setValueSummary1(s1{1});
    s2=i_get_summaries({var2});
    diffs.setValueSummary2(s2{1});
    if nargin>2&&~isempty(subsref1)
        diffs.setSubsref1(subsref1);
    end
    if nargin>3&&~isempty(subsref2)
        diffs.setSubsref2(subsref2);
    end

end


function diffs=i_vardiff(var1,var2)

    if isnumeric(var1)&&isnumeric(var2)
        if numel(size(var1))>2||numel(size(var2))>2


            c1=i_multidimensional_to_cell(var1);
            c2=i_multidimensional_to_cell(var2);
            diffs=i_do_cell(c1,c2);
        elseif~isreal(var1)||~isreal(var2)



            diffs=i_do_cell(num2cell(var1),num2cell(var2),true);
        else
            try
                diffs=com.mathworks.comparisons.decorator.variable.VariableDifferences.createNumericDiffs(var1,var2);
            catch E %#ok<NASGU>
                if canTreatAsStruct(var1)&&canTreatAsStruct(var2)
                    diffs=i_do_struct(var1,var2);
                else
                    diffs=createUnrelatedDiffs();
                end
            end
        end
    elseif islogical(var1)&&islogical(var2)
        if numel(size(var1))>2||numel(size(var2))>2


            c1=i_multidimensional_to_cell(var1);
            c2=i_multidimensional_to_cell(var2);
            diffs=i_do_cell(c1,c2);
        else
            diffs=com.mathworks.comparisons.decorator.variable.VariableDifferences.createLogicalDiffs(double(var1),double(var2));
        end
    elseif(ischar(var1)||(isstring(var1)&&isscalar(var1)))&&...
        (ischar(var2)||(isstring(var2)&&isscalar(var2)))
        [str1,str2]=stringdiff(var1,var2);
        diffs=com.mathworks.comparisons.decorator.variable.VariableDifferences.createStringDiffs(str1,str2);
    elseif iscell(var1)&&iscell(var2)
        if numel(size(var1))>2||numel(size(var2))>2

            c1=i_multidimensional_to_cell(var1);
            c2=i_multidimensional_to_cell(var2);
            diffs=i_do_cell(c1,c2);
        else
            diffs=i_do_cell(var1,var2);
        end
    elseif numel(var1)>1||numel(var2)>1


        if numel(size(var1))>2||numel(size(var2))>2

            diffs=i_do_cell(i_multidimensional_to_cell(var1),i_multidimensional_to_cell(var2));
        else
            diffs=i_do_cell(convertToCell(var1),convertToCell(var2));
        end
    elseif canTreatAsStruct(var1)&&canTreatAsStruct(var2)

        diffs=i_do_struct(var1,var2);
    else

        diffs=createUnrelatedDiffs();
    end
end


function result=convertToCell(var)
    if istable(var)||istimetable(var)
        result=table2cell(var);
    else
        result=num2cell(var);
    end
end


function result=canTreatAsStruct(var)
    result=isstruct(var)||isobject(var)||isa(var,'handle.handle');
end


function diff=createUnrelatedDiffs()
    diff=com.mathworks.comparisons.decorator.variable.VariableDifferences.createUnrelatedDiffs();
end



function diffs=i_do_cell(var1,var2,complex_numbers)
    if nargin<3
        complex_numbers=false;
    end
    s1=size(var1);
    s2=size(var2);
    h=false(min(s1(1),s2(1)),min(s1(2),s2(2)));
    d1=i_get_summaries(var1);
    d2=i_get_summaries(var2);

    rd1=i_summaries_to_java_2d(d1);
    rd2=i_summaries_to_java_2d(d2);
    for i=1:size(h,1)
        for j=1:size(h,2)
            h(i,j)=~strcmp(comparisons.internal.variablesEqual(var1{i,j},var2{i,j}),'yes');
        end
    end
    if~complex_numbers
        diffs=com.mathworks.comparisons.decorator.variable.VariableDifferences.createNonNumericDiffs(rd1,rd2,h);
    else
        diffs=com.mathworks.comparisons.decorator.variable.VariableDifferences.createComplexNumericDiffs(rd1,rd2,h);
    end
end



function diffs=i_do_struct(var1,var2)
    is_structs=isstruct(var1)&&isstruct(var2);
    if~is_structs





        w=warning('off','MATLAB:structOnObject');
        reset_warnings=onCleanup(@()warning(w));
        try
            var1=struct(var1);
        catch E %#ok<NASGU>
        end
        try
            var2=struct(var2);
        catch E %#ok<NASGU>
        end
        delete(reset_warnings);
    end


    fieldnames1=fieldnames(var1);
    fieldnames2=fieldnames(var2);


    [fieldvalues1,isvalid1]=i_get_field_values(var1,fieldnames1);
    [fieldvalues2,isvalid2]=i_get_field_values(var2,fieldnames2);


    descriptions1=cell(size(fieldvalues1));
    descriptions1(isvalid1)=i_get_summaries(fieldvalues1(isvalid1));
    descriptions1(~isvalid1)=i_invalid;
    descriptions2=cell(size(fieldvalues2));
    descriptions2(isvalid2)=i_get_summaries(fieldvalues2(isvalid2));
    descriptions2(~isvalid2)=i_invalid;

    allfields=unique([fieldnames1(:);fieldnames2(:)]);

    [~,i]=ismember(fieldnames1,allfields);
    d1=cell(size(allfields));
    d1(i)=descriptions1;

    [~,j]=ismember(fieldnames2,allfields);
    d2=cell(size(allfields));
    d2(j)=descriptions2;


    diffs=false(size(allfields));
    added_or_removed=false(size(allfields));
    for k=1:numel(allfields)
        both_sides=true;
        if isempty(d1{k})



            d1{k}=i_empty;
            both_sides=false;
        end
        if isempty(d2{k})



            d2{k}=i_empty;
            both_sides=false;
        end
        if both_sides
            comp=comparisons.internal.variablesEqual(var1.(allfields{k}),var2.(allfields{k}));
            diffs(k)=~strcmp(comp,'yes');
        else
            added_or_removed(k)=true;
        end
    end



    if~any(diffs)&&~any(added_or_removed)&&...
        ~strcmp(comparisons.internal.variablesEqual(var1,var2),'yes')
        allfields{end+1}=comparisons.internal.message('message','comparisons:comparisons:VarDiffPrivateData');
        d1{end+1}=i_invalid;
        d2{end+1}=i_invalid;
        diffs(end+1)=true;
    end

    d1=i_summaries_to_java_1d(d1);
    d2=i_summaries_to_java_1d(d2);
    if is_structs
        diffs=com.mathworks.comparisons.decorator.variable.VariableDifferences.createStructDiffs(allfields,d1,d2,diffs);
    else
        diffs=com.mathworks.comparisons.decorator.variable.VariableDifferences.createObjectDiffs(allfields,d1,d2,diffs);
    end
end


function[fieldvalues,isvalid]=i_get_field_values(var,fieldnames)
    if isobject(var)



        fieldvalues=cell(size(fieldnames));
        isvalid=true(size(fieldvalues));
        for i=1:numel(fieldnames)
            try
                fieldvalues{i}=var.(fieldnames{i});
            catch E
                fieldvalues{i}=['??? ',E.message];
                isvalid(i)=false;
            end
        end
    else
        fieldvalues=struct2cell(struct(var));
        isvalid=true(size(fieldvalues));
    end
end


function cells=i_multidimensional_to_cell(var)


    sizes=size(var);
    cells=cell(sizes(1),sizes(2));
    substr=repmat({':'},1,numel(sizes)-2);
    cellsize=sizes(3:end);
    for i=1:size(cells,1)
        for j=1:size(cells,2)
            subcell=[{i,j},substr{:}];


            cells{i,j}=i_reshape(subsref(var,struct('type','()','subs',{subcell})),cellsize);
        end
    end
end





function[var,exp]=i_do_subsref(var,exp)
    if any(exp=='|')

        exp=textscan(exp,'%s','delimiter','|');
        exp=exp{1};
        for i=1:numel(exp)
            [var,exp{i}]=i_do_subsref(var,exp{i});
        end
        exp=[exp{:}];
        return;
    end
    if exp(1)=='.'
        fieldname=exp(2:end);
        if strcmp(fieldname,comparisons.internal.message('message','comparisons:comparisons:VarDiffPrivateData'))



            comparisons.internal.message('error','comparisons:comparisons:VarDiffDataInaccessible');
        end
        try

            var=var.(fieldname);
        catch E
            if strcmp(E.identifier,'MATLAB:class:GetProhibited')

                w=warning('off','MATLAB:structOnObject');
                reset_warnings=onCleanup(@()warning(w));
                try
                    var=struct(var);
                    var=var.(fieldname);
                catch %#ok<CTCH>
                    rethrow(E);
                end
                delete(reset_warnings);
            end
        end
    else



        if iscell(var)
            varsize=size(var);
            if numel(varsize)==2

                exp=['{',exp,',:}'];
                var=eval(['var',exp]);
            else



                exp=['(',exp,',:)'];
                var=i_reshape(eval(['var',exp]),varsize(3:end));
            end
        elseif istable(var)||istimetable(var)
            exp=['{',exp,'}'];
            var=eval(['var',exp]);
        else



            exp=['(',exp,',:)'];
            var=eval(['var',exp]);
        end
        varsize=size(var);
        if numel(varsize)>2&&varsize(1)==1&&varsize(2)==1

            var=i_reshape(var,varsize(3:end));
        end
    end
end



function var=i_reshape(var,newsize)
    if numel(newsize)==1

        newsize=[newsize,1];
    end
    var=reshape(var,newsize);
end


function s=i_invalid
    s=com.mathworks.comparisons.decorator.variable.ValueInfo.getInvalid;
end


function s=i_empty
    s=com.mathworks.comparisons.decorator.variable.ValueInfo.getEmpty;
end





function s=i_get_summaries(var)
    assert(iscell(var));
    if isempty(var)
        s=[];
        return;
    end


    summaries=workspacefunc('getabstractvaluesummariesj',var(:));
    strings=workspacefunc('getshortvalueobjectsj',var(:));


    infoarray=com.mathworks.comparisons.decorator.variable.ValueInfo.summariesToInfo(summaries,strings);
    s=cell(size(var));
    for i=1:numel(s)
        s{i}=infoarray(i);
    end
end



function ret=i_summaries_to_java_2d(s)
    z=size(s);
    if all(z>0)
        ret=javaArray('com.mathworks.comparisons.decorator.variable.ValueInfo[]',z(1));
        for i=1:z(1)
            a=i_summaries_to_java_1d(s(i,:));
            for j=1:z(2)
                a(j)=s{i,j};
            end
            ret(i)=a;
        end
    else
        ret=[];
    end
end



function ret=i_summaries_to_java_1d(s)
    z=numel(s);
    if all(z>0)
        ret=javaArray('com.mathworks.comparisons.decorator.variable.ValueInfo',z);
        for i=1:z
            ret(i)=s{i};
        end
    else
        ret=[];
    end
end
