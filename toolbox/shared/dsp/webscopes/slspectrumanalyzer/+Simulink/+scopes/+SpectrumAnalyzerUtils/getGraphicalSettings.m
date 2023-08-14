function graphical=getGraphicalSettings(blk)




    graphical=strrep(get_param(blk,'GraphicalSettings'),'''','"');

    graphical=jsondecode(graphical);
    if isfield(graphical,'GraphicalSettings')
        graphical=graphical.GraphicalSettings;
    end
end