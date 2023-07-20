classdef MEXCompilationCheck<Simulink.sfunction.analyzer.internal.ComplianceCheck


    properties
Description
Category
EnableUsePublishedOnly
    end

    methods
        function obj=MEXCompilationCheck(description,category,enableUsePublishedOnly)
            obj@Simulink.sfunction.analyzer.internal.ComplianceCheck(description,category);
            obj.EnableUsePublishedOnly=enableUsePublishedOnly;
        end

        function input=constructInput(obj,target)
            sfunctionName=target.SfcnFile;
            libFileList=target.LibFileList;
            srcFileList=target.ExtraSrcFileList;
            objFileList=target.ObjFileList;
            addIncPaths=target.IncPaths;
            addLibPaths=target.LibPaths;
            addSrcPaths=target.SrcPaths;
            preProcDefList=target.PreProcDefList;

            libAndObjFilesWithFullPath=slprivate('locateFileInPath',{libFileList{:},objFileList{:}},...
            {addLibPaths{:},addSrcPaths{:},pwd},...
            filesep);
            srcFilesSearchPaths={addSrcPaths{:},pwd};
            srcFilesWithFullPath=slprivate('locateFileInPath',srcFileList,srcFilesSearchPaths,filesep);
            sfunctionName=char(slprivate('locateFileInPath',sfunctionName,srcFilesSearchPaths,filesep));
            customSrcAndLibAndObj=slprivate('joinCellToStr',{...
            libAndObjFilesWithFullPath{:}...
            ,srcFilesWithFullPath{:}},''',''');
            customSrcAndLibAndObj=['''',customSrcAndLibAndObj,''''];

            input.sfunctionFile=sfunctionName;
            input.customSrcAndLibAndObj=customSrcAndLibAndObj;
            input.addIncPaths=addIncPaths;
            input.preProcDefList=preProcDefList;
            input.outdir=target.targetDir;
            input.isDebug=target.isDebug;
        end

        function[description,result,details]=execute(obj,input)
            description=obj.Description;
            try
                [mexVerboseText,errorOccurred]=Simulink.sfunction.analyzer.internal.sfuncSourceCompile(true,input.sfunctionFile,input.customSrcAndLibAndObj,...
                input.addIncPaths,input.preProcDefList,input.outdir,obj.EnableUsePublishedOnly,input.isDebug);
            catch ex
                errorOccurred=1;
                mexVerboseText=slprivate('getExceptionMsgReport',ex);
                if(isempty(mexVerboseText))
                    mexVerboseText=sprintf(['\n\n\n\t\tAn unexpected error occurred during compilation. Please'...
                    ,' verify the following:\n'...
                    ,'\t\t -The MEX command is configured correctly. Type ''mex -setup'' at \n',...
                    '\t\t  MATLAB command prompt to configure this command.\n',...
                    '\t\t -The S-function settings in the Initialization or Libraries tab were entered incorrectly.\n',...
                    '\t\t  (i.e. use comma separated list for the library/source files)\n']);
                end
            end
            compilerInfo=mex.getCompilerConfigurations('C','Selected');
            compiler=compilerInfo.ShortName;
            [result,details]=Simulink.sfunction.analyzer.internal.parseCompileResult(mexVerboseText,compiler,errorOccurred);
        end
    end

end

