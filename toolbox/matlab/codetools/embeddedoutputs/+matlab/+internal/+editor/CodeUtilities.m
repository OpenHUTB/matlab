classdef CodeUtilities






    properties(Constant=true,Access=private)
    end

    methods(Static,Hidden)
        function numberOfCharacters=findNumberOfCharactersToPriorToLine(fullText,line)



            if line~=1
                newLines=find(fullText==newline,line-1);
                numberOfCharacters=newLines(end);
            else
                numberOfCharacters=0;
            end
        end
        function numberOfLines=numberOfLinesInText(fullText)
            newLines=find(fullText==newline);
            numberOfLines=length(newLines)+1;
        end
    end
end
