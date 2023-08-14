classdef(Hidden)frametosamples_gatewayin




%#codegen

    methods
        function obj=frametosample_gatewayin(varargin)%#ok<STOUT> % needed for p-code
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

        function gatewayIn(blk)

            commhdl.internal.frametosamples_gatewayin.gatewayInChangeNumberOfPorts(blk);
        end

        function gatewayInSettingChecking(blk)

            try %#ok<EMTC>

                intersampleidlecycles=slResolve(get_param(blk,'InterSampleIdleCycles'),blk);
                interframeidlecycles=slResolve(get_param(blk,'InterFrameIdleCycles'),blk);
                outputsize=slResolve(get_param(blk,'OutputSize'),blk);
            catch ME %#ok<NASGU>
                return;
            end

...
...
...
...

            validateattributes(intersampleidlecycles,{'numeric'},...
            {'scalar','finite','integer','>=',0},'frametosamples_gatewayin','Invalid samples inserted between valid samples');

            validateattributes(interframeidlecycles,{'numeric'},...
            {'scalar','finite','integer','>=',0},'frametosamples_gatewayin','Invalid samples inserted at the end of frame');

            validateattributes(outputsize,{'numeric'},...
            {'scalar','finite','integer','>',0},'frametosamples_gatewayin','Number of samples in the output');

        end


        function gatewayInFIL(blk,action)



            s=dbstack;
            if strcmpi(s(end).name,'frametosamples_gatewayin.gatewayInSettingChecking')

                return;
            end

            if strcmpi(action,'init')

                commhdl.internal.frametosamples_gatewayin.gatewayInFILChangeNumberOfPorts(blk);
            end


            commhdl.internal.frametosamples_gatewayin.gatewayInChangeNumberOfPorts(blk);
        end

    end

    methods(Static,Hidden,Access=private)

        function gatewayInChangeNumberOfPorts(blk)
            try %#ok<EMTC>
                outputsize=slResolve(get_param(blk,'OutputSize'),blk);
            catch ME %#ok<NASGU>
                return;
            end

            visStr=get_param(blk,'MaskVisibilities');


            if(ceil(outputsize)==outputsize)&&...
                (outputsize~=0)&&...
                (outputsize>1)

                vis='on';
            else
                vis='off';
            end
            visStr{end}=vis;
            set_param(blk,'MaskVisibilities',visStr);
        end

        function gatewayInFILChangeNumberOfPorts(blk)

            set_param(blk,'MaskSelfModifiable','on');

            try %#ok<EMTC>
                ExpectedNumOutputs=slResolve(get_param(blk,'OutputSize'),blk);
            catch ME %#ok<NASGU>
                return;
            end



            Demuxblklist=find_system(blk,'LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'FollowLinks','on',...
            'regexp','on','Name','sampledemux');
            Demuxblk=Demuxblklist{1};


            CurrentNumOutputs=numel(find_system(Demuxblk,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'regexp','on','BlockType','Outport'));

            if ExpectedNumOutputs~=CurrentNumOutputs



                if CurrentNumOutputs==1

                    delete_line(blk,'sampledemux/1','sample1/1');
                    delete_block([blk,'/sample1']);


                    delete_line(Demuxblk,'In1/1','Reshape1/1');
                    delete_line(Demuxblk,'Reshape1/1','Out1/1');
                    delete_block([Demuxblk,'/Reshape1']);
                    delete_block([Demuxblk,'/Out1']);
                else
                    for ii=CurrentNumOutputs:-1:1


                        delete_line(blk,['sampledemux/',num2str(ii)],['sample',num2str(ii),'/1']);
                        delete_block([blk,'/sample',num2str(ii)]);




                        delete_line(Demuxblk,'In1/1',['Selector',num2str(ii),'/1']);
                        delete_line(Demuxblk,['Selector',num2str(ii),'/1'],['Out',num2str(ii),'/1']);
                        delete_block([Demuxblk,'/Selector',num2str(ii)]);
                        delete_block([Demuxblk,'/Out',num2str(ii)]);
                    end
                end




                selPos=[200,103,230,117];
                outPos=[510,23,540,37];
                if ExpectedNumOutputs==1



                    oporth=add_block('built-in/Outport',...
                    [Demuxblk,'/Out1'],...
                    'Position',[selPos(1)+90,selPos(2),selPos(3)+90,selPos(4)]);
                    portname=get_param(oporth,'Name');
                    reshapeh=add_block('built-in/Reshape',...
                    [Demuxblk,'/Reshape1'],...
                    'Position',selPos,...
                    'OutputDimensionality','Column vector (2-D)');
                    reshapename=get_param(reshapeh,'Name');
                    add_line(Demuxblk,'In1/1',[reshapename,'/1']);
                    add_line(Demuxblk,[reshapename,'/1'],[portname,'/1']);


                    oporth=add_block('built-in/Outport',[blk,'/sample',num2str(ii)],...
                    'Position',outPos,'Port',num2str(ii));
                    portname=get_param(oporth,'Name');
                    add_line(blk,['sampledemux/',num2str(ii)],[portname,'/1']);
                else
                    for ii=1:ExpectedNumOutputs

                        blkh=add_block('built-in/Selector',...
                        [Demuxblk,'/Selector',num2str(ii)]);
                        blkname=get_param(blkh,'Name');
                        set_param(blkh,'Position',selPos,...
                        'NumberOfDimensions','2',...
                        'IndexMode','One-Based',...
                        'IndexOptions','Select all,Index vector (dialog)',...
                        'IndexParamArray',{'1',num2str(ii)});

                        oporth=add_block('built-in/Outport',...
                        [Demuxblk,'/Out',num2str(ii)],...
                        'Position',[selPos(1)+90,selPos(2),selPos(3)+90,selPos(4)]);
                        portname=get_param(oporth,'Name');

                        add_line(Demuxblk,'In1/1',[blkname,'/1']);
                        add_line(Demuxblk,[blkname,'/1'],[portname,'/1']);

                        selPos=selPos+[0,25,0,25];





                        oporth=add_block('built-in/Outport',[blk,'/sample',num2str(ii)],...
                        'Position',outPos,'Port',num2str(ii));
                        portname=get_param(oporth,'Name');
                        add_line(blk,['sampledemux/',num2str(ii)],[portname,'/1']);
                        outPos=outPos+[0,25,0,25];
                    end
                end
            end
        end

    end
end
