classdef Language<cgfe.util.BaseClass

    properties(Constant,GetAccess=public,Hidden)
        LANGUAGES={'c','c_old','c99','cxx'};
        DIALECTS={'none','gnu','lcc','msvc','msvc6.0','msvc7.0','msvc7.1','msvc8.0','msvc9.0','msvc10.0','msvc11.0'};
        PTRDIFFTYPES={'int','long','longlong','short'};
        SIZETYPES={'uint','ulong','ulonglong'};
        WCHARTYPES={'ushort','uint','ulong','short','int','long'};
    end

    properties
        LanguageMode='c';
        LanguageExtra={};
        AllowLongLong=true
        MinStructAlignment=1;
        MaxAlignment=4;
        PtrDiffTypeKind='int';
        SizeTypeKind='uint';
        WcharTypeKind='ushort';
        AllowMultibyteChars=true
        PlainCharsAreSigned=true;
        PlainBitFieldsAreSigned=false;
        Dialect='none';
    end

    methods
        function this=Language(arg1,arg2)

            if nargin==1&&isa(arg1,'cgfe.frontend.Language')
                this=arg1;
            else
                if nargin<1||isempty(arg1)
                    arg1='c';
                end
                if nargin<2||isempty(arg2)
                    arg2='none';
                end

                arg1=convertStringsToChars(arg1);
                if ischar(arg1)
                    lang=lower(arg1);
                else
                    lang=arg1;
                end

                this.Dialect=arg2;

                isForCxx=strcmpi(lang,'c++')||strcmpi(lang,'cxx');
                if isForCxx
                    this.LanguageMode='cxx';
                else
                    this.LanguageMode=lang;
                end

            end

        end

        function this=set.LanguageMode(this,aValue)
            cgfe.util.verifyStringValue('LanguageMode',aValue);
            this.LanguageMode=cgfe.util.verifyEnumValue('LanguageMode',...
            cgfe.frontend.Language.LANGUAGES,lower(aValue));
        end

        function this=set.Dialect(this,aValue)
            cgfe.util.verifyStringValue('Dialect',aValue);
            this.Dialect=cgfe.util.verifyEnumValue('Dialect',...
            cgfe.frontend.Language.DIALECTS,lower(aValue));
        end

        function this=set.LanguageExtra(this,aValue)
            this.LanguageExtra=cgfe.util.verifyCellOfStrings('LanguageExtra',aValue);
        end

        function this=set.AllowLongLong(this,aValue)
            this.AllowLongLong=cgfe.util.verifyLogicalValue('AllowLongLong',aValue);
        end

        function this=set.MinStructAlignment(this,aValue)
            this.MinStructAlignment=cgfe.util.verifyUint32Value('MinStructAlignment',aValue);
        end

        function this=set.MaxAlignment(this,aValue)
            this.MaxAlignment=cgfe.util.verifyUint32Value('MaxAlignment',aValue);
        end

        function this=set.PtrDiffTypeKind(this,aValue)
            cgfe.util.verifyStringValue('PtrDiffTypeKind',aValue);
            this.PtrDiffTypeKind=cgfe.util.verifyEnumValue('PtrDiffTypeKind',...
            cgfe.frontend.Language.PTRDIFFTYPES,lower(aValue));
        end

        function this=set.SizeTypeKind(this,aValue)
            cgfe.util.verifyStringValue('SizeTypeKind',aValue);
            this.SizeTypeKind=cgfe.util.verifyEnumValue('SizeTypeKind',...
            cgfe.frontend.Language.SIZETYPES,lower(aValue));
        end

        function this=set.WcharTypeKind(this,aValue)
            cgfe.util.verifyStringValue('WcharTypeKind',aValue);
            this.WcharTypeKind=cgfe.util.verifyEnumValue('WcharTypeKind',...
            cgfe.frontend.Language.WCHARTYPES,lower(aValue));
        end

        function this=set.AllowMultibyteChars(this,aValue)
            this.AllowMultibyteChars=cgfe.util.verifyLogicalValue('AllowMultibyteChars',aValue);
        end

        function this=set.PlainCharsAreSigned(this,aValue)
            this.PlainCharsAreSigned=cgfe.util.verifyLogicalValue('PlainCharsAreSigned',aValue);
        end

        function this=set.PlainBitFieldsAreSigned(this,aValue)
            this.PlainBitFieldsAreSigned=cgfe.util.verifyLogicalValue('PlainBitFieldsAreSigned',aValue);
        end
    end
end



