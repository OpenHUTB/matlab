classdef PwsInstrumenter<internal.cxxfe.FrontEndHandler

    properties
        IsCharSigned=true;
        CharBitSize=8;
        SizeofShort=2;
        SizeofInt=4;
        SizeofLong=4;
        SizeofLongLong=8;
        SizeofFloat=4;
        SizeofDouble=8;
        SizeofLongDouble=16;
        SizeType='long';
        PtrdiffType='long';
        WcharType='unsigned short';
        MarshallParameters=true;
        ArithmeticCasts=true;
        ReplacementFunctions;
        DirToIgnore={}
    end


    properties(Access=public)
        TypedefDeclarations;
    end


    methods(Access=private)
        function targetString=getTargetString(this)

            if this.IsCharSigned
                signedCharStr='s';
            else
                signedCharStr='u';
            end

            targetString=sprintf('%c:%d:%d:%d:%d:%d:%d:%d:%d:%s:%s:%s',...
            signedCharStr,this.CharBitSize,...
            this.SizeofShort,this.SizeofInt,this.SizeofLong,this.SizeofLongLong,...
            this.SizeofFloat,this.SizeofDouble,this.SizeofLongDouble,...
            this.SizeType,this.PtrdiffType,this.WcharType);
        end


        function optionString=getOptionsString(this)
            optionString='';
            if~this.MarshallParameters
                if~this.arithmeticCasts
                    optionString='no_marshalling,no_casts';
                else
                    optionString='no_marshalling';
                end
            elseif~this.ArithmeticCasts
                optionString='no_casts';
            end
            firstElement=isempty(optionString);
            for k=this.ReplacementFunctions.keys()
                name=k{1};
                replacement=this.ReplacementFunctions(name);

                if firstElement
                    optionString=[name,'=',replacement];
                else
                    optionString=[optionString,',',name,'=',replacement];%#ok;
                    firstElement=false;
                end
            end
        end
    end


    methods
        function obj=PwsInstrumenter()
            obj.ReplacementFunctions=containers.Map();
        end


        function setTargetInfoString(instance,targetInfoString)
            elements=strsplit(targetInfoString,':');
            if length(elements)==12
                if strcmp(elements{1},'s')
                    instance.IsCharSigned=true;
                else
                    instance.IsCharSigned=false;
                end
                instance.CharBitSize=sscanf(elements{2},'%d');
                instance.SizeofShort=sscanf(elements{3},'%d');
                instance.SizeofInt=sscanf(elements{4},'%d');
                instance.SizeofLong=sscanf(elements{5},'%d');
                instance.SizeofLongLong=sscanf(elements{6},'%d');
                instance.SizeofFloat=sscanf(elements{7},'%d');
                instance.SizeofDouble=sscanf(elements{8},'%d');
                instance.SizeofLongDouble=sscanf(elements{9},'%d');
                instance.SizeType=elements{10};
                instance.PtrdiffType=elements{11};
                instance.WcharType=elements{12};
            else
                codeinstrum.internal.error('CodeInstrumentation:portablewordsizes:invalidTargetDescriptionString',targetInfoString);
            end
        end


        function setAllTargetInfo(instance,...
            IsCharSigned,...
            CharBits,...
            SizeofShort,...
            SizeofInt,...
            SizeofLong,...
            SizeofLongLong,...
            SizeofFloat,...
            SizeofDouble,...
            SizeofLongDouble,...
            SizeType,...
            PtrdiffType,...
            WcharType)
            instance.IsCharSigned=IsCharSigned;
            instance.CharBitSize=CharBits;
            instance.SizeofShort=SizeofShort;
            instance.SizeofInt=SizeofInt;
            instance.SizeofLong=SizeofLong;
            instance.SizeofLongLong=SizeofLongLong;
            instance.SizeofFloat=SizeofFloat;
            instance.SizeofDouble=SizeofDouble;
            instance.SizeofLongDouble=SizeofLongDouble;
            instance.SizeType=SizeType;
            instance.PtrdiffType=PtrdiffType;
            instance.WcharType=WcharType;
        end


        function setTargetInfo(instance,varargin)
            p=inputParser;

            p.addParameter('IsCharSigned',instance.IsCharSigned);
            p.addParameter('CharBitSize',instance.CharBitSize);
            p.addParameter('SizeofShort',instance.SizeofShort);
            p.addParameter('SizeofInt',instance.SizeofInt);
            p.addParameter('SizeofLong',instance.SizeofLong);
            p.addParameter('SizeofLongLong',instance.SizeofLongLong);
            p.addParameter('SizeofFloat',instance.SizeofFloat);
            p.addParameter('SizeofDouble',instance.SizeofDouble);
            p.addParameter('SizeofLongDouble',instance.SizeofLongDouble);
            p.addParameter('SizeType',instance.SizeType);
            p.addParameter('PtrdiffType',instance.PtrdiffType);
            p.addParameter('WcharType',instance.WcharType);

            parse(p,varargin{:});
            instance.IsCharSigned=p.Results.IsCharSigned;
            instance.CharBitSize=p.Results.CharBitSize;
            instance.SizeofShort=p.Results.SizeofShort;
            instance.SizeofInt=p.Results.SizeofInt;
            instance.SizeofLong=p.Results.SizeofLong;
            instance.SizeofLongLong=p.Results.SizeofLongLong;
            instance.SizeofFloat=p.Results.SizeofFloat;
            instance.SizeofDouble=p.Results.SizeofDouble;
            instance.SizeofLongDouble=p.Results.SizeofLongDouble;
            instance.SizeType=p.Results.SizeType;
            instance.PtrdiffType=p.Results.PtrdiffType;
            instance.WcharType=p.Results.WcharType;

        end


        function addReplacementFunction(instance,originalFunction,replacementFunction)
            instance.ReplacementFunctions(originalFunction)=replacementFunction;
        end

        function afterPreprocessing(this,ilPtr,feOptions,fName,feMsgs)%#ok<INUSD>

        end

        function afterParsing(this,ilPtr,~,fName,~)
            targetString=this.getTargetString();
            options=this.getOptionsString();

            [this.TypedefDeclarations,pwsMessages]=portable_word_sizes_mex(ilPtr,targetString,options,this.DirToIgnore);%#ok<ASGLU> 
            messages=evalc('internal.cxxfe.util.printFEMessages(pwsMessages);');
            if~isempty(messages)
                msg=message('CodeInstrumentation:portablewordsizes:instrumentationError',fName,messages);
                warning('portablewordsizes:instrumentationError','%s',msg.getString());
            end
        end

        function finalizeFile(this,fileName)


            [fid,errMsg]=fopen(fileName,'rb');
            if fid<0||~isempty(errMsg)
                codeinstrum.internal.error('CodeInstrumentation:utils:openForReadingError',fileName,errMsg);
            end
            instrumentedFileContent=fread(fid,Inf,'*uint8')';
            fclose(fid);

            [fid,errMsg]=fopen(fileName,'wb');
            if fid<0||~isempty(errMsg)
                codeinstrum.internal.error('CodeInstrumentation:utils:openForWritingError',fileName,errMsg);
            end
            fprintf(fid,'%s\n',this.TypedefDeclarations);
            fwrite(fid,instrumentedFileContent,'*uint8');
            fclose(fid);
        end

        function hasError=instrumentFile(this,fileName,frontEndOptions)
            msgs=internal.cxxfe.FrontEnd.parseFile(fileName,frontEndOptions,this);

            hasError=~all(strcmp({msgs.kind},'warning'));

            if polyspace.internal.logging.Logger.getLogger('cxxfe.parser').Level>=polyspace.internal.logging.Level.FINE
                internal.cxxfe.util.printFEMessages(msgs,false);
            end

            if hasError

                codeinstrum.internal.error('CodeInstrumentation:instrumenter:instrumentationFailed',fileName);
            else
                this.finalizeFile(frontEndOptions.GenOutput);
            end
        end
    end
end



