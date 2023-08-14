
classdef Function
    properties
        name;
        returnArguments={};
        arguments={};
    end

    properties(Constant)
        OpLeadChar={'+','-','*','/','<','>','.','''','!','=','\'};
        OpNames={'+','-','*','/','<<','>>','.*','''','''*',...
        '*''','*/','.>>','>','>=','<','<=','!=','==',...
        './','/.','.''','.''*','*.''','\'};
    end
    methods
        function aStr=preview(obj)
            aStr='';
            closeBracket='';
            if length(obj.returnArguments)>1
                aStr='[';
                closeBracket=']';
            end
            for idx=1:length(obj.returnArguments)
                if idx<=length(obj.returnArguments)-1
                    comma=',';
                else
                    comma='';
                end
                arg=obj.returnArguments{idx};
                spaceStr=coder.parser.Function.getSpaceStr(aStr);
                aStr=[aStr,spaceStr,arg.preview,comma];%#ok<*AGROW>
            end
            aStr=[aStr,closeBracket];
            spaceStr=coder.parser.Function.getSpaceStr(aStr);
            aStr=[aStr,spaceStr,'= '];

            if~isempty(obj.name)&&isempty(intersect(obj.name,obj.OpNames))

                aStr=[aStr,obj.name,'('];
                for idx=1:length(obj.arguments)
                    if idx<=length(obj.arguments)-1
                        comma=',';
                    else
                        comma='';
                    end
                    arg=obj.arguments{idx};
                    spaceStr=coder.parser.Function.getSpaceStr(aStr);
                    aStr=[aStr,spaceStr,arg.preview,comma];
                end
                spaceStr=coder.parser.Function.getSpaceStr(aStr);
                aStr=strtrim([aStr,spaceStr,')']);
            else

                if length(obj.arguments)==2

                    aStr=[aStr,obj.arguments{1}.preview,' ',obj.name,' ',obj.arguments{2}.preview];
                else

                    if isempty(obj.name)

                        aStr=[aStr,obj.arguments{1}.preview];
                    else

                        aStr=[aStr,obj.arguments{1}.preview,obj.name];
                    end
                end
            end
        end
    end
    methods(Static)
        function spaceStr=getSpaceStr(aStr)
            spaceStr='';
            if~isempty(aStr)&&aStr(end)~=' '&&aStr(end)~='['
                spaceStr=' ';
            end
        end
    end
end
