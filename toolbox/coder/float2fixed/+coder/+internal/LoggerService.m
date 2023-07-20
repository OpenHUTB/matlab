




classdef LoggerService

    properties(Constant)
        inputLogValuePrefix='gEMLSimLogVal_in_';
        outputLogValuePrefix='gEMLSimLogVal_out_';
        iterationPrefix='gEMLSimLogRunIdx';

        fcnInputPrefix='in_';
        fcnOutputPrefix='out_';

        USE_CELLARRAY_LOGGING='USE_CELLARRAY_LOGGING';
        USE_NON_CELLARRAY_LOGGING='USE_NON_CELLARRAY_LOGGING';


        MEX_LOGGER_TEMPLATE_PATH=fullfile(matlabroot,'toolbox','coder','float2fixed','+coder','+internal','+logging','logger.m.txt');


        FETCH_CODER_LOGGER_ENTRY_POINT='customFetchLoggedData';
        FETCH_CODER_LOGGER_ENTRY_POINT_EXAMPLE_INPUTS={};
        LOGGING_RUNTIME_ENTRY_POINT='customCoderEnableLog';
        LOGGING_RUNTIME_ENTRY_POINT_EXAMPLE_INPUTS={coder.typeof(uint32(0),[1,Inf],[0,1]),coder.typeof(true,[1,Inf],[0,1])};
        LOGSTMTS_ENTRY_POINT='logStmts';
        LOGSTMTS_ENTRY_POINT_EXAMPLE_INPUTS={};
        CUSTOM_LOG_ENABLE_LOG_DEFAULT=false;



        FLOAT_PLOT_LINE_COLOR=[0,114,189]/255;

        FIXED_PLOT_LINE_COLOR=[77,190,238]/255;
        ERROR_PLOT_LINE_COLOR=[226,61,45]/255;
    end

    methods(Static,Access='private')

        function res=BuildOutVarName(name,suffix)
            res=[coder.internal.LoggerService.outputLogValuePrefix,name,suffix];
        end

        function res=BuildInVarName(name,suffix)
            res=[coder.internal.LoggerService.inputLogValuePrefix,name,suffix];
        end

        function res=BuildIterationVarName(suffix)
            res=[coder.internal.LoggerService.iterationPrefix,suffix];
        end


        function logSnippet=getFcnLoggingRoutine(dif,bailoutEarly,bailoutExceptionIdentifier,InVals,outVals,simLimit,coderConstIndices,inputVarDimIndices,outputVarDimIndices,loggingMode)

            inVars=dif.inportNames;
            outVars=dif.outportNames;

            if isfield(dif,'logFcnVarSuffix')
                suffix=dif.logFcnVarSuffix;
            else
                suffix='';
            end




            globalPrefixedOutArgNames=cellfun(@(x)coder.internal.LoggerService.BuildOutVarName(x,suffix)...
            ,outVars...
            ,'UniformOutput',false);
            globalPrefixedInArgNames=cellfun(@(x)coder.internal.LoggerService.BuildInVarName(x,suffix)...
            ,inVars...
            ,'UniformOutput',false);
            screenedglobalPrefixedInArgNames=globalPrefixedInArgNames;
            screenedglobalPrefixedInArgNames(coderConstIndices)=[];
            screenedglobalPrefixedInArgNames(inputVarDimIndices)=[];

            screenedglobalPrefixedOutArgNames=globalPrefixedOutArgNames;
            screenedglobalPrefixedOutArgNames(outputVarDimIndices)=[];

            globalPrefixedVars={screenedglobalPrefixedOutArgNames{:},screenedglobalPrefixedInArgNames{:}};



            inArgNames=cellfun(@(x)[coder.internal.LoggerService.fcnInputPrefix,x],inVars,'UniformOutput',false);
            outArgNames=cellfun(@(x)[coder.internal.LoggerService.fcnOutputPrefix,x],outVars,'UniformOutput',false);



            screenedInArgNames=inArgNames;
            screenedInArgNames(coderConstIndices)=[];
            screenedInArgNames(inputVarDimIndices)=[];

            screenedOutArgNames=outArgNames;
            screenedOutArgNames(outputVarDimIndices)=[];
            vars={screenedOutArgNames{:},screenedInArgNames{:}};



            fcnDeclVarList=strjoin(vars,', ');

            vals={InVals{:},outVals{:}};

            logSnippet=coder.internal.LoggerService.generateCodeForLocalLogData(loggingMode,fcnDeclVarList,globalPrefixedVars,vars,bailoutEarly,bailoutExceptionIdentifier,vals,simLimit,suffix);
        end


        function logSnippet=generateCodeForLocalLogData(loggingMode,fcnDeclVarList,prefixedVars,origVars,bailoutEarly,bailoutExceptionIdentifier,vals,simLimit,varSuffix)

            logStr=sprintf('function localLogData(%s)\n',fcnDeclVarList);
            gidxn=coder.internal.LoggerService.BuildIterationVarName(varSuffix);
            for ii=1:length(prefixedVars)
                vn=prefixedVars{ii};
                logStr=[logStr,sprintf('global %s;\n',vn)];
            end
            logStr=[logStr,sprintf('global %s;\n',gidxn)];
            logStr=[logStr,sprintf('persistent maxIdx;\n\n')];
            logStr=[logStr,sprintf('if isempty(%s)\n',gidxn)];
            logStr=[logStr,sprintf('\t%s = 1;\n',gidxn)];
            logStr=[logStr,sprintf('\tmaxIdx = 1;\n')];

            logStr=coder.internal.LoggerService.getFcnLoggingCodeForInitializers(loggingMode,logStr,prefixedVars,origVars,vals);

            logStr=[logStr,sprintf('\t%s = %s+1;\n',gidxn,gidxn)];
            logStr=[logStr,sprintf('\treturn\n\n')];
            logStr=[logStr,sprintf('end\n\n')];
            logStr=[logStr,sprintf('if %s > maxIdx\n',gidxn)];
            logStr=[logStr,sprintf('\tmaxIdx = 2 * maxIdx;\n')];

            logStr=coder.internal.LoggerService.getFcnLoggingCodeForGrowingArrays(loggingMode,logStr,prefixedVars,vals);
            logStr=[logStr,sprintf('end\n\n')];

            logStr=coder.internal.LoggerService.getFcnLoggingCodeForFillingArrays(loggingMode,logStr,prefixedVars,origVars,gidxn,vals);
            logStr=[logStr,sprintf('%s = %s+1;\n\n',gidxn,gidxn)];

            if bailoutEarly
                logStr=[logStr,sprintf('\n\nif %s > %d\n',gidxn,simLimit)];
                logStr=[logStr,sprintf('\t throw( MException(''%s'', ''Return early for input computation''));\n',bailoutExceptionIdentifier)];
                logStr=[logStr,sprintf('end\n\n')];
            end
            logSnippet=logStr;
        end

        function logStr=getFcnLoggingCodeForInitializers(logginMode,logStr,prefixedVars,origVars,vals)
            if(isempty(vals))

                for ii=1:length(prefixedVars)
                    vn=prefixedVars{ii};

                    origVar=origVars{ii};

                    if strcmp(logginMode,coder.internal.LoggerService.USE_CELLARRAY_LOGGING)
                        logStr=[logStr,sprintf('\t\t%s = {%s};\n',vn,origVar)];
                    else
                        logStr=[logStr,sprintf('\tif isstruct(%s)\n',origVar)];%#ok<*AGROW>
                        logStr=[logStr,sprintf('\t\t%s = %s;\n',vn,origVar)];
                        logStr=[logStr,sprintf('\telseif isscalar(%s)\n',origVar)];%#ok<*AGROW>
                        logStr=[logStr,sprintf('\t\t%s = %s;\n',vn,origVar)];
                        logStr=[logStr,sprintf('\telseif iscolumn(%s)\n',origVar)];
                        logStr=[logStr,sprintf('\t\t%s = %s.'';\n',vn,origVar)];
                        logStr=[logStr,sprintf('\telseif isrow(%s)\n',origVar)];
                        logStr=[logStr,sprintf('\t\t%s = %s;\n',vn,origVar)];

                        logStr=[logStr,sprintf('\telse\n')];
                        logStr=[logStr,sprintf('\t\t%s = {%s};\n',vn,origVar)];
                        logStr=[logStr,sprintf('\tend\n\n')];
                    end

                end
            else
                for ii=1:length(prefixedVars)
                    vn=prefixedVars{ii};
                    value=vals{ii};
                    origVar=origVars{ii};

                    if(isstruct(value))
                        logStr=[logStr,sprintf('\t%s = %s;\n',vn,origVar)];
                    elseif(isscalar(value))
                        logStr=[logStr,sprintf('\t%s = %s;\n',vn,origVar)];
                    elseif(iscolumn(value))
                        logStr=[logStr,sprintf('\t%s = %s.'';\n',vn,origVar)];
                    elseif(isrow(value))
                        logStr=[logStr,sprintf('\t%s = %s;\n',vn,origVar)];
                    else
                        logStr=[logStr,sprintf('\t%s = {%s};\n',vn,origVar)];
                    end
                end
            end
        end


        function logStr=getFcnLoggingCodeForGrowingArrays(logginMode,logStr,prefixedVars,vals)
            if(isempty(vals))
                for ii=1:length(prefixedVars)
                    vn=prefixedVars{ii};

                    if strcmp(logginMode,coder.internal.LoggerService.USE_CELLARRAY_LOGGING)
                        logStr=[logStr,sprintf('\t\t%s(maxIdx, :) = {%s{1}};\n',vn,vn)];
                    else
                        logStr=[logStr,sprintf('\tif(iscell(%s))\n',vn)];
                        logStr=[logStr,sprintf('\t\t%s(maxIdx, :) = {%s{1}};\n',vn,vn)];
                        logStr=[logStr,sprintf('\telse\n')];
                        logStr=[logStr,sprintf('\t\t%s(maxIdx, :) = %s(1);\n',vn,vn)];
                        logStr=[logStr,sprintf('\tend\n')];
                    end
                end
            else
                for ii=1:length(prefixedVars)
                    vn=prefixedVars{ii};
                    value=prefixedVars{ii};
                    if(iscell(value))
                        logStr=[logStr,sprintf('\t%s(maxIdx, :) = {%s{1}};\n',vn,vn)];
                    else
                        logStr=[logStr,sprintf('\t%s(maxIdx, :) = %s(1);\n',vn,vn)];
                    end
                end
            end
        end


        function logStr=getFcnLoggingCodeForFillingArrays(logginMode,logStr,prefixedVars,origVars,gidxn,vals)
            if(isempty(vals))
                for ii=1:length(prefixedVars)
                    vn=prefixedVars{ii};
                    origVar=origVars{ii};

                    if strcmp(logginMode,coder.internal.LoggerService.USE_CELLARRAY_LOGGING)
                        logStr=[logStr,sprintf('\t%s(%s, :) = {%s};\n',vn,gidxn,origVar)];
                    else
                        logStr=[logStr,sprintf('if isstruct(%s)\n',origVar)];
                        logStr=[logStr,sprintf('\t%s(%s, :) = %s;\n',vn,gidxn,origVar)];
                        logStr=[logStr,sprintf('elseif isscalar(%s)\n',origVar)];
                        logStr=[logStr,sprintf('\t%s(%s, :) = %s;\n',vn,gidxn,origVar)];
                        logStr=[logStr,sprintf('elseif iscolumn(%s)\n',origVar)];
                        logStr=[logStr,sprintf('\t%s(%s, :) = %s.'';\n',vn,gidxn,origVar)];
                        logStr=[logStr,sprintf('elseif(isrow(%s))\n',origVar)];
                        logStr=[logStr,sprintf('\t%s(%s, :) = %s;\n',vn,gidxn,origVar)];
                        logStr=[logStr,sprintf('else\n')];
                        logStr=[logStr,sprintf('\t%s(%s, :) = {%s};\n',vn,gidxn,origVar)];
                        logStr=[logStr,sprintf('end\n\n')];
                    end
                end
            else
                for ii=1:length(prefixedVars)
                    vn=prefixedVars{ii};
                    value=vals{ii};
                    origVar=origVars{ii};

                    if(isstruct(value))
                        logStr=[logStr,sprintf('%s(%s, :) = %s;\n',vn,gidxn,origVar)];
                    elseif(isscalar(value))
                        logStr=[logStr,sprintf('%s(%s) = %s;\n',vn,gidxn,origVar)];
                    elseif(iscolumn(value))
                        logStr=[logStr,sprintf('%s(%s, :) = %s.'';\n',vn,gidxn,origVar)];
                    elseif(isrow(value))
                        logStr=[logStr,sprintf('%s(%s, :) = %s;\n',vn,gidxn,origVar)];
                    else
                        logStr=[logStr,sprintf('%s(%s, :) = {%s};\n',vn,gidxn,origVar)];
                    end
                end
            end
        end



        function strVarList=buildLogVarNameList(inportNames,outportNames,varSuffix)
            prefixedInportName=arrayfun(@(x)coder.internal.LoggerService.BuildInVarName(x{:},varSuffix),inportNames,'UniformOutput',false);
            prefixedOutportName=arrayfun(@(x)coder.internal.LoggerService.BuildOutVarName(x{:},varSuffix),outportNames,'UniformOutput',false);

            prefixedVarNames={prefixedInportName{:},prefixedOutportName{:}};%#ok<*CCAT>

            strVarList=strjoin(prefixedVarNames,' ');
        end
    end



    methods(Static)

        function loggedValues=packageLoggedValues(dif)
            loggedValues=struct;
            loggedValues.inputs=struct;
            loggedValues.outputs=struct;
            loggedValues.iter=0;

            inportNames=dif.inportNames;
            outportNames=dif.outportNames;
            if isfield(dif,'logFcnVarSuffix')
                varSuffix=dif.logFcnVarSuffix;
            else
                varSuffix='';
            end

            for ii=1:length(inportNames)
                vn=inportNames{ii};
                eval(sprintf(['global ',coder.internal.LoggerService.BuildInVarName('%s',varSuffix)],vn));
                gvn=eval(sprintf(coder.internal.LoggerService.BuildInVarName('%s',varSuffix),vn));
                loggedValues.inputs.(vn)=gvn;
            end

            for ii=1:length(outportNames)
                vn=outportNames{ii};
                eval(sprintf(['global ',coder.internal.LoggerService.BuildOutVarName('%s',varSuffix)],vn));
                gvn=eval(sprintf(coder.internal.LoggerService.BuildOutVarName('%s',varSuffix),vn));
                loggedValues.outputs.(vn)=gvn;
            end

            iterVarName=coder.internal.LoggerService.BuildIterationVarName(varSuffix);
            eval(['global ',iterVarName]);
            loggedValues.iter=eval(iterVarName);
        end


        function clearLogValues(dif)
            if isfield(dif,'logFcnVarSuffix')
                varSuffix=dif.logFcnVarSuffix;
            else
                varSuffix='';
            end
            iterVarName=coder.internal.LoggerService.BuildIterationVarName(varSuffix);

            eval(['clear global ',iterVarName]);
            strVarList=coder.internal.LoggerService.buildLogVarNameList(dif.inportNames,dif.outportNames,varSuffix);
            cmd=sprintf('clear global %s;',strVarList);
            eval(cmd);
        end


        function defineSimLogValues(dif)
            if isfield(dif,'logFcnVarSuffix')
                varSuffix=dif.logFcnVarSuffix;
            else
                varSuffix='';
            end

            iterVarName=coder.internal.LoggerService.BuildIterationVarName(varSuffix);
            eval(['global ',iterVarName]);
            if~isempty(dif.inportNames)||~isempty(dif.outportNames)
                strVarList=coder.internal.LoggerService.buildLogVarNameList(dif.inportNames,dif.outportNames,varSuffix);
                cmd=sprintf('global %s;',strVarList);
                eval(cmd);
            end
        end
    end

    methods(Static)

        function addLoggingCalls(fcnPath,~,~,tempDir)
            [fcnDir,fcnName,~]=fileparts(fcnPath);
            assert(strcmp(fcnDir,tempDir),message('Coder:FxpConvDisp:FXPCONVDISP:logginCallsAllowedOnly4TempFiles').getString);

            [inputArgNames,outputArgNames]=coder.internal.Float2FixedConverter.getFcnInterface(fcnName);


            fcnImplName=[fcnName,'_impl'];
            coder.internal.Helper.changeIdInFile(fcnPath,fcnName,fcnImplName);

            fcnImplCode=fileread(fcnPath);

            coder.internal.LoggerService.createFunctionWithLocalLogDataCall(fcnPath,inputArgNames,outputArgNames,fcnImplName,fcnImplCode)
        end

        function createFunctionWithLocalLogDataCall(fullFileName,inputArgNames,outputArgNames,calleeName,additionalCode)
            if nargin<5
                additionalCode=[];
            end
            [~,fcnName,~]=fileparts(fullFileName);

            prefixedInArgNames=cellfun(@(x)[coder.internal.LoggerService.fcnInputPrefix,x],inputArgNames,'UniformOutput',false);
            prefixedOutArgNames=cellfun(@(x)[coder.internal.LoggerService.fcnOutputPrefix,x],outputArgNames,'UniformOutput',false);
            argNames={prefixedInArgNames{:},prefixedOutArgNames{:}};

            fid=coder.internal.Helper.fileOpen(fullFileName,'w');
            fprintf(fid,'%%#codegen\n');
            fprintf(fid,'function %s\n\n',coder.internal.Helper.getFcnInterfaceSignature(fcnName,prefixedInArgNames,prefixedOutArgNames));
            fprintf(fid,'\t%s;\n',coder.internal.Helper.getFcnInterfaceSignature(calleeName,prefixedInArgNames,prefixedOutArgNames));
            fprintf(fid,'\tcoder.extrinsic(''-sync:off'', ''localLogData'');\n');

            fprintf(fid,'\tlocalLogData(%s);\n',coder.internal.Helper.getArgList(argNames));



            fprintf(fid,'end\n');
            fprintf(fid,'\n');
            if~isempty(additionalCode)
                fprintf(fid,'%s\n',additionalCode);
            end
            fclose(fid);
            clear(fcnName);

        end

        function logDataFcnName=createLocalLogDataFunctionFile(dif,outputDir,coderConstIndices,inputVarDimIndices,outputVarDimIndices,bailoutEarly,bailoutExceptionIdentifier,inVals,outVals,simLimit,loggingMode)
            if nargin<3
                coderConstIndices=[];
            end
            if nargin<4
                inputVarDimIndices=[];
            end
            if nargin<5
                outputVarDimIndices=[];
            end
            if nargin<6
                bailoutEarly=false;
            end
            if nargin<7
                bailoutExceptionIdentifier='Coder:FXPCONV:MATLABSimBailOut';
            end
            if nargin<8
                inVals={};
            end
            if nargin<9
                outVals={};
            end
            if nargin<10


                simLimit=Inf;
            end
            if nargin<11
                loggingMode=coder.internal.LoggerService.USE_CELLARRAY_LOGGING;
            end

            logFcnSnippet=coder.internal.LoggerService.getFcnLoggingRoutine(dif,bailoutEarly,bailoutExceptionIdentifier,inVals,outVals,simLimit,coderConstIndices,inputVarDimIndices,outputVarDimIndices,loggingMode);

            if isfield(dif,'logFcnSuffix')
                suffix=dif.logFcnSuffix;
            else
                suffix='';
            end
            logDataFcnName=['localLogData',suffix];
            fid=coder.internal.Helper.fileOpen(fullfile(outputDir,[logDataFcnName,'.m']),'w');
            fprintf(fid,'%s',logFcnSnippet);
            fclose(fid);
            clear(logDataFcnName)
        end

        function out=convertRawDataFromCoderLogFormat(rdata)

            for kk=1:length(rdata)

                rdp=rdata{kk};
                out(kk).fcnName=rdp{1};
                out(kk).filePath=rdp{2};
                out(kk).loggedExprs=rdp{3};
            end
        end

        function out=convertToMapFormat(rawData,~)
            if isempty(rawData)
                out=coder.internal.Float2FixedConverter.LOGGED_DATA_DEFAULT;
                return
            end

            out=coder.internal.lib.Map();
            for kk=1:length(rawData)
                data=rawData(kk);

                fcnName=internal.mtree.FunctionTypeInfo.BuildUniqueFullName(data.FunctionPath,data.FunctionName,data.FunctionSpecializationNumber);

                if~isKey(out,fcnName)
                    out(fcnName)=struct('functionName',data.FunctionName,'filePath',data.FunctionPath,'inputs',struct,'outputs',struct,'loggedExps',[],'hasSpecializtion',data.HasFunctionSpecialization,'specializationNumber',data.FunctionSpecializationNumber);
                end


                fcnData=out(fcnName);

                exprType=data.ExprType;
                switch exprType
                case coder.internal.ComparisonPlotService.INPUT_EXPR
                    fcnData.inputs.(data.ExprId)=data.LoggedData;
                case coder.internal.ComparisonPlotService.OUTPUT_EXPR
                    fcnData.outputs.(data.ExprId)=data.LoggedData;
                otherwise
                    assert(false,'Unknown expression types for logging. Only input/output logging is supported.');
                end

                out(fcnName)=fcnData;
            end
        end
    end
end


