function[args,value]=findAndTrimNameValuePair(args,name)





    returnStruct=isstruct(args);
    if returnStruct
        args=namedargs2cell(args);
    end

    idx=find(strcmpi(args,name),1);
    if isempty(idx)
        value=[];
    elseif idx+1>numel(args)
        error(message("MATLAB:narginchk:notEnoughInputs"))
    else
        value=args{idx+1};
        args(idx:idx+1)=[];
    end

    if returnStruct
        args=struct(args{:});
    end
end