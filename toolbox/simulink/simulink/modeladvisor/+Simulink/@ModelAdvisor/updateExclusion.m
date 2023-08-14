function updateExclusion(this)

    exclusionFile=get_param(bdroot(this.system),'MAModelExclusionFile');


    if isempty(exclusionFile)&&isSLX(bdroot(this.system))
        exclusionFile=Simulink.slx.getUnpackedFileNameForPart(bdroot(this.system),'/advisor/exclusions.xml');
    end
    try
        ModelAdvisor.registerXML(exclusionFile,this);
    catch E %#ok<NASGU>
        disp(DAStudio.message('ModelAdvisor:engine:ExclusionFileParsingError',exclusionFile));
    end


    function flag=isSLX(mdl)
        [~,fName,ext]=fileparts(get_param(mdl,'filename'));
        if isempty(fName)
            flag=true;
        else
            flag=strcmp(ext,'.slx');
        end