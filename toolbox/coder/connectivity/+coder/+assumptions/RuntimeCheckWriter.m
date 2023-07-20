classdef(Hidden=true)RuntimeCheckWriter<handle








    properties(SetAccess='private',GetAccess='private')
        HeaderFilePath;
        SourceFilePath;
        EntryPointHeaderFilePath;

        Writer;
        CoderAssumptions;
        ComponentName;
        ExpHW;
        ActHW;
        HWRes;
        PWSRes;
        IncludeGuard;
    end

    methods

        function this=RuntimeCheckWriter(coderAssumptions,outputPath,componentName)
            narginchk(3,3);
            this.CoderAssumptions=coderAssumptions;

            this.ComponentName=componentName;

            headerFileName=coder.assumptions.CoderAssumptions.getHeaderFileName(this.ComponentName);
            this.HeaderFilePath=fullfile(outputPath,headerFileName);
            sourceFileName=coder.assumptions.CoderAssumptions.getSourceFileName(this.ComponentName);
            this.SourceFilePath=fullfile(outputPath,sourceFileName);

            this.EntryPointHeaderFilePath=fullfile(outputPath,...
            coder.assumptions.CoderAssumptions.getEntryPointHeaderFileName);

            this.ExpHW=sprintf('CA_%s_ExpHW',this.ComponentName);
            this.ActHW=sprintf('CA_%s_ActHW',this.ComponentName);
            this.HWRes=sprintf('CA_%s_HWRes',this.ComponentName);
            this.PWSRes=sprintf('CA_%s_PWSRes',this.ComponentName);
        end

        function writeOutput(this,append,callCBeautifier,obfuscateCode,encoding)
            narginchk(5,5);

            args={'append',append,...
            'callCBeautifier',callCBeautifier,...
            'obfuscateCode',obfuscateCode,...
            'encoding',encoding};


            [~,fname]=fileparts(this.HeaderFilePath);
            this.IncludeGuard=sprintf('%s_H',upper(fname));
            this.Writer=rtw.connectivity.CodeWriter.create('fileName',this.HeaderFilePath,args{:});
            this.writeHeaderFile;
            this.Writer.close;


            this.Writer=rtw.connectivity.CodeWriter.create('fileName',this.SourceFilePath,args{:});
            this.writeSourceFile;
            this.Writer.close;


            [~,fname]=fileparts(this.EntryPointHeaderFilePath);
            this.IncludeGuard=sprintf('%s_H',upper(fname));
            this.Writer=rtw.connectivity.CodeWriter.create('fileName',this.EntryPointHeaderFilePath,args{:});
            this.writeEntryPointHeaderFile;
            this.Writer.close;
        end
    end

    methods(Access='private')

        function writeHeaderFile(this)
            [~,fname,fext]=fileparts(this.HeaderFilePath);
            this.Writer.wLine('/*');
            this.Writer.wLine(' * File: %s%s',fname,fext);
            this.Writer.wLine(' *');
            this.Writer.wLine(' * Abstract: Tests assumptions in the generated code.');
            this.Writer.wLine(' */');
            this.Writer.newLine;
            this.writeSectionIncludeGuardHeader;
            this.Writer.newLine;
            this.Writer.wComment('preprocessor validation checks');
            this.Writer.wLine('#include "%s"',...
            coder.assumptions.CoderAssumptions.getPreprocessorHeaderFileName(this.ComponentName));
            this.Writer.newLine;
            this.Writer.wLine('#include "%s"',coder.assumptions.CoderAssumptions.getStaticHeader_HWImpl);
            this.Writer.newLine;
            this.Writer.wComment('variables holding test results');
            this.Writer.wLine('extern CA_HWImpl_TestResults %s;',this.HWRes);
            this.Writer.wLine('extern CA_PWS_TestResults %s;',this.PWSRes);
            this.Writer.wComment('variables holding "expected" and "actual" hardware implementation');
            this.Writer.wLine('extern const CA_HWImpl %s;',this.ExpHW);
            this.Writer.wLine('extern CA_HWImpl %s;',this.ActHW);
            this.Writer.newLine;
            this.Writer.wComment('entry point function to run tests');
            this.Writer.wLine('void %s(void);',...
            coder.assumptions.CoderAssumptions.getEntryPointFcnName(this.ComponentName));
            this.Writer.newLine;
            this.writeSectionIncludeGuardTrailer;
        end

        function writeSourceFile(this)
            [~,fname,fext]=fileparts(this.SourceFilePath);
            this.Writer.wLine('/*');
            this.Writer.wLine(' * File: %s%s',fname,fext);
            this.Writer.wLine(' *');
            this.Writer.wLine(' * Abstract: Tests assumptions in the generated code.');
            this.Writer.wLine(' */');
            this.Writer.newLine;
            this.Writer.wLine('#include "%s"',...
            coder.assumptions.CoderAssumptions.getHeaderFileName(this.ComponentName));
            this.Writer.newLine;

            this.Writer.wLine('CA_HWImpl_TestResults %s;',this.HWRes);
            this.Writer.wLine('CA_PWS_TestResults %s;',this.PWSRes);
            this.Writer.newLine;

            this.writeHWImpl_ExpHW();
            this.Writer.newLine;
            this.writeHWImpl_ActHW();
            this.Writer.newLine;

            this.Writer.wBlockStart('void %s(void)',...
            coder.assumptions.CoderAssumptions.getEntryPointFcnName(this.ComponentName));
            this.Writer.wComment('verify hardware implementation');
            this.Writer.wLine('caVerifyPortableWordSizes(&%s, &%s, &%s);',this.ActHW,this.ExpHW,this.PWSRes);
            this.Writer.wLine('caVerifyHWImpl(&%s, &%s, &%s);',this.ActHW,this.ExpHW,this.HWRes);
            this.Writer.wBlockEnd;
        end

        function writeEntryPointHeaderFile(this)
            [~,fname,fext]=fileparts(this.EntryPointHeaderFilePath);
            this.Writer.wLine('/*');
            this.Writer.wLine(' * File: %s%s',fname,fext);
            this.Writer.wLine(' *');
            this.Writer.wLine(' * Abstract: Coder assumptions header file');
            this.Writer.wLine(' */');
            this.Writer.newLine;
            this.writeSectionIncludeGuardHeader;
            this.Writer.newLine;
            this.Writer.wComment('include model specific checks');
            this.Writer.wLine('#include "%s"',...
            coder.assumptions.CoderAssumptions.getHeaderFileName(this.ComponentName));
            this.Writer.newLine;
            this.Writer.wComment('global results variable mapping for static code');
            this.Writer.wLine('#define CA_Expected_HWImpl %s',this.ExpHW);
            this.Writer.wLine('#define CA_Actual_HWImpl %s',this.ActHW);
            this.Writer.wLine('#define CA_HWImpl_Results %s',this.HWRes);
            this.Writer.wLine('#define CA_PortableWordSizes_Results %s',this.PWSRes);
            this.Writer.wComment('entry point function mapping for static code');
            this.Writer.wLine('#define CA_Run_Tests %s',...
            coder.assumptions.CoderAssumptions.getEntryPointFcnName(this.ComponentName));
            this.Writer.newLine;
            this.writeSectionIncludeGuardTrailer;
        end

        function writeHWImpl_ExpHW(this)
            this.Writer.wLine('const CA_HWImpl %s = {',this.ExpHW);
            this.Writer.incIndent;

            if this.CoderAssumptions.CoderConfig.PortableWordSizes
                this.Writer.wLine('#ifdef PORTABLE_WORDSIZES');
                this.Writer.incIndent;
                hwImpl=this.CoderAssumptions.Assumptions.PortableWordSizesHardware;
                this.writePWSDependentValues(hwImpl);
                this.Writer.decIndent;
                this.Writer.wLine('#else');
                this.Writer.incIndent;
                hwImpl=this.CoderAssumptions.Assumptions.TargetHardware;
                this.writePWSDependentValues(hwImpl);
                this.Writer.decIndent;
                this.Writer.wLine('#endif');
            else
                hwImpl=this.CoderAssumptions.Assumptions.TargetHardware;
                this.writePWSDependentValues(hwImpl);
            end
            this.writePWSIndependentValues(this.CoderAssumptions);
        end

        function writeHWImpl_ActHW(this)
            this.Writer.wLine('CA_HWImpl %s = {',this.ActHW);
            this.Writer.incIndent;



            [modelZI,coderAssumptionsZI]=...
            coder.assumptions.CoderAssumptionsSerializer.zeroInitCoderAssumptions();%#ok<ASGLU> 


            this.writePWSDependentValues(coderAssumptionsZI.Assumptions.TargetHardware);
            this.writePWSIndependentValues(coderAssumptionsZI);
        end

        function writePWSDependentValues(this,hwImpl)
            wordLengths=hwImpl.WordLengths;


            isFinal=false;
            isString=false;
            this.writeParam(isFinal,isString,wordLengths.BitPerChar,[],'BitPerChar');
            this.writeParam(isFinal,isString,wordLengths.BitPerShort,[],'BitPerShort');
            this.writeParam(isFinal,isString,wordLengths.BitPerInt,[],'BitPerInt');
            this.writeParam(isFinal,isString,wordLengths.BitPerLong,[],'BitPerLong');
            this.writeParam(isFinal,isString,wordLengths.BitPerLongLong,[],'BitPerLongLong');
            this.writeParam(isFinal,isString,wordLengths.BitPerFloat,[],'BitPerFloat');
            this.writeParam(isFinal,isString,wordLengths.BitPerDouble,[],'BitPerDouble');
            this.writeParam(isFinal,isString,wordLengths.BitPerPointer,[],'BitPerPointer');
            this.writeParam(isFinal,isString,wordLengths.BitPerSizeT,[],'BitPerSizeT');
            this.writeParam(isFinal,isString,wordLengths.BitPerPtrDiffT,[],'BitPerPtrDiffT');
            isString=true;
            this.writeParam(isFinal,isString,hwImpl.Endianess,...
            @(x,y)this.translateEndianess(y),'Endianess');
            this.writeParam(isFinal,isString,hwImpl.IntDivRoundTo,...
            @(x,y)this.translateIntDivRoundTo(y),'IntDivRoundTo');
            isString=false;
            this.writeParam(isFinal,isString,hwImpl.ShiftRightIntArith,...
            [],'ShiftRightIntArith');
        end

        function writePWSIndependentValues(this,coderAssumptions)
            coderConfig=coderAssumptions.CoderConfig;
            assumptions=coderAssumptions.Assumptions;

            isFinal=false;
            isString=false;






            this.writeParam(isFinal,isString,coderConfig.LongLongMode,[],'LongLongMode');
            this.writeParam(isFinal,isString,coderConfig.PortableWordSizes,[],'PortableWordSizes');
            isString=true;
            this.writeParam(isFinal,isString,coderConfig.HWDeviceType,@(x,y)this.wrapWithDoubleQuotes(y),'HWDeviceType');



            isString=false;
            this.writeParam(isFinal,isString,assumptions.MemoryAtStartup,[],'MemoryAtStartup');
            this.writeParam(isFinal,isString,assumptions.DynamicMemoryAtStartup,[],'DynamicMemoryAtStartup');
            this.writeParam(isFinal,isString,assumptions.DenormalFlushToZero,[],'DenormalFlushToZero');
            this.Writer.decIndent;

            isFinal=true;
            this.writeParam(isFinal,isString,assumptions.DenormalAsZero,[],'DenormalAsZero');
            this.Writer.decIndent;
        end

        function writeSectionIncludeGuardHeader(this)
            this.Writer.wLine('#ifndef %s',this.IncludeGuard);
            this.Writer.wLine('#define %s',this.IncludeGuard);
            this.Writer.newLine;
        end

        function writeSectionIncludeGuardTrailer(this)
            this.Writer.wLine('#endif /* %s */',this.IncludeGuard);
        end

        function writeParam(this,isFinal,isString,paramVal,fhRewrite,param)

            if~isempty(fhRewrite)

                paramVal=fhRewrite(param,paramVal);
            end

            if isString
                wLineTemplate='%s%s /* %s */%s';
            else
                wLineTemplate='%d%s /* %s */%s';
            end


            this.writeParamValue(wLineTemplate,isFinal,paramVal,param);
        end


        function writeParamValue(this,wLineTemplate,isFinal,paramVal,param)
            if isFinal
                commaStr='';
                closeBraceStr='};';
            else
                commaStr=',';
                closeBraceStr='';
            end

            this.Writer.wLine(wLineTemplate,paramVal,commaStr,param,closeBraceStr);
        end
    end


    methods(Static,Access=private)
        function str=wrapWithDoubleQuotes(str)

            str=sprintf('"%s"',str);
        end

        function enumVal=translateEndianess(endianess)

            switch endianess
            case 'LittleEndian'
                enumVal='CA_LITTLE_ENDIAN';
            case 'BigEndian'
                enumVal='CA_BIG_ENDIAN';
            case 'Unspecified'
                enumVal='CA_UNSPECIFIED';
            otherwise
                assert(false,'Unexpected setting for TargetEndianess: %s',endianess);
            end
        end

        function enumVal=translateIntDivRoundTo(intDivRoundTo)

            switch intDivRoundTo
            case 'Floor'
                enumVal='CA_FLOOR';
            case 'Zero'
                enumVal='CA_ZERO';
            case 'Undefined'
                enumVal='CA_UNDEFINED';
            otherwise
                assert(false,'Unexpected setting for TargetIntDivRoundTo: %s',intDivRoundTo);
            end
        end
    end
end


