function[finalOutput,errorMessages]=convertToRTF(this,theFormat)









    mySheet=this.getDSSSLStylesheetInfo(theFormat);
    appdata=rptgen.appdata_rg;
    encoding=appdata.RootComponent.FileEncoding;

    if isempty(mySheet.Filename)
        error(message('rptgen:rx_db_output:missingStylesheetMsg',this.getStylesheetID()));
    end

    jadeExecutable=locGetJadeExecutable();
    catalogFile=fullfile(matlabroot(),'sys','jade','mwsupport','catalog');

    driverFile=LocMakeDriverFile(mySheet,encoding);
    if isempty(driverFile)
        finalOutput='';
        errorMessages={
'RPTGEN:E:Could not write driver file "rptdriver.dsl".'
'RPTGEN:E:Check directory and file permissions.'
        };
        return;
    end

    [~,driverFileName,driverFileExt]=fileparts(driverFile);

    xmlFile=fullfile(matlabroot(),'sys','jade','docbook','dtds','decls','xml.dcl');
    xmlFile=[' "',xmlFile,'" '];

    JadeString=[...
    '"',jadeExecutable,'"'...
    ,' -wno-valid '...
    ,' -E 5000'...
    ,' -c "',catalogFile,'"'...
    ,' -t rtf'...
    ,' -b "',encoding,'"'...
    ,' -d "',driverFileName,driverFileExt,'"'];

    finalOutput=mySheet.reportname;
    rptDir=fileparts(mySheet.reportname);


    [intermediateSource,intermediateOutput]=locNonAsciiFileNameSupport(mySheet.sourcename,finalOutput,encoding);

    [~,intermediateSourceFileNameRoot,intermediateSourceFileExt]=fileparts(intermediateSource);
    intermediateSourceFileName=[intermediateSourceFileNameRoot,intermediateSourceFileExt];

    [~,intermediateOutputFileNameRoot,intermediateOutputFileExt]=fileparts(intermediateOutput);
    intermediateOutputFileName=[intermediateOutputFileNameRoot,intermediateOutputFileExt];

    JadeString=[JadeString...
    ,' -o "',intermediateOutputFileName,'"'...
    ,xmlFile...
    ,' "',intermediateSourceFileName,'"'];



    if(exist(finalOutput,'file')==2)
        try
            delete(finalOutput);
        catch
            warning(message('rptgen:rx_db_output:couldNotDeleteMsg',finalOutput));
        end
    end
    if(exist(intermediateOutput,'file')==2)
        try
            delete(intermediateOutput);
        catch
            warning(message('rptgen:rx_db_output:couldNotDeleteMsg',intermediateOutput));
        end
    end


    if~strcmpi(encoding,'shift_jis')




        setenv('SP_ENCODING',encoding);
    end


    oldDir=pwd;
    cd(rptDir);
    result=LocSystemCall(JadeString);
    setenv('SP_ENCODING','');
    cd(oldDir);

    if LocIsResultError(result)
        finalOutput='';
    else
        if~strcmp(intermediateOutput,finalOutput)
            locForceMoveFile(intermediateOutput,finalOutput);
        end
        if~strcmp(intermediateSource,mySheet.sourcename)
            locForceMoveFile(intermediateSource,mySheet.sourcename);
        end
    end

    isDebug=appdata.DebugMode;
    if~isDebug
        try
            delete(driverFile);
        catch ME
            warning(message('rptgen:rx_db_output:unableToDeleteDriverFile',ME.message));
        end
    else
        disp(JadeString);
    end

    errorMessages=LocWashErrors(result);


    function clean=LocWashErrors(messy)




        eol=strfind(messy,newline);
        eol=[0,eol];

        clean={};
        if(length(eol)>1)
            for i=2:length(eol)
                line=messy(eol(i-1)+1:eol(i)-1);
                fileseps=strfind(line,filesep);
                if~isempty(fileseps)
                    line=line(fileseps(length(fileseps))+1:end);
                end
                clean{end+1}=line;%#ok
            end
        end


        function jd=locGetJadeExecutable()

            arch=lower(computer);
            if strcmpi(arch,'pcwin')
                jadeFile='openjade.exe';
                arch='win32';
            elseif strcmpi(arch,'pcwin64')
                jadeFile='openjade.exe';
                arch='win64';
            else
                jadeFile='openjade';

            end


            jd=fullfile(pwd,jadeFile);
            if exist(jd,'file')
                return;
            end


            jd=fullfile(matlabroot(),'sys','jade','bin',arch,jadeFile);
            if exist(jd,'file')
                return;
            end


            warning(message('rptgen:rx_db_output:NoJADE'));
            jd=jadeFile;


            function driverName=LocMakeDriverFile(sheetStruct,encoding)

                sourcePath=fileparts(sheetStruct.sourcename);
                langFile=['dbl1',strrep(sheetStruct.Language,'_',''),'.dsl'];

                driverName=fullfile(sourcePath,'rptdriver.dsl');
                myFid=fopen(driverName,'w','n',encoding);
                if(myFid>0)
                    stylePath=fileparts(sheetStruct.Filename);
                    locEntityString=['<!ENTITY l10n SYSTEM    "'...
                    ,fullfile(stylePath,['../common/',langFile])...
                    ,'" CDATA DSSSL>$CR'];
                    locExternalSpecification='<external-specification id="l10n" document="l10n">$CR';
                    sheetStruct.Variables(end+1,:)=...
                    {'%default-language%',['"',sheetStruct.Language,'"']};


                    locEntityString=sprintf('%s<!ENTITY tmwlink SYSTEM "%s">',...
                    locEntityString,...
                    fullfile(matlabroot(),'sys','jade','docbook','contrib','textlink','textlink.dsl'));
                    entityImports='$CR&tmwlink;$CR';

                    drvHeader=['<!DOCTYPE style-sheet PUBLIC '...
                    ,'"-//James Clark//DTD DSSSL Style Sheet//EN" [$CR'...
                    ,'<!ENTITY dbstyle SYSTEM "',sheetStruct.Filename,'" CDATA DSSSL>$CR'...
                    ,locEntityString...
                    ,']>$CR'...
                    ,'$CR'...
                    ,'<style-sheet>$CR'...
                    ,'<style-specification use="l10n docbook">$CR'...
                    ,'<style-specification-body>$CR'...
                    ,entityImports...
                    ,'$CR'];

                    isJA=strncmpi(rpt_xml.getLanguage,'ja',2);
                    if isJA&&any(strncmpi(sheetStruct.Formats,'rtf',3))




                        fontKey='%mono-font-family%';
                        isFontCustomized=any(strcmp(sheetStruct.Variables(:,1),fontKey));
                        if~isFontCustomized
                            sheetStruct.Variables(end+1,:)={fontKey,'"MS Gothic"'};
                        end





                        sheetStruct.Variables(end+1,:)={'%title-font-family%',...
                        '%body-font-family%'};
                    end


                    drvVariables='';
                    for i=1:size(sheetStruct.Variables,1)
                        drvVariables=[drvVariables,...
                        '(define ',sheetStruct.Variables{i,1},' $CR '...
                        ,'$TAB',sheetStruct.Variables{i,2},')$CR'];%#ok
                    end


                    drvDSSSL='';
                    for i=1:length(sheetStruct.Overlays)
                        [~,~,oExt]=fileparts(sheetStruct.Overlays{i});
                        if strcmpi(oExt,'.m')


                        elseif strcmpi(oExt,'.dsl')

                            dslFID=fopen(sheetStruct.Overlays{i},'r');
                            if(dslFID>0)
                                drvDSSSL=[drvDSSSL,char(fread(dslFID)')];%#ok
                                fclose(dslFID);
                            else
                                rptgen.displayMessage(...
                                getString(message('rptgen:rx_db_output:cannotOpenStylesheetMsg',sheetStruct.Overlays{i})),...
                                2);
                            end
                        end
                    end

                    drvFooter=['$CR'...
                    ,'</style-specification-body>$CR'...
                    ,'</style-specification>$CR'...
                    ,'<external-specification id="docbook" document="dbstyle">$CR'...
                    ,locExternalSpecification...
                    ,'</style-sheet>$CR'];

                    drvString=[drvHeader,'$CR',drvVariables,'$CR',drvDSSSL,'$CR',drvFooter];
                    drvString=strrep(drvString,'\','\\');
                    drvString=strrep(drvString,'%','%%');
                    drvString=strrep(drvString,'$CR','\n');
                    drvString=strrep(drvString,'$TAB','\t');

                    fprintf(myFid,drvString);
                    fclose(myFid);
                else
                    driverName='';
                end



                function result=LocSystemCall(varargin)

                    if ispc

                        if length(varargin{1})>8192


                            batFileName=[tempname,'.bat'];



                            fid=fopen(batFileName,'w');
                            fprintf(fid,'@ECHO OFF \r\n%s \r\n',varargin{1});
                            fclose(fid);
                            varargin{1}=['"',batFileName,'"'];
                        else
                            batFileName='';
                        end




                        [~,result]=dos(varargin{:});

                        if~isempty(batFileName)
                            delete(batFileName);
                        end

                    else



                        [~,result]=unix(varargin{1});
                    end


                    function tf=LocIsResultError(result)





                        tf=false;

                        errStrings={
'internal or external command, operable program or batch file'
'document does not have the DSSSL architecture as a base'
'jade: Command not found'
'cannot continue because of previous errors'
                        };

                        for i=1:length(errStrings)
                            if~isempty(strfind(result,errStrings{i}))
                                tf=true;
                                break;
                            end
                        end


                        function out=renameNonAsciiCharsToNumbers(in)

                            prefix='c';
                            suffix='';
                            ASCII=128;

                            out=[];
                            for i=1:length(in)
                                if(in(i)>ASCII)
                                    out=[out,prefix,num2str(double(in(i))),suffix];%#ok
                                else
                                    out=[out,in(i)];%#ok
                                end
                            end


                            function[intermediateSource,intermediateOutput]=locNonAsciiFileNameSupport(source,output,encoding)



                                [sourceFilePath,sourceFileNameRoot,sourceFileExt]=fileparts(source);
                                sourceFileName=[sourceFileNameRoot,sourceFileExt];
                                intermediateSourceFileName=renameNonAsciiCharsToNumbers(sourceFileName);
                                if strcmp(sourceFileName,intermediateSourceFileName)

                                    intermediateSource=source;
                                    intermediateOutput=output;
                                    return
                                end

                                [outputFilePath,outputFileNameRoot,outputFileExt]=fileparts(output);
                                outputFileName=[outputFileNameRoot,outputFileExt];
                                intermediateOutputFileName=renameNonAsciiCharsToNumbers(outputFileName);

                                intermediateSource=fullfile(sourceFilePath,intermediateSourceFileName);
                                intermediateOutput=fullfile(outputFilePath,intermediateOutputFileName);



                                ad=rptgen.appdata_rg;
                                oldRelDirName=ad.ImageDirectoryRelative;
                                newRelDirName=renameNonAsciiCharsToNumbers(oldRelDirName);

                                fReadId=fopen(source,'r','native',encoding);
                                fWriteId=fopen(intermediateSource,'w','native',encoding);

                                tline=fgetl(fReadId);
                                while ischar(tline)
                                    tline=regexprep(tline,...
                                    ['(?<=!ENTITY sect\-.* SYSTEM ")(',oldRelDirName,')(?=.*xfrag">)'],...
                                    newRelDirName);
                                    fprintf(fWriteId,'%s\n',tline);
                                    tline=fgetl(fReadId);
                                end

                                fclose(fReadId);
                                fclose(fWriteId);


                                oldFullDirName=ad.ImageDirectory;
                                [oldParentDir,oldDirName]=fileparts(oldFullDirName);
                                newFullDirName=fullfile(oldParentDir,renameNonAsciiCharsToNumbers(oldDirName));
                                locForceMoveFile(oldFullDirName,newFullDirName);


                                xfragFiles=dir(fullfile(newFullDirName,'*.xfrag'));
                                for i=1:length(xfragFiles)
                                    xfragFile=fullfile(newFullDirName,xfragFiles(i).name);
                                    tmpXfragFile=fullfile(newFullDirName,[xfragFiles(i).name,'.tmp']);

                                    fReadId=fopen(xfragFile,'r','native',encoding);
                                    fWriteId=fopen(tmpXfragFile,'w','native',encoding);
                                    tline=fgetl(fReadId);
                                    while ischar(tline)
                                        tline=regexprep(tline,...
                                        ['(?<=<imagedata fileref\=")(',oldRelDirName,')(?=.*"\/>)'],...
                                        newRelDirName);
                                        fprintf(fWriteId,'%s\n',tline);
                                        tline=fgetl(fReadId);
                                    end
                                    fclose(fReadId);
                                    fclose(fWriteId);
                                    locForceMoveFile(tmpXfragFile,xfragFile);
                                end


                                ad.ImageDirectory=newFullDirName;


                                function locForceMoveFile(old,new)

                                    if strcmp(old,new)
                                        return;
                                    end

                                    if exist(new,'dir')
                                        delete(fullfile(new,'*.*'));
                                        rmdir(new,'s');
                                    end
                                    if exist(new,'file')
                                        delete(new);
                                    end
                                    movefile(old,new,'f');
