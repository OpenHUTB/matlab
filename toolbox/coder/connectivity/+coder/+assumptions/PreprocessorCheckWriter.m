classdef(Hidden=true)PreprocessorCheckWriter<handle









    properties(SetAccess='private',GetAccess='protected')
        WriterOutputPath;
        CoderAssumptions;

        Writer;
        IncludeGuard;
    end

    methods

        function this=PreprocessorCheckWriter(coderAssumptions,writerOutputPath)
            narginchk(2,2);

            this.WriterOutputPath=writerOutputPath;
            this.CoderAssumptions=coderAssumptions;
            [~,fname]=fileparts(this.WriterOutputPath);
            this.IncludeGuard=sprintf('%s_H',upper(fname));
        end

        function writeOutput(this,append,callCBeautifier,obfuscateCode,encoding)

            narginchk(5,5);
            args={'fileName',this.WriterOutputPath,...
            'append',append,...
            'callCBeautifier',callCBeautifier,...
            'obfuscateCode',obfuscateCode,...
            'encoding',encoding};


            this.Writer=rtw.connectivity.CodeWriter.create(args{:});

            this.writeOutputBody;

            this.Writer.close;
        end
    end

    methods(Access='protected')
        function writeOutputBody(this)
            this.writeSectionHeader;

            addSignedPrefix=true;
            this.writeTypeSizeCheck('uchar/char','CHAR',...
            this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerChar,addSignedPrefix);

            this.writeTypeSizeCheck('ushort/short','SHRT',...
            this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerShort);

            this.writeTypeSizeCheck('uint/int','INT',...
            this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerInt);

            this.writeTypeSizeCheck('ulong/long','LONG',...
            this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerLong);

            if this.CoderAssumptions.CoderConfig.LongLongMode
                this.writeTypeSizeCheck('ulong_long/long_long','LLONG',...
                this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerLongLong);
            end

            this.writeSectionPWSGuardTrailer;
            this.writeSectionIncludeGuardTrailer;
        end

        function writeSectionHeader(this)
            [~,fname,fext]=fileparts(this.WriterOutputPath);
            this.Writer.wLine('/*');
            this.Writer.wLine(' * File: %s%s',fname,fext);
            this.Writer.wLine(' *');
            this.Writer.wLine(' * Abstract: Preprocessor checks for hardware implementation settings.');
            this.Writer.wLine(' *');
            this.Writer.wLine(' * Hardware Implementation Specification:');
            this.Writer.wLine(' *');
            this.Writer.wLine(' * HWDeviceType: %s',this.CoderAssumptions.CoderConfig.HWDeviceType);
            this.Writer.wLine(' * PortableWordSizes: %s',this.bool2OnOff(...
            this.CoderAssumptions.CoderConfig.PortableWordSizes));
            this.Writer.wLine(' * PreprocMaxBitsUint: %d',this.CoderAssumptions.CoderConfig.PreprocMaxBitsUint);
            this.Writer.wLine(' * PreprocMaxBitsSint: %d',this.CoderAssumptions.CoderConfig.PreprocMaxBitsSint);
            this.Writer.wLine(' * BitPerChar: %d',this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerChar);
            this.Writer.wLine(' * BitPerShort: %d',this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerShort);
            this.Writer.wLine(' * BitPerInt: %d',this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerInt);
            this.Writer.wLine(' * BitPerLong: %d',this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerLong);
            this.Writer.wLine(' * LongLongMode: %s',this.bool2OnOff(this.CoderAssumptions.CoderConfig.LongLongMode));
            this.Writer.wLine(' * BitPerLongLong: %d',this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerLongLong);
            this.Writer.wLine(' */');
            this.Writer.newLine;
            this.writeSectionIncludeGuardHeader;
            this.writeSectionPWSGuardHeader;
            this.Writer.wComment('make sure limits are available');
            this.Writer.wLine('#ifndef UCHAR_MAX');
            this.Writer.wLine('#include <limits.h>');
            this.Writer.wLine('#endif');
            this.Writer.newLine;
        end

        function writeSectionIncludeGuardHeader(this)
            this.Writer.wLine('#ifndef %s',this.IncludeGuard);
            this.Writer.wLine('#define %s',this.IncludeGuard);
            this.Writer.newLine;
        end

        function writeSectionIncludeGuardTrailer(this)
            this.Writer.wLine('#endif /* %s */',this.IncludeGuard);
        end

        function writeSectionPWSGuardHeader(this)
            if this.CoderAssumptions.CoderConfig.PortableWordSizes
                this.Writer.wLine('#ifndef PORTABLE_WORDSIZES');
                this.Writer.newLine;
            end
        end

        function writeSectionPWSGuardTrailer(this)
            if this.CoderAssumptions.CoderConfig.PortableWordSizes
                this.Writer.wLine('#endif /* !PORTABLE_WORDSIZES */');
                this.Writer.newLine;
            end
        end

        function writeTypeSizeCheck(this,...
            typeName,...
            limitName,...
            numBits,...
            addSignedPrefixToMax)
            if nargin==4
                addSignedPrefixToMax=false;
            end

            if(numBits>this.CoderAssumptions.CoderConfig.PreprocMaxBitsUint)||...
                (numBits>this.CoderAssumptions.CoderConfig.PreprocMaxBitsSint)
                this.Writer.wLine('/* Skipping %s check: insufficient preprocessor integer range. */',typeName);
            else
                umask=this.getHexString(numBits,false);
                smask=this.getHexString(numBits,true);
                if addSignedPrefixToMax
                    signedPrefix='S';
                else
                    signedPrefix='';
                end
                this.Writer.wLine('#if (U%s_MAX != (%s)) || (%s%s_MAX != (%s))',...
                limitName,...
                umask,...
                signedPrefix,...
                limitName,...
                smask);
                this.Writer.wLine(['#error Code was generated for compiler with different sized %s. \\\n'...
                ,'Consider adjusting Hardware Implementation data type sizes to \\\n'...
                ,'match your compiler (defined in limits.h).'],typeName);
                this.Writer.wLine('#endif');
            end
            this.Writer.newLine;
        end
    end

    methods(Access='private')
        function hexString=getHexString(this,numBits,isSigned)
            assert(mod(numBits,8)==0,'numBits must be multiple of 8.');
            numBytes=numBits/8;
            if isSigned
                hexString=['0x7F',repmat('FF',1,numBytes-1)];
            else
                hexString=['0x',repmat('FF',1,numBytes)];
            end
            if~isSigned
                hexString=[hexString,'U'];
            end
            intNumBits=this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerInt;
            longNumBits=this.CoderAssumptions.Assumptions.TargetHardware.WordLengths.BitPerLong;
            if(numBits>intNumBits)&&(numBits<=longNumBits)
                hexString=[hexString,'L'];
            elseif(numBits>longNumBits)&&this.CoderAssumptions.CoderConfig.LongLongMode
                hexString=[hexString,'LL'];
            end
        end
    end

    methods(Static,Access=private)
        function str=bool2OnOff(bool)
            assert(islogical(bool),'bool must be boolean');
            if bool
                str='on';
            else
                str='off';
            end
        end
    end
end


