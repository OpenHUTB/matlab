function[componentBlockType,blockType,isReference,isBehavior]=getComponentBlockType(handleOrPath)




    import systemcomposer.internal.validator.*
    componentBlockType=BaseComponentBlockType(handleOrPath);
    blockType='';
    isReference=false;
    isBehavior=false;
    if~isempty(handleOrPath)&&strcmp(get_param(handleOrPath,'Type'),'block')
        blockType=get_param(handleOrPath,'BlockType');
        switch blockType
        case 'SubSystem'
            refName=get_param(handleOrPath,'ReferencedSubsystem');
            if strcmp(get_param(handleOrPath,'Variant'),'on')
                componentBlockType=Variant(handleOrPath);
            elseif strcmp(get_param(handleOrPath,'SFBlockType'),'Chart')
                isBehavior=true;
                componentBlockType=Stateflow(handleOrPath);
            elseif~isempty(refName)
                isReference=true;
                if strcmp(refName,'<file name>')
                    componentBlockType=SubsystemReferenceUninitialized(handleOrPath);
                elseif~isvarname(refName)
                    componentBlockType=SubsystemReferenceUnspecified(handleOrPath);
                else
                    isBehavior=true;
                    componentBlockType=SubsystemReferenceBehavior(handleOrPath);
                end
            else
                subDomain=get_param(handleOrPath,'SimulinkSubDomain');
                switch subDomain
                case 'ArchitectureAdapter'
                    componentBlockType=Adapter(handleOrPath);
                case 'Simulink'
                    isBehavior=true;
                    componentBlockType=SubsystemInlinedBehavior(handleOrPath);
                case{'Architecture','SoftwareArchitecture','AUTOSARArchitecture'}
                    componentBlockType=Component(handleOrPath);
                end
            end
        case 'ModelReference'
            isReference=true;
            refName=get_param(handleOrPath,'ModelNameInternal');
            isProtected=strcmpi(get_param(handleOrPath,'ProtectedModel'),'on');

            if~isvarname(refName)||strcmpi(refName,slInternal('getModelRefDefaultModelName'))
                componentBlockType=ModelUnspecified(handleOrPath);
            else

                if bdIsLoaded(refName)
                    subDomain=get_param(refName,'SimulinkSubDomain');
                    if strcmpi(subDomain,'Simulink')
                        isBehavior=true;
                        componentBlockType=ModelBehavior(handleOrPath);
                    elseif strcmpi(subDomain,'SoftwareArchitecture')
                        componentBlockType=ModelSoftwareArchitecture(handleOrPath);
                    elseif strcmpi(subDomain,'AUTOSARArchitecture')
                        componentBlockType=ModelAUTOSARArchitecture(handleOrPath);
                    else
                        assert(strcmpi(subDomain,'Architecture'));
                        componentBlockType=ModelArchitecture(handleOrPath);
                    end
                elseif(exist(refName,'file')>0)
                    mdlInfo=Simulink.MDLInfo(refName);
                    subDomain=mdlInfo.Interface.SimulinkSubDomainType;


                    if isempty(subDomain)
                        subDomain='Simulink';
                    end

                    if isProtected
                        isBehavior=true;
                        componentBlockType=ProtectedModelBehavior(handleOrPath);
                    elseif strcmpi(subDomain,'Simulink')
                        isBehavior=true;
                        componentBlockType=ModelBehavior(handleOrPath);
                    elseif strcmpi(subDomain,'SoftwareArchitecture')
                        componentBlockType=ModelSoftwareArchitecture(handleOrPath);
                    elseif strcmpi(subDomain,'AUTOSARArchitecture')
                        componentBlockType=ModelAUTOSARArchitecture(handleOrPath);
                    else
                        assert(strcmpi(subDomain,'Architecture'));
                        componentBlockType=ModelArchitecture(handleOrPath);
                    end
                elseif(strcmp(refName,slInternal('getModelRefDefaultModelName')))
                    componentBlockType=ModelUninitialized(handleOrPath);
                else
                    componentBlockType=ModelUnspecified(handleOrPath);
                end
            end
        end
    end


