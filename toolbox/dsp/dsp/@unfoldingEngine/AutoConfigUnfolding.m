function[lastPass,FoundStateLength]=AutoConfigUnfolding(obj,bc,stateless_only)





    try
        samplemode=any(obj.data.FrameInputs);
        lastPass=false;
        FoundStateLength=[];
        FoundStateSamples=false;

        if stateless_only
            UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigCheckStatelessLog')),0);
            overlap.SKIP_AHEAD_SUBFRAME=0;
            overlap.SKIP_AHEAD=0;
            lastPass=check_unfolded(obj,bc,overlap,true,false);
            if lastPass
                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigPassedLog')));
                FoundStateLength=overlap.SKIP_AHEAD;
            else
                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigFailedLog')));
            end
        else
            minState=0;
            if samplemode
                maxState=(obj.Threads-1)*obj.Repetition*obj.data.FRAMES_LENGTH;
            else
                maxState=(obj.Threads-1)*obj.Repetition;
            end


            if(obj.Threads-1)*obj.Repetition>=2
                overlap.SKIP_AHEAD=1;
                overlap.SKIP_AHEAD_SUBFRAME=0;
                if samplemode
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigCheckSamplesLog',num2str(overlap.SKIP_AHEAD*obj.data.FRAMES_LENGTH))),0);
                else
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigCheckFramesLog',num2str(overlap.SKIP_AHEAD))),0);
                end
                lastPass=check_unfolded(obj,bc,overlap,false,false);
                if lastPass
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigPassedLog')));
                    if samplemode
                        FoundStateLength=overlap.SKIP_AHEAD*obj.data.FRAMES_LENGTH;
                        FoundStateSamples=true;
                    else
                        FoundStateLength=overlap.SKIP_AHEAD;
                        return;
                    end
                    maxState=FoundStateLength;
                else
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigFailedLog')));
                    if samplemode
                        minState=overlap.SKIP_AHEAD*obj.data.FRAMES_LENGTH;
                        FoundStateSamples=true;
                    else
                        minState=overlap.SKIP_AHEAD;
                        FoundStateSamples=false;
                    end
                end
            end


            if~lastPass
                if samplemode
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigCheckInfiniteSamplesLog',num2str(obj.data.FRAMES_LENGTH*(obj.Threads-1)*obj.Repetition))),0);
                else
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigCheckInfiniteFramesLog',num2str((obj.Threads-1)*obj.Repetition))),0);
                end
                if(maxState>2)
                    if samplemode
                        if obj.data.FRAMES_LENGTH>1
                            overlap.SKIP_AHEAD=maxState/obj.data.FRAMES_LENGTH;
                            overlap.SKIP_AHEAD_SUBFRAME=obj.data.FRAMES_LENGTH-1;
                        else
                            overlap.SKIP_AHEAD=maxState-1;
                            overlap.SKIP_AHEAD_SUBFRAME=0;
                        end
                    else
                        overlap.SKIP_AHEAD=maxState-1;
                        overlap.SKIP_AHEAD_SUBFRAME=0;
                    end


                    [lastPass,build_pass]=check_unfolded(obj,bc,overlap,false,(overlap.SKIP_AHEAD_SUBFRAME~=0));
                    if~build_pass&&overlap.SKIP_AHEAD>1

                        overlap.SKIP_AHEAD=overlap.SKIP_AHEAD-1;
                        overlap.SKIP_AHEAD_SUBFRAME=0;
                        lastPass=check_unfolded(obj,bc,overlap,false,false);
                    end
                end


                if~lastPass
                    overlap.SKIP_AHEAD=(obj.Threads-1)*obj.Repetition;
                    overlap.SKIP_AHEAD_SUBFRAME=0;

                    lastPass=check_unfolded(obj,bc,overlap,false,false);

                    if~lastPass

                        UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigFailedLog')));
                        FoundStateLength=-1;
                        lastPass=true;
                        if samplemode
                            coder.internal.warning('dsp:dspunfold:InfinteStateSamplesFailed',[obj.data.real_mname,obj.data.mext],[obj.data.mname,'_st',obj.data.mext],num2str(obj.data.FRAMES_LENGTH*(obj.Threads-1)*obj.Repetition),obj.data.fname);
                        else
                            coder.internal.warning('dsp:dspunfold:InfinteStateFramesFailed',[obj.data.real_mname,obj.data.mext],[obj.data.mname,'_st',obj.data.mext],num2str((obj.Threads-1)*obj.Repetition),obj.data.fname);
                        end
                        return;
                    else
                        FoundStateLength=Inf;
                    end
                end
                UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigPassedLog')));
            end



            maxState=maxState/obj.data.FRAMES_LENGTH;
            minState=minState/obj.data.FRAMES_LENGTH;
            while(maxState-minState>1)
                overlap.SKIP_AHEAD=floor((maxState+minState)/2);
                overlap.SKIP_AHEAD_SUBFRAME=0;
                if samplemode
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigCheckSamplesLog',num2str(overlap.SKIP_AHEAD*obj.data.FRAMES_LENGTH))),0);
                else
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigCheckFramesLog',num2str(overlap.SKIP_AHEAD))),0);
                end
                lastPass=check_unfolded(obj,bc,overlap,false,false);
                if lastPass
                    FoundStateLength=overlap.SKIP_AHEAD;
                    FoundStateSamples=false;
                    maxState=FoundStateLength;
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigPassedLog')));
                else
                    minState=overlap.SKIP_AHEAD;
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigFailedLog')));
                end
            end


            if samplemode
                overlap.SKIP_AHEAD=maxState;
                maxState=maxState*obj.data.FRAMES_LENGTH;
                minState=minState*obj.data.FRAMES_LENGTH;
                while(maxState-minState>1)
                    Slength=floor((maxState+minState)/2);
                    overlap.SKIP_AHEAD_SUBFRAME=mod(Slength,obj.data.FRAMES_LENGTH);
                    UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigCheckSamplesLog',num2str(Slength))),0);
                    [lastPass,build_pass]=check_unfolded(obj,bc,overlap,false,true);
                    if lastPass
                        FoundStateLength=Slength;
                        FoundStateSamples=true;
                        maxState=FoundStateLength;
                        UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigPassedLog')));
                    else
                        minState=Slength;
                        if build_pass
                            UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigFailedLog')));
                        else
                            UnfoldingVerbose(obj,false,getString(message('dsp:dspunfold:AutoConfigBuildFailedLog')));
                        end
                    end
                end
            end

            if samplemode&&~FoundStateSamples
                FoundStateLength=FoundStateLength*obj.data.FRAMES_LENGTH;
            end
        end

    catch err
        coder.internal.error('dsp:dspunfold:ErrorAutoConfig',strrep(err.message,'\','\\'));
    end

end


function[numeric_pass,build_pass]=check_unfolded(obj,bc,overlap,stateless_only,allow_not_pass)
    numeric_pass=false;

    [build_pass,config]=BuildParallelSolution(obj,bc,overlap,allow_not_pass,true);

    if(build_pass)
        if stateless_only
            GenerateAnalyzerFile(obj,true,config);
        end
        curdir=pwd;
        chdir(obj.data.workdirectory);
        rehash;

        testName=strcat(obj.data.tempname,'_analyzer(');
        for i=1:numel(obj.InputArgs)
            if isa(obj.InputArgs{i},'coder.Constant')
                testName=strcat(testName,['obj.InputArgs{',num2str(i),'}.Value']);
            else
                testName=strcat(testName,['obj.InputArgs{',num2str(i),'}']);
            end
            if i<numel(obj.InputArgs)
                testName=strcat(testName,',');
            end
        end
        testName=strcat(testName,')');
        [~,numeric_pass]=evalc(testName);
        chdir(curdir);
    end

end
