function rtw_get_region_from_template(inFileName,outFileName,isC,isCPPEncap,isSingleLineComments,bGenFcnBannerFile)














    [~,file,ext]=fileparts(inFileName);

    doclink=rtw_template_helper('get_doc_link');

    if~isequal(ext,'.cgt')
        DAStudio.error('RTW:targetSpecific:cgtFileNotFound',inFileName);
    end
    inId=-1;
    outId=-1;
    curr_region='';

    savingPath=fileparts(outFileName);


    if exist(fullfile(savingPath,'function_banner_template.tlc'),'file')
        bGenFcnBannerFile=false;
    end

    loc_delete_region_tlc_file(bGenFcnBannerFile,file,savingPath);
    remain_buffer=[];
    try

        inId=fopen(inFileName,'r');
        [~,~,~,encoding]=fopen(inId);
        if inId<0
            DAStudio.error('RTW:utility:fileIOError',inFileName,'open');
        end

        lineCount=0;
        lineNo=0;

        requiredTokens={'Includes','Defines','Types','Enums','Definitions','Declarations','Functions'};
        validRegions={...
        {'FileBanner'},{'FunctionBanner'},{'SharedUtilityBanner'},...
        {'FileTrailer'}};

        while true
            str=fgetl(inId);
            if~ischar(str),break,end
            lineCount=lineCount+1;
            lineNo=lineNo+1;

            if~isempty(regexp(str,'^\s*%%','ONCE'))
                continue;
            end
            region=regexp(str,'<[^\s].*?>');



            if isempty(curr_region)&&isCPPEncap
                if isempty(region)
                    str='';%#ok<NASGU>
                    continue;
                end
            end
            if~isempty(region)&&~isempty(regexp(str,'<encodingIn\s*=?\s"','once'))


                new_encoding=cell2mat(regexprep(regexp(str,'".*"','match'),'"',''));
                if isempty(new_encoding)

                    new_encoding='';
                end
                if~strcmp(encoding,new_encoding)
                    fPosition=ftell(inId);
                    fclose(inId);
                    inId=fopen(inFileName,'r','n',new_encoding);
                    if inId<0
                        DAStudio.error('RTW:utility:fileIOError',inFileName,'open');
                    end
                    fseek(inId,fPosition,'bof');
                    encoding=new_encoding;
                end
                continue;
            end
            region_txt=regexp(str,'<[^\s].*?>','match');
            if isempty(curr_region)&&isCPPEncap
                isRequired=ismember(region_txt{1}(2:end-1),requiredTokens);
                if(~isRequired)
                    subStr=strtok(region_txt{1},' ');%#ok<NASGU>
                    for rIdx=1:length(validRegions)
                        subStr=strtok(region_txt{1},' ');
                        if strcmp(subStr(2:end),validRegions{rIdx})
                            isRequired=true;
                            break;
                        end
                    end
                end

                if~isRequired
                    str='';%#ok<NASGU>
                    continue;
                end
            end

            start_pos=1;
            end_pos=1;
            custToken=[];
            removedLen=0;
            for i=1:length(region)
                if region(i)>1&&str(region(i)-1-removedLen)=='%'

                    if~isempty(curr_region)
                        token_text=region_txt{i}(2:end-1);
                        token_obj=loc_parse_token(token_text,lineNo,inFileName,doclink);
                        isValid_buildinToken=rtw_template_helper('isValid_buildinToken',curr_region.Name,token_obj.Name);
                        if isValid_buildinToken
                            if strcmp(token_obj.Name,'BlockDescription')...
                                &&strcmp(curr_region.Name,'FunctionBanner')
                                if isfield(token_obj,'style')&&strcmp(token_obj.style,'content_only')
                                    token_obj.Name='BlockDescriptionContent';

                                    str=strrep(str,token_text,'BlockDescriptionContent');
                                end
                            end



                            curr_region.Tokens{end+1}={token_obj.Name,region(i)-2};
                        elseif~isempty(token_obj.Name)&&token_obj.Name(1)=='!'
                            if isCPPEncap
                                subStr=strcat('%<',token_obj.Name,'>');
                                str=strrep(str,subStr,'');
                                removedLen=removedLen+length(token_obj.Name)+3;
                            else
                                str=strrep(str,token_obj.Name,token_obj.Name(2:end));
                                curr_region.Tokens{end+1}={token_obj.Name(2:end),region(i)-2};
                                removedLen=removedLen+1;
                            end
                        elseif strcmp(curr_region.Name,'FileBanner')||strcmp(curr_region.Name,'FileTrailer')
                            if isCPPEncap
                                subStr=strcat('%<',token_obj.Name,'>');
                                str=strrep(str,subStr,'');
                                removedLen=removedLen+length(token_obj.Name)+3;
                            else

                                custToken{end+1}=token_obj.Name;%#ok
                                curr_region.custTokenBuf{end+1}=token_obj.Name;
                            end
                        else
                            if strcmp(curr_region.Name,'SharedUtilityBanner')&&...
                                rtw_template_helper('isValid_buildinToken','FunctionBanner',token_obj.Name)
                                DAStudio.error('RTW:targetSpecific:cgtInvalidFcnBannerTokenForSharedUtility',...
                                token_obj.Name,lineNo,inFileName,doclink);
                            else
                                DAStudio.error('RTW:targetSpecific:cgtInvalidToken',...
                                token_obj.Name,lineNo,inFileName,doclink);
                            end
                        end
                    else

                        start_pos=region(i)+length(region_txt{i});
                    end
                else


                    if length(region_txt{i})>3&&region_txt{i}(2)=='/'

                        if~isempty(curr_region)&&strcmp((region_txt{i}(3:end-1)),curr_region.Name)
                            if region(i)>1



                                end_pos=region(i)-1;
                                ostr=str(start_pos:end_pos);
                                nbuf=loc_update_region_buffer(ostr,...
                                custToken);
                                invalidTlcToken=loc_getInvalidTlcToken(nbuf);
                                if~isempty(invalidTlcToken)
                                    DAStudio.error('RTW:targetSpecific:cgtInvalidToken',invalidTlcToken,lineNo,inFileName,doclink);
                                else
                                    curr_region.Buffer{end+1}=nbuf;
                                end

                                str(start_pos:end_pos)=' ';
                            end

                            str(end_pos:end_pos+length(region_txt{i}))=' ';
                            remain_buffer_str='';
                            if strcmp(curr_region.Name,'FunctionBanner')||strcmp(curr_region.Name,'SharedUtilityBanner')

                                if bGenFcnBannerFile


                                    remain_buffer_str=curr_region.OutputMethod(curr_region,savingPath);
                                end
                            elseif~isempty(curr_region.Buffer)

                                remain_buffer_str=curr_region.OutputMethod(curr_region,savingPath);
                            end
                            if~isempty(remain_buffer_str)
                                remain_buffer{end+1}=remain_buffer_str;%#ok
                            end

                            curr_region='';
                            custToken=[];
                        else
                            if isempty(curr_region)

                                DAStudio.error('RTW:targetSpecific:cgtStartTagMissing',...
                                region_txt{i}(3:end-1),lineNo,inFileName,doclink);
                            else

                                DAStudio.error('RTW:targetSpecific:cgtMismatchTags',...
                                curr_region.Name,region_txt{i}(3:end-1),lineNo,inFileName,doclink);
                            end
                        end
                    else

                        h_region=loc_read_region_header(region_txt{i},lineNo,inFileName,doclink,isC,isSingleLineComments);

                        if~isempty(curr_region)
                            DAStudio.error('RTW:targetSpecific:cgtInvalidNestedTag',...
                            h_region.StartTag,lineNo,inFileName,curr_region.EndTag,doclink);
                        end
                        start_pos=region(i)+length(region_txt{i});

                        str(region(i):start_pos-1)=' ';
                        curr_region=h_region;
                    end
                end
            end

            if~isempty(curr_region)
                end_pos=length(str);

                if isempty(str)
                    curr_region.Buffer{end+1}=sprintf('\n');
                elseif(start_pos~=end_pos+1||start_pos==1)




                    ostr=str(start_pos:end_pos);
                    nbuf=loc_update_region_buffer(ostr,custToken);
                    invalidTlcToken=loc_getInvalidTlcToken(nbuf);
                    if~isempty(invalidTlcToken)
                        DAStudio.error('RTW:targetSpecific:cgtInvalidToken',invalidTlcToken,lineNo,inFileName,doclink);
                    else
                        curr_region.Buffer{end+1}=nbuf;
                    end

                    str(start_pos:end_pos)=' ';
                end
            end
            if~isempty(strtrim(str))
                str=sprintf('%s\n',str);
                remain_buffer{end+1}=str;%#ok
            end
        end
        if~isempty(curr_region)
            DAStudio.error('RTW:targetSpecific:cgtEndTagMissing',...
            curr_region.EndTag,inFileName,doclink);
        end
        if exist(outFileName,'file')

            rtw_delete_file(outFileName);
        end
        outId=fopen(outFileName,'w','n','UTF-8');
        for i=1:length(remain_buffer)
            fprintf(outId,'%s',remain_buffer{i});
        end
        fclose(outId);
        fclose(inId);
    catch exc

        if inId~=-1
            fclose(inId);
        end
        if outId~=-1
            fclose(outId);
        end
        rethrow(exc);
    end





    function out=loc_update_region_buffer(ostr,custToken)

        if~isempty(custToken)
            custToken=unique(custToken);
            for j=1:length(custToken)
                ostr=strrep(ostr,['%<',custToken{j},'>'],[...
                '%<LibGetSourceFileCustomSection(fileIdx,"',custToken{j},'")>']);
            end
        end
        out=sprintf('%s\n',ostr);




        function remain_buffer_str=file_trailer_output(curr_region,savingPath)
            remain_buffer_str='';
            regionFileName=fullfile(savingPath,curr_region.OutputFileName);
            if~exist(regionFileName,'file')
                outId=fopen(regionFileName,'w','n','UTF-8');
                isAppending=false;
            else

                outId=fopen(regionFileName,'a','n','UTF-8');
                isAppending=true;
            end
            if outId<0
                DAStudio.error('RTW:utility:fileIOError',regionFileName,'open');
            end

            if~isempty(curr_region.custTokenBuf)
                curr_region.custTokenBuf=unique(curr_region.custTokenBuf);
                fprintf(outId,'%%%% Identified custom tokens in code generation template:\n');
                fprintf(outId,'%%%%\n');
                for i=1:length(curr_region.custTokenBuf)
                    fprintf(outId,'%s\n',['%<SLibSetSourceFileCustomTokenInUse(fileIdx,"',curr_region.custTokenBuf{i},'")>']);
                end
            end

            fprintf(outId,'%%openfile regionBuf\n');
            for i=1:length(curr_region.Buffer)
                fprintf(outId,'%s',curr_region.Buffer{i});
            end
            fprintf(outId,'%%closefile regionBuf\n');

            fprintf(outId,'%%assign regionBuf = FEVAL("rtwprivate", "rtw_format_banner", ...\n');
            fprintf(outId,'"formatBanner", regionBuf,');
            fprintf(outId,'"%s", %s',curr_region.style,curr_region.width);
            fprintf(outId,')\n');
            fprintf(outId,'%%<regionBuf>\n');

            if~isAppending
                remain_buffer_str=sprintf('\n%%include "%s"\n',curr_region.OutputFileName);
            end
            fclose(outId);




            function remain_buffer_str=file_banner_output(curr_region,savingPath)
                remain_buffer_str='';
                regionFileName=fullfile(savingPath,curr_region.OutputFileName);
                if~exist(regionFileName,'file')
                    outId=fopen(regionFileName,'w','n','UTF-8');
                    isAppending=false;
                else
                    outId=fopen(regionFileName,'a','n','UTF-8');
                    isAppending=true;
                end
                if outId<0
                    DAStudio.error('RTW:utility:fileIOError',regionFileName,'open');
                end

                if~isempty(curr_region.custTokenBuf)
                    curr_region.custTokenBuf=sort(unique(curr_region.custTokenBuf));
                    fprintf(outId,'%%%% Identified custom tokens in code generation template:\n');
                    fprintf(outId,'%%%%\n');
                    for i=1:length(curr_region.custTokenBuf)
                        fprintf(outId,'%s\n',['%<SLibSetSourceFileCustomTokenInUse(fileIdx,"',curr_region.custTokenBuf{i},'")>']);
                    end
                end
                fprintf(outId,'%%assign CodeGenSettings_backup = CodeGenSettings\n');

                fprintf(outId,'%%if !ISEMPTY(CodeGenSettings)\n%%assign CodeGenSettings = SLibCodeGenSettings()\n%%endif\n');

                fprintf(outId,'%%openfile regionBuf\n');
                if(~isempty(emit(coder.internal.watermark)))
                    fprintf(outId,'%s\n\n',emit(coder.internal.watermark));
                end
                for i=1:length(curr_region.Buffer)
                    fprintf(outId,'%s',curr_region.Buffer{i});
                end
                fprintf(outId,'%%closefile regionBuf\n');

                fprintf(outId,'%%assign regionBuf = FEVAL("rtwprivate", "rtw_format_banner", ...\n');
                fprintf(outId,'"formatBanner", regionBuf,');
                fprintf(outId,'"%s", %s',curr_region.style,curr_region.width);
                fprintf(outId,')\n');

                fprintf(outId,'%%<regionBuf>\n');
                fprintf(outId,'%%assign CodeGenSettings = CodeGenSettings_backup\n\n');

                if~isAppending
                    remain_buffer_str=sprintf('%%include "%s"\n',curr_region.OutputFileName);
                end
                fclose(outId);




                function remain_buffer_str=function_banner_output(curr_region,savingPath)
                    remain_buffer_str='';
                    regionFileName=fullfile(savingPath,curr_region.OutputFileName);
                    if~exist(regionFileName,'file')
                        outId=fopen(regionFileName,'w','n','UTF-8');
                        isAppending=false;
                    else
                        outId=fopen(regionFileName,'a','n','UTF-8');
                        isAppending=true;
                    end
                    if outId<0
                        DAStudio.error('RTW:utility:fileIOError',regionFileName,'open');
                    end


                    Abstract_indent=-1;
                    Arguments_indent=-1;
                    BlockDescriptionContent_indent=-1;
                    GeneratedFor_indent=-1;
                    ReturnType_Flag=false;
                    for i=1:length(curr_region.Tokens)
                        token_name=curr_region.Tokens{i}{1};
                        token_indent=curr_region.Tokens{i}{2};
                        switch token_name
                        case 'FunctionDescription'
                            if token_indent>Abstract_indent
                                Abstract_indent=token_indent;
                            end
                        case 'Arguments'
                            if token_indent>Arguments_indent
                                Arguments_indent=token_indent;
                            end
                        case 'BlockDescriptionContent'
                            if token_indent>BlockDescriptionContent_indent
                                BlockDescriptionContent_indent=token_indent;
                            end
                        case 'ReturnType'
                            ReturnType_Flag=true;
                        case 'GeneratedFor'
                            if token_indent>GeneratedFor_indent
                                GeneratedFor_indent=token_indent;
                            end
                        end
                    end


                    if Abstract_indent>=0
                        fprintf(outId,'%%assign FunctionDescription = FEVAL("rtwprivate", "rtw_format_banner", "formatFcnDescription", ...\n');
                        fprintf(outId,'rawFcnDescription, %d, %s)\n',Abstract_indent,...
                        curr_region.width);
                    end
                    if Arguments_indent>=0
                        fprintf(outId,'%%assign Arguments = FEVAL("rtwprivate", "rtw_format_banner", "formatArguments", ...\n');
                        fprintf(outId,'rawArguments, %d)\n',Arguments_indent);
                        fprintf(outId,'%%if isCppStructor\n%%assign Arguments = ""\n%%endif\n');
                    end
                    if BlockDescriptionContent_indent>=0
                        fprintf(outId,'%%assign BlockDescriptionContent = FEVAL("rtwprivate", "rtw_format_banner", "formatBlockDescriptionContent", ...\n');
                        fprintf(outId,'BlockDescriptionContent, %d)\n',BlockDescriptionContent_indent);
                    end
                    if GeneratedFor_indent>=0
                        fprintf(outId,'%%assign GeneratedFor = FEVAL("rtwprivate", "rtw_format_banner", "formatGeneratedFor", ...\n');
                        fprintf(outId,'GeneratedFor, %d)\n',GeneratedFor_indent);
                    end
                    if ReturnType_Flag
                        fprintf(outId,'%%assign ReturnType = FEVAL("rtwprivate", "rtw_format_banner", "formatReturnType", rawReturnType)\n');
                        fprintf(outId,'%%if isCppStructor\n%%assign ReturnType = ""\n%%endif\n');
                    end

                    fprintf(outId,'%%openfile regionBuf\n');
                    for i=1:length(curr_region.Buffer)
                        fprintf(outId,'%s',curr_region.Buffer{i});
                    end
                    fprintf(outId,'%%closefile regionBuf\n');

                    fprintf(outId,'%%assign regionBuf = FEVAL("rtwprivate", "rtw_format_banner", ...\n');
                    fprintf(outId,'"formatBanner", regionBuf,');
                    fprintf(outId,'"%s", %s',curr_region.style,curr_region.width);
                    fprintf(outId,')\n');

                    if isAppending
                        fprintf(outId,'%%assign bannerBuf = bannerBuf + regionBuf\n\n');
                    else
                        fprintf(outId,'%%assign bannerBuf = regionBuf\n\n');
                    end
                    fclose(outId);




                    function loc_delete_region_tlc_file(bGenFcnBannerFile,file,tlc_path)
                        region_name={'function_banner','file_banner','file_trailer'};
                        for i=1:length(region_name)
                            switch region_name{i}
                            case 'function_banner'
                                if~bGenFcnBannerFile
                                    continue;
                                end
                                outFileName='function_banner_template.tlc';
                            case 'file_banner'
                                outFileName=[file,'_file_banner.tlc'];
                            case 'file_trailer'
                                outFileName=[file,'_file_trailer.tlc'];
                            end
                            outFileName=fullfile(tlc_path,outFileName);
                            if exist(outFileName,'file')
                                rtw_delete_file(outFileName);
                            end
                        end






                        function h_region=loc_initialize_region(region_token,lineNo,inFileName,doclink)

                            fcn_banner_header_attribs={'style','width'};
                            file_banner_header_attribs={'style','width'};
                            file_trailer_header_attribs={'style','width'};
                            shared_utility_header_attribs={'style','width'};

                            h_region='';
                            [~,file]=fileparts(inFileName);
                            switch region_token
                            case 'FunctionBanner'
                                h_region.Name='FunctionBanner';
                                h_region.StartTag='<FunctionBanner>';
                                h_region.EndTag='</FunctionBanner>';
                                h_region.Attribs=fcn_banner_header_attribs;
                                h_region.OutputFileName='function_banner_template.tlc';
                                h_region.OutputMethod=@function_banner_output;
                            case 'SharedUtilityBanner'
                                h_region.Name='SharedUtilityBanner';
                                h_region.StartTag='<SharedUtilityBanner>';
                                h_region.EndTag='</SharedUtilityBanner>';
                                h_region.Attribs=shared_utility_header_attribs;
                                h_region.OutputFileName='function_banner_template_sharedutility.tlc';
                                h_region.OutputMethod=@function_banner_output;
                            case 'FileBanner'
                                h_region.Name='FileBanner';
                                h_region.StartTag='<FileBanner>';
                                h_region.EndTag='</FileBanner>';
                                h_region.Attribs=file_banner_header_attribs;
                                h_region.OutputFileName=[file,'_file_banner.tlc'];
                                h_region.OutputMethod=@file_banner_output;
                                h_region.custTokenBuf=[];
                            case 'FileTrailer'
                                h_region.Name='FileTrailer';
                                h_region.StartTag='<FileTrailer>';
                                h_region.EndTag='</FileTrailer>';
                                h_region.Attribs=file_trailer_header_attribs;
                                h_region.OutputFileName=[file,'_file_trailer.tlc'];
                                h_region.OutputMethod=@file_trailer_output;
                                h_region.custTokenBuf=[];
                            otherwise
                                DAStudio.error('RTW:targetSpecific:cgtInvalidTagName',region_token,lineNo,inFileName,doclink);
                            end

                            h_region.Buffer={};

                            h_region.Tokens=[];

                            h_region.style='classic';
                            h_region.width='0';





                            function h_region=loc_read_region_header(str,lineNo,inFile,doclink,isC,isSingleLineComments)
                                str=strrep(str,'=',' = ');
                                locations=regexp(str,'\s+','split');
                                if locations{1}(end)=='>'

                                    region_token=locations{1}(2:end-1);
                                else

                                    region_token=locations{1}(2:end);
                                end
                                h_region=loc_initialize_region(region_token,lineNo,inFile,doclink);
                                i=2;
                                while i<=length(locations)

                                    isValid_attrib=false;
                                    if locations{i}=='>'
                                        break;
                                    end
                                    if ischar(locations{i})


                                        attrib_name='';
                                        for j=1:length(h_region.Attribs)
                                            if strcmp(locations{i},h_region.Attribs{j})
                                                isValid_attrib=true;
                                                attrib_name=h_region.Attribs{j};
                                                break;
                                            end
                                        end
                                        if locations{i}(1)=='<'&&locations{i}(end)=='>'
                                            DAStudio.error('RTW:targetSpecific:cgtInvalidTagFormat',h_region.Name,lineNo,inFile,doclink);
                                        end
                                    end
                                    if~isValid_attrib
                                        DAStudio.error('RTW:targetSpecific:cgtInvalidTagAttribName',locations{i},lineNo,...
                                        inFile,doclink);
                                    end

                                    i=i+1;
                                    if i<length(locations)&&locations{i}=='='
                                        i=i+1;
                                        if locations{i}(end)=='>'
                                            locations{i}=locations{i}(1:end-1);
                                        end

                                        if locations{i}(1)=='='

                                            DAStudio.error('RTW:targetSpecific:cgtInvalidTagAttribFormat',...
                                            attrib_name,lineNo,inFile,doclink);
                                        end

                                        attrib_value=loc_getAttribValue(locations{i});
                                        if isempty(attrib_value)
                                            DAStudio.error('RTW:targetSpecific:cgtTagAttribMissingQuote',...
                                            attrib_name,lineNo,inFile,doclink);
                                        end
                                        if loc_isValid_attrib_value(h_region.Name,attrib_name,attrib_value)
                                            if isSingleLineComments&&strcmp(attrib_name,'style')&&isempty(strfind(attrib_value,'_cpp'))
                                                attrib_value=[attrib_value,'_cpp'];%#ok
                                            end

                                            eval_cmd=sprintf('h_region.%s = ''%s'';',attrib_name,attrib_value);
                                            eval(eval_cmd);


                                            isMultiLineComments=~isSingleLineComments;
                                            if(strcmp(attrib_name,'style')&&any(strfind(attrib_value,'_cpp')))&&(isC&&isMultiLineComments)
                                                DAStudio.error('RTW:targetSpecific:cgtInvalidCppStyleForCTarget',...
                                                attrib_value,attrib_name,lineNo,inFile);
                                            end
                                        else
                                            DAStudio.error('RTW:targetSpecific:cgtInvalidTagAttribValue',...
                                            attrib_value,attrib_name,lineNo,inFile,doclink);
                                        end
                                        i=i+1;
                                    else
                                        DAStudio.error('RTW:targetSpecific:cgtInvalidTagAttribFormat',...
                                        attrib_name,lineNo,inFile,doclink);
                                    end
                                end





                                function isValid=loc_isValid_attrib_value(name,attrib_name,value)
                                    isValid=false;


                                    style_values={'classic','box','open_box',...
                                    'classic_cpp','box_cpp','open_box_cpp',...
                                    'doxygen','doxygen_qt','doxygen_cpp','doxygen_qt_cpp'};
                                    blockDescription_style_values={'content_only'};
                                    valid_attribs={{'FunctionBanner','style',style_values},...
                                    {'FileBanner','style',style_values},...
                                    {'FileTrailer','style',style_values}...
                                    ,{'SharedUtilityBanner','style',style_values}...
                                    ,{'BlockDescription','style',blockDescription_style_values}...
                                    };
                                    for i=1:length(valid_attribs)
                                        if strcmp(name,valid_attribs{i}{1})&&strcmp(attrib_name,valid_attribs{i}{2})
                                            isValid=any(strcmp(valid_attribs{i}{3},value));
                                        end
                                    end
                                    if strcmp(attrib_name,'width')
                                        isValid=true;
                                        if~all(isstrprop(value,'digit'))
                                            isValid=false;
                                            return;
                                        end
                                        if str2double(value)==0.0
                                            isValid=false;
                                        end
                                    end
                                    return;




                                    function invalidTlcToken=loc_getInvalidTlcToken(str)
                                        invalidTlcToken='';

                                        idx=regexp(str,'%<\s','once');
                                        if~isempty(idx)
                                            idx_close=strfind(str(idx:end),'>');
                                            if isempty(idx_close)
                                                invalidTlcToken=str(idx:end);
                                            else
                                                invalidTlcToken=str(idx:idx_close(1)+idx);
                                            end
                                            return;
                                        end

                                        opens=[0,strfind(str,'%<')];
                                        closes=[0,strfind(str,'>')];
                                        if opens(end)>closes(end)
                                            invalidTlcToken=str(opens(end):end);
                                        end
                                        return;






                                        function ret=loc_getAttribValue(value_str)
                                            ret='';
                                            if value_str(1)==value_str(end)&&length(value_str)>1&&...
                                                (value_str(1)==''''||value_str(1)=='"')
                                                ret=value_str(2:end-1);
                                            end
                                            return;









                                            function token_obj=loc_parse_token(token_text,lineNo,inFile,doclink)
                                                if isempty(strfind(token_text,'='))
                                                    token_obj.Name=token_text;
                                                    return;
                                                end
                                                token_element=regexp(token_text,'=','split');
                                                if length(token_element)~=2
                                                    DAStudio.error('RTW:targetSpecific:cgtInvalidToken',...
                                                    token_text,lineNo,inFileName,doclink);
                                                end
                                                tmp=regexp(strtrim(token_element{1}),'\s+','split');
                                                if length(tmp)~=2
                                                    DAStudio.error('RTW:targetSpecific:cgtInvalidToken',...
                                                    token_text,lineNo,inFileName,doclink);
                                                end
                                                token_name=tmp{1};
                                                attrib_name=tmp{2};
                                                attrib_value=loc_getAttribValue(strtrim(token_element{2}));
                                                if isempty(attrib_value)
                                                    DAStudio.error('RTW:targetSpecific:cgtTagAttribMissingQuote',...
                                                    attrib_name,lineNo,inFile,doclink);
                                                end
                                                if~loc_isValid_attrib_value(token_name,attrib_name,attrib_value)
                                                    DAStudio.error('RTW:targetSpecific:cgtInvalidTagAttribValue',...
                                                    attrib_value,attrib_name,lineNo,inFile,doclink);
                                                end
                                                token_obj=struct('Name',token_name,attrib_name,attrib_value);




