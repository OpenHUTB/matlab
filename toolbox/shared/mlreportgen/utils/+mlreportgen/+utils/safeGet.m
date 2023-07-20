function[result,badIdx]=safeGet(h,propName,varargin)
















    badIdx=[];
    if isempty(varargin)
        varargin={'get'};
    end

    if isempty(h)
        result={};
        return;
    elseif ischar(h)
        h={h};
        subsrefType='{}';
    elseif iscell(h)
        subsrefType='{}';
    else
        subsrefType='()';
    end

    propName=char(propName);

    try
        result=feval(varargin{:},h,propName);
        if length(h)==1&strcmp(subsrefType,'()')
            result={result};
        else
            result=result(:);
        end
    catch
        for i=length(h):-1:1
            try
                result{i,1}=feval(varargin{:},subsref(h,substruct(subsrefType,{i})),propName);
            catch
                badIdx(end+1)=i;
                result{i,1}='N/A';
            end
        end
    end
