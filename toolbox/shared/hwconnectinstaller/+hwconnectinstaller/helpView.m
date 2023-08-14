function helpView(varargin)






    if nargin>2
        assert(false);
    end

    if nargin==0
        anchorID='abouttargetintaller';
        mapFile=fullfile(docroot,'matlab','matlab_external','matlab_external.map');
    elseif nargin==1
        anchorID=varargin{1};
        mapFile=fullfile(docroot,'matlab','matlab_external','matlab_external.map');
    else
        anchorID=varargin{1};
        mapFile=varargin{2};
    end

    helpview(mapFile,anchorID);

