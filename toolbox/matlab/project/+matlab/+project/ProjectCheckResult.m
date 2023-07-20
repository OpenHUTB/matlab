classdef ProjectCheckResult<handle




    properties
ID
Description
Passed
ProblemFiles
    end

    methods
        function checkResult=ProjectCheckResult(check,passed)
            assert(isa(check,...
            'com.mathworks.toolbox.slproject.project.integrity.ProjectCheck'),...
            'Expect a slproject.project.integrity.ProjectCheck')

            checkResult.ID=string(check.getID);
            checkResult.Description=string(check.getDescription);
            checkResult.Passed=logical(passed);
            checkResult=addProblemFiles(checkResult,check);
        end

        function tableOfResults=table(checkArray)
            Passed=[checkArray(:).Passed]';%#ok<PROP>
            Description=[checkArray(:).Description]';%#ok<PROP>
            ID=[checkArray(:).ID]';%#ok<PROP>
            tableOfResults=table(Passed,Description,ID);%#ok<PROP>
        end

    end

    methods(Access=private)
        function checkResult=addProblemFiles(checkResult,check)

            checkResult.ProblemFiles=[...
            string(check.getFixableFiles.toArray)
            string(check.getUnfixableFiles.toArray)
            ];

        end
    end
end

