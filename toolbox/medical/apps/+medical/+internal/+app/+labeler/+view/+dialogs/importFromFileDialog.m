function [ filename, isCanceled ] = importFromFileDialog( namedArgs )

arguments

    namedArgs.FilterSpec cell = { '*.mat', 'MAT-files (*.mat)' };

    namedArgs.DialogTitle( 1, 1 )string{ mustBeNonmissing } = "Open";

    namedArgs.DefaultPath( 1, 1 )string{ mustBeNonmissing } = "";

end

persistent cached_path;

filename = "";
isCanceled = false;

if namedArgs.DefaultPath ~= ""
    cached_path = namedArgs.DefaultPath;
end

if isempty( cached_path )
    cached_path = '';
end

[ fname, pathname ] = uigetfile( namedArgs.FilterSpec, namedArgs.DialogTitle, cached_path );



if fname == 0
    isCanceled = true;
else
    cached_path = pathname;
    filename = fullfile( pathname, fname );
end

end

