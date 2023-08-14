function val=getDisplayIcon(this)



    switch this.Type
    case 'TflCustomization'
        val=fullfile('toolbox','matlab','icons','HDF_point.gif');
    case 'TflEntry'
        val=fullfile('toolbox','matlab','icons','HDF_point.gif');
    case 'TargetRegistry'
        val=fullfile('toolbox','matlab','icons','HDF_VGroup.gif');
    case 'TflTable'
        val=fullfile('toolbox','matlab','icons','HDF_pointfieldset.gif');
    otherwise
        val=fullfile('toolbox','matlab','icons','foldericon.gif');
    end




