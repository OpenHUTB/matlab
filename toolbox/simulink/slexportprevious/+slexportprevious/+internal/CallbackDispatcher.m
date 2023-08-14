
classdef CallbackDispatcher<handle


    properties(Access='private')
sourceModelName
targetModelName
targetVersion
    end

    properties(Access='public')
progressFcn
errorFcn
useGUI
    end

    methods(Access='public')

        function obj=CallbackDispatcher(sourceModelName,targetModelName,...
            targetVersion)
            obj.sourceModelName=sourceModelName;
            obj.targetModelName=targetModelName;
            obj.targetVersion=targetVersion;
            obj.progressFcn=@(val)fprintf('Progress: %2d%%\n',round(val*100));
            obj.errorFcn=@(E)warning(E.identifier,'%s',E.message);
            obj.useGUI=false;
        end

        function runCallbacks(obj,helper)


            assert(bdIsLoaded(obj.targetModelName));
            assert(bdIsLoaded(obj.sourceModelName));
            assert(isa(helper,'slexportprevious.internal.PreprocessHelper'));

            if~isempty(Simulink.defaultModelTemplate)



                Simulink.defaultModelTemplate('$clear');
                restore_template=onCleanup(@()Simulink.defaultModelTemplate('$restore'));
            end



            packageName='slexportprevious.preprocess';
            pkg=meta.package.fromName(packageName);
            functionNames={pkg.FunctionList.Name}';
            qualifiedFunctionNames=strcat(packageName,'.',functionNames);

            num_steps=numel(qualifiedFunctionNames);
            progress_step=1/num_steps;


            for idx=1:numel(qualifiedFunctionNames)
                fh=str2func(qualifiedFunctionNames{idx});
                try
                    fh(helper);
                catch e
                    slexportprevious.internal.CallbackDispatcher.printError(e);
                    obj.errorFcn(MException(['slexportprevious:preprocess:FunctionError_',functionNames{idx}],...
                    'Error running method slexportprevious.preprocess.%s: (%s) %s',...
                    functionNames{idx},e.identifier,e.message));
                    continue;
                end
                obj.progressFcn(idx*progress_step);
            end
        end

    end

    methods(Static)
        function p=getDatabasePaths
            p=which('-all','slexportprevious.rules');
            p=slfileparts(p);
        end

        function fcns=getPostprocessFunctionNames(folder)
            files=dir(slfullfile(folder,'+slexportprevious','+postprocess','*.m'));
            files={files.name}';
            [~,fcns]=slfileparts(files);

            fcns=fcns(~contains(fcns,'.#'));
            fcns=strcat('slexportprevious.postprocess.',fcns);

            sort(fcns);
        end

        function printError(s)
            fprintf(1,'Error: %s (%s)\n',s.message,s.identifier);
            for i=1:numel(s.stack)
                e=s.stack(i);
                ff=which(e.file);
                [~,command]=fileparts(ff);
                n=e.name;
                href=sprintf('matlab:opentoline(''%s'',%d)',ff,e.line);
                if strcmp(command,n)

                    fprintf(1,'    <a href="%s">%s,%d</a>\n',href,ff,e.line);
                else

                    fprintf(1,'    <a href="%s">%s >%s,%d</a>\n',href,ff,n,e.line);
                end
            end
            fprintf(1,'\n');
        end
    end
end
