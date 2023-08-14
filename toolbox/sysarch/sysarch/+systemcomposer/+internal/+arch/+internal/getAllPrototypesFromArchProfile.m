function prototypes=getAllPrototypesFromArchProfile(archOrSlddName,varargin)










    includeRefModels=false;

    switch nargin
    case 1
        ignoreAbstract=true;
    case 2
        ignoreAbstract=varargin{1};
        elemClass='all';
    case 3
        ignoreAbstract=varargin{1};
        parts=split(string(varargin{2}),'.');
        elemClass=parts(end);
    case 4
        ignoreAbstract=varargin{1};
        parts=split(string(varargin{2}),'.');
        elemClass=parts(end);
        includeRefModels=varargin{3};
    end

    [~,~,ext]=fileparts(archOrSlddName);

    if isempty(ext)

        zcModel=systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel(archOrSlddName);
        rootArch=zcModel.getRootArchitecture;
        if(includeRefModels)
            da=systemcomposer.internal.DependencyAnalyzer.getDependencies([archOrSlddName,'.slx']);
            profNames=da.profiles;
            rootProfiles=[];
            for i=1:numel(profNames)
                try
                    profile=systemcomposer.loadProfile(profNames{i});
                    if~isempty(profile)
                        rootProfiles=[rootProfiles,profile.getImpl];%#ok<AGROW>
                    end
                catch

                end
            end
        else
            rootProfiles=rootArch.p_Model.getProfiles;
        end
    else

        assert(strcmp(ext,'.sldd'),'Only SLDD are supported');
        ddObj=Simulink.data.dictionary.open(archOrSlddName);
        interfaceSemanticModel=Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel(ddObj.filepath());
        zcModel=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(interfaceSemanticModel);
        pic=zcModel.getPortInterfaceCatalog;
        rootProfiles=pic.getProfiles;
    end

    prototypes=systemcomposer.internal.profile.Prototype.empty(1,0);
    for p=1:numel(rootProfiles)
        if strcmp(rootProfiles(p).getName,'systemcomposer')
            continue
        else
            allPrototypes=rootProfiles(p).prototypes.toArray;
            for i=1:numel(allPrototypes)
                if(shouldAddPrototypeToList(allPrototypes(i),ignoreAbstract,elemClass))
                    prototypes(end+1)=allPrototypes(i);%#ok<AGROW>
                end
            end
        end
    end

    function tf=shouldAddPrototypeToList(prototype,ignoreAbstract,elemClass)
        tf=false;
        extendedClass=prototype.getExtendedElement();
        if prototype.abstract&&ignoreAbstract
            tf=false;
        elseif strcmpi(elemClass,'all')
            tf=true;
        elseif strcmpi(elemClass,extendedClass)||~prototype.isElementPrototype()
            tf=true;
        elseif strcmpi(elemClass,'Component')&&strcmpi(extendedClass,'Architecture')
            tf=true;
        elseif strcmpi(elemClass,'Architecture')&&strcmpi(extendedClass,'Component')
            tf=true;
        elseif strcmpi(elemClass,'PortInterface')&&strcmpi(extendedClass,'Interface')
            tf=true;
        elseif strcmpi(elemClass,'Function')&&strcmpi(extendedClass,'Function')&&...
            slfeature('SoftwareModeling')>0
            tf=true;
        end
    end

end


