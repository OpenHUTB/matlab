function writeA2LWithECUAddressIFDataXCP(a2lFileFullPath,mapFileFullPath,ifDataXcp,segments,includeXCPInfo,usingUserCustomizationObj)










    if~isempty(segments)&&...
        ~isempty(which('slrealtime.internal.cal.PageSwitchingSegment'))
        segText=coder.internal.xcp.a2l.slrealtime.getSegmentsString(segments);
    else
        segText='';
    end
    newSegmentTextWithECUAddrSize=segText;


    a2lText=fileread(a2lFileFullPath);
    newA2LTextWithECUAddress=a2lText;



    if~isempty(mapFileFullPath)


        addrPrefixECU='0x0* \/\* @ECU_Address@';
        addrPrefixSize='0x0* \/\* @SEGMENT_SIZE@';
        addrSuffixCommon='@ \*\/';


        fileFormat=rtw.esa.getFileFormat(mapFileFullPath);


        assert(strcmp(fileFormat,'ELF'),'Map file format is not ELF');


        db=coder.internal.DwarfParser(mapFileFullPath);







        missingSymbolList={};
        invalidAddressList={};
        repfun=@(name)loc_getSymbolValForName(name);%#ok<NASGU>
        newA2LTextWithECUAddress=regexprep(a2lText,[addrPrefixECU,'(\S+)',addrSuffixCommon],...
        '0x${repfun($1)}');

        newSegmentTextWithECUAddress=regexprep(segText,[addrPrefixECU,'(\S+)',addrSuffixCommon],...
        '0x${repfun($1)}');

        repfun=@(name)loc_getSymbolSizeForName(name);
        newSegmentTextWithECUAddrSize=regexprep(newSegmentTextWithECUAddress,[addrPrefixSize,'(\S+)',addrSuffixCommon],...
        '0x${repfun($1)}');


        if~isempty(invalidAddressList)
            msg=message('RTW:asap2:SymbolAddressExceedsLimit',strjoin(invalidAddressList,', '));
            disp(msg.getString());
        end




        if~isempty(missingSymbolList)
            msg=message('RTW:asap2:NoSymbolInTable',...
            strjoin(missingSymbolList,', '),'ELF',mapFileFullPath);
            disp(msg.getString());
        end
    end

    if includeXCPInfo











        [a2lContentsTillBeginModule,a2lContentsRest]=splitA2LContents(newA2LTextWithECUAddress,...
        '/begin MODULE');
        if~isempty(usingUserCustomizationObj)&&~isempty(usingUserCustomizationObj.AfterBeginModuleContents)

            a2lBeforeBeginPart=extractBefore(a2lContentsRest,'/begin');
            a2lContentsRest=append('    /begin',extractAfter(a2lContentsRest,'/begin'));
        end


        fileWriter=getFileWriter(a2lFileFullPath);
        a2lWriter=coder.internal.xcp.a2l.A2LWriter(fileWriter);


        a2lWriter.wLine(a2lContentsTillBeginModule);
        a2lWriter.wLine('');






        if~isempty(usingUserCustomizationObj)&&~isempty(usingUserCustomizationObj.AfterBeginModuleContents)
            a2lWriter.wLine(a2lBeforeBeginPart);
            a2lWriter.wLine('');
        end


        a2lWriter.wLine(['    ',getA2ML()]);



        baseIndent=4;
        indentSpacing=2;
        str=asam.mcd2mc.writeIFDataXCPInfo(ifDataXcp,...
        baseIndent,...
        indentSpacing);

        a2lWriter.wLine(str);
        a2lWriter.wLine('');

        if~isempty(newSegmentTextWithECUAddrSize)

            [a2lContentsTillBeginMod_par,a2lContentsLast]=splitA2LContents(a2lContentsRest,...
            '/begin MOD_PAR');


            if~isempty(usingUserCustomizationObj)&&~isempty(usingUserCustomizationObj.AfterBeginModParContents)
                [a2lContentsTillBeginMod_par,a2lContentsLast]=splitA2LContents(a2lContentsRest,...
                usingUserCustomizationObj.AfterBeginModParContents);
            end


            a2lWriter.wLine(a2lContentsTillBeginMod_par);


            a2lWriter.wLine(newSegmentTextWithECUAddrSize);


            a2lWriter.wLine(a2lContentsLast);
        else

            a2lWriter.wLine(a2lContentsRest);
        end
    end


    function hexaddr=loc_getSymbolValForName(name)
        try

            rec=db.describeSymbol(name);
            hexaddr=dec2hex(rec.address,8);
            if rec.address>0xFFFFFFFF
                invalidAddressList{end+1}=name;
            end
        catch

            hexaddr=['0000 /* @ECU_Address@',name,'@ */'];
            missingSymbolList{end+1}=name;
        end
    end


    function hexsize=loc_getSymbolSizeForName(name)
        try

            rec=db.describeSymbol(name);
            hexsize=dec2hex(rec.size,2);
        catch

            hexsize=['00 /* @SEGMENT_SIZE@',name,'@ */'];
            missingSymbolList{end+1}=name;
        end
    end
end

function varargout=splitA2LContents(a2lContents,splitLine)


    varargout=regexp(a2lContents,...
    ['(?<=(',splitLine,'.*))\n'],...
    'split','once','dotexceptnewline');
end

function text=getA2ML()





    mfd=fileparts(mfilename('fullpath'));
    text=fileread(fullfile(mfd,'xcp100.aml'));
end


function fileWriter=getFileWriter(outputFile)


    append=false;
    callCBeautifier=false;
    obfuscateCode=false;
    fileWriter=rtw.connectivity.FileWriter(outputFile,append,callCBeautifier,obfuscateCode);
end


