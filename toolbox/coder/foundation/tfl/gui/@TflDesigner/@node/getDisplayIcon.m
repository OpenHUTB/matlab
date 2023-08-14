function val=getDisplayIcon(this)



    ResourcePath=fullfile(fileparts(mfilename('fullpath')),'..','resources');
    switch this.Type
    case 'TflRegistry'
        val=fullfile('toolbox','matlab','icons','HDF_VGroup.gif');
    case 'TflTable'
        val=fullfile('toolbox','matlab','icons','HDF_pointfieldset.gif');
    case 'TflEntry'
        if this.isValid
            if isempty(this.errLog)
                val=fullfile(ResourcePath,'checkmark.png');
            else
                val=fullfile(ResourcePath,'warningentry.png');
            end
        else
            if isempty(this.errLog)
                val=fullfile('toolbox','matlab','icons','HDF_point.gif');
            else
                val=fullfile(ResourcePath,'erroricon.png');
            end
        end
    end

