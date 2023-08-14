function names=autoExtrinsicMgr(varargin)



















    if nargin==0
        command='-getNames';
    else
        command=varargin{1};
    end

    switch command
    case '-getFile'
        names=autoExtrinsicNamesTxt();
    case '-getNames'
        names=getNames();
    case '-proposeNames'
        dir=varargin{2};
        names=proposeNames(dir);
    case '-dumpNames'
        names=varargin{2};
        names=dumpNames(names);
    case '-defaultNames'
        names=getDefaultNames();
    otherwise
        error('Unrecognized command');
    end
end

function s=dumpNames(names)

    if size(names,1)>1
        names=names';
    end

    X=[names;repmat({newline},1,numel(names))];
    s=[X{:}];
end

function names=proposeNames(dir)
    files=what(dir);
    names=strrep(files.m,'.m','');


    names=setdiff(names,{'Contents','set','get'});
end

function names=getNames
    names=builtin('_getEmlAutoExtrinsicNames');
end

function names=getDefaultNames
    dirs={'toolbox/matlab/graphics'
'toolbox/matlab/graph2d'
    'toolbox/matlab/graph3d'};

    names={};
    for i=1:numel(dirs)
        d=fullfile(matlabroot,dirs{i});
        names=union(names,proposeNames(d));
    end
end

function s=autoExtrinsicNamesTxt
    s=fullfile(matlabroot,'toolbox/shared/coder/coder/extrinsics/autoExtrinsicNames.txt');
end
