function sorted = sortNames( names, direction )
arguments
    names( 1, : )string;
    direction( 1, : )char{ mustBeMember( direction, { 'ascend', 'descend' } ) } = 'ascend';
end
namesMatrix = sortrows( [ upper( names );names ]', direction );
sorted = namesMatrix( :, 2 )';
end


