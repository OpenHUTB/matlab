classdef SendBlockMask<slrealtime.internal.dds.ui.CommonMessageMask






    properties(Constant)


        MaskType='DDS Send'

        SysObjBlockName='SendBlock';
    end

    methods

        function updateSubsystem(obj,block)
            sysobj_block=[block,'/',obj.SysObjBlockName];

            set_param(block,'datadict',get_param(bdroot(block),'DataDictionary'));

            if isempty(get_param(bdroot(block),'DataDictionary'))
                return;
            end

            topic=get_param(block,'topic');
            topicInSysObj=get_param(sysobj_block,'DDSTopic');
            writerPathInSysObj=get_param(sysobj_block,'DataWriterPath');
            sampleTimeInSysObj=get_param(sysobj_block,'SampleTime');

            if~isempty(topic)
                if~strcmp(topic,topicInSysObj)
                    set_param(sysobj_block,'DDSTopic',topic);
                end
            end

            writerPath=get_param(block,'xmlPath');
            if~isempty(writerPath)



                if~strcmp(writerPath,'Auto')

                    if~strcmp(writerPath,writerPathInSysObj)
                        [participantLibrary,participant,pub,writer]=slrealtime.internal.dds.utils.getDDSMapping(...
                        writerPath);
                        set_param(sysobj_block,'DataWriterPath',writerPath);
                        set_param(sysobj_block,'ParticipantName',[participantLibrary,'_',participant]);
                        set_param(sysobj_block,'PublisherName',[pub,'_',writer]);
                    end
                end
            end

            if~strcmp(get_param(block,'sampleTime'),sampleTimeInSysObj)
                set_param(sysobj_block,'SampleTime',get_param(block,'sampleTime'));
            end

            typeName=slrealtime.internal.dds.utils.getTypeNameFromTopic(bdroot(block),topic);
            if~isempty(typeName)
                set_param(sysobj_block,'DDSType',typeName);
                inport_block=[block,'/','Inport'];
                set_param(inport_block,'OutDataTypeStr',['Bus: ',typeName]);
            end

        end

        function topicEdit(obj,block)

            obj.updateSubsystem(block);
        end

        function maskInitialize(~,block)
            blkH=get_param(block,'handle');
            maskDisplayText=sprintf('port_label(''input'', 1, ''DDS Msg'');');
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
            writerPathInSysObj=get_param(sysobj_block,'DataWriterPath');
            try
                writerPath=get_param(block,'xmlPath');
                if~isempty(writerPath)
                    if strcmp(writerPath,'Auto')
                        qos=get_param(block,'qos');
                        if strcmp(qos,'Default')
                            qos='';
                        end
                        writerPath=slrealtime.internal.dds.simulink.createReaderWriter(bdroot(block),block,topic,qos,false,'','','');
                    end
                    if~strcmp(writerPath,writerPathInSysObj)
                        [participantLibrary,participant,pub,writer]=slrealtime.internal.dds.utils.getDDSMapping(...
                        writerPath);
                        set_param(sysobj_block,'DataWriterPath',writerPath);
                        set_param(sysobj_block,'ParticipantName',[participantLibrary,'_',participant]);
                        set_param(sysobj_block,'PublisherName',[pub,'_',writer]);
                    end
                end
            catch Me

            end
            cleanup();
        end
    end

    methods(Static)

        function dispatch(methodName,varargin)
            obj=slrealtime.internal.dds.ui.SendBlockMask();
            obj.(methodName)(varargin{:});
        end

    end
end
