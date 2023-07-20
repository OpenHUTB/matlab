classdef Classification

    enumeration
Automatic
    end

    methods(Static)
        function selectedVarName=classify(varNames,type)
            lowerVarNames=lower(varNames);
            switch type
            case 'group'
                firstMatch=find(ismember(lowerVarNames,{'id','group','i','run'}),1);
            case 'independent'
                firstMatch=find(ismember(lowerVarNames,{'time','t','idv'}),1);
            end
            if isempty(firstMatch)
                selectedVarName='';
            else
                selectedVarName=varNames{firstMatch};
            end
        end
    end
end
