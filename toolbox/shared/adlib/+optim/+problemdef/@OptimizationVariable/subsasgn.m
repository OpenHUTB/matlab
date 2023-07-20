function obj=subsasgn(obj,sub,val)






    try
        switch sub(1).type
        case '()'
            obj=subsasgnParens(obj,sub,val);
        case '.'
            obj=subsasgnDot(obj,sub,val);
        otherwise

            obj=builtin('subsasgn',obj,sub,val);
        end
    catch E
        throwAsCaller(E);
    end
end

function obj=subsasgnParens(obj,sub,val)
    if isscalar(sub)

        error(message('shared_adlib:OptimizationVariable:CannotAssign','OptimizationVariable'));

    elseif strcmp(sub(2).type,'.')


        ptyname=sub(2).subs;


        optim.internal.problemdef.checkPublicPropertyOrMethod(obj,ptyname,...
        optim.problemdef.OptimizationVariable.getPublicPropertiesAndSupportedHiddenMethods);

        if any(strcmp(ptyname,{'LowerBound','UpperBound'}))
            if numel(sub)<3

                obj=setSubsasgnBounds(obj,sub(1),ptyname,val);
            else

                obj=setSubsasgnBounds(obj,sub(1),ptyname,val,sub(3:end));
            end

        elseif strcmpi(ptyname,'Name')
            error(message('shared_adlib:OptimizationVariable:NameIsReadOnly'));

        elseif strcmpi(ptyname,'Type')
            error(message('shared_adlib:OptimizationVariable:CannotOverwritePartsOfTypeArray'));

        elseif strcmpi(ptyname,'IndexNames')
            error(message('shared_adlib:OptimizationVariable:CannotOverwritePartsOfIndexNamesArray'));

        else



            sub=optim.internal.problemdef.indexing.convertStringToNumericIdx(sub,obj.Size,obj.IndexNames);

            obj=builtin('subsasgn',obj,sub,val);
        end
    else


        sub=optim.internal.problemdef.indexing.convertStringToNumericIdx(sub,obj.Size,obj.IndexNames);

        obj=builtin('subsasgn',obj,sub,val);
    end
end

function obj=subsasgnDot(obj,sub,val)


    optim.internal.problemdef.checkPublicPropertyOrMethod(obj,sub(1).subs,...
    optim.problemdef.OptimizationVariable.getPublicPropertiesAndSupportedHiddenMethods);

    if strcmp(sub(1).subs,'Name')

        error(message('shared_adlib:OptimizationVariable:NameIsReadOnly'));

    elseif numel(sub)>1&&strcmp(sub(2).type,'()')&&any(strcmp(sub(1).subs,{'LowerBound','UpperBound'}))


        if numel(sub)<3
            obj=setSubsasgnBounds(obj,sub(2),sub(1).subs,val);
        else
            obj=setSubsasgnBounds(obj,sub(2),sub(1).subs,val,sub(3:end));
        end

    else

        obj=builtin('subsasgn',obj,sub,val);
    end
end

function obj=setSubsasgnBounds(obj,sub1,ptyname,val,sub2)






    objSize=size(obj);
    objIdxNames=getIndexNames(obj);



    [subrefSize,linIdx,tempIdxNames]=optim.internal.problemdef.indexing.getSubsrefOutputs(sub1,objSize,objIdxNames);


    linearIdxing=numel(sub1(1).subs)==1;


    if nargin>4
        if strcmp(sub2(1).type,'()')



            [subrefSize,linIdx2]=optim.internal.problemdef.indexing.getSubsrefOutputs(sub2,subrefSize,tempIdxNames);


            linIdx=linIdx(linIdx2);


            linearIdxing=numel(sub2(1).subs)==1;
        else

            val=builtin('subsasgn',obj.(ptyname)(linIdx),sub2,val);
        end
    end

    try

        optim.internal.problemdef.indexing.checkValidRHSForSubsasgn(subrefSize,size(val),linearIdxing);
    catch ME
        throwAsCaller(ME);
    end


    obj.(ptyname)(linIdx)=val(:);
end

