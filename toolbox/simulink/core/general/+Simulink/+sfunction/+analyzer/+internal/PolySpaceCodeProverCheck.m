classdef PolySpaceCodeProverCheck<Simulink.sfunction.analyzer.internal.ComplianceCheck

    properties
Description
Category
    end
    methods

        function obj=PolySpaceCodeProverCheck(description,category)
            obj@Simulink.sfunction.analyzer.internal.ComplianceCheck(description,category);
        end

        function input=constructInput(obj,target)



            input.sfcnSrcPaths=target.SrcPaths;
            input.sfcnIncPaths=target.IncPaths;
            input.resultDir=fullfile(target.targetDir,'polyspace_result');
            input.srcType=target.SrcType;
            input.sfcnFile=target.SfcnFile;
            input.extraSrcFileList=target.ExtraSrcFileList;
        end

        function[description,result,details]=execute(obj,input)
            description=obj.Description;
            if~isempty(input.sfcnSrcPaths)||~isempty(input.sfcnFile)

                opts=polyspace.Options(input.srcType);
                if isequal(input.srcType,'C')
                    opts.TargetCompiler.CVersion='c90';
                end
                if ispc
                    if isequal(input.srcType,'C')
                        cc=mex.getCompilerConfigurations('C','Selected');
                    else
                        cc=mex.getCompilerConfigurations('CPP','Selected');
                    end
                    if strcmp(cc.Manufacturer,'GNU')

                        dialect='gnu4.9';
                    else
                        dialect='visual12.0';
                    end
                elseif ismac
                    dialect='clang3';
                else
                    dialect='gnu4.9';
                end
                opts.TargetCompiler.Compiler=dialect;
                opts.ChecksAssumption.DisableInitializationChecks=true;
                opts.Sources={input.sfcnFile};
                for kk=1:numel(input.sfcnSrcPaths)
                    for i=1:numel(input.extraSrcFileList)
                        if(exist(fullfile(input.sfcnSrcPaths{kk},input.extraSrcFileList{i}),'file')==2)
                            opts.Sources={opts.Sources{:},fullfile(input.sfcnSrcPaths{kk},input.extraSrcFileList{i})};
                        end
                    end
                end
                opts.ResultsDir=input.resultDir;
                opts.EnvironmentSettings.IncludeFolders={fullfile(matlabroot,'simulink','include'),...
                fullfile(matlabroot,'extern','include'),...
                input.sfcnIncPaths{:}};
                opts.Macros.DefinedMacros={'MATLAB_MEX_FILE'};



                opts.Precision.To='Software Safety Analysis level 0';


                polyspaceCodeProver(opts);
                resdirBF=opts.ResultsDir;
                resObj=polyspace.CodeProverResults(resdirBF);
                res=resObj.getResults();
                [s,~]=size(res);
                if(s==0)
                    result=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                    details={opts.ResultsDir};
                else
                    result=Simulink.sfunction.analyzer.internal.ComplianceCheck.WARNING;
                    summaryTable=resObj.getSummary();
                    [rows,cols]=size(summaryTable);
                    reds=summaryTable.Red;
                    for i=1:rows
                        if(char(reds(i))~='0')
                            result=Simulink.sfunction.analyzer.internal.ComplianceCheck.FAIL;
                        end
                    end


                    details={};
                    tableHeads=summaryTable.Properties.VariableNames;
                    details={tableHeads};
                    files=cellstr(char(summaryTable.File));
                    for i=1:rows
                        if(~isequal(files{i},'simulink.c')&~isequal(files{i},'Total')&~isequal(files{i},'_polyspace_main.cpp')...
                            &~isequal(files{i},'simulink_solver_api.c')&~isequal(files{i},'__polyspace_main.c'))
                            temp=cellstr(char(summaryTable{i,1:cols}));
                            details=[details,{temp}];
                        end
                    end

                    details=[details,{opts.ResultsDir}];

                end
            else
                result=Simulink.sfunction.analyzer.internal.ComplianceCheck.NOTRUN;
                details={input.resultDir};
            end
        end

    end

end

