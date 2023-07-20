function val=isPragma(node)




    switch node.kind
    case 'SUBSCR'
        pragmaName=node.Left.tree2str(0,1);
    case 'DOT'
        pragmaName=node.tree2str(0,1);
    otherwise
        pragmaName='';
    end

    val=startsWith(pragmaName,{'coder.','eml.','hdl.'});

end


