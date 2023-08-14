function result=slBlockType(block)



    type=get_param(block,'Type');
    switch type
    case 'block_diagram'
        result=getString(message('Slvnv:rmi:resolveobj:BlockDiagram'));
    case 'block'
        try
            if slprivate('is_stateflow_based_block',block)
                result=rmisf.sfBlockType(block);
            else
                result=get_param(block,'BlockType');
            end
        catch ME %#ok<NASGU>
            result='';
        end
    otherwise
        result=type;
    end
end
