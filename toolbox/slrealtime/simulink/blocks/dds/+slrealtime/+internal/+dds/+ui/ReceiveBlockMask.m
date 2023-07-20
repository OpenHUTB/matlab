classdef ReceiveBlockMask<slrealtime.internal.dds.ui.CommonMessageMask






    properties(Constant)
        MaskType='DDS Receive'
        SysObjBlockName='ReceiveBlock';
    end

    methods

        function updateSubsystem(obj,block)
            sysobj_block=[block,'/',obj.SysObjBlockName];

            set_param(block,'datadict',get_param(bdroot(block),'DataDictionary'));

            if isempty(get_param(bdroot(block),'DataDictionary'))





                outport_block=[block,'/','BusInit/Out1'];
                set_param(outport_block,'OutDataTypeStr','double');
                return;
            end

            topic=get_param(block,'topic');
            topicInSysObj=get_param(sysobj_block,'DDSTopic');
            readerPathInSysObj=get_param(sysobj_block,'DataReaderPath');
            sampleTimeInSysObj=get_param(sysobj_block,'SampleTime');



            if~isempty(topic)
                if~strcmp(topic,topicInSysObj)
                    set_param(sysobj_block,'DDSTopic',topic);
                end
            end
            readerPath=get_param(block,'xmlPath');
            if~isempty(readerPath)



                if~strcmp(readerPath,'Auto')
                    if~strcmp(readerPath,readerPathInSysObj)
                        [participantLibrary,participant,sub,reader]=slrealtime.internal.dds.utils.getDDSMapping(...
                        readerPath);
                        set_param(sysobj_block,'DataReaderPath',readerPath);
                        set_param(sysobj_block,'ParticipantName',[participantLibrary,'_',participant]);
                        set_param(sysobj_block,'SubscriberName',[sub,'_',reader]);
                    end
                end
            end

            if~strcmp(get_param(block,'sampleTime'),sampleTimeInSysObj)
                set_param(sysobj_block,'SampleTime',get_param(block,'sampleTime'));
            end

            typeName=slrealtime.internal.dds.utils.getTypeNameFromTopic(bdroot(block),topic);
            if~isempty(typeName)
                set_param(sysobj_block,'DDSType',typeName);
                outport_block=[block,'/','BusInit/Out1'];
                set_param(outport_block,'OutDataTypeStr',['Bus: ',typeName]);
            end

        end

        function topicEdit(obj,block)
            obj.updateSubsystem(block);
        end

        function maskInitialize(~,block)
            blkH=get_param(block,'handle');
            maskDisplayText=sprintf('port_label(''output'', 1, ''DDS Msg'');');
            set_param(blkH,'MaskDisplay',maskDisplayText);
            set_param(blkH,'datadict',get_param(bdroot(block),'DataDictionary'));
        end

        function updateDDSDefinitions(obj,block)

            original_status=get_param(bdroot(block),'Dirty');

            function cleanup()
                set_param(bdroot(block),'Dirty',original_status);
            end

            sysobj_block=[block,'/',obj.SysObjBlockName];
            topic=get_param(block,'topic');
            readerPathInSysObj=get_param(sysobj_block,'DataReaderPath');
            try
                readerPath=get_param(block,'xmlPath');
                if~isempty(readerPath)
                    if strcmp(readerPath,'Auto')
                        qos=get_param(block,'qos');
                        if strcmp(qos,'Default')
                            qos='';
                        end
                        readerPath=slrealtime.internal.dds.simulink.createReaderWriter(bdroot(block),block,topic,qos,true,'','','');
                    end
                    if~strcmp(readerPath,readerPathInSysObj)
                        [participantLibrary,participant,sub,reader]=slrealtime.internal.dds.utils.getDDSMapping(...
                        readerPath);
                        set_param(sysobj_block,'DataReaderPath',readerPath);
                        set_param(sysobj_block,'ParticipantName',[participantLibrary,'_',participant]);
                        set_param(sysobj_block,'SubscriberName',[sub,'_',reader]);
                    end
                end
            catch Me

            end
            cleanup();
        end
    end

    methods(Static)

        function dispatch(methodName,varargin)
            obj=slrealtime.internal.dds.ui.ReceiveBlockMask();
            obj.(methodName)(varargin{:});
        end

    end
end
