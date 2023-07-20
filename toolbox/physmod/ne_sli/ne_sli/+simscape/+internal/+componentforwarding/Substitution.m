classdef Substitution















    properties(SetAccess=private)


ID
Expression
    end

    properties(Access=private)
NeedsParens
    end

    methods
        function obj=Substitution(expressionString)
            obj.Expression=expressionString;
            obj.ID=lGetIDFromExpression(expressionString);
            obj.NeedsParens=~strcmp(obj.Expression,obj.ID);
        end

        function result=getValueString(obj,substitutionString)














            if contains(substitutionString,'%')
                substitutionString=extractBefore(substitutionString,'%');
            end
            substitutionString=strip(substitutionString);

            if obj.NeedsParens&&~(strcmp(substitutionString(1),'(')&&strcmp(substitutionString(end),')'))
                substitutionString=['(',substitutionString,')'];
            end
            result=regexprep(obj.Expression,'[A-z]+\w*',...
            substitutionString);
        end
    end

end

function id=lGetIDFromExpression(expressionString)
    ids=regexp(expressionString,'[A-z]+\w*','match');
    assert(numel(ids)==1,'All substitutions must be 1-to-1.');
    id=ids{1};
end
