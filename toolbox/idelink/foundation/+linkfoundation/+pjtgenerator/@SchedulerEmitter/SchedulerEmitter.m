classdef SchedulerEmitter<handle





    properties(SetAccess='private')
        mBuffer=[];
        mFileName='';
    end

    methods



        function h=SchedulerEmitter()
            h.mBuffer='';
        end




        function emit(h,SchedulerInfo,filename)
            h.mFileName=filename;
            h.emitMain(SchedulerInfo);
            fName=linkfoundation.util.File(h.mFileName);
            fName=fName.FullPathName;
            [fid,errmsg]=fopen(fName,'w');
            if fid<0
                error(message('ERRORHANDLER:pjtgenerator:CannotOpenMainFile',fName,errmsg));
            end
            fprintf(fid,h.mBuffer);
            fclose(fid);
        end




        function emitMain(h,SchedulerInfo)
            fileH=[];
            try
                if SchedulerInfo.getNumSubTasks()>0
                    error(message('ERRORHANDLER:pjtgenerator:MLCodeGenDoesNotSupportSubTasks'));
                end
                h.generateMain(SchedulerInfo);
            catch ex
                if(~isempty(fileH))
                    close(fileH);
                end
                rethrow(ex);
            end
        end




        function generateMain(h,SchedulerInfo)
            [~,name,ext]=fileparts(h.mFileName);
            mainFile=[name,ext];
            eol=char(10);
            buff='';
            buff=[buff,eol,sprintf('/*')];
            buff=[buff,eol,sprintf(' * %s',mainFile)];
            buff=[buff,eol,sprintf(' *')];
            buff=[buff,eol,sprintf(' * Main function for ''%s''',name)];
            buff=[buff,eol,sprintf(' *')];
            buff=[buff,eol,sprintf(' * C source code generated on: %s',datestr(now,'ddd mmm dd HH:MM:SS yyyy'))];
            buff=[buff,eol,sprintf(' *')];
            buff=[buff,eol,sprintf(' */')];
            buff=[buff,eol,sprintf('')];
            buff=[buff,eol,sprintf('/* Include files */')];
            buff=[buff,eol,sprintf('#include "%s.h"',SchedulerInfo.getRunStepFunc())];
            buff=[buff,eol,sprintf('#include "%s.h"',SchedulerInfo.getInitializeFunc())];
            buff=[buff,eol,sprintf('#include "%s.h"',SchedulerInfo.getTerminateFunc())];
            buff=[buff,eol,sprintf('')];
            buff=[buff,eol,sprintf('/* Main function */')];
            buff=[buff,eol,sprintf('int main(void)')];
            buff=[buff,eol,sprintf('{')];
            buff=[buff,eol,sprintf('  %s();',SchedulerInfo.getInitializeFunc())];
            buff=[buff,eol,sprintf('')];
            buff=[buff,eol,sprintf('  %s();',SchedulerInfo.getRunStepFunc())];
            buff=[buff,eol,sprintf('')];
            buff=[buff,eol,sprintf('  %s();',SchedulerInfo.getTerminateFunc())];
            buff=[buff,eol,sprintf('')];
            buff=[buff,eol,sprintf('  return 0;')];
            buff=[buff,eol,sprintf('}')];
            buff=[buff,eol,sprintf('')];
            buff=[buff,eol,sprintf('/* End of code generation (%s) */',mainFile)];
            buff=[buff,eol];
            h.mBuffer=buff;
        end

    end

end