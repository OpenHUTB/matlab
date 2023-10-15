function out = version( in )

arguments
    in double = [  ]
end

persistent VERSION

if isempty( VERSION )
    VERSION = 3;
end

if ~isempty( in )
    VERSION = in;
end

out = VERSION;
end

