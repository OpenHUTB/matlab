function[isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem,mt]=isSystemObjectFile(filePath,code)













    isConfirmedSystem=false;
    isConfirmedEventSystem=false;
    isConfirmedNonSystem=true;



    [pathStr,~,ext]=fileparts(filePath);
    if~isempty(pathStr)&&ext~=".m"
        return;
    end


    [isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem,requiresMetaClassCheck,mt]=...
    matlab.system.editor.internal.isSystemObjectCode(code);


    if requiresMetaClassCheck
        [isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem]=isSystemObjectUsingMetaclass(filePath);
    end
end

function[isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem]=isSystemObjectUsingMetaclass(fileName)


    try
        candidateName=matlab.system.editor.internal.getClassNameFromFile(fileName);


        candidatePath=which(candidateName);
        if isempty(candidatePath)
            isConfirmedSystem=false;
            isConfirmedNonSystem=false;
            isConfirmedEventSystem=false;
            return;
        end


        mc=meta.class.fromName(candidateName);
        isConfirmedSystem=~isempty(mc)&&isa(mc,'matlab.system.SysObjCustomMetaClass');
        isConfirmedEventSystem=~isempty(mc)&&(isa(mc,'matlab.DiscreteEventSystem')||isa(mc,'matlab.EventSystem'));
        isConfirmedNonSystem=~isConfirmedSystem;
    catch e %#ok<NASGU> % Error trying to load class
        isConfirmedSystem=false;
        isConfirmedEventSystem=false;
        isConfirmedNonSystem=false;
    end
end

