function y=fieldnames(h)









    y={};
    for i=1:numel(h.prop_sets)
        y=[y;fieldnames(h.prop_sets{i})];
    end


