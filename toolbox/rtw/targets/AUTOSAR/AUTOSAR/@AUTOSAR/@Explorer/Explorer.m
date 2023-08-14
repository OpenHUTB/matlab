function h=Explorer(varargin)





    if nargin>0
        root=varargin{1};
    else
        assert(false,autosar.ui.metamodel.PackageString.NoRootErr);
    end

    h=AUTOSAR.Explorer(root,'AUTOSAR Explorer',false);
