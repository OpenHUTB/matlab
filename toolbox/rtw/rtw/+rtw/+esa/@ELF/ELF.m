classdef ELF<rtw.esa.BinaryFormat












    properties(Constant=true,Hidden=true)



        ELFMagicNumber=[char(hex2dec('7f')),'E','L','F'];

    end


    properties(Constant=true,GetAccess='private')

        ElfIdent=...
        {...
        'uint8',16,'e_ident'...
        };


        EI_MAG0=1;
        EI_MAG1=2;
        EI_MAG2=3;
        EI_MAG3=4;
        EI_CLASS=5;
        EI_DATA=6;
        EI_VERSION=7;
        EI_PAD=8;
        EI_NIDENT=16;


        ELFCLASS32=1;
        ELFCLASS64=2;


        ELFDATA2LSB=1;
        ELFDATA2MSB=2;


        ET_NONE=0;
        ET_REL=1;
        ET_EXEC=2;
        ET_DYN=3;
        ET_CORE=4;


        PT_NULL=0;
        PT_LOAD=1;
        PT_DYNAMIC=2;
        PT_INTERP=3;
        PT_NOTE=4;
        PT_SHLIB=5;
        PT_PHDR=6;


        ElfProgramTypeStrings=...
        struct('Type',...
        {...
        rtw.esa.ELF.PT_NULL,...
        rtw.esa.ELF.PT_LOAD,...
        rtw.esa.ELF.PT_DYNAMIC,...
        rtw.esa.ELF.PT_INTERP,...
        rtw.esa.ELF.PT_NOTE,...
        rtw.esa.ELF.PT_SHLIB,...
        rtw.esa.ELF.PT_PHDR,...
        },...
        'String',...
        {...
        'unused',...
        'loadable',...
        'dynamic',...
        'interpreter',...
        'note',...
        'reserved',...
        'header',...
        });...


        SHT_NULL=0;
        SHT_PROGBITS=1;
        SHT_SYMTAB=2;
        SHT_STRTAB=3;
        SHT_RELA=4;
        SHT_HASH=5;
        SHT_DYNAMIC=6;
        SHT_NOTE=7;
        SHT_NOBITS=8;
        SHT_REL=9;
        SHT_SHLIB=10;
        SHT_DYNSYM=11;


        ElfSectionTypeStrings=...
        struct('Type',...
        {...
        rtw.esa.ELF.SHT_NULL,...
        rtw.esa.ELF.SHT_PROGBITS,...
        rtw.esa.ELF.SHT_SYMTAB,...
        rtw.esa.ELF.SHT_STRTAB,...
        rtw.esa.ELF.SHT_RELA,...
        rtw.esa.ELF.SHT_HASH,...
        rtw.esa.ELF.SHT_DYNAMIC,...
        rtw.esa.ELF.SHT_NOTE,...
        rtw.esa.ELF.SHT_NOBITS,...
        rtw.esa.ELF.SHT_REL,...
        rtw.esa.ELF.SHT_SHLIB,...
        rtw.esa.ELF.SHT_DYNSYM,...
        },...
        'String',...
        {...
        'unused',...
        'program info',...
        'symbol table',...
        'string table',...
        'rela',...
        'hash table',...
        'dynamic linking table',...
        'note',...
        'uninitialized',...
        'rel',...
        'reserved',...
        'dynamic symbol table',...
        });...


        SHF_WRITE=1;
        SHF_ALLOC=2;
        SHF_EXECINSTR=4;


        DOTSTRTAB='.strtab';
        DOTSYMTAB='.symtab';




        STB_LOCAL=0;
        STB_GLOBAL=1;
        STB_WEAK=2;


        ElfSymbolBindingStrings=...
        struct('Binding',...
        {...
        rtw.esa.ELF.STB_LOCAL,...
        rtw.esa.ELF.STB_GLOBAL,...
        rtw.esa.ELF.STB_WEAK,...
        },...
        'String',...
        {...
        'local',...
        'global',...
        'weak',...
        });...


        STT_NOTYPE=0;
        STT_OBJECT=1;
        STT_FUNC=2;
        STT_SECTION=3;
        STT_FILE=4;


        ElfSymbolTypeStrings=...
        struct('Type',...
        {...
        rtw.esa.ELF.STT_NOTYPE,...
        rtw.esa.ELF.STT_OBJECT,...
        rtw.esa.ELF.STT_FUNC,...
        rtw.esa.ELF.STT_SECTION,...
        rtw.esa.ELF.STT_FILE,...
        },...
        'String',...
        {...
        'none',...
        'object',...
        'function',...
        'section',...
        'file',...
        });...


        SHN_UNDEF=0;
        SHN_ABS=hex2dec('fff1');
        SHN_COMMON=hex2dec('fff2');


        ElfSpecialSectionStrings=...
        struct('Section',...
        {...
        rtw.esa.ELF.SHN_UNDEF,...
        rtw.esa.ELF.SHN_ABS,...
        rtw.esa.ELF.SHN_COMMON,...
        },...
        'String',...
        {...
        'undefined',...
        'absolute',...
        'common',...
        });...




        Elf32_Addr='uint32';
        Elf32_Off='uint32';
        Elf32_Half='uint16';
        Elf32_Word='uint32';
        Elf32_Sword='int32';




        Elf32Header=...
        {...
        'uint8',16,'e_ident';...
        rtw.esa.ELF.Elf32_Half,1,'e_type';...
        rtw.esa.ELF.Elf32_Half,1,'e_machine';...
        rtw.esa.ELF.Elf32_Word,1,'e_version';...
        rtw.esa.ELF.Elf32_Addr,1,'e_entry';...
        rtw.esa.ELF.Elf32_Off,1,'e_phoff';...
        rtw.esa.ELF.Elf32_Off,1,'e_shoff';...
        rtw.esa.ELF.Elf32_Word,1,'e_flags';...
        rtw.esa.ELF.Elf32_Half,1,'e_ehsize';...
        rtw.esa.ELF.Elf32_Half,1,'e_phentsize';...
        rtw.esa.ELF.Elf32_Half,1,'e_phnum';...
        rtw.esa.ELF.Elf32_Half,1,'e_shentsize';...
        rtw.esa.ELF.Elf32_Half,1,'e_shnum';...
        rtw.esa.ELF.Elf32_Half,1,'e_shstrndx';...
        };




        Elf32ProgramHeader=...
        {...
        rtw.esa.ELF.Elf32_Word,1,'p_type';...
        rtw.esa.ELF.Elf32_Off,1,'p_offset';...
        rtw.esa.ELF.Elf32_Addr,1,'p_vaddr';...
        rtw.esa.ELF.Elf32_Addr,1,'p_paddr';...
        rtw.esa.ELF.Elf32_Word,1,'p_filesz';...
        rtw.esa.ELF.Elf32_Word,1,'p_memsz';...
        rtw.esa.ELF.Elf32_Word,1,'p_flags';...
        rtw.esa.ELF.Elf32_Word,1,'p_align';...
        };




        Elf32SectionHeader=...
        {...
        rtw.esa.ELF.Elf32_Word,1,'sh_name';...
        rtw.esa.ELF.Elf32_Word,1,'sh_type';...
        rtw.esa.ELF.Elf32_Word,1,'sh_flags';...
        rtw.esa.ELF.Elf32_Addr,1,'sh_addr';...
        rtw.esa.ELF.Elf32_Off,1,'sh_offset';...
        rtw.esa.ELF.Elf32_Word,1,'sh_size';...
        rtw.esa.ELF.Elf32_Word,1,'sh_link';...
        rtw.esa.ELF.Elf32_Word,1,'sh_info';...
        rtw.esa.ELF.Elf32_Word,1,'sh_addralign';...
        rtw.esa.ELF.Elf32_Word,1,'sh_entsize';...
        };




        Elf32SymbolTableEntry=...
        {...
        rtw.esa.ELF.Elf32_Word,1,'st_name';...
        rtw.esa.ELF.Elf32_Addr,1,'st_value';...
        rtw.esa.ELF.Elf32_Word,1,'st_size';...
        'uint8',1,'st_info';...
        'uint8',1,'st_other';...
        rtw.esa.ELF.Elf32_Half,1,'st_shndx';...
        };





        Elf64_Addr='uint64';
        Elf64_Off='uint64';
        Elf64_Half='uint16';
        Elf64_Word='uint32';
        Elf64_Sword='uint32';
        Elf64_Xword='uint64';
        Elf64_Sxword='uint64';




        Elf64Header=...
        {...
        'uint8',16,'e_ident';...
        rtw.esa.ELF.Elf64_Half,1,'e_type';...
        rtw.esa.ELF.Elf64_Half,1,'e_machine';...
        rtw.esa.ELF.Elf64_Word,1,'e_version';...
        rtw.esa.ELF.Elf64_Addr,1,'e_entry';...
        rtw.esa.ELF.Elf64_Off,1,'e_phoff';...
        rtw.esa.ELF.Elf64_Off,1,'e_shoff';...
        rtw.esa.ELF.Elf64_Word,1,'e_flags';...
        rtw.esa.ELF.Elf64_Half,1,'e_ehsize';...
        rtw.esa.ELF.Elf64_Half,1,'e_phentsize';...
        rtw.esa.ELF.Elf64_Half,1,'e_phnum';...
        rtw.esa.ELF.Elf64_Half,1,'e_shentsize';...
        rtw.esa.ELF.Elf64_Half,1,'e_shnum';...
        rtw.esa.ELF.Elf64_Half,1,'e_shstrndx';...
        };




        Elf64ProgramHeader=...
        {...
        rtw.esa.ELF.Elf64_Word,1,'p_type';...
        rtw.esa.ELF.Elf64_Word,1,'p_flags';...
        rtw.esa.ELF.Elf64_Off,1,'p_offset';...
        rtw.esa.ELF.Elf64_Addr,1,'p_vaddr';...
        rtw.esa.ELF.Elf64_Addr,1,'p_paddr';...
        rtw.esa.ELF.Elf64_Xword,1,'p_filesz';...
        rtw.esa.ELF.Elf64_Xword,1,'p_memsz';...
        rtw.esa.ELF.Elf64_Xword,1,'p_align';...
        };




        Elf64SectionHeader=...
        {...
        rtw.esa.ELF.Elf64_Word,1,'sh_name';...
        rtw.esa.ELF.Elf64_Word,1,'sh_type';...
        rtw.esa.ELF.Elf64_Xword,1,'sh_flags';...
        rtw.esa.ELF.Elf64_Addr,1,'sh_addr';...
        rtw.esa.ELF.Elf64_Off,1,'sh_offset';...
        rtw.esa.ELF.Elf64_Xword,1,'sh_size';...
        rtw.esa.ELF.Elf64_Word,1,'sh_link';...
        rtw.esa.ELF.Elf64_Word,1,'sh_info';...
        rtw.esa.ELF.Elf64_Xword,1,'sh_addralign';...
        rtw.esa.ELF.Elf64_Xword,1,'sh_entsize';...
        };




        Elf64SymbolTableEntry=...
        {...
        rtw.esa.ELF.Elf64_Word,1,'st_name';...
        'uint8',1,'st_info';...
        'uint8',1,'st_other';...
        rtw.esa.ELF.Elf64_Half,1,'st_shndx';...
        rtw.esa.ELF.Elf64_Addr,1,'st_value';...
        rtw.esa.ELF.Elf64_Xword,1,'st_size';...
        };

    end




    properties(Access='private')
FileClass
        ValidSpecialSectionIdxs;
        HeaderFormat;
        SectionHeaderFormat;
        ProgramHeaderFormat;
        SymbolTableEntryFormat;
        Header;
        SectionHeaders;
        ProgramHeaders;
        SectionNameTable;
        StrTblSecIdx;
        SymTblSecIdx;
        Symbols;
        Sections;
        Segments;

    end




    methods(Hidden=true)






        function obj=ELF(fileName)
            if(nargin~=1)
                DAStudio.error('RTW:asap2:invalidInputParam',mfilename);
            end


            initializeProperties(obj);


            parseFile(obj,fileName);
        end






        function symbols=getSymbolTable(obj)
            if(isempty(obj.Symbols))
                getSymbols(obj);
            end
            symbols=obj.Symbols;
        end

    end




    methods(Access='private')



        function initializeProperties(obj)
            obj.FileMap=[];
            obj.NeedByteSwap=false;
            obj.FileClass=0;

            validSpecialSectionStrs=rtw.esa.ELF.ElfSpecialSectionStrings;
            obj.ValidSpecialSectionIdxs=[validSpecialSectionStrs.Section];

            obj.HeaderFormat=[];
            obj.SectionHeaderFormat=[];
            obj.ProgramHeaderFormat=[];
            obj.SymbolTableEntryFormat=[];
            obj.Header=[];
            obj.SectionHeaders=[];
            obj.ProgramHeaders=[];
            obj.SectionNameTable=[];
            obj.StrTblSecIdx=[];
            obj.SymTblSecIdx=[];
            obj.Symbols=[];
            obj.Sections=[];
            obj.Segments=[];
        end




        function parseFile(obj,fileName)
            parseIdent(obj,fileName);
            getHeaders(obj);
            getSectionNameTable(obj);
            getSections(obj);
            getSegments(obj);
        end








        function parseIdent(obj,fileName)



            filemap=memmapfile(fileName,...
            'format',obj.ElfIdent,...
            'Repeat',1,...
            'Offset',0);
            ident=filemap.data;




            obj.FileClass=ident.e_ident(obj.EI_CLASS);
            if(ident.e_ident(obj.EI_CLASS)==obj.ELFCLASS64)
                headerFormat=rtw.esa.ELF.Elf64Header;
                sectionHeaderFormat=rtw.esa.ELF.Elf64SectionHeader;
                programHeaderFormat=rtw.esa.ELF.Elf64ProgramHeader;
                symbolTableEntryFormat=rtw.esa.ELF.Elf64SymbolTableEntry;
            elseif(ident.e_ident(obj.EI_CLASS)==obj.ELFCLASS32)
                headerFormat=rtw.esa.ELF.Elf32Header;
                sectionHeaderFormat=rtw.esa.ELF.Elf32SectionHeader;
                programHeaderFormat=rtw.esa.ELF.Elf32ProgramHeader;
                symbolTableEntryFormat=rtw.esa.ELF.Elf32SymbolTableEntry;
            else
                DAStudio.error('RTW:ESA:unsupportedELF');
            end




            if(ident.e_ident(obj.EI_DATA)==obj.ELFDATA2MSB)
                isBigEndian=true;
            elseif(ident.e_ident(obj.EI_DATA)==obj.ELFDATA2LSB)
                isBigEndian=false;
            else
                DAStudio.error('RTW:ESA:unsupportedELF');
            end





            needByteSwap=rtw.esa.BinaryFormat.isByteSwapNeeded(isBigEndian);




            obj.FileMap=filemap;
            obj.NeedByteSwap=needByteSwap;
            obj.HeaderFormat=headerFormat;
            obj.SectionHeaderFormat=sectionHeaderFormat;
            obj.ProgramHeaderFormat=programHeaderFormat;
            obj.SymbolTableEntryFormat=symbolTableEntryFormat;
        end





        function getHeaders(obj)
            sectionHeaders=[];
            programHeaders=[];




            obj.FileMap.format=obj.HeaderFormat;
            obj.FileMap.repeat=1;
            obj.FileMap.offset=0;
            header=obj.FileMap.data;


            if(obj.NeedByteSwap)
                header=rtw.esa.BinaryFormat.doByteSwap(header);
            end




            if~((header.e_type==rtw.esa.ELF.ET_REL)||...
                (header.e_type==rtw.esa.ELF.ET_EXEC)||...
                (header.e_type==rtw.esa.ELF.ET_DYN))
                DAStudio.error('RTW:ESA:unsupportedELF');
            end




            numSections=header.e_shnum;
            sectionOffset=header.e_shoff;

            if(numSections>0)



                obj.FileMap.format=obj.SectionHeaderFormat;
                obj.FileMap.repeat=numSections;
                obj.FileMap.offset=sectionOffset;
                sectionHeaders=obj.FileMap.data;


                if(obj.NeedByteSwap)
                    sectionHeaders=rtw.esa.BinaryFormat.doByteSwap(sectionHeaders);
                end
            end




            numSegments=header.e_phnum;
            segmentOffset=header.e_phoff;

            if(numSegments>0)



                obj.FileMap.format=obj.ProgramHeaderFormat;
                obj.FileMap.Repeat=numSegments;
                obj.FileMap.Offset=segmentOffset;
                programHeaders=obj.FileMap.data;


                if(obj.NeedByteSwap)
                    programHeaders=rtw.esa.BinaryFormat.doByteSwap(programHeaders);
                end
            end




            obj.Header=header;
            obj.SectionHeaders=sectionHeaders;
            obj.ProgramHeaders=programHeaders;
        end








        function getSectionNameTable(obj)
            secNameTbl='';

            if(~isempty(obj.SectionHeaders))




                secNameTblIdx=obj.Header.e_shstrndx;
                secNameTblExists=(secNameTblIdx>0);





                secNameTblIdx=secNameTblIdx+1;






                if(secNameTblExists)




                    secNameTblSize=obj.SectionHeaders(secNameTblIdx).sh_size;
                    secNameTblOffset=obj.SectionHeaders(secNameTblIdx).sh_offset;
                    obj.FileMap.format='uint8';
                    obj.FileMap.Repeat=secNameTblSize;
                    obj.FileMap.Offset=secNameTblOffset;
                    secNameTblStr=char(obj.FileMap.data');













                    secNameOffsets=[obj.SectionHeaders.sh_name]+1;
                    numSections=obj.Header.e_shnum;
                    secNameTbl=cell(1,numSections);
                    secNameTbl{1}='';
                    for nSection=2:numSections
                        secNameTbl{nSection}=rtw.esa.ELF.getstring_nullterminated(secNameTblStr,secNameOffsets(nSection));
                    end
                end
            end




            obj.SectionNameTable=secNameTbl;
        end





        function getSections(obj)
            sections=[];

            numSections=obj.Header.e_shnum;
            if(~isempty(obj.SectionHeaders))



                secNameStrs=cell(1,numSections);
                for nSec=1:numSections
                    secNameStrs{nSec}=getSecNameFromIdx(obj,nSec-1);
                end




                secTypeStrs=cell(1,numSections);
                secTypes=[obj.SectionHeaders.sh_type];
                validSecTypeStrs=rtw.esa.ELF.ElfSectionTypeStrings;
                validSecTypes=[validSecTypeStrs.Type];
                for nSec=1:numSections
                    idx=find(validSecTypes==secTypes(nSec));
                    if(isempty(idx))
                        secTypeStrs{nSec}='';
                    else
                        secTypeStrs{nSec}=rtw.esa.ELF.ElfSectionTypeStrings(idx).String;
                    end
                end




                secInfoWriteStrs=cell(1,numSections);
                secInfoAllocStrs=cell(1,numSections);
                secInfoExecInstrStrs=cell(1,numSections);
                for nSec=1:numSections
                    if(bitand(obj.SectionHeaders(nSec).sh_flags,rtw.esa.ELF.SHF_WRITE))
                        secInfoWriteStrs{nSec}='true';
                    else
                        secInfoWriteStrs{nSec}='false';
                    end
                    if(bitand(obj.SectionHeaders(nSec).sh_flags,rtw.esa.ELF.SHF_ALLOC))
                        secInfoAllocStrs{nSec}='true';
                    else
                        secInfoAllocStrs{nSec}='false';
                    end
                    if(bitand(obj.SectionHeaders(nSec).sh_flags,rtw.esa.ELF.SHF_EXECINSTR))
                        secInfoExecInstrStrs{nSec}='true';
                    else
                        secInfoExecInstrStrs{nSec}='false';
                    end
                end




                sections=struct('Name',secNameStrs,...
                'Type',secTypeStrs,...
                'Writable',secInfoWriteStrs,...
                'Allocates',secInfoAllocStrs,...
                'Instructions',secInfoExecInstrStrs);
            end




            obj.Sections=sections;
        end





        function getSegments(obj)
            segments=[];

            numSegments=obj.Header.e_phnum;
            if(~isempty(obj.ProgramHeaders))



                segStart=double([obj.ProgramHeaders.p_offset]);
                segEnd=segStart+double([obj.ProgramHeaders.p_filesz]);
                secStart=double([obj.SectionHeaders.sh_offset]);
                secEnd=secStart+double([obj.SectionHeaders.sh_size]);
                segSecIdxs=cell(1,numSegments);
                for nSegment=1:numSegments
                    segSecIdxs{nSegment}=(find(secStart>=segStart(nSegment)&...
                    secEnd<=segEnd(nSegment)));
                end




                segTypeStrs=cell(1,numSegments);
                segTypes=[obj.ProgramHeaders.p_type];
                validSegTypeStrs=rtw.esa.ELF.ElfProgramTypeStrings;
                validSegTypes=[validSegTypeStrs.Type];
                for nSeg=1:numSegments
                    idx=find(validSegTypes==segTypes(nSeg));
                    if(isempty(idx))
                        segTypeStrs{nSeg}='';
                    else
                        segTypeStrs{nSeg}=rtw.esa.ELF.ElfProgramTypeStrings(idx).String;
                    end
                end




                segments=struct('Type',segTypeStrs,...
                'SectionIdxs',segSecIdxs,...
                'MemorySize',{obj.ProgramHeaders.p_memsz});
            end




            obj.Segments=segments;
        end






        function name=getSecNameFromIdx(obj,idx)
            name='';







            specialIdx=find(obj.ValidSpecialSectionIdxs==idx);
            if(~isempty(specialIdx))
                name=rtw.esa.ELF.ElfSpecialSectionStrings(specialIdx).String;
                return;
            end





            if(~isempty(obj.SectionNameTable))
                name=obj.SectionNameTable{idx+1};
            end
        end





        function idx=getSecIdxFromName(obj,name)
            idx=[];






            if(~isempty(obj.SectionNameTable))
                idx=find(strcmpi(obj.SectionNameTable,name));
                idx=idx-1;
            end
        end
















        function getSymbols(obj)
            symbols=[];





            symTblSecIdx=getSecIdxFromName(obj,rtw.esa.ELF.DOTSYMTAB);
            strTblSecIdx=getSecIdxFromName(obj,rtw.esa.ELF.DOTSTRTAB);

            if(~isempty(symTblSecIdx))






                symTblSecHdr=obj.SectionHeaders(symTblSecIdx+1);
                symTblOffset=symTblSecHdr.sh_offset;
                symTblSize=symTblSecHdr.sh_size;
                symTblEntrySize=symTblSecHdr.sh_entsize;
                numSymbols=double(symTblSize)/double(symTblEntrySize);

                if(numSymbols>1)



                    obj.FileMap.format=obj.SymbolTableEntryFormat;
                    obj.FileMap.Repeat=numSymbols;
                    obj.FileMap.Offset=symTblOffset;
                    symTable=obj.FileMap.data;


                    if(obj.NeedByteSwap)
                        symTable=rtw.esa.BinaryFormat.doByteSwap(symTable);
                    end




                    if(~isempty(strTblSecIdx))




                        strTblSecHdr=obj.SectionHeaders(strTblSecIdx+1);
                        strTblOffset=strTblSecHdr.sh_offset;
                        strTblSize=strTblSecHdr.sh_size;




                        obj.FileMap.format='uint8';
                        obj.FileMap.Repeat=strTblSize;
                        obj.FileMap.Offset=strTblOffset;
                        strTable=char(obj.FileMap.data');












                        symStrTblIdxs=[symTable.st_name]+1;
                    else




                        symNameStrs=cell(1,numSymbols);
                        for nSymbol=1:numSymbols
                            symNameStrs{nSymbol}='';
                        end
                    end




                    symTypes=rtw.esa.ELF.getSymTblType([symTable.st_info]);


                    symBindings=rtw.esa.ELF.getSymTblBinding([symTable.st_info]);



                    idx=find((rtw.esa.ELF.STT_OBJECT==symTypes)&...
                    (rtw.esa.ELF.STB_GLOBAL==symBindings|...
                    rtw.esa.ELF.STB_WEAK==symBindings));


                    symNameStrs=arrayfun(@(x)rtw.esa.ELF.getstring_nullterminated(strTable,symStrTblIdxs(x)),idx,'UniformOutput',false);

                    if(obj.FileClass==obj.ELFCLASS64)
                        numHexDigits=16;
                    else
                        numHexDigits=8;
                    end
                    symValue=cellstr(dec2hex([symTable(idx).st_value],...
                    numHexDigits));
                    symValue=symValue';


                    symbols=containers.Map(symNameStrs,symValue);
                end
            end




            obj.Symbols=symbols;
        end

    end




    methods(Static=true,Access='private')



        function v=getSymTblBinding(a)
            v=bitshift(a,-4);
        end




        function v=getSymTblType(a)
            v=bitand(a,hex2dec('0f'));
        end






        function txt=getstring_nullterminated(fulltxt,startpos)
            i=startpos;
            while fulltxt(i)~=uint8(0)
                i=i+1;
            end
            txt=fulltxt(startpos:i-1);
        end

    end

end
