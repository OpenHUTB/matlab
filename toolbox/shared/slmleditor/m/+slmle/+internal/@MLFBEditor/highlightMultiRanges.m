function highlightMultiRanges( obj, ranges )

arguments
    obj
    ranges cell
end

data = [  ];
data.ranges = ranges;

obj.publish( 'highlightMultiRanges', data );
