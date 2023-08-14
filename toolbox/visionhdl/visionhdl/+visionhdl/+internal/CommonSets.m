classdef(Hidden)CommonSets




%#codegen

    methods
        function obj=CommonSets(varargin)
            coder.allowpcode('plain');
        end
    end

    properties(Constant=true)


        AutoOrProperty=matlab.system.StringSet({'Auto','Property'});
        BitOrInt=matlab.system.StringSet({'Bit','Integer'});
        ImageType=matlab.system.StringSet({'Intensity','Binary'});
        DoubleOrSingle=matlab.system.StringSet({'double','single'});
        BooleanOrDouble=matlab.system.StringSet({'boolean','double'});
        LogicalOrDouble=matlab.system.StringSet({'logical','double'});
        DoubleLogicalSmallestUnsigned=matlab.system.StringSet({'double','logical','Smallest unsigned integer'});
        BitDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest unsigned integer',...
        'double','single','int8',...
        'uint8','int16','uint16',...
        'int32','uint32','logical'},...
        {'Internal rule'},{'Full precision'});
        IntDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest unsigned integer',...
        'double','single','int8',...
        'uint8','int16','uint16',...
        'int32','uint32'},...
        {'Internal rule'},{'Full precision'});
        SignedIntDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest integer','double',...
        'single','int8','int16','int32'},...
        {'Internal rule'},{'Full precision'});
        UnsignedIntDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest integer','Same as input',...
        'double','single','int8','uint8',...
        'int16','uint16','int32','uint32'},...
        {'Internal rule'},{'Full precision'});
        UnsignedBitDataType=matlab.system.internal.StringSetGF({'Full precision',...
        'Smallest unsigned integer',...
        'Same as input','double','single',...
        'int8','uint8','int16','uint16',...
        'int32','uint32','logical'},...
        {'Internal rule'},{'Full precision'});


        UnsignedSrcDataType=matlab.system.StringSet({'double','single','int8','uint8',...
        'int16','uint16','int32','uint32'});
        NoneOrProperty=matlab.system.StringSet({'None','Property'});
        SpecifyInputs=matlab.system.StringSet({'Property','Input port'});
        OutDataType=matlab.system.StringSet({'logical',...
        'int8','uint8','int16','uint16',...
        'int32','uint32','double'});
        SignedOutDataType=matlab.system.StringSet({...
        'int8','int16','int32','double'});
        OutDataType1=matlab.system.internal.StringSetGF({'Full precision','Same as input'...
        ,'double','single','int8','int16',...
        'int32'},...
        {'Internal rule'},{'Full precision'});
        OutDataType2=matlab.system.internal.StringSetGF({'Full precision','Same as input'...
        ,'double','int8','uint8','int16','uint16'...
        ,'int32','uint32','boolean'},...
        {'Internal rule'},{'Full precision'});


        VideoFormats=matlab.system.StringSet({'240p','480p','480pH','576p','720p',...
        '768p','1024p','1080p','1200p','2KCinema','4KUHDTV','8KUHDTV',...
        'Custom'});
    end

    methods(Static=true)
        function en=getSet(name)
            persistent instance;
            if isempty(instance)
                instance=visionhdl.internal.CommonSets;
            end

            switch name
            case 'AutoOrProperty'
                en=instance.AutoOrProperty;
            case 'BitOrInt'
                en=instance.BitOrInt;
            case 'ImageType'
                en=instance.ImageType;
            case 'DoubleOrSingle'
                en=instance.DoubleOrSingle;
            case 'BooleanOrDouble'
                en=instance.BooleanOrDouble;
            case 'LogicalOrDouble'
                en=instance.LogicalOrDouble;
            case 'DoubleLogicalSmallestUnsigned'
                en=instance.DoubleLogicalSmallestUnsigned;
            case 'BitDataType'
                en=instance.BitDataType;
            case 'IntDataType'
                en=instance.IntDataType;
            case 'SignedIntDataType'
                en=instance.SignedIntDataType;
            case 'UnsignedIntDataType'
                en=instance.UnsignedIntDataType;
            case 'UnsignedBitDataType'
                en=instance.UnsignedBitDataType;
            case 'UnsignedSrcDataType'
                en=instance.UnsignedSrcDataType;
            case 'NoneOrProperty'
                en=instance.NoneOrProperty;
            case 'SpecifyInputs'
                en=instance.SpecifyInputs;
            case 'OutDataType'
                en=instance.OutDataType;
            case 'SignedOutDataType'
                en=instance.SignedOutDataType;
            case 'OutDataType1'
                en=instance.OutDataType1;
            case 'OutDataType2'
                en=instance.OutDataType2;
            otherwise
                en=instance.VideoFormats;





            end
        end


        function[ActivePixelsPerLine,ActiveVideoLines,TotalPixelsPerLine,TotalVideoLines,StartingActiveLine,EndingActiveLine,...
            FrontPorch,BackPorch]=getVideoFormatParameters(format)
            switch format
            case '240p'
                ActivePixelsPerLine=320;
                ActiveVideoLines=240;
                TotalPixelsPerLine=402;
                TotalVideoLines=324;
                StartingActiveLine=1;
                EndingActiveLine=240;
                FrontPorch=44;
                BackPorch=38;

            case '480p'
                ActivePixelsPerLine=640;
                ActiveVideoLines=480;
                TotalPixelsPerLine=800;
                TotalVideoLines=525;
                StartingActiveLine=36;
                EndingActiveLine=515;
                FrontPorch=16;
                BackPorch=48+96;

            case '480pH'
                ActivePixelsPerLine=720;
                ActiveVideoLines=480;
                TotalPixelsPerLine=858;
                TotalVideoLines=525;
                StartingActiveLine=33;
                EndingActiveLine=512;
                FrontPorch=16;
                BackPorch=122;

            case '576p'
                ActivePixelsPerLine=720;
                ActiveVideoLines=576;
                TotalPixelsPerLine=864;
                TotalVideoLines=625;
                StartingActiveLine=47;
                EndingActiveLine=622;
                FrontPorch=12;
                BackPorch=132;

            case '720p'
                ActivePixelsPerLine=1280;
                ActiveVideoLines=720;
                TotalPixelsPerLine=1650;
                TotalVideoLines=750;
                StartingActiveLine=25;
                EndingActiveLine=744;
                FrontPorch=110;
                BackPorch=260;

            case '768p'
                ActivePixelsPerLine=1024;
                ActiveVideoLines=768;
                TotalPixelsPerLine=1344;
                TotalVideoLines=806;
                StartingActiveLine=10;
                EndingActiveLine=777;
                FrontPorch=24;
                BackPorch=160+136;

            case '1024p'
                ActivePixelsPerLine=1280;
                ActiveVideoLines=1024;
                TotalPixelsPerLine=1688;
                TotalVideoLines=1066;
                StartingActiveLine=42;
                EndingActiveLine=1065;
                FrontPorch=48;
                BackPorch=248+112;

            case '1080p'
                ActivePixelsPerLine=1920;
                ActiveVideoLines=1080;
                TotalPixelsPerLine=2200;
                TotalVideoLines=1125;
                StartingActiveLine=42;
                EndingActiveLine=1121;
                FrontPorch=44+44;
                BackPorch=44+148;

            case '1200p'
                ActivePixelsPerLine=1600;
                ActiveVideoLines=1200;
                TotalPixelsPerLine=2160;
                TotalVideoLines=1250;
                StartingActiveLine=50;
                EndingActiveLine=1249;
                FrontPorch=64;
                BackPorch=304+192;

            case '2KCinema'
                ActivePixelsPerLine=2048;
                ActiveVideoLines=1080;
                TotalPixelsPerLine=2750;
                TotalVideoLines=1125;
                StartingActiveLine=42;
                EndingActiveLine=1121;
                FrontPorch=639;
                BackPorch=44+19;

            case '4KUHDTV'
                ActivePixelsPerLine=3840;
                ActiveVideoLines=2160;
                TotalPixelsPerLine=4400;
                TotalVideoLines=2250;
                StartingActiveLine=42;
                EndingActiveLine=2201;
                FrontPorch=44+44;
                BackPorch=472;

            case '8KUHDTV'
                ActivePixelsPerLine=7680;
                ActiveVideoLines=4320;
                TotalPixelsPerLine=8800;
                TotalVideoLines=4500;
                StartingActiveLine=42;
                EndingActiveLine=4361;
                FrontPorch=44+44;
                BackPorch=1032;

            otherwise
                ActivePixelsPerLine=[];
                ActiveVideoLines=[];
                TotalPixelsPerLine=[];
                TotalVideoLines=[];
                StartingActiveLine=[];
                EndingActiveLine=[];
                FrontPorch=[];
                BackPorch=[];



            end
        end

        function gatewayIn(blk,action)
            if nargin==1
                action='init';
            end

            switch action
            case 'init'
                visionhdl.internal.CommonSets.gatewayInChangeNumberOfPorts(blk);
                visionhdl.internal.CommonSets.gatewayInUpdateCachedVideoFormatParameters(blk);
            case 'formatParameters'
                visionhdl.internal.CommonSets.gatewayInUpdateVideoFormatParameters(blk);
                visionhdl.internal.CommonSets.gatewayInVideoFormatDialogHelper(blk);
            otherwise
                visionhdl.internal.CommonSets.gatewayInVideoFormatDialogHelper(blk);





            end
        end

        function gatewayInFIL(blk,action)
            if nargin==1
                action='init';
            end

            switch action
            case 'init'
                visionhdl.internal.CommonSets.gatewayInFILChangeNumberOfPorts(blk);
                visionhdl.internal.CommonSets.gatewayInUpdateCachedVideoFormatParameters(blk);
            case 'formatParameters'
                visionhdl.internal.CommonSets.gatewayInUpdateVideoFormatParameters(blk);
            otherwise
                visionhdl.internal.CommonSets.gatewayInFILVideoFormatDialogHelper(blk);





            end
        end

        function gatewayOut(blk,action)
            if nargin==1
                action='init';
            end

            switch action
            case 'init'
                visionhdl.internal.CommonSets.gatewayOutChangeNumberOfInports(blk);
                visionhdl.internal.CommonSets.gatewayOutUpdateCachedVideoFormatParameters(blk);
            case 'formatParameters'
                visionhdl.internal.CommonSets.gatewayOutUpdateVideoFormatParameters(blk);
            otherwise
                visionhdl.internal.CommonSets.gatewayOutVideoFormatDialogHelper(blk);





            end
        end

        function gatewayOutFIL(blk,action)
            if nargin==1
                action='init';
            end

            switch action
            case 'init'
                visionhdl.internal.CommonSets.gatewayOutFILChangeNumberOfInports(blk);
                visionhdl.internal.CommonSets.gatewayOutUpdateCachedVideoFormatParameters(blk);
            case 'formatParameters'
                visionhdl.internal.CommonSets.gatewayOutUpdateVideoFormatParameters(blk);
            otherwise
                visionhdl.internal.CommonSets.gatewayOutFILVideoFormatDialogHelper(blk);





            end
        end

        function gatewayInInfoGroupUpdate(blk,format)
            [helpText_appl,helpText_avl,helpText_tppl,...
            helpText_tvl,helpText_sal,helpText_eal,helpText_fp,...
            helpText_bp]=visionhdl.internal.CommonSets.getVideoFormatHelpText(blk,format);

            if strcmpi(format,'Custom')

                infoGroup1=getDialogControl(get_param(blk,'MaskObject'),'InfoGroup1');
                infoDisplayEal=getDialogControl(infoGroup1,'InfoDisplayEal1');
                infoDisplayEal.Prompt=helpText_eal;
                infoDisplayBp=getDialogControl(infoGroup1,'InfoDisplayBp1');
                infoDisplayBp.Prompt=helpText_bp;
                infoGroup1.Visible='on';

                infoGroup=getDialogControl(get_param(blk,'MaskObject'),'InfoGroup');
                infoGroup.Visible='off';
            else

                infoGroup=getDialogControl(get_param(blk,'MaskObject'),'InfoGroup');
                infoDisplayAppl=getDialogControl(infoGroup,'InfoDisplayAppl');
                infoDisplayAppl.Prompt=helpText_appl;
                infoDisplayAvl=getDialogControl(infoGroup,'InfoDisplayAvl');
                infoDisplayAvl.Prompt=helpText_avl;
                infoDisplayTppl=getDialogControl(infoGroup,'InfoDisplayTppl');
                infoDisplayTppl.Prompt=helpText_tppl;
                infoDisplayTvl=getDialogControl(infoGroup,'InfoDisplayTvl');
                infoDisplayTvl.Prompt=helpText_tvl;
                infoDisplaySal=getDialogControl(infoGroup,'InfoDisplaySal');
                infoDisplaySal.Prompt=helpText_sal;
                infoDisplayEal=getDialogControl(infoGroup,'InfoDisplayEal');
                infoDisplayEal.Prompt=helpText_eal;
                infoDisplayFp=getDialogControl(infoGroup,'InfoDisplayFp');
                infoDisplayFp.Prompt=helpText_fp;
                infoDisplayBp=getDialogControl(infoGroup,'InfoDisplayBp');
                infoDisplayBp.Prompt=helpText_bp;
                infoGroup.Visible='on';

                infoGroup1=getDialogControl(get_param(blk,'MaskObject'),'InfoGroup1');
                infoGroup1.Visible='off';
            end
        end

        function gatewayOutSettingChecking(blk)
            TotalVideoLines=slResolve(get_param(blk,'TotalVideoLines'),blk);
            TotalPixelsPerLine=slResolve(get_param(blk,'TotalPixelsPerLine'),blk);
            ActivePixelsPerLine=slResolve(get_param(blk,'ActivePixelsPerLine'),blk);
            ActiveVideoLines=slResolve(get_param(blk,'ActiveVideoLines'),blk);
            try %#ok
                validateattributes(TotalVideoLines,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<',65536},'','TotalVideoLines');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Total video lines''','1','65535');
            end

            try %#ok
                validateattributes(TotalPixelsPerLine,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<',65536},'','TotalPixelsPerLine');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Total pixels per line''','1','65535');
            end

            try %#ok
                validateattributes(ActiveVideoLines,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<=',TotalVideoLines},'','ActiveVideoLines');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Active video lines''','1','''Total video lines''');
            end

            try %#ok
                validateattributes(ActivePixelsPerLine,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<=',TotalPixelsPerLine},'','ActivePixelsPerLine');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Active pixels per line''','1','''Total pixels per line''');
            end
        end
    end

    methods(Static,Hidden,Access=private)

        function gatewayInChangeNumberOfPorts(blk)
            VFormat=get_param(blk,'VideoFormat');
            if strcmpi(VFormat,'Custom')
                visionhdl.internal.CommonSets.gatewayInSettingChecking(blk);
                visionhdl.internal.CommonSets.gatewayInInfoGroupUpdate(blk,'Custom');
            end
        end

        function gatewayInVideoFormatDialogHelper(blk)

            me=[];
            try %#ok<EMTC>
                set_param(blk,'MaskSelfModifiable','on');
            catch me


            end

            visStr=get_param(blk,'MaskVisibilities');
            VFormat=get_param(blk,'VideoFormat');

            if strcmpi(VFormat,'Custom')
                [visStr{4:9}]=deal('on');
            else
                [visStr{4:9}]=deal('off');
            end
            set_param(blk,'MaskVisibilities',visStr);


            visionhdl.internal.CommonSets.gatewayInInfoGroupUpdate(blk,VFormat);

            dialog=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag','SubSystem.Gateway_In_HDL_Video');
            for ii=1:numel(dialog)

                dialog(ii).refresh;
            end
            if~isempty(me)
                rethrow(me);
            end
        end

        function gatewayInFILChangeNumberOfPorts(blk)

            maskStr=get_param(blk,'MaskValues');
            if strcmpi(maskStr{4},'Custom')
                visionhdl.internal.CommonSets.gatewayInSettingChecking(blk);
            end

            ExpectedNumComponentsStr=slResolve('NumComponents',blk,'expression','startUnderMask');
            CurrentNumComponentsStr=slResolve('NumComponents',[blk,'/hf2p'],'expression','startUnderMask');






            numPix=slResolve(maskStr{2},blk);



            ExpectedOutputFormatStr=get_param(blk,'OutputVectorFormat');


            if numPix>1&&ExpectedNumComponentsStr>1&&(~strcmpi(ExpectedOutputFormatStr,'Frame'))
                coder.internal.error('visionhdl:FILFrameToPixels:MultiPixelMultiComponent')
            end

            Bufblk=find_system(blk,'MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks','all','FollowLinks','on','regexp','on',...
            'Name','buf');
            if isempty(Bufblk)
                CurrentOutputFormatStr='Frame';
            else
                if strcmp(get_param([blk,'/ctrldemux'],'BlockType'),'Demux')
                    CurrentOutputFormatStr='Pixel';
                else
                    CurrentOutputFormatStr='Line';




                    if strcmpi(maskStr{4},'Custom')
                        tppl=slResolve(maskStr{7},blk);
                    else
                        [~,~,tppl,~,~,~,~,~]=...
                        visionhdl.internal.CommonSets.getVideoFormatParameters(maskStr{4});
                    end


                    set_param([blk,'/databuf'],'N',sprintf('%d',tppl/numPix));
                    set_param([blk,'/ctrlbuf'],'N',sprintf('%d',tppl/numPix));
                end

            end



            DemuxBlk=find_system(blk,'MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks','all','FollowLinks','on','regexp','on',...
            'Name','datademux');

            if~isempty(DemuxBlk)
                SubsystemPathName=[blk,'/datademux'];

                selBlk=find_system(SubsystemPathName,'MatchFilter',@Simulink.match.allVariants,...
                'LookUnderMasks','all','FollowLinks','on','regexp','on',...
                'Name','sel');
                range=['[1 ',num2str(CurrentNumComponentsStr),']'];

                if numPix>1
                    NumDimString='3';
                    IndexString='Select all,Select all,Index vector (dialog)';
                    IndicesString=[range,',',range,','];
                else
                    NumDimString='2';
                    IndexString='Select all,Index vector (dialog)';
                    IndicesString=[range,','];
                end

                if~isempty(selBlk)
                    for ii=1:CurrentNumComponentsStr

                        block_name=[SubsystemPathName,'/sel',num2str(ii)];
                        set_param(block_name,...
                        'ShowName','off',...
                        'NumberOfDimensions',NumDimString,...
                        'IndexMode','One-based',...
                        'IndexOptions',IndexString,...
                        'Indices',[IndicesString,num2str(ii)]);

                    end
                end
            end

            if(ExpectedNumComponentsStr==CurrentNumComponentsStr)&&...
                strcmp(ExpectedOutputFormatStr,CurrentOutputFormatStr)
                return
            end


            if~strcmp(ExpectedOutputFormatStr,CurrentOutputFormatStr)
                if strcmp(ExpectedOutputFormatStr,'Frame')

                    CurrLH=get_param([blk,'/hf2p'],'lineHandles');
                    delete_line(CurrLH.Outport(1));
                    delete_line(CurrLH.Outport(2));

                    if strcmp(CurrentOutputFormatStr,'Pixel')

                        delete_line(blk,'ctrldemux/1','hStartOut/1');
                        delete_line(blk,'ctrldemux/2','hEndOut/1');
                        delete_line(blk,'ctrldemux/3','vStartOut/1');
                        delete_line(blk,'ctrldemux/4','vEndOut/1');
                        delete_line(blk,'ctrldemux/5','validOut/1');
                        delete_block([blk,'/ctrldemux']);







                        add_block('simulink/Ports & Subsystems/Subsystem',...
                        [blk,'/ctrldemux'],...
                        'Position',[645,157,650,283]);
                        in_handle=get_param([blk,'/ctrldemux/In1'],'PortHandles');
                        out_handle=get_param([blk,'/ctrldemux/Out1'],'PortHandles');
                        delete_line([blk,'/ctrldemux'],in_handle.Outport,out_handle.Inport);
                        delete_block([blk,'/ctrldemux/Out1']);
                        clear in_handle out_handle;

                        visionhdl.internal.CommonSets.BuildMultiPortSel([blk,'/ctrldemux'],5,1);

                        add_line(blk,'ctrldemux/1','hStartOut/1');
                        add_line(blk,'ctrldemux/2','hEndOut/1');
                        add_line(blk,'ctrldemux/3','vStartOut/1');
                        add_line(blk,'ctrldemux/4','vEndOut/1');
                        add_line(blk,'ctrldemux/5','validOut/1');

                        CurrLH=get_param([blk,'/dataunbuf'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_block([blk,'/dataunbuf']);
                        if(CurrentNumComponentsStr)==1
                            add_line(blk,'hf2p/1','data1/1');
                        else
                            add_line(blk,'hf2p/1','datademux/1');
                        end

                        CurrLH=get_param([blk,'/ctrlunbuf'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_block([blk,'/ctrlunbuf']);
                        add_line(blk,'hf2p/2','ctrldemux/1');
                    elseif strcmp(CurrentOutputFormatStr,'Line')
                        CurrLH=get_param([blk,'/databuf'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_block([blk,'/databuf']);
                        if(CurrentNumComponentsStr)==1
                            add_line(blk,'hf2p/1','data1/1');
                        else
                            add_line(blk,'hf2p/1','datademux/1');
                        end

                        CurrLH=get_param([blk,'/ctrlbuf'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_block([blk,'/ctrlbuf']);
                        add_line(blk,'hf2p/2','ctrldemux/1');
                    else

                    end

                elseif strcmp(ExpectedOutputFormatStr,'Line')
                    if strcmp(CurrentOutputFormatStr,'Pixel')

                        delete_line(blk,'ctrldemux/1','hStartOut/1');
                        delete_line(blk,'ctrldemux/2','hEndOut/1');
                        delete_line(blk,'ctrldemux/3','vStartOut/1');
                        delete_line(blk,'ctrldemux/4','vEndOut/1');
                        delete_line(blk,'ctrldemux/5','validOut/1');
                        delete_block([blk,'/ctrldemux']);







                        add_block('simulink/Ports & Subsystems/Subsystem',...
                        [blk,'/ctrldemux'],...
                        'Position',[645,157,650,283]);
                        in_handle=get_param([blk,'/ctrldemux/In1'],'PortHandles');
                        out_handle=get_param([blk,'/ctrldemux/Out1'],'PortHandles');
                        delete_line([blk,'/ctrldemux'],in_handle.Outport,out_handle.Inport);
                        delete_block([blk,'/ctrldemux/Out1']);
                        clear in_handle out_handle;

                        visionhdl.internal.CommonSets.BuildMultiPortSel([blk,'/ctrldemux'],5,1);

                        add_line(blk,'ctrldemux/1','hStartOut/1');
                        add_line(blk,'ctrldemux/2','hEndOut/1');
                        add_line(blk,'ctrldemux/3','vStartOut/1');
                        add_line(blk,'ctrldemux/4','vEndOut/1');
                        add_line(blk,'ctrldemux/5','validOut/1');


                        CurrBK=get_param([blk,'/dataunbuf'],'handle');
                        pos=get(CurrBK,'Position');
                        delete_block(CurrBK);
                        add_block('built-in/Buffer',...
                        [blk,'/databuf'],...
                        'OutputFrames','off',...
                        'TreatMby1Signals','One channel',...
                        'Position',pos);

                        CurrBK=get_param([blk,'/ctrlunbuf'],'handle');
                        pos=get(CurrBK,'Position');
                        delete_block(CurrBK);
                        add_block('built-in/Buffer',...
                        [blk,'/ctrlbuf'],...
                        'OutputFrames','off',...
                        'TreatMby1Signals','One channel',...
                        'Position',pos);
                    elseif strcmp(CurrentOutputFormatStr,'Frame')

                        CurrBK=get_param([blk,'/hf2p'],'handle');
                        CurrLH=get_param(CurrBK,'lineHandles');
                        delete_line(CurrLH.Outport(1));
                        delete_line(CurrLH.Outport(2));


                        add_block('built-in/Buffer',...
                        [blk,'/databuf'],...
                        'OutputFrames','off',...
                        'TreatMby1Signals','One channel',...
                        'Position',[575,89,610,121]);
                        add_line(blk,'hf2p/1','databuf/1');
                        if(CurrentNumComponentsStr)==1
                            add_line(blk,'databuf/1','data1/1');
                        else
                            add_line(blk,'databuf/1','datademux/1');
                        end


                        add_block('built-in/Buffer',...
                        [blk,'/ctrlbuf'],...
                        'OutputFrames','off',...
                        'TreatMby1Signals','One channel',...
                        'Position',[575,204,610,236]);
                        add_line(blk,'hf2p/2','ctrlbuf/1');
                        add_line(blk,'ctrlbuf/1','ctrldemux/1');
                    else

                    end












                elseif strcmp(ExpectedOutputFormatStr,'Pixel')

                    pos=[645,152,650,288];
                    delete_block([blk,'/ctrldemux']);
                    add_block('simulink/Signal Routing/Demux',...
                    [blk,'/ctrldemux'],...
                    'Position',pos,...
                    'Outputs','5');


                    if strcmp(CurrentOutputFormatStr,'Line')

                        CurrBK=get_param([blk,'/databuf'],'handle');
                        pos=get(CurrBK,'Position');
                        delete_block(CurrBK);
                        add_block('built-in/Unbuffer',...
                        [blk,'/dataunbuf'],...
                        'SampleBasedProcessing','Same As Frame Based',...
                        'Position',pos);

                        CurrBK=get_param([blk,'/ctrlbuf'],'handle');
                        pos=get(CurrBK,'Position');
                        delete_block(CurrBK);
                        add_block('built-in/Unbuffer',...
                        [blk,'/ctrlunbuf'],...
                        'SampleBasedProcessing','Same As Frame Based',...
                        'Position',pos);
                    elseif strcmp(CurrentOutputFormatStr,'Frame')

                        CurrBK=get_param([blk,'/hf2p'],'handle');
                        CurrLH=get_param(CurrBK,'lineHandles');
                        delete_line(CurrLH.Outport(1));
                        delete_line(CurrLH.Outport(2));


                        add_block('built-in/Unbuffer',...
                        [blk,'/dataunbuf'],...
                        'SampleBasedProcessing','Same As Frame Based',...
                        'Position',[575,89,610,121]);
                        add_line(blk,'hf2p/1','dataunbuf/1');
                        if(CurrentNumComponentsStr)==1
                            add_line(blk,'dataunbuf/1','data1/1');
                        else
                            add_line(blk,'dataunbuf/1','datademux/1');
                        end


                        add_block('built-in/Unbuffer',...
                        [blk,'/ctrlunbuf'],...
                        'SampleBasedProcessing','Same As Frame Based',...
                        'Position',[575,204,610,236]);
                        add_line(blk,'hf2p/2','ctrlunbuf/1');
                        add_line(blk,'ctrlunbuf/1','ctrldemux/1');
                    else

                    end

                else

                end


                Demuxblk=find_system(blk,'MatchFilter',@Simulink.match.allVariants,...
                'LookUnderMasks','all','FollowLinks','on','regexp','on',...
                'Name','datademux');
                if(~isempty(Demuxblk))&&...
                    ((ExpectedNumComponentsStr)~=1)&&...
                    ((CurrentNumComponentsStr)~=1)&&...
                    (strcmp(CurrentOutputFormatStr,'Pixel')||strcmp(ExpectedOutputFormatStr,'Pixel'))
                    pos=get_param([blk,'/datademux'],'Position');
                    if strcmp(get_param([blk,'/datademux'],'BlockType'),'Demux')

                        NumOutputs=str2double(get_param([blk,'/datademux'],'Outputs'));
                        for ii=1:(CurrentNumComponentsStr)
                            delete_line(blk,['datademux/',num2str(ii)],['data',num2str(ii),'/1']);
                        end
                        delete_block([blk,'/datademux']);








                        add_block('simulink/Ports & Subsystems/Subsystem',...
                        [blk,'/datademux'],...
                        'Position',pos);
                        in_handle=get_param([blk,'/datademux/In1'],'PortHandles');
                        out_handle=get_param([blk,'/datademux/Out1'],'PortHandles');
                        delete_line([blk,'/datademux'],in_handle.Outport,out_handle.Inport);
                        delete_block([blk,'/datademux/Out1']);
                        clear in_handle out_handle;

                        visionhdl.internal.CommonSets.BuildMultiPortSel([blk,'/datademux'],NumOutputs,numPix);

                        for ii=1:(ExpectedNumComponentsStr)
                            add_line(blk,['datademux/',num2str(ii)],['data',num2str(ii),'/1']);
                        end



                    else









                        PortH=get_param([blk,'/datademux'],'PortHandles');
                        NumOutputs=numel(PortH.Outport);
                        delete_block([blk,'/datademux']);
                        add_block('simulink/Signal Routing/Demux',...
                        [blk,'/datademux'],...
                        'Position',pos,...
                        'Outputs',num2str(NumOutputs));
                    end
                end

            end

            if strcmp(ExpectedOutputFormatStr,'Line')
                maskStr=get_param(blk,'MaskValues');
                if strcmpi(maskStr{4},'Custom')
                    tppl=slResolve(maskStr{7},blk);
                else
                    [~,~,tppl,~,~,~,~,~]=...
                    visionhdl.internal.CommonSets.getVideoFormatParameters(maskStr{4});
                end
                numPix=slResolve(maskStr{2},blk);
                set_param([blk,'/databuf'],'N',sprintf('%d',tppl/numPix));
                set_param([blk,'/ctrlbuf'],'N',sprintf('%d',tppl/numPix));
            end

            if strcmp(ExpectedOutputFormatStr,'Frame')
                ToConnect='hf2p/1';
            elseif strcmp(ExpectedOutputFormatStr,'Line')
                ToConnect='databuf/1';
            else
                ToConnect='dataunbuf/1';
            end

            if(ExpectedNumComponentsStr~=CurrentNumComponentsStr)
                set_param([blk,'/hf2p'],...
                'NumComponents',sprintf('%d',ExpectedNumComponentsStr));

                if(ExpectedNumComponentsStr)==1
                    for ii=1:(CurrentNumComponentsStr)
                        CurrBK=get_param([blk,'/data',num2str(ii)],'handle');
                        CurrLH=get_param(CurrBK,'lineHandles');
                        delete_line(CurrLH.Inport);
                        delete_block(CurrBK);
                    end

                    CurrBK=get_param([blk,'/datademux'],'handle');
                    CurrLH=get_param(CurrBK,'lineHandles');
                    delete_line(CurrLH.Inport);
                    delete_block(CurrBK);

                    add_block('simulink/Sinks/Out1',...
                    [blk,'/data1'],...
                    'Position',[695,98,725,112],...
                    'Port','1');

                    add_line(blk,ToConnect,'data1/1');

                elseif(CurrentNumComponentsStr)==1
                    CurrBK=get_param([blk,'/data1'],'handle');
                    CurrLH=get_param(CurrBK,'lineHandles');
                    delete_line(CurrLH.Inport);
                    delete_block(CurrBK);

                    if strcmp(ExpectedOutputFormatStr,'Pixel')
                        add_block('simulink/Signal Routing/Demux',...
                        [blk,'/datademux'],...
                        'Position',[645,61,650,149],...
                        'Outputs',sprintf('%d',ExpectedNumComponentsStr));
                    else






                        NumOutputs=(ExpectedNumComponentsStr);












                        add_block('simulink/Ports & Subsystems/Subsystem',...
                        [blk,'/datademux'],...
                        'Position',[645,61,650,149]);
                        in_handle=get_param([blk,'/datademux/In1'],'PortHandles');
                        out_handle=get_param([blk,'/datademux/Out1'],'PortHandles');
                        delete_line([blk,'/datademux'],in_handle.Outport,out_handle.Inport);
                        delete_block([blk,'/datademux/Out1']);
                        clear in_handle out_handle;

                        visionhdl.internal.CommonSets.BuildMultiPortSel([blk,'/datademux'],NumOutputs,numPix);





                    end


                    add_line(blk,ToConnect,'datademux/1');

                    if(ExpectedNumComponentsStr)==3
                        voffset=30;
                    else
                        voffset=20;
                    end

                    for ii=1:(ExpectedNumComponentsStr)
                        add_block('simulink/Sinks/Out1',...
                        [blk,'/data',num2str(ii)],...
                        'Position',[695,68+voffset*(ii-1),725,82+voffset*(ii-1)],...
                        'Port',num2str(ii));
                        add_line(blk,['datademux/',num2str(ii)],['data',num2str(ii),'/1']);
                    end
                elseif(ExpectedNumComponentsStr)==3
                    CurrBK=get_param([blk,'/data4'],'handle');
                    CurrLH=get_param(CurrBK,'lineHandles');
                    delete_line(CurrLH.Inport);
                    delete_block(CurrBK);

                    set_param([blk,'/data3'],'Position',[695,128,725,142]);
                    set_param([blk,'/data2'],'Position',[695,98,725,112]);
                    if strcmp(ExpectedOutputFormatStr,'Pixel')
                        set_param([blk,'/datademux'],'Outputs','3');
                    else




                        for ii=1:3
                            delete_line(blk,['datademux/',num2str(ii)],['data',num2str(ii),'/1']);
                        end

                        pos=get_param([blk,'/datademux'],'position');
                        delete_block([blk,'/datademux']);

                        add_block('simulink/Ports & Subsystems/Subsystem',...
                        [blk,'/datademux'],...
                        'Position',pos);
                        in_handle=get_param([blk,'/datademux/In1'],'PortHandles');
                        out_handle=get_param([blk,'/datademux/Out1'],'PortHandles');
                        delete_line([blk,'/datademux'],in_handle.Outport,out_handle.Inport);
                        delete_block([blk,'/datademux/Out1']);
                        clear in_handle out_handle;

                        visionhdl.internal.CommonSets.BuildMultiPortSel([blk,'/datademux'],3,numPix);

                        for ii=1:3
                            add_line(blk,['datademux/',num2str(ii)],['data',num2str(ii),'/1']);
                        end



                    end
                else
                    if strcmp(ExpectedOutputFormatStr,'Pixel')
                        set_param([blk,'/datademux'],'Outputs','4');
                    else


                        for ii=1:(CurrentNumComponentsStr)
                            delete_line(blk,['datademux/',num2str(ii)],['data',num2str(ii),'/1']);
                        end

                        pos=get_param([blk,'/datademux'],'position');
                        delete_block([blk,'/datademux']);

                        add_block('simulink/Ports & Subsystems/Subsystem',...
                        [blk,'/datademux'],...
                        'Position',pos);
                        in_handle=get_param([blk,'/datademux/In1'],'PortHandles');
                        out_handle=get_param([blk,'/datademux/Out1'],'PortHandles');
                        delete_line([blk,'/datademux'],in_handle.Outport,out_handle.Inport);
                        delete_block([blk,'/datademux/Out1']);
                        clear in_handle out_handle;

                        visionhdl.internal.CommonSets.BuildMultiPortSel([blk,'/datademux'],4,numPix);

                        for ii=1:(CurrentNumComponentsStr)
                            add_line(blk,['datademux/',num2str(ii)],['data',num2str(ii),'/1']);
                        end
                    end
                    set_param([blk,'/data3'],'Position',[695,108,725,122]);
                    set_param([blk,'/data2'],'Position',[695,88,725,102]);

                    add_block('simulink/Sinks/Out1',...
                    [blk,'/data4'],...
                    'Position',[695,128,725,142],...
                    'Port','4');
                    add_line(blk,'datademux/4','data4/1');
                end
            end
        end

        function gatewayInFILVideoFormatDialogHelper(blk)
            set_param(blk,'MaskSelfModifiable','on');
            visStr=get_param(blk,'MaskVisibilities');
            maskStr=get_param(blk,'MaskValues');

            if strcmpi(maskStr{4},'Custom')
                [visStr{5:10}]=deal('on');
            else
                [visStr{5:10}]=deal('off');
            end
            set_param(blk,'MaskVisibilities',visStr);


            [helpText_appl,helpText_avl,helpText_tppl,...
            helpText_tvl,helpText_sal,helpText_eal,helpText_fp,...
            helpText_bp]=visionhdl.internal.CommonSets.getVideoFormatHelpText(blk,maskStr{4});


            infoGroup=getDialogControl(...
            get_param(blk,'MaskObject'),'InfoGroup');


            infoDisplayAppl=getDialogControl(infoGroup,'InfoDisplayAppl');
            infoDisplayAppl.Prompt=helpText_appl;
            infoDisplayAvl=getDialogControl(infoGroup,'InfoDisplayAvl');
            infoDisplayAvl.Prompt=helpText_avl;
            infoDisplayTppl=getDialogControl(infoGroup,'InfoDisplayTppl');
            infoDisplayTppl.Prompt=helpText_tppl;
            infoDisplayTvl=getDialogControl(infoGroup,'InfoDisplayTvl');
            infoDisplayTvl.Prompt=helpText_tvl;
            infoDisplaySal=getDialogControl(infoGroup,'InfoDisplaySal');
            infoDisplaySal.Prompt=helpText_sal;
            infoDisplayEal=getDialogControl(infoGroup,'InfoDisplayEal');
            infoDisplayEal.Prompt=helpText_eal;
            infoDisplayFp=getDialogControl(infoGroup,'InfoDisplayFp');
            infoDisplayFp.Prompt=helpText_fp;
            infoDisplayBp=getDialogControl(infoGroup,'InfoDisplayBp');
            infoDisplayBp.Prompt=helpText_bp;

            if strcmpi(maskStr{4},'Custom')

                infoGroup.Visible='off';
            else
                infoGroup.Visible='on';
            end

            dialog=DAStudio.ToolRoot.getOpenDialogs.find('dialogTag','SubSystem.Gateway_In_HDL_Video');
            for ii=1:numel(dialog)

                dialog(ii).refresh;
            end
        end

        function gatewayOutChangeNumberOfInports(blk)
            maskStr=get_param(blk,'MaskValues');
            NumPixels=slResolve(maskStr{2},blk);%#ok
            if strcmpi(maskStr{3},'Custom')
                TotalPixelsPerLine=slResolve(maskStr{6},blk);%#ok
                TotalVideoLines=slResolve(maskStr{7},blk);%#ok
                visionhdl.internal.CommonSets.gatewayOutSettingChecking(blk);
            else
                [~,~,TotalPixelsPerLine,TotalVideoLines,~,~,~,~]=...
                visionhdl.internal.CommonSets.getVideoFormatParameters(maskStr{3});%#ok
            end








        end

        function gatewayOutVideoFormatDialogHelper(blk)
            visStr=get_param(blk,'MaskVisibilities');
            VFormat=get_param(blk,'VideoFormat');
            NumPixels=slResolve(get_param(blk,'NumPixels'),blk);
            NumComponents=slResolve(get_param(blk,'NumComponents'),blk);

            if strcmpi(VFormat,'Custom')
                [visStr{4:7}]=deal('on');
            else
                [visStr{4:7}]=deal('off');
            end

            set_param(blk,'MaskVisibilities',visStr);


            if strcmpi(VFormat,'Custom')
                TotalPixelsPerLine=slResolve(get_param(blk,'TotalPixelsPerLine'),blk);
                TotalVideoLines=slResolve(get_param(blk,'TotalVideoLines'),blk);

            else
                [~,~,TotalPixelsPerLine,TotalVideoLines,~,~,~,~]=...
                visionhdl.internal.CommonSets.getVideoFormatParameters(VFormat);
            end

            if NumPixels==1
                set_param([gcb,'/PixelBuffer'],'LabelModeActiveChoice','Single')
                set_param([gcb,'/PixelBuffer/SinglePixel/databuf'],'N',sprintf('%d*%d',TotalPixelsPerLine,TotalVideoLines));
                set_param([gcb,'/ctrlbuf'],'N',sprintf('%d*%d',TotalPixelsPerLine,TotalVideoLines));
            else
                if NumComponents==1
                    set_param([gcb,'/PixelBuffer'],'LabelModeActiveChoice','Multi')
                    set_param([gcb,'/PixelBuffer/MultiplePixels/databuf'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                    set_param([gcb,'/ctrlbuf'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                elseif NumComponents==3
                    set_param([gcb,'/PixelBuffer'],'LabelModeActiveChoice','MultiThree')
                    set_param([gcb,'/PixelBuffer/MultiplePixelsThreeComp/databuf'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                    set_param([gcb,'/PixelBuffer/MultiplePixelsThreeComp/databuf1'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                    set_param([gcb,'/PixelBuffer/MultiplePixelsThreeComp/databuf2'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                    set_param([gcb,'/ctrlbuf'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));

                elseif NumComponents==4
                    set_param([gcb,'/PixelBuffer'],'LabelModeActiveChoice','MultiFour')
                    set_param([gcb,'/PixelBuffer/MultiplePixelsFourComp/databuf'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                    set_param([gcb,'/PixelBuffer/MultiplePixelsFourComp/databuf1'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                    set_param([gcb,'/PixelBuffer/MultiplePixelsFourComp/databuf2'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                    set_param([gcb,'/PixelBuffer/MultiplePixelsFourComp/databuf3'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));
                    set_param([gcb,'/ctrlbuf'],'N',sprintf('%d*%d',TotalPixelsPerLine/NumPixels,TotalVideoLines));

                end
            end




        end

        function gatewayOutFILChangeNumberOfInports(blk)

            ExpectedNumComponentsStr=slResolve('NumComponents',blk,'expression','startUnderMask');
            CurrentNumComponentsStr=slResolve('NumComponents',[blk,'/hp2f'],'expression','startUnderMask');

            ExpectedInputFormatStr=get_param(blk,'InputVectorFormat');
            Bufblk=find_system(blk,'MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks','all','FollowLinks','on','regexp','on',...
            'Name','buf');

            maskStr=get_param(blk,'MaskValues');
            NumPix=slResolve(maskStr{2},blk);

            if NumPix>1&&ExpectedNumComponentsStr>1&&(~strcmpi(ExpectedInputFormatStr,'Frame'))
                coder.internal.error('visionhdl:FILPixelsToFrame:MultiPixelMultiComponent')
            end


            Demuxblk=find_system(blk,'MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks','all','FollowLinks','on','regexp','on',...
            'Name','datamux');
            if~isempty(Demuxblk)&&(strcmpi(get_param(Demuxblk{1},'Blocktype'),'Concatenate'))
                if NumPix==1
                    set_param(Demuxblk{1},...
                    'ConcatenateDimension','2');
                else
                    set_param(Demuxblk{1},...
                    'ConcatenateDimension','3');
                end
            end


            if isempty(Bufblk)
                CurrentInputFormatStr='Frame';
            else
                if strcmp(get_param([blk,'/ctrlmux'],'BlockType'),'Mux')
                    CurrentInputFormatStr='Pixel';
                else



                    if strcmpi(maskStr{4},'Custom')
                        tppl=slResolve(maskStr{7},blk);
                        tvl=slResolve(maskStr{8},blk);
                    else
                        [~,~,tppl,tvl,~,~,~,~]=...
                        visionhdl.internal.CommonSets.getVideoFormatParameters(maskStr{4});
                    end

                    set_param([blk,'/databuf'],'N',sprintf('%d*%d',tppl/NumPix,tvl));
                    set_param([blk,'/ctrlbuf'],'N',sprintf('%d*%d',tppl/NumPix,tvl));

                    CurrentInputFormatStr='Line';
                end
            end


            if~strcmp(ExpectedInputFormatStr,CurrentInputFormatStr)
                if strcmp(ExpectedInputFormatStr,'Frame')

                    pos=get_param([blk,'/databuf'],'Position');
                    delete_block([blk,'/databuf']);
                    add_block('simulink/Discrete/Unit Delay',...
                    [blk,'/datadelay'],...
                    'Position',pos);

                    pos=get_param([blk,'/ctrlbuf'],'Position');
                    delete_block([blk,'/ctrlbuf']);
                    add_block('simulink/Discrete/Unit Delay',...
                    [blk,'/ctrldelay'],...
                    'Position',pos);

                    if strcmp(CurrentInputFormatStr,'Pixel')

                        pos=get_param([blk,'/ctrlmux'],'Position');
                        delete_block([blk,'/ctrlmux']);
                        add_block('simulink/Math Operations/Matrix Concatenate',...
                        [blk,'/ctrlmux'],...
                        'Position',pos,...
                        'NumInputs','5',...
                        'Mode','Multidimensional array',...
                        'ConcatenateDimension','2');


                        CurrLH=get_param([blk,'/ctrlspec'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_line(CurrLH.Inport);
                        delete_block([blk,'/ctrlspec']);
                        add_line(blk,'ctrlmux/1','ctrldelay/1');
                    end

                elseif strcmp(ExpectedInputFormatStr,'Line')
                    if strcmp(CurrentInputFormatStr,'Pixel')

                        pos=get_param([blk,'/ctrlmux'],'Position');
                        delete_block([blk,'/ctrlmux']);
                        add_block('simulink/Math Operations/Matrix Concatenate',...
                        [blk,'/ctrlmux'],...
                        'Position',pos,...
                        'NumInputs','5',...
                        'Mode','Multidimensional array',...
                        'ConcatenateDimension','2');


                        CurrLH=get_param([blk,'/ctrlspec'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_line(CurrLH.Inport);
                        delete_block([blk,'/ctrlspec']);
                        add_line(blk,'ctrlmux/1','ctrlbuf/1');
                    elseif strcmp(CurrentInputFormatStr,'Frame')

                        pos=get_param([blk,'/datadelay'],'Position');
                        delete_block([blk,'/datadelay']);
                        add_block('built-in/Buffer',...
                        [blk,'/databuf'],...
                        'OutputFrames','off',...
                        'TreatMby1Signals','One channel',...
                        'Position',pos);

                        pos=get_param([blk,'/ctrldelay'],'Position');
                        delete_block([blk,'/ctrldelay']);
                        add_block('built-in/Buffer',...
                        [blk,'/ctrlbuf'],...
                        'OutputFrames','off',...
                        'TreatMby1Signals','One channel',...
                        'Position',pos);












                    else

                    end

                elseif strcmp(ExpectedInputFormatStr,'Pixel')
                    if strcmp(CurrentInputFormatStr,'Frame')

                        pos=get_param([blk,'/datadelay'],'Position');
                        delete_block([blk,'/datadelay']);
                        add_block('built-in/Buffer',...
                        [blk,'/databuf'],...
                        'OutputFrames','off',...
                        'TreatMby1Signals','One channel',...
                        'Position',pos);

                        pos=get_param([blk,'/ctrldelay'],'Position');
                        delete_block([blk,'/ctrldelay']);
                        add_block('built-in/Buffer',...
                        [blk,'/ctrlbuf'],...
                        'OutputFrames','off',...
                        'TreatMby1Signals','One channel',...
                        'Position',pos);












                    end


                    pos=get_param([blk,'/ctrlmux'],'Position');
                    delete_block([blk,'/ctrlmux']);
                    add_block('simulink/Signal Routing/Mux',...
                    [blk,'/ctrlmux'],...
                    'Position',pos,...
                    'Inputs','5');


                    CurrLH=get_param([blk,'/ctrlmux'],'lineHandles');
                    delete_line(CurrLH.Outport);
                    add_block('simulink/Signal Attributes/Signal Specification',...
                    [blk,'/ctrlspec'],...
                    'Position',[200,273,235,297],...
                    'Dimensions','[1 5]');
                    add_line(blk,'ctrlmux/1','ctrlspec/1');
                    add_line(blk,'ctrlspec/1','ctrlbuf/1');
                else

                end





                if(~isempty(Demuxblk))&&...
                    ((ExpectedNumComponentsStr)~=1)&&...
                    ((CurrentNumComponentsStr)~=1)&&...
                    (strcmp(CurrentInputFormatStr,'Pixel')||strcmp(ExpectedInputFormatStr,'Pixel'))

                    pos=get_param([blk,'/datamux'],'Position');
                    if strcmp(get_param([blk,'/datamux'],'BlockType'),'Mux')

                        NumInputs=get_param([blk,'/datamux'],'Inputs');
                        delete_block([blk,'/datamux']);

                        if NumPix==1
                            add_block('simulink/Math Operations/Matrix Concatenate',...
                            [blk,'/datamux'],...
                            'Position',pos,...
                            'NumInputs',NumInputs,...
                            'Mode','Multidimensional array',...
                            'ConcatenateDimension','2');
                        else
                            add_block('simulink/Math Operations/Matrix Concatenate',...
                            [blk,'/datamux'],...
                            'Position',pos,...
                            'NumInputs',NumInputs,...
                            'Mode','Multidimensional array',...
                            'ConcatenateDimension','3');
                        end


                        CurrLH=get_param([blk,'/dataspec'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_line(CurrLH.Inport);
                        delete_block([blk,'/dataspec']);
                        if strcmp(ExpectedInputFormatStr,'Frame')
                            add_line(blk,'datamux/1','datadelay/1');
                        else
                            add_line(blk,'datamux/1','databuf/1');
                        end
                    else

                        NumInputs=get_param([blk,'/datamux'],'NumInputs');
                        delete_block([blk,'/datamux']);
                        add_block('simulink/Signal Routing/Mux',...
                        [blk,'/datamux'],...
                        'Position',pos,...
                        'Inputs',NumInputs);


                        CurrLH=get_param([blk,'/datamux'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        add_block('simulink/Signal Attributes/Signal Specification',...
                        [blk,'/dataspec'],...
                        'Position',[200,163,235,187],...
                        'Dimensions',['[1 ',NumInputs,']']);
                        add_line(blk,'datamux/1','dataspec/1');
                        if strcmp(ExpectedInputFormatStr,'Frame')
                            add_line(blk,'dataspec/1','datadelay/1');
                        else
                            add_line(blk,'dataspec/1','databuf/1');
                        end
                    end
                end

            end


            Bufblk=find_system(blk,'MatchFilter',@Simulink.match.allVariants,...
            'LookUnderMasks','all','FollowLinks','on','regexp','on',...
            'Name','buf');
            if~isempty(Bufblk)

                maskStr=get_param(blk,'MaskValues');
                if strcmpi(maskStr{4},'Custom')
                    tppl=slResolve(maskStr{7},blk);
                    tvl=slResolve(maskStr{8},blk);
                else
                    [~,~,tppl,tvl,~,~,~,~]=...
                    visionhdl.internal.CommonSets.getVideoFormatParameters(maskStr{4});
                end
                NumPix=slResolve(maskStr{2},blk);
                set_param([blk,'/databuf'],'N',sprintf('%d*%d',tppl/NumPix,tvl));
                set_param([blk,'/ctrlbuf'],'N',sprintf('%d*%d',tppl/NumPix,tvl));
            end


            if strcmp(ExpectedInputFormatStr,'Frame')
                ToConnect='datadelay/1';
            else
                ToConnect='databuf/1';
            end

            if(ExpectedNumComponentsStr~=CurrentNumComponentsStr)
                set_param([blk,'/hp2f'],...
                'NumComponents',sprintf('%d',ExpectedNumComponentsStr));

                if(ExpectedNumComponentsStr)==1
                    for ii=1:(CurrentNumComponentsStr)
                        CurrBK=get_param([blk,'/data',num2str(ii)],'handle');
                        CurrLH=get_param(CurrBK,'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_block(CurrBK);
                    end

                    if strcmp(get_param([blk,'/datamux'],'BlockType'),'Mux')

                        CurrLH=get_param([blk,'/dataspec'],'lineHandles');
                        delete_line(CurrLH.Outport);
                        delete_block([blk,'/dataspec']);
                    end
                    CurrLH=get_param([blk,'/datamux'],'lineHandles');
                    delete_line(CurrLH.Outport);
                    delete_block([blk,'/datamux']);

                    add_block('simulink/Sources/In1',...
                    [blk,'/data1'],...
                    'Position',[110,168,140,182],...
                    'Port','1');
                    add_line(blk,'data1/1',ToConnect);

                elseif(CurrentNumComponentsStr)==1
                    CurrBK=get_param([blk,'/data1'],'handle');
                    CurrLH=get_param(CurrBK,'lineHandles');
                    delete_line(CurrLH.Outport);
                    delete_block(CurrBK);

                    if strcmp(ExpectedInputFormatStr,'Pixel')
                        add_block('simulink/Signal Routing/Mux',...
                        [blk,'/datamux'],...
                        'Position',[170,133,175,217],...
                        'Inputs',sprintf('%d',ExpectedNumComponentsStr));

                        if(ExpectedNumComponentsStr)>1

                            add_block('simulink/Signal Attributes/Signal Specification',...
                            [blk,'/dataspec'],...
                            'Position',[200,163,235,187],...
                            'Dimensions',['[1 ',sprintf('%d',ExpectedNumComponentsStr),']']);
                            add_line(blk,'datamux/1','dataspec/1');
                            add_line(blk,'dataspec/1',ToConnect);
                        else
                            add_line(blk,'datamux/1',ToConnect);
                        end
                    else

                        if NumPix==1
                            add_block('simulink/Math Operations/Matrix Concatenate',...
                            [blk,'/datamux'],...
                            'Position',[170,133,175,217],...
                            'NumInputs',sprintf('%d',ExpectedNumComponentsStr),...
                            'Mode','Multidimensional array',...
                            'ConcatenateDimension','2');
                        else
                            add_block('simulink/Math Operations/Matrix Concatenate',...
                            [blk,'/datamux'],...
                            'Position',[170,133,175,217],...
                            'NumInputs',sprintf('%d',ExpectedNumComponentsStr),...
                            'Mode','Multidimensional array',...
                            'ConcatenateDimension','3');
                        end


                        add_line(blk,'datamux/1',ToConnect);
                    end

                    if(ExpectedNumComponentsStr)==3
                        voffset=30;
                    else
                        voffset=20;
                    end

                    for ii=1:(ExpectedNumComponentsStr)
                        add_block('simulink/Sources/In1',[blk,'/data',num2str(ii)],...
                        'Position',[110,138+voffset*(ii-1),140,152+voffset*(ii-1)],...
                        'Port',num2str(ii));
                        add_line(blk,['data',num2str(ii),'/1'],['datamux/',num2str(ii)]);
                    end
                elseif(ExpectedNumComponentsStr)==3
                    CurrBK=get_param([blk,'/data4'],'handle');
                    CurrLH=get_param(CurrBK,'lineHandles');
                    delete_line(CurrLH.Outport);
                    delete_block(CurrBK);

                    set_param([blk,'/data3'],'Position',[110,198,140,212]);
                    set_param([blk,'/data2'],'Position',[110,168,140,182]);
                    if strcmp(ExpectedInputFormatStr,'Pixel')
                        set_param([blk,'/datamux'],'Inputs','3');
                        set_param([blk,'/dataspec'],'Dimensions','[1 3]');
                    else
                        set_param([blk,'/datamux'],'NumInputs','3');
                    end
                else
                    if strcmp(ExpectedInputFormatStr,'Pixel')
                        set_param([blk,'/datamux'],'Inputs','4');
                        set_param([blk,'/dataspec'],'Dimensions','[1 4]');
                    else
                        set_param([blk,'/datamux'],'NumInputs','4');
                    end

                    set_param([blk,'/data3'],'Position',[110,178,140,192]);
                    set_param([blk,'/data2'],'Position',[110,158,140,172]);

                    add_block('simulink/Sources/In1',[blk,'/data4'],...
                    'Position',[110,198,140,212],...
                    'Port','4');
                    add_line(blk,'data4/1','datamux/4');
                end
            end

            if strcmpi(get_param(blk,'VideoFormat'),'Custom')
                visionhdl.internal.CommonSets.gatewayOutSettingChecking(blk);
            end
        end

        function gatewayOutFILVideoFormatDialogHelper(blk)
            maskStr=get_param(blk,'MaskValues');
            visStr=get_param(blk,'MaskVisibilities');
            if strcmpi(maskStr{4},'Custom')
                [visStr{5:8}]=deal('on');
            else
                [visStr{5:8}]=deal('off');
            end
            set_param(blk,'MaskVisibilities',visStr);
        end

        function gatewayInSettingChecking(blk)
            ActivePixelsPerLine=slResolve(get_param(blk,'ActivePixelsPerLine'),blk);
            ActiveVideoLines=slResolve(get_param(blk,'ActiveVideoLines'),blk);
            TotalPixelsPerLine=slResolve(get_param(blk,'TotalPixelsPerLine'),blk);
            TotalVideoLines=slResolve(get_param(blk,'TotalVideoLines'),blk);
            StartingActiveLine=slResolve(get_param(blk,'StartingActiveLine'),blk);
            FrontPorch=slResolve(get_param(blk,'FrontPorch'),blk);
            BackPorch=TotalPixelsPerLine-ActivePixelsPerLine-FrontPorch;

            try %#ok
                validateattributes(TotalVideoLines,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<',65536},'','TotalVideoLines');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Total video lines''','1','65535');
            end

            try %#ok
                validateattributes(TotalPixelsPerLine,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<',65536},'','TotalPixelsPerLine');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Total pixels per line''','1','65535');
            end

            try %#ok
                validateattributes(ActiveVideoLines,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<=',TotalVideoLines},'','ActiveVideoLines');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Active video lines''','1','''Total video lines''');
            end

            try %#ok
                validateattributes(ActivePixelsPerLine,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<=',TotalPixelsPerLine},'','ActivePixelsPerLine');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Active pixels per line''','1','''Total pixels per line''');
            end

            try %#ok
                validateattributes(StartingActiveLine,{'numeric'},...
                {'scalar','finite','integer','>=',1,'<=',TotalVideoLines-ActiveVideoLines+1},'','StartingActiveLine');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Starting active line''','1','''Total video lines''-''Active video lines''+1');
            end

            try %#ok
                validateattributes(FrontPorch,{'numeric'},...
                {'scalar','finite','integer','>=',0,'<',TotalPixelsPerLine},'','FrontPorch');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Front porch''','0','''Total pixels per line''-1');
            end

            try %#ok
                validateattributes(BackPorch,{'numeric'},...
                {'scalar','finite','integer','>=',0,'<',TotalPixelsPerLine},'','BackPorch');
            catch
                coder.internal.errorIf(true,'visionhdl:FrameToPixels:InvalidMaskSetting',...
                '''Back porch''','0','''Total pixels per line''-1');
            end
















        end

        function[helpText_appl,helpText_avl,helpText_tppl,...
            helpText_tvl,helpText_sal,helpText_eal,helpText_fp,...
            helpText_bp]=getVideoFormatHelpText(blk,format)

            [appl,avl,tppl,tvl,sal,eal,fp,bp]=visionhdl.internal.CommonSets.getVideoFormatParameters(format);
            if isempty(appl)
                [helpText_appl,helpText_avl,helpText_tppl,...
                helpText_tvl,helpText_sal,helpText_fp]=deal('');
                eal=slResolve(get_param(blk,'ActiveVideoLinesCache'),blk)+...
                slResolve(get_param(blk,'StartingActiveLineCache'),blk)-1;
                bp=slResolve(get_param(blk,'TotalPixelsPerLineCache'),blk)-...
                slResolve(get_param(blk,'ActivePixelsPerLineCache'),blk)-...
                slResolve(get_param(blk,'FrontPorchCache'),blk);
                helpText_eal=sprintf('Ending active line:\t%5d',eal);
                helpText_bp=sprintf('Back porch:\t%5d',bp);
            else
                helpText_appl=sprintf('Active pixels per line:\t%5d',appl);
                helpText_avl=sprintf('Active video lines:\t%5d',avl);
                helpText_tppl=sprintf('Total pixels per line:\t%5d',tppl);
                helpText_tvl=sprintf('Total video lines:\t%5d',tvl);
                helpText_sal=sprintf('Starting active line:\t%5d',sal);
                helpText_eal=sprintf('Ending active line:\t%5d',eal);
                helpText_fp=sprintf('Front porch:\t%5d',fp);
                helpText_bp=sprintf('Back porch:\t%5d',bp);
            end
        end

        function BuildMultiPortSel(SubsystemPathName,NumComponents,NumPixels)
            InportHandle=get_param([SubsystemPathName,'/In1'],'PortHandles');
            range=['[1 ',num2str(NumComponents),']'];

            if NumPixels>1
                NumDimString='3';
                IndexString='Select all,Select all,Index vector (dialog)';
                IndicesString=[range,',',range,','];
            else
                NumDimString='2';
                IndexString='Select all,Index vector (dialog)';
                IndicesString=[range,','];
            end


            for ii=1:NumComponents

                block_name=[SubsystemPathName,'/sel',num2str(ii)];
                add_block('simulink/Signal Routing/Selector',block_name,...
                'ShowName','off',...
                'NumberOfDimensions',NumDimString,...
                'IndexMode','One-based',...
                'IndexOptions',IndexString,...
                'Indices',[IndicesString,num2str(ii)],...
                'Position',[175,73+15*(ii-1),205,87+15*(ii-1)]);
                SelHandle=get_param(block_name,'PortHandles');


                block_name=[SubsystemPathName,'/output',num2str(ii)];
                add_block('simulink/Sinks/Out1',block_name,...
                'ShowName','off',...
                'Position',[230,73+15*(ii-1),260,87+15*(ii-1)]);
                OutportHandle=get_param(block_name,'PortHandles');


                add_line(SubsystemPathName,InportHandle.Outport,SelHandle.Inport);
                add_line(SubsystemPathName,SelHandle.Outport,OutportHandle.Inport);
            end

        end

        function gatewayInUpdateVideoFormatParameters(blk)

            VideoFormat=get_param(blk,'VideoFormat');
            if strcmpi(VideoFormat,'Custom')

                APPL=get_param(blk,'ActivePixelsPerLineCache');
                AVL=get_param(blk,'ActiveVideoLinesCache');
                TPPL=get_param(blk,'TotalPixelsPerLineCache');
                TVL=get_param(blk,'TotalVideoLinesCache');
                SAL=get_param(blk,'StartingActiveLineCache');
                FP=get_param(blk,'FrontPorchCache');
            else

                [APPL,AVL,TPPL,TVL,SAL,~,FP,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(VideoFormat);
                APPL=num2str(APPL);
                AVL=num2str(AVL);
                TPPL=num2str(TPPL);
                TVL=num2str(TVL);
                SAL=num2str(SAL);
                FP=num2str(FP);
            end

            set_param(blk,'VideoFormatCache',VideoFormat,'ActivePixelsPerLine',APPL,'ActiveVideoLines',AVL,'TotalPixelsPerLine',TPPL,'TotalVideoLines',TVL,'StartingActiveLine',SAL,'FrontPorch',FP);
        end

        function gatewayInUpdateCachedVideoFormatParameters(blk)



            VideoFormatCache=get_param(blk,'VideoFormatCache');
            if strcmpi(VideoFormatCache,'Custom')
                set_param(blk,'ActivePixelsPerLineCache',get_param(blk,'ActivePixelsPerLine'),...
                'ActiveVideoLinesCache',get_param(blk,'ActiveVideoLines'),...
                'TotalPixelsPerLineCache',get_param(blk,'TotalPixelsPerLine'),...
                'TotalVideoLinesCache',get_param(blk,'TotalVideoLines'),...
                'StartingActiveLineCache',get_param(blk,'StartingActiveLine'),...
                'FrontPorchCache',get_param(blk,'FrontPorch'));
            end
        end

        function gatewayOutUpdateVideoFormatParameters(blk)

            VideoFormat=get_param(blk,'VideoFormat');
            if strcmpi(VideoFormat,'Custom')

                APPL=get_param(blk,'ActivePixelsPerLineCache');
                AVL=get_param(blk,'ActiveVideoLinesCache');
                TPPL=get_param(blk,'TotalPixelsPerLineCache');
                TVL=get_param(blk,'TotalVideoLinesCache');
            else

                [APPL,AVL,TPPL,TVL,~,~,~,~]=visionhdl.internal.CommonSets.getVideoFormatParameters(VideoFormat);
                APPL=num2str(APPL);
                AVL=num2str(AVL);
                TPPL=num2str(TPPL);
                TVL=num2str(TVL);
            end

            set_param(blk,'VideoFormatCache',VideoFormat,'ActivePixelsPerLine',APPL,'ActiveVideoLines',AVL,'TotalPixelsPerLine',TPPL,'TotalVideoLines',TVL);
        end

        function gatewayOutUpdateCachedVideoFormatParameters(blk)



            VideoFormatCache=get_param(blk,'VideoFormatCache');
            if strcmpi(VideoFormatCache,'Custom')
                set_param(blk,'ActivePixelsPerLineCache',get_param(blk,'ActivePixelsPerLine'),...
                'ActiveVideoLinesCache',get_param(blk,'ActiveVideoLines'),...
                'TotalPixelsPerLineCache',get_param(blk,'TotalPixelsPerLine'),...
                'TotalVideoLinesCache',get_param(blk,'TotalVideoLines'));
            end
        end

    end
end
