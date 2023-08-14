function varargout=generate_outputs(BlockInfoCache,input)



    if ischar(input)
        varargout{1}=BlockInfoCache.(input);
    elseif iscell(input)
        outputs={};
        for idx=1:length(input)
            if ischar(input{idx})
                outputs{end+1}=BlockInfoCache.(input{idx});
            end
        end
        varargout{1}=outputs;
    end


