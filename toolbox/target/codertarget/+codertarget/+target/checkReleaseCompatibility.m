function checkReleaseCompatibility(target)





    validateattributes(target,{'struct'},{'nonempty'});
    if~isfield(target,'Name')||~isfield(target,'TargetFolder')
        error(message('codertarget:targetapi:UnexpectedInputForReleaseCheck'));
    end


    persistent thisRelease;

    if isempty(thisRelease)
        thisRelease=['R',version('-release')];
    end

    hwFiles=dir(fullfile(target.TargetFolder,'registry','targethardware','*.xml'));
    for i=1:numel(hwFiles)
        defFile=fullfile(target.TargetFolder,'registry','targethardware',hwFiles(i).name);
        hwrelinfo=performance.utils.getReleseFromXMLFile(defFile);
        if~isempty(hwrelinfo)&&~isequal(thisRelease,hwrelinfo)
            error(message('codertarget:targetapi:TargetReleaseIncompatibility',target.Name,hwrelinfo,thisRelease));
        end
    end
