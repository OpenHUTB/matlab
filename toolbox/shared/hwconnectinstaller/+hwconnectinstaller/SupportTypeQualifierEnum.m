classdef SupportTypeQualifierEnum




    enumeration
Standard
TechPreview
    end

    methods(Static)
        function out=isTechPreview()
            out=strcmpi(hwconnectinstaller.SupportTypeQualifierEnum.typeQualifierPersistentVarHandler,...
            char(hwconnectinstaller.SupportTypeQualifierEnum.TechPreview));
        end

        function setType(typeRequested)
            hwconnectinstaller.SupportTypeQualifierEnum.typeQualifierPersistentVarHandler(typeRequested);
        end

        function out=getType()
            out=hwconnectinstaller.SupportTypeQualifierEnum.typeQualifierPersistentVarHandler();
        end

        function out=getUserFacingFolderLabel(type)
            validateattributes(type,{'char'},{},'getUserFacingFolderLabel','type');
            if strcmpi(type,char(hwconnectinstaller.SupportTypeQualifierEnum.Standard))
                out='SupportPackages';
            else
                adjustedLabel=type;
                spaceIndices=isspace(char(type));

                firstLetterIndices=circshift(spaceIndices,[1,1]);


                adjustedLabel(1)=upper(adjustedLabel(1));
                for i=1:length(firstLetterIndices)
                    if firstLetterIndices(i)==true
                        adjustedLabel(i)=upper(adjustedLabel(i));
                    end
                end
                out=[deblank(char(type)),'s'];
            end
        end

    end

    methods(Static,Access=private)
        function out=typeQualifierPersistentVarHandler(varargin)
















            mlock;
            persistent SupportTypeQualifier;

            switch nargin
            case 0
                typeRequested=char(hwconnectinstaller.SupportTypeQualifierEnum.Standard);
            case 1
                typeRequested=varargin{1};
                validateattributes(typeRequested,{'char'},{'nonempty'},'hwconnectinstaller.SupportTypeQualifierEnum.typeQualifier','typeRequested');
            otherwise
                error('hwconnectinstaller.SupportTypeQualifierEnum.typeQualifier: Unsupported syntax');
            end



            if isequal(nargin,1)||isempty(SupportTypeQualifier)

                [~,supportedTypeQualifiers]=enumeration('hwconnectinstaller.SupportTypeQualifierEnum');

                isSupportedMode=ismember(lower(typeRequested),lower(supportedTypeQualifiers));
                if~isSupportedMode




                    error(message('hwconnectinstaller:setup:SupportTypeQualifier_invalidValue',strjoin(supportedTypeQualifiers','\n')));
                else

                    SupportTypeQualifier=typeRequested;
                end
            end
            out=SupportTypeQualifier;
        end


    end

end