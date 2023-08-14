classdef unfoldingEngine<matlab.mixin.CustomDisplay



    properties(Hidden)
        FunctionName=''
        InputArgs={}
        MexName=''
        Repetition=1
        Threads=feature('numCores')
        StateLength=0
        FrameInputs=false
        Verbose=true
        SubFrameCapable=true
        GenerateAnalyzer=true
        NonBlockingOutput=true
        RunFirstFrame=true
        AnalyzerInputDifferent=false
        BuildConfig=[]
        Debugging=false
        GenerateEmpty=false
    end

    properties(Hidden,SetAccess='protected')
        data=[];
        workspaceDir=[];
    end

    methods
        function obj=unfoldingEngine(varargin)
            if nargin>0
                for i=1:nargin/2
                    obj.(varargin{2*i-1})=varargin{2*i};
                end
            end
        end
    end

    methods(Hidden)




























































































        function generate(obj)
            try
                obj.data.workdirectory='';
                obj.data.orig_warning_state=warning;
                obj.data.tempname='';
                obj.data=ValidateOptions(obj,true);

                if~obj.Debugging
                    obj.data.tempname=strrep(tempname,tempdir,'');
                    obj.data.tempname=obj.data.tempname(1:13);
                else
                    obj.data.tempname='debugtemp';
                end

                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AnalyzingInputFileLog',[obj.data.fname,'.m'])));

                UnfoldingVerbose(obj,true,getString(message('dsp:dspunfold:GenerateWorkspaceLog',obj.data.workdirectory)));
                warning('off','MATLAB:MKDIR:DirectoryExists');
                warning('off','MATLAB:RMDIR:RemovedFromPath');
                c=onCleanup(@()CleanWorkspace(obj));
                if exist(obj.data.workdirectory,'dir')
                    rmdir(obj.data.workdirectory,'s');
                end
                mkdir(obj.data.workdirectory);
                mkdir(obj.data.mpath);
                addpath(obj.data.workdirectory);
                addpath(obj.data.currentdirectory);
                warning(obj.data.orig_warning_state);


                bc=GetBuildConfig(obj);

                UnfoldingVerbose(obj,true,getString(message('dsp:dspunfold:CodegenMATLABFunctionLog')));
                [log,bc]=CodegenInputFilename(obj,bc);

                UnfoldingVerbose(obj,true,getString(message('dsp:dspunfold:AssociateDataTypesLog')));
                obj.data=AssociateDataTypes(obj,log,obj.StateLength>0);

                if(obj.StateLength>-1)||(obj.Threads==1)
                    UnfoldingVerbose(obj,true,getString(message('dsp:dspunfold:ComputeOverlapLog')));
                    [overlap,obj.data.FRAMES_LENGTH]=ComputeOverlapSize(obj,obj.StateLength,obj.SubFrameCapable);
                else
                    obj.data.FRAMES_LENGTH=DetectGeneralFrameSize(obj);
                end

                if obj.GenerateAnalyzer||(obj.StateLength==-1&&obj.Threads>1)
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:CompileSingleThreadedLog',[obj.data.mname,'_st',obj.data.mext])));
                    BuildSequentialSolution(obj,bc);

                    if(obj.GenerateEmpty)
                        UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:CompileEmptyLog',[obj.data.mname,'_empty',obj.data.mext])));
                        BuildEmptySolution(obj,bc);
                    end
                end

                if(obj.StateLength==-1)
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigureLog')));
                    if obj.Threads==1
                        UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigureSingleThreadedLog')));
                    else
                        [lastPass,FoundStateLength]=AutoConfigUnfolding(obj,bc,true);
                        if~lastPass
                            obj.data=AssociateDataTypes(obj,log,true);
                            obj.data.FRAMES_LENGTH=DetectGeneralFrameSize(obj);
                            [~,FoundStateLength]=AutoConfigUnfolding(obj,bc,false);
                        end



                        coder.internal.errorIf(isempty(FoundStateLength),'dsp:dspunfold:InternalError');
                        if(FoundStateLength>=0)
                            if any(obj.data.FrameInputs)
                                if FoundStateLength==Inf
                                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigureStateLengthValueInfiniteSamplesLog',num2str(obj.data.FRAMES_LENGTH*(obj.Threads-1)*obj.Repetition))));
                                else
                                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigureStateLengthValueSamplesLog',num2str(FoundStateLength))));
                                end
                            else
                                if FoundStateLength==Inf
                                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigureStateLengthValueInfiniteFramesLog',num2str((obj.Threads-1)*obj.Repetition))));
                                else
                                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigureStateLengthValueFramesLog',num2str(FoundStateLength))));
                                end
                            end
                        else
                            FoundStateLength=Inf;
                        end
                        [overlap,obj.data.FRAMES_LENGTH]=ComputeOverlapSize(obj,FoundStateLength,true);
                    end
                end

                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:CompileMultiThreadedLog',[obj.data.real_mname,obj.data.mext])));
                [pass,config]=BuildParallelSolution(obj,bc,overlap,obj.SubFrameCapable,false);
                if~pass


                    coder.internal.errorIf(obj.StateLength==-1,'dsp:dspunfold:InternalError');


                    [overlap,obj.data.FRAMES_LENGTH]=ComputeOverlapSize(obj,obj.StateLength,false);
                    [~,config]=BuildParallelSolution(obj,bc,overlap,false,false);
                end
                if obj.GenerateAnalyzer
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:CompileAnalyzerLog',[obj.data.mname,'_analyzer.p'])));
                    GenerateAnalyzerFile(obj,false,config);
                end
                UnfoldingVerbose(obj,true,getString(message('dsp:dspunfold:WriteFilesLog',obj.data.mpath)));
                movefile(fullfile(obj.data.workdirectory,[obj.data.tempname,'_mt',obj.data.mext]),fullfile(obj.data.mpath,[obj.data.real_mname,obj.data.mext]),'f');
                movefile(fullfile(obj.data.workdirectory,[obj.data.tempname,'_mt.m']),fullfile(obj.data.mpath,[obj.data.real_mname,'.m']),'f');
                if obj.GenerateAnalyzer
                    movefile(fullfile(obj.data.workdirectory,[obj.data.tempname,'_st',obj.data.mext]),fullfile(obj.data.mpath,[obj.data.mname,'_st',obj.data.mext]),'f');
                    movefile(fullfile(obj.data.workdirectory,[obj.data.tempname,'_st.m']),fullfile(obj.data.mpath,[obj.data.mname,'_st.m']),'f');
                    if(obj.GenerateEmpty)
                        movefile(fullfile(obj.data.workdirectory,[obj.data.tempname,'_empty',obj.data.mext]),fullfile(obj.data.mpath,[obj.data.mname,'_empty',obj.data.mext]),'f');
                    end
                    if~obj.Debugging
                        movefile(fullfile(obj.data.workdirectory,[obj.data.tempname,'_analyzer_help.m']),fullfile(obj.data.mpath,[obj.data.mname,'_analyzer.m']),'f');
                        movefile(fullfile(obj.data.workdirectory,[obj.data.tempname,'_analyzer.p']),fullfile(obj.data.mpath,[obj.data.mname,'_analyzer.p']),'f');
                    else
                        movefile(fullfile(obj.data.workdirectory,[obj.data.tempname,'_analyzer.m']),fullfile(obj.data.mpath,[obj.data.mname,'_analyzer.m']),'f');
                    end
                end

                UnfoldingVerbose(obj,true,getString(message('dsp:dspunfold:AllDoneLog')));
                warning(obj.data.orig_warning_state);
            catch err
                msg=strrep(err.message,'\','\\');
                msg=strrep(msg,[obj.data.workdirectory,'\\'],'');
                if~ispc
                    msg=strrep(msg,[obj.data.workdirectory,'/'],'');
                end
                msg=strrep(msg,obj.data.workdirectory,'');
                msg=strrep(msg,obj.data.tempname,'internal');

                cg=getString(message('Coder:reportGen:compilationFailed',''));
                dp=strfind(cg,':');
                if~isempty(dp)
                    indx=strfind(msg,cg(1:dp(1)-1));
                    if~isempty(indx)
                        msg=msg(1:indx(1)-1);
                    end
                end

                warning(obj.data.orig_warning_state);

                error(err.identifier,msg);
            end
        end

        data=ValidateOptions(obj,from_engine)

        ValidateCompiler(obj)
    end

    methods(Access=protected)
        [data]=AssociateDataTypes(obj,log,stateful)
        [lastPass,FoundStateLength]=AutoConfigUnfolding(obj,bc,stateless_only)
        BuildEmptySolution(obj,bc)
        [pass,config]=BuildParallelSolution(obj,bc,overlap,allow_to_fail,for_autodetect)
        BuildSequentialSolution(obj,bc)
        CleanWorkspace(obj)
        [log,bcc]=CodegenInputFilename(obj,bc)
        [overlap,FRAMES_LENGTH]=ComputeOverlapSize(obj,StateLength,SubFrameCapable)
        frames_length=DetectGeneralFrameSize(obj)
        GenerateAnalyzerFile(obj,for_autodetect,config)
        GenerateAnalyzerHelp(obj)
        GenerateEmptyMexFile(obj)
        GenerateParallelDispatcher(obj,config,for_autodetect)
        GenerateParallelMexFile(obj,config)
        GenerateParallelMexHeader(obj)
        GenerateParallelMexHelp(obj,config)
        [gen_output]=GenerateParallelWorkers(obj,gen_input,config,for_autodetect)
        GenerateRenamedTop(obj,tname)
        GenerateSequentialMexFile(obj)
        GenerateSequentialMexHelp(obj)
        bc=GetBuildConfig(obj)
        UnfoldingVerbose(obj,forDebug,text,varargin)

        function header=getHeader(obj)%#ok<MANU>
            header='';
        end
        function group=getPropertyGroups(obj)%#ok<MANU>
            h.Class='unfoldingEngine';
            group=matlab.mixin.util.PropertyGroup(h);
        end
        function footer=getFooter(obj)%#ok<MANU>
            footer='';
        end
    end
end
