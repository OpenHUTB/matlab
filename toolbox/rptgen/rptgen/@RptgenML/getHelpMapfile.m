function mapfileName=getHelpMapfile(mapPath)






    dR=docroot;
    if isempty(dR);
        dR=fullfile(matlabroot,'help');
    end

    if((nargin>0)&&~isempty(mapPath))
        if rptgen.isFileRelative(mapPath)
            mapfileName=fullfile(dR,mapPath);
        else
            mapfileName=mapPath;
        end

    else
        mapfileName=fullfile(dR,'rptgen','rptgen.map');

    end

