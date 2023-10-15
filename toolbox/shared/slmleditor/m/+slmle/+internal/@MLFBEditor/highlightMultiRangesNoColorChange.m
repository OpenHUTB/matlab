function highlightMultiRangesNoColorChange( obj, ranges )

arguments
    obj
    ranges cell
end

data = [  ];
data.ranges = ranges;

obj.publish( 'highlightMultiRangesNoColorChange', data );

