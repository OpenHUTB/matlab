





































classdef TML

    methods(Static)
        function code_out=tostr_numcol(matrix_in)
            code=coder.internal.tools.TML.tostr(matrix_in);
            is_transpose=strcmpi(code(end-1:end),'.''');
            if(is_transpose)
                code_out=coder.internal.tools.TML.buildmat2str_folded(code(2:end-3),true,3);
            else
                code_out=coder.internal.tools.TML.buildmat2str_folded(code(2:end-1),false,3);
            end
        end


        function code=translate(templateName,toFID,escapeHTML)


            if(nargin<2)
                toFID=true;
            end
            if(nargin<3)
                escapeHTML=false;
            end



            nonTopLevel=false;
            code=coder.internal.tools.TML.template_parse_eval(templateName,nonTopLevel,escapeHTML,toFID);
            if(toFID)
                [~,fname,~]=fileparts(templateName);
                [argsList,argsInit]=coder.internal.tools.TML.argslist(code);
                code=['function ',fname,'( ',argsList,')',char(10),...
                '% default to STDOUT',char(10),...
                'if ( nargin < 1 ), fid = 1; end;',char(10),...
                argsInit,...
                code,...
                'end'];
            end
            try
                code=mtree(code,'-com').tree2str();
            catch mEx
                disp('coder.internal.tools.TML generated syntactically invalid MATLAB, as,')
                disp(code)
                mEx %#ok<NOPRT>
            end
        end













        function data=render_in_context(templateName_,varargin)
            narginchk(2,inf);
            if(isa(varargin{1},'containers.Map'))
                ctx_=varargin{1};
            else
                ctx_=containers.Map();
                if(mod(length(varargin),2))
                    error('TML:RenderCtxInvocation:Failure',['TML render_context takes context variable-name,value arguments in pairs; odd number of elements supplied'])
                end
                for itr_=1:2:length(varargin)
                    ctx_(varargin{itr_})=varargin{itr_+1};
                end
                clear itr_;
            end
            taboo_={'ans','templateName_','code_','varargin','PV_','itr_','istmp_','ctx_','taboo_'};
            for itr_=ctx_.keys()

                if any(strcmpi(taboo_,itr_{1}))
                    error('TML:RenderCtxInvocation:Failure',['error : special variable names used ''',itr_{1},'''']);
                end
                eval([itr_{1},'= ctx_(itr_{1});']);
            end

            [templateName_,istmp_]=coder.internal.tools.TML.convert_strings_maybe(templateName_);

            code_=coder.internal.tools.TML.template_parse_eval(templateName_);
            try
                data=evalc(code_);
                trim_newlines=true;
                if(trim_newlines)

                    data=regexprep(data,'[ ]+\n+','');
                end
            catch mEx
                disp('failed rendering : due to syntax error or missing variables/functions, in template')
                disp(code_)
                if usejava('desktop')&&evalin('base','exist(''DEBUG_TML'',''var'')')
                    if(evalin('base','DEBUG_TML'))
                        matlab.desktop.editor.newDocument(code);
                    end
                end
                disp(mEx)
                disp(mEx.message)
                arrayfun(@(x)disp(x),mEx.stack)
                tmlEx=MException('TML:Parser:RuntimeMATLABError','Template rendering failed with runtime error');
                tmlEx=tmlEx.addCause(mEx);
                throw(tmlEx)
            end

            if(istmp_),delete(templateName_);end;

        end


        function data=render(templateName,trim_newlines)
            if(nargin<2)
                trim_newlines=~true;
            end






            variables_list=evalin('caller','who()');
            for itr=1:length(variables_list)
                if(strcmpi(variables_list{itr},'ans'))
                    continue;
                end
                eval([variables_list{itr},'=','evalin(''caller'',''',variables_list{itr},''');']);
            end

            [templateName,istmp]=coder.internal.tools.TML.convert_strings_maybe(templateName);


            code=coder.internal.tools.TML.template_parse_eval(templateName);
            try
                data=evalc(code);
                if(trim_newlines)

                    data=regexprep(data,'[ ]+\n+','');
                end
            catch mEx
                disp('failed rendering : due to syntax error or missing variables/functions, in template')
                disp(code)
                if usejava('desktop')&&evalin('base','exist(''DEBUG_TML'',''var'')')
                    if(evalin('base','DEBUG_TML'))
                        matlab.desktop.editor.newDocument(code);
                    end
                end
                disp(mEx)
                disp(mEx.message)
                arrayfun(@(x)disp(x),mEx.stack)
                tmlEx=MException('TML:Parser:RuntimeMATLABError','Template rendering failed with runtime error');
                tmlEx=tmlEx.addCause(mEx);
                throw(tmlEx)
            end


            if(istmp),delete(templateName);end;

        end


        function data=render_to_string(templateName)






            variables_list=evalin('caller','who()');
            for itr=1:length(variables_list)
                if(strcmpi(variables_list{itr},'ans'))
                    continue;
                end
                eval([variables_list{itr},'=','evalin(''caller'',''',variables_list{itr},''');']);
            end

            [templateName,istmp]=coder.internal.tools.TML.convert_strings_maybe(templateName);

            code=coder.internal.tools.TML.template_parse_eval(templateName);
            try
                data=evalc(code);
            catch mEx
                disp('failed rendering : due to syntax error in template')
                disp(code)
                mEx %#ok<NOPRT>
                disp('Stack trace ==>')
                arrayfun(@disp,mEx.stack)
            end

            if(istmp)
                delete(templateName);
            end
        end


        function render_to_file(templateName,fname,indentMATLAB)


            if(nargin<3)

                indentMATLAB=false;
            end





            variables_list=evalin('caller','who()');
            for itr=1:length(variables_list)
                if(strcmpi(variables_list{itr},'ans'))
                    continue;
                end
                eval([variables_list{itr},'=','evalin(''caller'',''',variables_list{itr},''');']);
            end

            [templateName,istmp]=coder.internal.tools.TML.convert_strings_maybe(templateName);

            code=coder.internal.tools.TML.template_parse_eval(templateName);
            try
                data=evalc(code);
            catch mEx
                disp('failed rendering : due to syntax error in template')
                disp(code)
                mEx %#ok<NOPRT>
                arrayfun(@(x)disp(x),mEx.stack)
            end
            if(indentMATLAB)
                data=coder.internal.tools.TML.indentMATLABcode(data,'keep-comments');
            end
            coder.internal.tools.TML.write_tofile(fname,data);
            if(istmp)
                delete(templateName);
            end
        end

    end

    methods(Static,Access=private)


        function str=template_prototype(varargin)
            str=coder.internal.tools.TML.template_parse_eval(varargin{:});
        end

        function str=template_parse_eval(fname,nonTopLevel,escapeHTML,toFID)
            if(nargin<2)
                nonTopLevel=false;
            end
            if(nargin<3)
                escapeHTML=false;
            end
            if(nargin<4)
                toFID=false;
            end


            lexer=coder.internal.tools.TMLLexer(fname);




            if(lexer.length()==1)
                noprint=true;
                tok=lexer.next();
                str=coder.internal.tools.TML.print_newlines_correctly(tok.value,noprint,nonTopLevel);
                str=['disp(',str,');'];
                return
            end
            str='';
            while~lexer.empty()
                tok=lexer.next();


                raw_op=false;
                eval_locally=false;
                include_tag=false;

                c_part='';
                s_part='';
                if(tok.type==coder.internal.tools.TMLTypes.TEXT)
                    s_part=tok.value;
                    raw_op=true;
                else
                    tag_tok=tok;


                    tok=lexer.next();
                    if(tok.type~=coder.internal.tools.TMLTypes.TEXT)
                        error('TML:Parser:NestedTags','TML.template_parse_eval : text token expected within nested tags - template has error');
                    end
                    assert(tok.type==coder.internal.tools.TMLTypes.TEXT)
                    c_part=deblank(tok.value);

                    switch(tag_tok.type)
                    case coder.internal.tools.TMLTypes.VERBATIM_TAG
                        error('Verbatim tag not implemented yet')
                    case coder.internal.tools.TMLTypes.IMMEDIATE_TAG

                    case coder.internal.tools.TMLTypes.DELAYED_TAG
                        raw_op=true;
                    case coder.internal.tools.TMLTypes.INCLUDE_TAG

                        include_tag=true;
                    otherwise
                        disp(['Unexpected token "',tok.tostr(),'" with the value ',evalc('tok.value()')])
                        lexer.dumpText()
                        error('TML:Parser:UnexpectedTokens',strrep(['parse error - unexpected close end-tag token "',tag_tok.value(),'"'],'%','%%'))
                    end


                    tok=lexer.next();
                    if(tok.type~=coder.internal.tools.TMLTypes.END_TAG)
                        disp(['Unexpected token "',tok.value(),'"; template does not have matching end tag for start tag "',tag_tok.value(),'"'])
                        lexer.dumpText()
                        error('TML:Parser:TagNotClosed','TML.template_parse_eval: No matching tag, or nested tags found');
                    end
                    assert(tok.type==coder.internal.tools.TMLTypes.END_TAG)
                end



                if(toFID)
                    c_part=regexprep(c_part,'fprintf[ ]*(','fprintf(fid,');


                    q=mtree(c_part);
                    if(count(q)==2&&strcmpi(q.select(1).kind,'PRINT')&&strcmpi(q.select(2).kind,'CHARVECTOR'))
                        msg=q.select(2).tree2str();
                        msgID=regexprep(msg,'[^a-zA-Z0-9]','');
                        msgID=msgID(1:min(10,length(msgID)));
                        if(length(msg)<2)
                            msg=['''',msg,''''];
                        end
                        str=[str,char(10),'%% <entry key="',msgID,'">',msg(2:end-1),'</entry>',char(10),];
                        c_part=['message(''',msgID,''').getString()'];
                    end
                end


                if(~nonTopLevel||~eval_locally)

                    s_part=coder.internal.tools.TML.escape_chars(s_part,escapeHTML);
                end

                if(include_tag)
                    s_part=eval(c_part);
                    lexer.addLexerTokensToHead(coder.internal.tools.TMLLexer(s_part));
                elseif(raw_op)

                    str=[str,coder.internal.tools.TML.print_newlines_correctly(s_part,false,0,toFID)];%#ok<*AGROW>
                    str=[str,sprintf('%s\n',c_part)];
                else
                    if(~nonTopLevel)
                        c_part=mtree(c_part).tree2str();
                        if(isempty(c_part))
                            c_part='''''';
                        else
                            c_part=strtrim(c_part);
                        end
                        if(toFID)
                            str=[str,coder.internal.tools.TML.print_newlines_correctly(s_part,false,0,toFID),sprintf('fprintf(fid,''%%s'',coder.internal.tools.TML.tostr(%s));',c_part)];
                        else
                            str=[str,coder.internal.tools.TML.print_newlines_correctly(s_part),sprintf('fprintf(''%%s'',coder.internal.tools.TML.tostr(%s));',c_part)];
                        end
                    else
                        str=[str,coder.internal.tools.TML.print_newlines_correctly(s_part,false,0,toFID)];
                        if(toFID)
                            str=[str,sprintf('fprintf(fid,''%%s\\n'',coder.internal.tools.TML.tostr(%s));',strrep(c_part,'''',''''''))];
                        else
                            str=[str,sprintf('fprintf(''%%s\\n'',coder.internal.tools.TML.tostr(%s));',strrep(c_part,'''',''''''))];
                        end
                    end
                end
            end


            str=regexprep(str,'[ ]+\n+','');
            return
        end




        function q_part=escape_chars(s_part,escapeHTML)
            if(nargin<2)
                escapeHTML=false;
            end

            if(escapeHTML)
                s_part=strrep(s_part,'&gt;','>');
                s_part=strrep(s_part,'&lt;','<');
            end

            s_part=strrep(s_part,'\','\\');
            s_part=strrep(s_part,char(13),'\r');

            s_part=strrep(s_part,char(9),'\t');
            s_part=strrep(s_part,'%','%%');
            q_part=s_part;
            return
        end



        function str=print_newlines_correctly(s_part,noprint,indentLevel,toFID)
            if(nargin<2)
                noprint=false;
            end
            if(nargin<3)
                indentLevel=0;
            end
            if(nargin<4)
                toFID=false;
            end
            if(noprint)
                str='[';
            else
                str='';
            end
            if(isempty(s_part))
                str=s_part;
                return
            end

            q=regexp(s_part,char(10),'split');
            for itr=1:length(q)
                q{itr}=strrep(q{itr},char(10),'');
                q{itr}=strrep(q{itr},char(13),'');

                strrep(q{itr},char(9),'\\t');
                q{itr}=strrep(q{itr},'''','''''');
                if(noprint)
                    q{itr}=[repmat(char(9),[1,1+indentLevel]),q{itr}];
                end
                if(itr==length(q))
                    if(noprint)
                        str=[str,'''',q{itr},''']'];%#ok<*AGROW>
                    else
                        if(toFID)
                            str=[str,sprintf('fprintf(fid,''%s'');\n',q{itr})];%#ok<*AGROW>
                        else
                            str=[str,sprintf('fprintf(''%s'');\n',q{itr})];%#ok<*AGROW>
                        end
                    end
                else
                    if(noprint)
                        str=[str,'''',q{itr},''',char(10),...',char(10)];%#ok<*AGROW>
                    else
                        if(toFID)
                            str=[str,sprintf('fprintf(fid,''%s\\n'');\n',q{itr})];
                        else
                            str=[str,sprintf('fprintf(''%s\\n'');\n',q{itr})];
                        end
                    end
                end
            end
        end



        function[argsList,argsInit]=argslist(code)
            mt=mtree(code);
            q=mt.find('Kind','ID');
            p=q.indices();
            arg={};
            for itr=1:length(p)
                r=mt.select(p(itr));
                arg{itr}=r.tree2str();
            end

            arg=sort(unique(arg));
            fid_pos=strmatch('fid',arg);%#ok<MATCH2>
            if(~isempty(fid_pos))
                arg(fid_pos)=[];
            end

            builtin_ids=cell2mat(cellfun(@(y)exist(y),arg,'UniformOutput',false));%#ok<EXIST>

            arg(builtin_ids(:)>=1)=[];
            arg={'fid',arg{:}};%#ok<CCAT>
            argsList='fid';
            argsInit='';
            for itr=2:length(arg)
                argsList=[argsList,', ',arg{itr}];
                argsInit=[argsInit,...
                'if ( nargin < ',num2str(itr),')',char(10),...
                arg{itr},'=','evalin(''caller'',''',arg{itr},''');',char(10),...
                'end',char(10),...
                ];
            end

            return
        end
    end

    methods(Static,Access=private)

        function strv=raw_fcall2str(varargin)
            strv=coder.internal.tools.TML.fcall2str(varargin{:});
            strv=strrep(strv,'''','');
        end



        function[fname,istemp]=convert_strings_maybe(templatename)
            istemp=false;
            if(~iscell(templatename))
                fname=templatename;
                return;
            end

            assert(length(templatename)==2&&strcmpi(templatename{1},'-rawstring'))
            fname=tempname();


            fid=fopen(fname,'w');
            assert(fid>0);
            fprintf(fid,'%s',templatename{2});
            fclose(fid);

            istemp=true;
            return;
        end
    end

    methods(Static,Access=public)
        function strv=tostr(arg,varargin)
            if(ischar(arg))
                quote=false;
                if(nargin>1)
                    quote=varargin{1};
                end
                strv=coder.internal.tools.TML.str2str(arg,quote);
            elseif(iscell(arg))
                if(~isempty(arg)&&ischar(arg{1})&&exist(arg{1},'builtin'))
                    strv=coder.internal.tools.TML.fcall2str(arg{:});
                else
                    strv=coder.internal.tools.TML.cell2str(arg);
                end
            elseif(islogical(arg))
                if arg
                    strv='true';
                else
                    strv='false';
                end
            elseif(isnumeric(arg))
                strv=coder.internal.tools.TML.mat2str(arg);
            elseif(isa(arg,'containers.Map'))
                strv=coder.internal.tools.TML.containersMap2str(arg);
            elseif(isstruct(arg))
                strv=coder.internal.tools.TML.struct2str(arg);
            else
                strv=coder.internal.tools.TML.str2str(char(arg));
            end
        end



        function strv=fcall2str(varargin)
            assert(length(varargin)>=1);
            fname=char(varargin{1});
            strv=[fname,'(',];
            for itr=2:length(varargin)
                needsComma=' ';
                if(itr>2)
                    needsComma=', ';
                end
                strv=[strv,needsComma,coder.internal.tools.TML.tostr(varargin{itr})];
            end
            strv=[strv,' )'];
        end

        function strv=buildmat2str(mat,varargin)
            if(nargin<2)
                need_transpose=false;
            else
                need_transpose=varargin{1};
            end

            if(nargin>=3)

                strv=coder.internal.tools.TML.buildmat2str_folded(mat,varargin{:});
                return;
            end

            strv=['[',mat,']'];

            if(need_transpose)
                strv=[strv,'.'''];
            end
            return
        end


        function strv=buildmat2str_folded(mat,need_transpose,COL_LIMIT)
            if(nargin<2)
                need_transpose=false;
            end


            if(nargin<3)
                COL_LIMIT=6+1;
            end


            COL_LIMIT=COL_LIMIT-1;

            mat_elements=regexp(mat,'(,?\s+)','split');
            if(isempty(mat_elements{end}))
                mat_elements(end)=[];
            end

            mat_text='';itr=1;
            MAX_L=length(mat_elements);
            while(itr<=MAX_L)
                mat_text=[mat_text,strjoin(mat_elements(itr:min([itr+COL_LIMIT,MAX_L])),', '),', ...',char(10),char(9)];
                itr=itr+COL_LIMIT+1;
            end


            if(length(mat_text)>=5)
                mat_text(end-5+1:end)=[];
            end


            strv=['[',mat_text,']'];

            if(need_transpose)
                strv=[strv,''''];
            end
            return
        end



        function strv=mat2str(matV,varargin)
            if(isscalar(matV))
                strv=num2str(matV,'%.15g');
            elseif(isempty(matV))
                strv='[]';
            elseif(isrow(matV))
                strv=coder.internal.tools.TML.buildmat2str(num2str(matV,'%.15g '),varargin{:});
            elseif(iscolumn(matV))
                strv=coder.internal.tools.TML.buildmat2str(num2str(matV.','%.15g '),true,varargin{2:end});
            elseif(length(size(matV))==2)
                strv=mat2str(matV);
            else
                sizeQ=coder.internal.tools.TML.buildmat2str(sprintf('%g, ',size(matV)),varargin{:});
                strv=coder.internal.tools.TML.buildmat2str(sprintf('%g, ',reshape(matV,[1,numel(matV)])),varargin{:});
                strv=coder.internal.tools.TML.raw_fcall2str(@reshape,strv,sizeQ);
            end
        end

        function strv=str2str(strI,quote)
            if(nargin<2)
                quote=false;
            end
            if(quote)
                strv=strjoin(cellfun(@coder.internal.tools.TML.quote,strsplit(strI,char(10)),'UniformOutput',false),[',char(10),...',char(10)]);
                if(length(strfind(strv,['...',char(10)]))>=1)
                    strv=['[',strv,']'];
                end
            else
                strv=strI;
            end
            return
        end
        function strv=quote(str)
            strv=['''',str,''''];
        end
        function strv=struct2str(ss)
            struct_array=length(ss)>1;
            if struct_array
                strv='[';
            else
                strv='';
            end

            for itr=1:length(ss)
                s=ss(itr);
                str=['struct(',strjoin(cellfun(@(x)([coder.internal.tools.TML.quote(x),',',coder.internal.tools.TML.tostr(s.(x),true)]),fieldnames(s)','UniformOutput',false),', '),')'];

                if(struct_array)
                    strv=[strv,' , ',str];
                else
                    strv=str;
                end
            end
            if(struct_array)
                strv=[strv,' ]'];
            end
        end


        function strv=containersMap2str(c)
            strv=strjoin(cellfun(@(x)(['c(''',coder.internal.tools.TML.tostr(x),''') = ''',coder.internal.tools.TML.tostr(c(x)),''';']),c.keys(),'UniformOutput',false),char(10));
        end



        function strv=cell2str(cellV,isTopLevel)
            if(nargin<2)
                isTopLevel=true;
            end

            if(iscell(cellV))
                strv=['{'];%#ok<NBRAK>
                for itr=1:length(cellV)
                    strv=[strv,coder.internal.tools.TML.cell2str(cellV{itr},false)];
                    if(itr<length(cellV))
                        strv=[strv,', '];
                    end
                end
                strv=[strv,'}'];
            else
                if(ischar(cellV))
                    strv=['''',cellV,''''];
                elseif isempty(cellV)
                    strv='[]';
                else
                    strv=num2str(cellV);
                end
            end
            if(isTopLevel)
                strv=[strv,';'];
            end
            return
        end

        function write_tofile(fname,str)

            fid=fopen(fname,'w');
            fprintf(fid,'%s',str);
            fclose(fid);
        end



        function strOut=indentMATLABcode(strIn,comment)

            if(nargin<2)
                comment=true;
            end
            if(~islogical(comment))
                comment=strcmpi({'comments-on','keep-comments'},comment);
            end
            args={strIn};
            if(any(comment))
                args{end+1}='-com';
            end
            strOut=mtree(args{:}).tree2str();
        end
    end
end
