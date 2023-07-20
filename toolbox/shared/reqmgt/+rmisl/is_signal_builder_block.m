function result=is_signal_builder_block(obj)



    if isempty(obj)
        result=false;
        return;
    end

    if length(obj)>1&&isa(obj,'double')

        sigbH=find_system(obj,'SearchDepth',0,'MaskType','Sigbuilder block');
        [~,idx1,~]=intersect(obj,sigbH);
        result=false(1,length(obj));
        result(idx1)=true;

    else
        obj=convertStringsToChars(obj);
        try
            switch class(obj)
            case{'char','double'}
                result=strcmp(get_param(obj,'Type'),'block')...
                &&strcmp(get_param(obj,'MaskType'),'Sigbuilder block');
            otherwise
                result=strcmp(obj.Type,'block')...
                &&strcmp(obj.MaskType,'Sigbuilder block');
            end
        catch Mex %#ok<NASGU>
            result=false;
        end
    end