classdef CustomizeHeaderUtil<handle








    properties
        File;
        Lines;
        LineNum;
        Cursor;
        CurrentSymbolLineNum;
        CurrentSymbolCursor;
        IsChangeMember;
        Class2Members;
        Class2Types;
        CurNamespace;
    end

    methods
        function obj=CustomizeHeaderUtil(file)


            text=fileread(file);
            obj.File=file;
            obj.Lines=strsplit(text,'\n');
            obj.LineNum=1;
            obj.Cursor=1;
            obj.CurrentSymbolLineNum=0;
            obj.CurrentSymbolCursor=0;
            obj.IsChangeMember=true;
            obj.Class2Members={};


            obj.Class2Types={};
            obj.CurNamespace={};
        end

        function getAndCustomizeMembers(obj)


            symbol=obj.getNextSymbol();
            while~strcmp(symbol,'@EOF')
                if strcmp(symbol,'//')

                    obj.nextLine();
                elseif strcmp(symbol,'/*')
                    obj.parseComment();
                elseif strcmp(symbol,'#')
                    obj.nextLine();
                elseif strcmp(symbol,'class')
                    obj.parseClass();
                elseif strcmp(symbol,'namespace')
                    obj.parseNamespace();
                elseif strcmp(symbol,'enum')
                    obj.parseEnum();
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
            obj.CurrentSymbolLineNum=obj.LineNum;
            obj.CurrentSymbolCursor=obj.Cursor;
        end

        function parseNamespace(obj)
            namespaceName=obj.getNextSymbol();
            obj.CurNamespace{end+1}=namespaceName;
            symbol='';
            while~strcmp(symbol,'}')
                symbol=obj.getNextSymbol;
                if strcmp(symbol,'//')

                    obj.nextLine();
                elseif strcmp(symbol,'/*')
                    obj.parseComment();
                elseif strcmp(symbol,'#')
                    obj.nextLine();
                elseif strcmp(symbol,'class')
                    obj.parseClass();
                elseif strcmp(symbol,'namespace')
                    obj.parseNamespace();
                elseif strcmp(symbol,'enum')
                    obj.parseEnum();
                end
            end
            obj.CurNamespace(end)=[];
        end

















        function parseClass(obj)
            className=obj.getNextSymbol();
            symbol=obj.getNextSymbol();
            if strcmp(symbol,'{')
                namespaceStr='';
                for i=1:numel(obj.CurNamespace)
                    if isempty(namespaceStr)
                        namespaceStr=obj.CurNamespace{i};
                    else
                        namespaceStr=[namespaceStr,'::',obj.CurNamespace{i}];
                    end
                end
                if~isempty(namespaceStr)
                    className=[namespaceStr,'::',className];
                end
                obj.Class2Members{end+1}={};
                obj.Class2Members{end}{end+1}=className;
                obj.Class2Types{end+1}={};
                obj.Class2Types{end}{end+1}=className;
                obj.parseClassBody();
            elseif strcmp(symbol,';')

            end
        end

        function parseClassBody(obj)
            symbol=obj.getNextSymbol();
            while~strcmp(symbol,';')
                if strcmp(symbol,'public:')
                    obj.parseClassPublicBody();
                    obj.parseClassPrivateBody();
                    obj.addConstructor();
                end
                symbol=obj.getNextSymbol();
            end
        end

        function addConstructor(obj)

            constrLines={};
            constrLineNum=1;
            constrLines{constrLineNum}='';
            obj.Class2Members{end}{1};
            classNameWithNS=obj.Class2Members{end}{1};
            strs=strsplit(classNameWithNS,'::');
            constrLines{constrLineNum}=['eProsima_user_DllExport',' ',...
            strs{end},'('];
            for i=2:length(obj.Class2Members{end})
                if obj.Class2Types{end}{i}(end)=='*'
                    constrLines{constrLineNum}=[constrLines{constrLineNum},...
                    'const ',obj.Class2Types{end}{i}(1:end-1),'& _',obj.Class2Members{end}{i}(3:end)];
                else
                    constrLines{constrLineNum}=[constrLines{constrLineNum},...
                    'const ',obj.Class2Types{end}{i},'& _',obj.Class2Members{end}{i}(3:end)];
                end
                if i==length(obj.Class2Members{end})
                    constrLines{constrLineNum}=[constrLines{constrLineNum},')'];
                else
                    constrLines{constrLineNum}=[constrLines{constrLineNum},', '];
                end
            end
            constrLineNum=constrLineNum+1;
            constrLines{constrLineNum}='{';
            for i=2:length(obj.Class2Members{end})
                constrLineNum=constrLineNum+1;
                if obj.Class2Types{end}{i}(end)=='*'
                    constrLines{constrLineNum}=[obj.Class2Members{end}{i}(3:end),...
                    ' =  new ',obj.Class2Types{end}{i}(1:end-1),';'];
                    constrLineNum=constrLineNum+1;
                    constrLines{constrLineNum}=['*',obj.Class2Members{end}{i}(3:end),...
                    ' = _',obj.Class2Members{end}{i}(3:end),';'];
                else
                    constrLines{constrLineNum}=[obj.Class2Members{end}{i}(3:end),...
                    ' = _',obj.Class2Members{end}{i}(3:end),';'];
                end
            end
            constrLineNum=constrLineNum+1;
            constrLines{constrLineNum}='}';
            obj.Lines=[obj.Lines{1:obj.LineNum-1},constrLines,obj.Lines{obj.LineNum:end}];
            obj.LineNum=obj.LineNum+constrLineNum-1;
        end

        function parseClassPublicBody(obj)
            symbol=obj.getNextSymbol();
            i=1;
            isGetterSetterEnd=false;
            while~strcmp(symbol,'private:')
                if strcmp(symbol,'//')

                    obj.nextLine();
                elseif strcmp(symbol,'/*')
                    obj.parseComment();
                elseif strcmp(symbol,'eProsima_user_DllExport')
                    if i<=6
                        obj.parseConstrDestr();
                    elseif isGetterSetterEnd
                        obj.nextLine();
                    else
                        funcName=obj.parseFunction();
                        if strcmp(funcName,'getMaxCdrSerializedSize')
                            isGetterSetterEnd=true;
                            obj.nextLine();
                        end

                    end
                    i=i+1;
                end
                symbol=obj.getNextSymbol();
            end
            obj.Lines{obj.LineNum}='';
            obj.nextLine();
        end

        function parseClassPrivateBody(obj)
            symbol=obj.getNextSymbol();
            while~strcmp(symbol,'}')
                type=symbol;
                if strcmp(type,'std::array')
                    type=obj.getArrTypeStr(type);
                end
                obj.Class2Types{end}{end+1}=type;
                name=obj.getNextSymbol();
                obj.Class2Members{end}{end+1}=name;
                newName=name(3:end);
                obj.changeCurrentSymbol(name,newName);
                semicolor=obj.getNextSymbol();
                symbol=obj.getNextSymbol();
            end
        end

        function parseConstrDestr(obj)
            obj.nextLine();
        end

        function funcName=parseFunction(obj)



            symbol=obj.getNextSymbol();
            if strcmp(symbol,'static')||strcmp(symbol,'const')
                symbol=obj.getNextSymbol();
            end

            if strcmp(symbol,'std::array')
                type=obj.getArrTypeStr(symbol);
                symbol=obj.getNextSymbol();
                if strcmp(symbol,'&')||strcmp(symbol,'&&')
                    type=[type,symbol];
                    symbol=obj.getNextSymbol();
                end
            else
                type=symbol;
                symbol=obj.getNextSymbol();
            end

            funcName=symbol;

            if~strcmp(funcName,'getMaxCdrSerializedSize')
                if strcmp(type,'void')
                    obj.changeCurrentSymbol(funcName,['set_',funcName]);
                else
                    obj.changeCurrentSymbol(funcName,['get_',funcName]);
                end
            end
            assert(strcmp(obj.getNextSymbol(),'('));
            while~strcmp(symbol,')')
                symbol=obj.getNextSymbol();
            end
            symbol=obj.getNextSymbol();
            if strcmp(symbol,'const')
                symbol=obj.getNextSymbol();
            end
            assert(symbol,';');
        end

        function parseEnum(obj)
            symbol=obj.getNextSymbol();
            while~strcmp(symbol,'}')
                if strcmp(symbol,'//')
                    obj.nextLine();
                elseif strcmp(symbol,'/*')
                    obj.parseComment();
                end
                symbol=obj.getNextSymbol();
            end
            symbol=obj.getNextSymbol();
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
                    obj.CurrentSymbolCursor=obj.Cursor;
                    while(obj.Cursor<=length(line))&&(line(obj.Cursor)==' '||uint8(line(obj.Cursor)<32))
                        obj.Cursor=obj.Cursor+1;
                    end
                    while obj.Cursor<=length(line)&&line(obj.Cursor)~=' '&&uint8(line(obj.Cursor))>=32
                        if any(strcmp(line(obj.Cursor),{';','(',')','<','>'}))...
                            &&~isempty(symbol)
                            return;
                        end
                        symbol=[symbol,obj.Lines{obj.LineNum}(obj.Cursor)];

                        if any(strcmp(symbol,{'//','/*','*/','#','{','}',';','(',')','<','>','std::array'}))
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
                obj.CurrentSymbolLineNum=obj.LineNum;
                obj.LineNum=obj.LineNum+1;
                obj.Cursor=1;
                if~isempty(symbol)
                    return;
                end
            end


            symbol='@EOF';
        end

        function changeCurrentSymbol(obj,orig,dest)
            obj.Lines{obj.LineNum}=[obj.Lines{obj.LineNum}(1:obj.CurrentSymbolCursor),...
            dest,obj.Lines{obj.LineNum}(obj.CurrentSymbolCursor+length(orig)+1:end)];
            obj.Cursor=obj.Cursor+(length(dest)-length(orig));
        end
    end
end

