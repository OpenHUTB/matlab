function varargout=rtw_format_banner(function_name,varargin)






    [varargout{1:nargout}]=feval(function_name,varargin{1:end});






    function out=formatBanner(in,style_value,width)%#ok
        if isempty(strtrim(in))
            out=' ';
            return;
        end
        if isempty(style_value)
            style_value='classic';
        end
        out=LocFormatContent(style_value,in,width);
        return;





        function out=formatGeneratedFor(inArgs,indentLength)%#ok
            out=loc_format_token_with_indentation(inArgs,indentLength);












            function out=formatArguments(inArgs,indentLength)%#ok

                if isempty(strtrim(inArgs))
                    out='void';
                    return
                end
                args=regexp(inArgs,',','split');
                for i=1:length(args)
                    args{i}=strtrim(args{i});
                end
                indent(1:indentLength)=' ';
                if~isempty(args{1})
                    out=sprintf('%s\n',args{1});
                end
                for i=2:length(args)
                    out=sprintf('%s%s%s\n',out,indent,args{i});
                end

                out=deblank(out);
                if isempty(strtrim(out))
                    out='void';
                end
                return





                function out=formatReturnType(in)%#ok


                    if isempty(strtrim(in))
                        out='void';
                        return
                    end
                    out=strrep(in,'extern','');
                    out=strrep(out,'static','');
                    out=strtrim(out);








                    function out=formatFcnDescription(in,indentLength,width)%#ok
                        if width==0
                            max_len=80;
                        else
                            max_len=width;
                        end

                        if isempty(strtrim(in))
                            out=' ';
                            return;
                        end
                        buffer=regexp(in,'\n','split');
                        if isempty(buffer{end})
                            buffer_len=length(buffer)-1;
                        else
                            buffer_len=length(buffer);
                        end

                        if indentLength==0
                            indent='';
                        else
                            indent='  ';
                            if indentLength<length(indent)
                                indent(1:indentLength)=' ';
                            end
                        end
                        if buffer_len>1


                            if length(unicode2native(buffer{1}))<max_len&&...
                                length(unicode2native(buffer{1}))+indentLength>max_len
                                out=sprintf('\n%s%s\n',indent,buffer{1});
                            else
                                out=sprintf('%s\n',buffer{1});
                            end
                            for i=2:buffer_len
                                out=sprintf('%s%s%s\n',out,indent,buffer{i});
                            end
                        else


                            if length(unicode2native(buffer{1}))<max_len&&...
                                indentLength~=0&&length(unicode2native(in))+indentLength>max_len
                                out=sprintf('\n%s%s',indent,in);
                            else
                                out=in;
                            end
                        end

                        out=deblank(out);
                        return








                        function out=formatBlockDescriptionContent(in,indentLength)%#ok
                            out=loc_format_token_with_indentation(in,indentLength);




                            function out=loc_format_token_with_indentation(in,indentLength)
                                if isempty(strtrim(in))
                                    out=' ';
                                    return;
                                end
                                buffer=regexp(in,'\n','split');
                                if isempty(buffer{end})
                                    buffer_len=length(buffer)-1;
                                else
                                    buffer_len=length(buffer);
                                end

                                if indentLength==0
                                    indent='';
                                else
                                    indent='  ';
                                    if indentLength>length(indent)
                                        indent(1:indentLength)=' ';
                                    end
                                end
                                if buffer_len>1

                                    out=sprintf('%s\n',buffer{1});
                                    for i=2:buffer_len
                                        out=sprintf('%s%s%s\n',out,indent,buffer{i});
                                    end
                                else

                                    out=in;
                                end

                                out=deblank(out);
                                return




                                function out=insert_comment_prefix(in)%#ok

                                    out=deblank(in);
                                    out=regexprep(out,'\n','\n * ');
                                    out=sprintf(' * %s\n',out);
                                    return










                                    function out=LocFormatContent(style_value,in,width)

                                        in=deblank(in);
                                        buffer=regexp(in,'\n','split');
                                        max_line_len=0;
                                        if width==0
                                            isCustomWidth=false;
                                            width=80;
                                        else
                                            if width<4
                                                width=4;
                                            end
                                            isCustomWidth=true;
                                        end

                                        buffer=regexprep(buffer,'\s',' ');
                                        doclink=rtw_template_helper('get_doc_link');
                                        for i=1:length(buffer)

                                            max_line_len=max(max_line_len,length(unicode2native(buffer{i})));
                                        end
                                        if strfind(style_value,'_cpp')
                                            isC=false;
                                            repeater='/';
                                        else
                                            isC=true;
                                            repeater='*';
                                        end
                                        style_value=strrep(style_value,'_cpp','');
                                        switch style_value
                                        case 'doxygen'
                                            if isC
                                                bracel=' * ';
                                                header='/** ';
                                                foot=' */';

                                                if length(buffer)==1
                                                    out=[header,buffer{1},foot];
                                                    return;
                                                end
                                            else
                                                bracel='/// ';
                                                header=bracel;
                                                foot=header;

                                                if length(buffer)==1
                                                    out=[header,buffer{1}];
                                                    return;
                                                end
                                            end
                                            bracer='';
                                        case 'doxygen_qt'
                                            if isC
                                                bracel=' * ';
                                                header='/*!';
                                                foot=' */';

                                                if length(buffer)==1
                                                    out=[header,buffer{1},foot];
                                                    return;
                                                end
                                            else
                                                bracel='//! ';
                                                header=bracel;
                                                foot=header;

                                                if length(buffer)==1
                                                    out=[header,buffer{1}];
                                                    return;
                                                end
                                            end
                                            bracer='';
                                        case 'box'
                                            if isC
                                                bracel='/* ';
                                                bracer=' */';
                                            else
                                                bracel='// ';
                                                bracer=' //';
                                            end
                                            if isCustomWidth
                                                header_len=width;
                                            else
                                                header_len=LocGetMaxLength(max_line_len,length(bracel),length(bracer),width);
                                            end
                                            header(2:header_len-1)=repeater;
                                            header(1)='/';
                                            header(header_len)='/';
                                            foot=header;
                                        case 'open_box'
                                            if isC
                                                bracel=' * ';
                                            else
                                                bracel='// ';
                                            end
                                            bracer='';
                                            if isCustomWidth
                                                header_len=width;
                                            else
                                                header_len=LocGetMaxLength(max_line_len,length(bracel),length(bracer),width);
                                            end
                                            header(2:header_len)=repeater;
                                            header(1)='/';
                                            foot=header;
                                            if isC
                                                foot(1)=' ';
                                                foot(header_len)='/';
                                            else
                                                foot=header;
                                            end
                                        case 'classic'
                                            if isC
                                                bracel=' * ';
                                                header='/* ';
                                                foot=' */';

                                                if length(buffer)==1
                                                    out=[header,buffer{1},foot];
                                                    return;
                                                end
                                            else
                                                bracel='// ';
                                                header=bracel;
                                                foot=header;

                                                if length(buffer)==1
                                                    out=[header,buffer{1}];
                                                    return;
                                                end
                                            end
                                            bracer='';
                                        otherwise
                                            DAStudio.error('RTW:targetSpecific:cgtInvalidStyle',style_value,doclink);

                                        end

                                        out=sprintf('%s\n',header);
                                        max_line_len=LocGetMaxLength(max_line_len,length(bracel),length(bracer),width);

                                        for i=1:length(buffer)
                                            line_buf=unicode2native(buffer{i});
                                            padding='';
                                            if~isempty(bracer)
                                                if isCustomWidth
                                                    padding_len=width-length(bracel)-length(bracer)-length(line_buf);
                                                else
                                                    padding_len=max_line_len-length(bracel)-length(bracer)-length(line_buf);
                                                end
                                                if(padding_len>0)
                                                    padding(1:padding_len)=' ';
                                                end
                                            end
                                            out=sprintf('%s%s%s%s%s\n',out,...
                                            bracel,...
                                            buffer{i},...
                                            padding,...
                                            bracer);
                                        end
                                        out=sprintf('%s%s\n',out,foot);
                                        return




                                        function out=getBlockDescriptionContent(in)%#ok
                                            out='';
                                            in=deblank(in);
                                            if isempty(strtrim(in))
                                                out=' ';
                                                return;
                                            end
                                            buffer=regexp(in,'\n','split');

                                            for i=2:length(buffer)
                                                if length(buffer{i})>=2&&strcmp(buffer{i}(1:2),'  ')
                                                    out=sprintf('%s%s\n',out,buffer{i}(3:end));
                                                else
                                                    out=sprintf('%s%s\n',out,buffer{i});
                                                end
                                            end
                                            out=deblank(out);
                                            return;



                                            function max_len=LocGetMaxLength(max_len,len1,len2,width)
                                                MAX_LENGTH=width;
                                                max_len=max_len+len1+len2;
                                                if max_len<MAX_LENGTH
                                                    max_len=MAX_LENGTH;
                                                end
                                                return


