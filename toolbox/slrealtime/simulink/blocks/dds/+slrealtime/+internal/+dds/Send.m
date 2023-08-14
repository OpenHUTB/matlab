classdef Send<matlab.System








%#codegen


    properties

    end


    properties(Nontunable)
        DDSTopic='';
        ParticipantName=''
        PublisherName=''
        DataWriterPath=''
        DDSType='double'
        SampleTime=-1;
    end
    properties(Hidden)
    end
    properties(DiscreteState)

    end


    properties(Access=private)
        ddsStructPtr=uint64(0);
    end

    methods

        function obj=Send(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)
        function interface=getInterfaceImpl(obj)

            import matlab.system.interface.*;%#ok<EMIMP>
            coder.extrinsic('slrealtime.internal.dds.utils.BlockProperties.set');

            interface=Input("in1",Message);


            data=struct('TopicName',obj.DDSTopic,'ParticipantName',obj.ParticipantName,...
            'DDSType',obj.DDSType,'DataWriterPath',obj.DataWriterPath);
            slrealtime.internal.dds.utils.BlockProperties.set(bdroot(gcs),gcbh,'send',data);
        end


        function setupImpl(obj)




            if coder.target('MATLAB')

            elseif coder.target('RtwForRapid')



                coder.internal.errorIf(true,'slrealtime:dds:rapidAccelNotSupported','DDS Send');

            elseif coder.target('Rtw')

                obj.ddsStructPtr=uint64(0);
                coder.cinclude("slrealtime_fastdds_adapter.h");
                zeroDeliminatedParticipantName=[obj.ParticipantName,0];
                zeroDeliminatedPublisherName=[obj.PublisherName,0];

                obj.ddsStructPtr=coder.ceval('slrealtime_dds_init_pub',zeroDeliminatedParticipantName,...
                zeroDeliminatedPublisherName);

            elseif coder.target('Sfun')





            else


                coder.internal.errorIf(true,'slrealtime:dds:unsupportedCodegenMode',coder.target);
            end
        end

        function stepImpl(obj,msg)


            if coder.target('MATLAB')


            elseif coder.target('Rtw')

                nMsg=numel(msg);
                for iMsg=1:nMsg

                    coder.ceval('(void) slrealtime_dds_send',obj.ddsStructPtr,coder.rref(msg(iMsg)));
                end

            end
        end

        function resetImpl(obj)


        end

        function releaseImpl(obj)

            if coder.target('Rtw')
                coder.ceval("slrealtime_dds_terminate");
            end
        end

        function validatePropertiesImpl(obj)

            coder.extrinsic('slrealtime.internal.dds.utils.validateDDSModel');
            if coder.target('MATLAB')
                slrealtime.internal.dds.utils.validateDDSModel(gcbh);
            end

        end


        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);

        end

        function loadObjectImpl(obj,s,wasLocked)



            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end



        function flag=isInputSizeMutableImpl(obj,index)


            flag=false;
        end

        function num=getNumInputsImpl(obj)

            num=1;
        end

        function num=getNumOutputsImpl(obj)


            num=0;
        end

        function icon=getIconImpl(obj)

            icon=["Simulink Real-Time","DDS Send"];

        end

        function name=getInputNamesImpl(obj)

            name='';
        end

        function sts=getSampleTimeImpl(obj)

            switch obj.SampleTime
            case-1
                sts=createSampleTime(obj,'Type','Inherited','ErrorOnPropagation','Controllable');
            otherwise
                sts=createSampleTime(obj,'Type','Discrete',...
                'SampleTime',obj.SampleTime);
            end
        end

    end

    methods(Static,Access=protected)

        function header=getHeaderImpl

            header=matlab.system.display.Header(mfilename("class"),...
            'ShowSourceLink',false,...
            'Title','DDS Send',...
            'Text','Send DDS data to DDS Network.');
        end

        function group=getPropertyGroupsImpl

            group=matlab.system.display.Section(mfilename("class"));
        end

        function simMode=getSimulateUsingImpl


            simMode="Interpreted execution";
        end

        function flag=showSimulateUsingImpl

            flag=false;
        end
    end
end
