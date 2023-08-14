function param_struct=HtoIL_cellToStruct(collected_params)





    for i=1:length(collected_params)

        collected_params(i).base=extractBefore([collected_params(i).base,'%'],'%');
        param_struct.(collected_params(i).name)=collected_params(i);
    end


end