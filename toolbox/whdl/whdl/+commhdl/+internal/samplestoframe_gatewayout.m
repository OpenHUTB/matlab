classdef(Hidden)samplestoframe_gatewayout




%#codegen

    methods
        function obj=samplestoframe_gatewayout(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
        end
    end

    methods(Static=true)

        function gatewayOutSettingChecking(blk)

            try %#ok<EMTC>
                inputsize=slResolve(get_param(blk,'InputSize'),blk);
                framesearchwindow=slResolve(get_param(blk,'FrameSearchWindow'),blk);
                outputsize=slResolve(get_param(blk,'OutputSize'),blk);
            catch ME %#ok<NASGU> % do nothing
                return;
            end

            validateattributes(inputsize,{'numeric'},...
            {'scalar','finite','integer','>',0},'samplestoframe_gatewayout','Input size');

            validateattributes(framesearchwindow,{'numeric'},...
            {'scalar','finite','integer','>',0},'samplestoframe_gatewayout','Frame search window');

            validateattributes(outputsize,{'numeric'},...
            {'scalar','finite','integer','>',0},'samplestoframe_gatewayout','Output size');
        end

        function gatewayOutInit(blk)






            s=dbstack;
            if strcmpi(s(end).name,'samplestoframe_gatewayout.gatewayOutSettingChecking')

                return;
            end


            commhdl.internal.samplestoframe_gatewayout.gatewayOutSettingChecking(blk);

            try %#ok<EMTC>

                inputsize=slResolve(get_param(blk,'InputSize'),blk);
                framesearchwindow=slResolve(get_param(blk,'FrameSearchWindow'),blk);
            catch ME %#ok<NASGU> % do nothing
                return;
            end

            if mod(framesearchwindow,inputsize)~=0
                error(message('whdl:FrameOfSamplesToFrame:WindowNotMultipleOfInputSize',...
                framesearchwindow,inputsize));
            end


            set_param(blk,'MaskSelfModifiable','on');
            commhdl.internal.samplestoframe_gatewayout.fixFrameLenPort(blk);

        end

        function gatewayOutFILSettingChecking(blk)

            set_param(blk,'MaskSelfModifiable','on');

            try %#ok<EMTC>
                numsampleinputs=slResolve(get_param(blk,'NumSampleInputs'),blk);
                outputsize=slResolve(get_param(blk,'OutputSize'),blk);
            catch ME %#ok<NASGU>
                return;
            end

            validateattributes(numsampleinputs,{'numeric'},...
            {'scalar','finite','integer','>',0},'samplestoframe_gatewayout','Number of sample inputs');

            validateattributes(outputsize,{'numeric'},...
            {'scalar','finite','integer','>',0},'samplestoframe_gatewayout','Output size');

        end


        function gatewayOutFIL(blk,action)



            s=dbstack;
            if strcmpi(s(end).name,'samplestoframe_gatewayout.gatewayOutFILSettingChecking')

                return;
            end


            commhdl.internal.samplestoframe_gatewayout.gatewayOutFILSettingChecking(blk);

            if strcmpi(action,'init')
                set_param(blk,'MaskSelfModifiable','on');

                commhdl.internal.samplestoframe_gatewayout.gatewayOutFILChangeNumberOfPorts(blk);

                commhdl.internal.samplestoframe_gatewayout.fixFrameLenPort(blk);
            end
        end

    end

    methods(Static,Hidden,Access=private)

        function gatewayOutFILChangeNumberOfPorts(blk)

            set_param(blk,'MaskSelfModifiable','on');

            commhdl.internal.samplestoframe_gatewayout.fixFILSamplePorts(blk);

        end

        function fixFILSamplePorts(blk)

            try %#ok<EMTC>


                ExpectedNumSampleInputs=slResolve(get_param(blk,'NumsampleInputs'),blk);
            catch ME %#ok<NASGU> % do nothing
                return;
            end



            sampleBlkName='sample';


            siport=find_system(blk,'regexp','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all','FollowLinks','on',...
            'BlockType','Inport','Name',sampleBlkName);
            CurrentNumSampleInputs=numel(siport);

            if ExpectedNumSampleInputs~=CurrentNumSampleInputs





                muxblkname='SampleMux';
                muxblk=[blk,'/',muxblkname];


                for ii=1:numel(siport)

                    iport=get_param(siport{ii},'Name');
                    delete_line(blk,[iport,'/1'],[muxblkname,'/',num2str(ii)]);
                    delete_block(siport{ii});
                end



                inblkpos=[20,135,50,149];

                set_param(muxblk,'NumInputs',num2str(ExpectedNumSampleInputs));
                for ii=1:ExpectedNumSampleInputs
                    iblk=add_block('built-in/Inport',[blk,'/sample',num2str(ii)],...
                    'Port',num2str(ii),'Position',inblkpos);
                    iblkname=get_param(iblk,'Name');
                    add_line(blk,[iblkname,'/1'],[muxblkname,'/',num2str(ii)]);
                    inblkpos=inblkpos+[0,35,0,35];
                end
            end
        end

        function fixFrameLenPort(blk)




            currentLenout=~isempty(find_system(blk,...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','all','FollowLinks','on',...
            'BlockType','Outport','Name','len'));
            expectedLenout=strcmpi(get_param(blk,'FrameLengthOutputPort'),'on');

            if expectedLenout~=currentLenout

                set_param(blk,'MaskSelfModifiable','on');





                lenblks=find_system(blk,'LookUnderMasks','all',...
                'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
                'FollowLinks','on','Name','len');
                lenblk=lenblks{1};

                lenpos=get_param(lenblk,'Position');
                delete_line(blk,'FOS2F/3','len/1')
                delete_block(lenblk);



                if expectedLenout
                    add_block('built-in/Outport',lenblk,'Position',lenpos);
                else
                    add_block('built-in/Terminator',lenblk,'Position',lenpos);
                end


                add_line(blk,'FOS2F/3','len/1')

            end
        end

    end
end
