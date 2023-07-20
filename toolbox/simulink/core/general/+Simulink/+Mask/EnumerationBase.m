



classdef(Abstract)EnumerationBase<Simulink.IntEnumType

    methods(Access=public)

        function aObj=EnumerationBase(aValue,aDisplayName)





            aObj=aObj@Simulink.IntEnumType(Simulink.Mask.EnumerationBase.Index('Increment'));
            try
                Simulink.Mask.EnumerationBase.PopupOptionsCache('Add',aObj,aValue,aDisplayName);
            catch exp
                Simulink.Mask.EnumerationBase.Index('Reset');
                rethrow(exp);
            end
        end

    end

    methods(Static)
        function aOut=addClassNameToEnumNames()
            aOut=true;
        end

        function aOut=Index(aAction)
            mlock;
            persistent sIndex;

            if isempty(sIndex)
                sIndex=int32(0);
            end

            switch(aAction)
            case 'Increment'
                sIndex=sIndex+1;
            case 'Reset'
                sIndex=[];
            end

            aOut=sIndex;
        end

        function aOut=PopupOptionsCache(varargin)
            mlock;
            persistent sPopupOptionsCache;

            aOut=[];
            aAction=varargin{1};

            switch(aAction)
            case 'Add'
                aEnumClass=metaclass(varargin{2});
                aEnumClassName=aEnumClass.Name;
                aEnumOption.Value=varargin{3};
                aEnumOption.DisplayName=varargin{4};

                if Simulink.Mask.EnumerationBase.Index('Get')==1
                    Simulink.Mask.EnumerationBase.PopupOptionsCache('Clear',aEnumClassName);
                end

                iIdx=[];
                if~isempty(sPopupOptionsCache)
                    iIdx=find(strcmp({sPopupOptionsCache.EnumClassName},aEnumClassName));
                end

                if isempty(iIdx)
                    sPopupOptionsCache(end+1).EnumClassName=aEnumClassName;
                    sPopupOptionsCache(end).EnumOptions=aEnumOption;
                    iNumOptions=1;
                else
                    sPopupOptionsCache(iIdx).EnumOptions(end+1)=aEnumOption;
                    iNumOptions=length(sPopupOptionsCache(iIdx).EnumOptions);
                end

                if length(aEnumClass.EnumerationMemberList)==iNumOptions
                    Simulink.Mask.EnumerationBase.Index('Reset');
                end

            case 'Get'

                aEnumClassName=varargin{2};
                iIdx=find(strcmp({sPopupOptionsCache.EnumClassName},aEnumClassName));
                if~isempty(iIdx)
                    aOut=sPopupOptionsCache(iIdx).EnumOptions;
                end

            case 'Clear'
                aEnumClassName=varargin{2};
                if~isempty(sPopupOptionsCache)
                    iIdx=find(strcmp({sPopupOptionsCache.EnumClassName},aEnumClassName));
                    if~isempty(iIdx)
                        sPopupOptionsCache(iIdx)=[];
                    end
                end
            end
        end

    end
end
