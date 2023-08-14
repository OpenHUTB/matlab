function Simscape_params=HtoIL_convert_to_simscape_values(params)





    for i=1:length(params)
        base_value=str2num(params(i).base);%#ok<*ST2NM>
        if isempty(base_value)
            Simscape_params.(params(i).name)={params(i).base,params(i).unit};
        else
            Simscape_params.(params(i).name)=simscape.Value(str2num(params(i).base),params(i).unit);
        end
    end

end