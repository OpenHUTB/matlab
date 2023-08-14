function h=root(varargin)




    h=TflDesigner.root;

    h.uiclipboard=TflDesigner.uiclipboard;
    h.buildinfouiclipboard=TflDesigner.uiclipboard;

    if nargin~=0
        h.populate(varargin{:});
    else
        h.populate;
    end

