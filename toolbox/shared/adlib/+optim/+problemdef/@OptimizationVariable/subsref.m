function varargout=subsref(obj,sub)










    try
        switch sub(1).type
        case '()'
            [varargout{1:nargout}]=subsrefParens(obj,sub);
        case '.'
            [varargout{1:nargout}]=subsrefDot(obj,sub);
        otherwise
            [varargout{1:nargout}]=builtin('subsref',obj,sub);
        end
    catch E
        throwAsCaller(E);
    end

end

function varargout=subsrefParens(obj,sub)

    if isscalar(sub)

        out=optim.problemdef.OptimizationVariable;
        out=createSubset(out,obj,sub(1));
        [varargout{1:nargout}]=out;

    elseif strcmp(sub(2).type,'.')

        ptyname=sub(2).subs;


        optim.internal.problemdef.checkPublicPropertyOrMethod(obj,ptyname,...
        optim.problemdef.OptimizationVariable.getPublicPropertiesAndSupportedHiddenMethods);

        if numel(sub)<3

            if any(strcmp(ptyname,{'LowerBound','UpperBound'}))

                [varargout{1:nargout}]=getSubsrefBounds(obj,sub(1),ptyname);

            elseif strcmp(ptyname,'IndexNames')

                [varargout{1:nargout}]=getSubsrefIndexNames(obj,sub(1));

            else

                temp=subsref(obj,sub(1));
                [varargout{1:nargout}]=builtin('subsref',temp,sub(2));
            end

        else

            if any(strcmp(ptyname,{'LowerBound','UpperBound'}))

                out=getSubsrefBounds(obj,sub(1),ptyname,sub(3));
                if numel(sub)>3
                    [varargout{1:nargout}]=builtin('subsref',out,sub(4:end));
                else
                    [varargout{1:nargout}]=out;
                end
            elseif strcmp(ptyname,'IndexNames')

                out=getSubsrefIndexNames(obj,sub(1));
                [varargout{1:nargout}]=builtin('subsref',out,sub(3:end));
            else
                temp=subsref(obj,sub(1));
                [varargout{1:nargout}]=subsref(temp,sub(2:end));
            end

        end
    else
        temp=subsref(obj,sub(1));
        [varargout{1:nargout}]=subsref(temp,sub(2:end));
    end
end

function varargout=subsrefDot(obj,sub)


    optim.internal.problemdef.checkPublicPropertyOrMethod(obj,sub(1).subs,...
    optim.problemdef.OptimizationVariable.getPublicPropertiesAndSupportedHiddenMethods);

    if numel(sub)>1&&strcmp(sub(2).type,'()')&&any(strcmp(sub(1).subs,{'LowerBound','UpperBound'}))


        if numel(sub)<3
            [varargout{1:nargout}]=getSubsrefBounds(obj,sub(2),sub(1).subs);
        else
            [varargout{1:nargout}]=getSubsrefBounds(obj,sub(2),sub(1).subs,sub(3:end));
        end
    else
        [varargout{1:nargout}]=builtin('subsref',obj,sub);
    end
end

function out=getSubsrefBounds(obj,sub1,ptyname,sub2)






    objSize=size(obj);
    objIdxNames=getIndexNames(obj);


    [out1Size,linIdx1,out1IdxNames]=optim.internal.problemdef.indexing.getSubsrefOutputs(sub1,objSize,objIdxNames);


    sub1.subs={linIdx1};
    out=builtin('subsref',obj.(ptyname),sub1);
    out=reshape(out,out1Size);


    if nargin>3

        tempIdxNames=optim.internal.problemdef.makeValidIndexNames(...
        out1IdxNames,out1Size);



        sub2=optim.internal.problemdef.indexing.convertStringToNumericIdx(sub2,out1Size,tempIdxNames);


        out=builtin('subsref',out,sub2);
    end
end

function out=getSubsrefIndexNames(obj,sub1,sub2)






    objSize=size(obj);
    objIdxNames=getIndexNames(obj);


    [~,~,newIdxNames]=optim.internal.problemdef.indexing.getSubsrefOutputs(sub1,objSize,objIdxNames);


    out=optim.internal.problemdef.makeValidIndexNames(newIdxNames,objSize);


    if nargin>2

        out=builtin('subsref',out,sub2);
    end
end
