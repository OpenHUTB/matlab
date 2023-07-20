








function varargout=rtwrptgen(function_name,varargin)

    [varargout{1:nargout}]=feval(function_name,varargin{1:end});






    function generate %#ok<DEFNU>

        rptgen.report('codegen');





        function out=checkdir(givenDir,model)%#ok<DEFNU>

            out=0;
            [srcDir,prjDir]=RptgenRTW.getBuildDir(model);
            if~exist(srcDir,'dir')
                out=1;
            elseif~isempty(givenDir)&&~strcmp(givenDir,srcDir)
                out=2;
            elseif~exist(prjDir,'dir')
                out=3;
            end


