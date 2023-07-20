function[isOnRetval,bbDirRetval]=bb(v)


    persistent isOn
    persistent bbDir;

    if isempty(isOn)
        isOn=false;
        bbDir=tempname;
    end


    if nargin==0
        isOnRetval=isOn;
        bbDirRetval=bbDir;
        return;
    end


    if islogical(v)&&~v
        isOn=false;
        isOnRetval=false;
        bbDirRetval='';
        return;
    end

    if ischar(v)||isstring(v)
        bbDir=char(v);
    end
    if~isfolder(bbDir)
        mkdir(bbDir);
    end
    disp(' ');
    disp(['All reproduction steps will be stored this folder: ',bbDir]);
    isOn=true;
    isOnRetval=true;
    bbDirRetval=bbDir;
