classdef customTerminateGenerator<handle
























    properties(SetAccess=private,GetAccess=public)

funcName

cfg
    end

    properties

srcFileDst
    end

    methods
        function obj=customTerminateGenerator(varargin)

            p=inputParser;
            addRequired(p,'cfg');
            addRequired(p,'funcName',@obj.validate);
            addParameter(p,'srcFileDst','');
            parse(p,varargin{:});


            obj.cfg=p.Results.cfg;
            obj.funcName=p.Results.funcName;
            obj.srcFileDst=p.Results.srcFileDst;
        end
    end

    methods(Static)
        function validate(funcname)
            validateattributes(funcname,{'char','string'},{'nonempty'},...
            'validate','funcName');
        end
    end


    methods

        function set.srcFileDst(obj,value)
            validateattributes(value,{'char','string'},{},...
            '','srcFileDst');
            obj.srcFileDst=value;
        end

        function genrateMainTerminate(obj)

            s=StringWriter;


            s=insertIncludes(obj,s);


            s=insertFunctionDefinitions(obj,s);


            s=finalizeMainTerminatefile(obj,s);



            s.indentCode('c');


            if isempty(obj.srcFileDst)
                obj.srcFileDst=pwd;
            end

            try
                try
                    s.write(fullfile(obj.srcFileDst,obj.getFileName))
                catch exception
                    if isequal(exception.identifier,'siglib:stringwriter:ErrorCreateDirectory')
                        error(message('codertarget:matlabtarget:FolderAccessDenied',string(obj.srcFileDst)));
                    else
                        error(exception.message);
                    end
                end
            catch me
                throwAsCaller(me);
            end
        end

        function fileName=getFileName(obj)
            if strcmp(obj.cfg.TargetLang,'C')
                fileName=[obj.funcName,'_main_terminate.c'];
            else
                fileName=[obj.funcName,'_main_terminate.cpp'];
            end
        end

        function s=insertCommentLines(~,s)
            commentLines='/*Add comments here*/';
            s.addcr(commentLines);
        end

        function s=insertIncludes(obj,s)

            commentLines='/* Include Files */';
            s.addcr(commentLines);
            if isequal(obj.cfg.FilePartitionMethod,'MapMFileToCFile')
                s.addcr(sprintf('#include "%s_terminate.h"',obj.funcName));
            else
                s.addcr(sprintf('#include "%s.h"',obj.funcName));
            end
        end


        function s=insertFunctionDefinitions(obj,s)

            commentLines='/* Function Definition */';
            s.craddcr(commentLines);




            s.addcr('void main_terminate(void)');
            s.addcr('{');
            s.addcr('/* Call the entry-point function. */');
            s.addcr(sprintf('%s_terminate();',obj.funcName));
            s.addcr('}');
        end


        function s=finalizeMainTerminatefile(~,s)

            s.craddcr('/*');
            s.addcr('* File trailer for main_terminate');
            s.addcr('*');
            s.addcr('* [EOF]');
            s.addcr('*/');
        end

    end
end


