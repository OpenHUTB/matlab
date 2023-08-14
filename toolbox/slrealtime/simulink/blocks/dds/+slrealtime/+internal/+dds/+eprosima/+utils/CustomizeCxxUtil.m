classdef CustomizeCxxUtil<handle







    properties
        File;
        Lines;
        LineNum;
        Cursor;
        Class2Members;
        CurrentSymbolCursor;
        PreviousGetOpChangedLineNum;
    end

    methods
        function obj=CustomizeCxxUtil(file,class2Members)


            text=fileread(file);
            obj.File=file;
            obj.Lines=strsplit(text,'\n');
            obj.LineNum=1;
            obj.Cursor=1;
            obj.CurrentSymbolCursor=0;
            obj.Class2Members=class2Members;

            obj.PreviousGetOpChangedLineNum=0;
        end

        function modify(obj)
            symbol=obj.getNextSymbol();
            while~strcmp(symbol,'@EOF')
                if strcmp(symbol,'//')

                    obj.nextLine();
                elseif strcmp(symbol,'/*')
                    obj.parseComment();
                elseif strcmp(symbol,'#')
                    obj.nextLine();
                elseif strcmp(symbol,'namespace')
                    obj.nextLine();
                elseif strcmp(symbol,'using')
                    obj.nextLine();
                elseif strcmp(symbol,'class')
                    obj.nextLine();
                elseif strcmp(symbol,'@EOF')
                    break;
                else
                    obj.parseFunction(symbol);
                end
                symbol=obj.getNextSymbol;
            end

            fid=fopen(obj.File,'w+');
            out=strjoin(obj.Lines,'\n');
            fprintf(fid,out);
            fclose(fid);
        end

        function nextLine(obj)
            obj.LineNum=obj.LineNum+1;
            obj.Cursor=1;
            obj.CurrentSymbolCursor=obj.Cursor;
        end

        function parseFunction(obj,symbol)


            type='';
            if strcmp(symbol,'@EOF')
                return;
            end
            if strcmp(symbol,'const')
                symbol=obj.getNextSymbol();
            end



            functionNameWithNS=symbol;
            symbol=obj.getNextSymbol();
            if strcmp(symbol,'(')

            else
                type=functionNameWithNS;
                if strcmp(type,'std::array')
                    type=obj.getArrTypeStr(symbol);
                    symbol=obj.getNextSymbol();
                    if strcmp(symbol,'&')||strcmp(symbol,'&&')
                        type=[type,symbol];
                        symbol=obj.getNextSymbol();
                    end
                end

                functionNameWithNS=symbol;
            end
            strs=strsplit(functionNameWithNS,'::');
            className='';
            for i=1:numel(strs)-1
                if isempty(className)
                    className=strs{i};
                else
                    className=[className,'::',strs{i}];
                end
            end
            members={};


            for i=1:length(obj.Class2Members)
                if strcmp(className,obj.Class2Members{i}{1})
                    members=obj.Class2Members{i}(2:end);
                    break;
                end
            end
            functionName=strs{end};

            for i=1:length(members)
                if strcmp(members(i),['m_',functionName])
                    if strcmp(type,'void')
                        obj.changeCurrentSymbol(symbol,[className,'::set_',functionName]);
                    elseif~isempty(type)
                        obj.changeCurrentSymbol(symbol,[className,'::get_',functionName]);
                    end
                end
            end

            if~strcmp(symbol,'(')

                symbol=obj.getNextSymbol();
            end
            if strcmp(symbol,'=')

                symbol=obj.getNextSymbol();
            end


            if strcmp(symbol,'(')
                while~strcmp(symbol,')')
                    symbol=obj.getNextSymbol();
                end
            end
            symbol=obj.getNextSymbol();
            if strcmp(symbol,'const')
                symbol=obj.getNextSymbol();
            end

            if strcmp(symbol,'{')
                braceCnt=1;
                while braceCnt>0&&~strcmp(symbol,'@EOF')
                    symbol=obj.getNextSymbol();
                    if strcmp(symbol,'{')
                        braceCnt=braceCnt+1;
                    elseif strcmp(symbol,'}')
                        braceCnt=braceCnt-1;
                    elseif strcmp(symbol,'.')
                        symbol=obj.getNextSymbol;
                        for i=1:length(members)

                            if strcmp(members{i},symbol)
                                newSymbol=symbol(3:end);
                                obj.changeCurrentSymbol(symbol,newSymbol);
                                break;


                            elseif strcmp(members{i},['m_',symbol])






                                if obj.PreviousGetOpChangedLineNum==obj.LineNum&&...
                                    strcmp(symbol,'size')





                                    obj.changeCurrentSymbol(symbol,symbol);
                                else
                                    newSymbol=['get_',symbol];
                                    obj.changeCurrentSymbol(symbol,newSymbol);
                                    obj.PreviousGetOpChangedLineNum=obj.LineNum;
                                end
                                break;
                            end
                        end
                    else


                        if isempty(symbol)
                            continue;
                        end
                        offset=1;
                        while offset<=length(symbol)&&...
                            (strcmp(symbol(offset),'*')||strcmp(symbol(offset),'&'))
                            offset=offset+1;
                        end
                        if offset<=length(symbol)
                            for i=1:length(members)
                                if strcmp(members{i},symbol(offset:end))
                                    newSymbol=symbol(offset+2:end);
                                    if offset==1
                                        newSymbol=['this->',newSymbol];
                                    else
                                        newSymbol=[symbol(1:offset-1),'(this->',newSymbol,')'];
                                    end
                                    obj.changeCurrentSymbol(symbol,newSymbol);
                                    break;
                                end
                            end
                        end

                    end
                end
            end
        end

        function type=getArrTypeStr(obj,symbol)


            type=[symbol,obj.getNextSymbol()];
            symbol=obj.getNextSymbol();
            if strcmp(symbol,'std::array')
                type=[type,obj.getArrTypeStr(symbol)];
            else
                type=[type,symbol];
            end
            type=[type,obj.getNextSymbol()];
            symbol=obj.getNextSymbol();

            assert(strcmp(symbol,'>'));
            type=[type,symbol];
        end

        function parseComment(obj)
            while~strcmp(obj.getNextSymbol(),'*/')
                continue;
            end
        end

        function symbol=getNextSymbol(obj)

            symbol='';
            while obj.LineNum<=length(obj.Lines)
                line=obj.Lines{obj.LineNum};
                while obj.Cursor<=length(line)
                    while(obj.Cursor<=length(line))&&...
                        ((line(obj.Cursor)==' ')||uint8(line(obj.Cursor))<32)...

                        obj.Cursor=obj.Cursor+1;
                    end
                    obj.CurrentSymbolCursor=obj.Cursor;
                    while obj.Cursor<=length(line)&&line(obj.Cursor)~=' '&&uint8(line(obj.Cursor))>=32
                        if any(strcmp(line(obj.Cursor),{';','(',')','.',',','<','>'}))...
                            &&~isempty(symbol)
                            return;
                        end
                        symbol=[symbol,obj.Lines{obj.LineNum}(obj.Cursor)];

                        if any(strcmp(symbol,{'//','/*','*/','#','{','}',';','(',')','.',',','<','>'}))
                            obj.Cursor=obj.Cursor+1;
                            return;
                        end
                        obj.Cursor=obj.Cursor+1;
                    end

                    if~isempty(symbol)
                        return;
                    end
                end
                obj.CurrentSymbolCursor=obj.Cursor;
                obj.LineNum=obj.LineNum+1;
                obj.Cursor=1;
                if~isempty(symbol)
                    return;
                end
            end
            symbol='@EOF';

        end

        function changeCurrentSymbol(obj,orig,dest)
            obj.Lines{obj.LineNum}=[obj.Lines{obj.LineNum}(1:obj.Cursor-length(orig)-1),...
            dest,obj.Lines{obj.LineNum}(obj.Cursor:end)];
            obj.Cursor=obj.Cursor+(length(dest)-length(orig));
        end
    end
end

