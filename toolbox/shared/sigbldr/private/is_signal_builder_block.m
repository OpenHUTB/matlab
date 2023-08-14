function result=is_signal_builder_block(obj)



    try
        result=~isempty(obj)...
        &&strcmp(get_param(obj,'Type'),'block')...
        &&strcmp(get_param(obj,'MaskType'),'Sigbuilder block');
    catch invalidBlock %#ok<NASGU>
        result=false;
    end
