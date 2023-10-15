function res = getNodeDisplayOption( node, name, default )

arguments
    node simscape.logging.Node{ mustBeNonempty }
    name( 1, 1 )string
    default
end

res = simscape.logging.internal.getNodeDisplayOptions( node, name, { default } );
res = res{ 1 };

end

