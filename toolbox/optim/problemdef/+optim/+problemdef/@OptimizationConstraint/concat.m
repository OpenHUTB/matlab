function con=concat(dim,varargin)








    nConArray=length(varargin);




    relation='';
    firstcon=[];
    for i=1:nConArray
        if isa(varargin{i},'optim.problemdef.OptimizationConstraint')



            if~isa(firstcon,'optim.problemdef.OptimizationConstraint')
                firstcon=varargin{i};
            end


            if~isempty(varargin{i}.Relation)
                relation=varargin{i}.Relation;
                break
            end
        end
    end


    expr1=cell(1,nConArray);
    expr2=cell(1,nConArray);
    for i=1:nConArray
        con=varargin{i};
        if isa(con,'optim.problemdef.OptimizationConstraint')
            checkConcat(firstcon,relation,con);
            expr1{i}=con.Expr1;
            expr2{i}=con.Expr2;
        elseif isequal(con,[])

            continue
        else
            messageID="optim_problemdef:"+firstcon.className+":InvalidTypesCat";
            error(message(messageID));
        end
    end


    try
        lhsexpr=cat(dim,expr1{:});
        rhsexpr=cat(dim,expr2{:});
    catch ME
        if strcmp(ME.identifier,'shared_adlib:HashMapFunctions:VariableNameClash')
            [startTag,endTag]=optim.internal.problemdef.createHotlinks(...
            '','ug_no_duplicate_names','normal',true);
            ME=MException(message('shared_adlib:HashMapFunctions:VariableNameClash',...
            firstcon.className,startTag,endTag));
        end
        throwAsCaller(ME);
    end




    firstcon.Relation=relation;




    con=createConstraint(firstcon,...
    lhsexpr,firstcon.Relation,rhsexpr,lhsexpr.IndexNames);