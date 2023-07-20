function[isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem,requiresMetaClassCheck,mt]=isSystemObjectCode(code)
















    [isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem,requiresMetaClassCheck,mt]=pIsSystemObjectCode(code);
end

function[isConfirmedSystem,isConfirmedNonSystem,isConfirmedEventSystem,requiresMetaClassCheck,mt]=pIsSystemObjectCode(code,parentSuperClasses)



    if nargin<2
        parentSuperClasses={};
    end


    isConfirmedSystem=false;
    isConfirmedNonSystem=false;
    isConfirmedEventSystem=false;
    requiresMetaClassCheck=false;

    mt=matlab.system.editor.internal.ParseTreeUtils.getTree(code);
    if matlab.system.editor.internal.ParseTreeUtils.isTreeError(mt)
        return;
    end


    classdefNode=mtfind(mt,'Kind','CLASSDEF');
    if isempty(classdefNode)
        isConfirmedNonSystem=true;
        return;
    end


    superClasses=matlab.system.editor.internal.ParseTreeUtils.getSuperClasses(classdefNode);
    systemObjectBaseClasses={'matlab.System','matlab.DiscreteEventSystem','matlab.EventSystem',...
    'matlab.system.SFunSystem','matlab.system.CoreBlockSystem'};
    for k=1:numel(superClasses)
        if ismember(superClasses{k},systemObjectBaseClasses)
            isConfirmedSystem=true;
            if ismember(superClasses{k},{'matlab.DiscreteEventSystem','matlab.EventSystem'});
                isConfirmedEventSystem=true;
            end
            return;
        end
    end





    allSuperNonSystem=true;
    allSuperFound=true;
    mixinName='matlab.system.mixin.';
    numCharMixinName=length(mixinName);
    for k=1:numel(superClasses)
        superClassName=superClasses{k};


        if strncmp(superClassName,mixinName,numCharMixinName)||...
            ismember(superClassName,parentSuperClasses)
            continue;
        end



        superClassFile=which(superClassName);
        if isempty(superClassFile)||~exist(superClassFile,'file')
            if~exist(superClassName,'builtin')&&~contains(superClassFile,"built-in")



                allSuperFound=false;
            end
            continue;
        end

        [~,~,ext]=fileparts(superClassFile);
        if strcmp(ext,'.m')
            filecontents=fileread(superClassFile);

            [isSuperSystem,isSuperNonSystem,isSuperEventSystem,superRequiresMetaClassCheck]=...
            pIsSystemObjectCode(filecontents,[parentSuperClasses,superClasses]);

            if isSuperSystem
                isConfirmedSystem=true;
                isConfirmedEventSystem=isSuperEventSystem;
                requiresMetaClassCheck=false;
                return;
            elseif~isSuperNonSystem
                allSuperNonSystem=false;
            end
            if superRequiresMetaClassCheck
                requiresMetaClassCheck=true;
            end
        elseif strcmp(ext,'.p')
            requiresMetaClassCheck=true;
        end


    end


    if allSuperFound&&allSuperNonSystem&&~requiresMetaClassCheck
        isConfirmedNonSystem=true;
    end
end
