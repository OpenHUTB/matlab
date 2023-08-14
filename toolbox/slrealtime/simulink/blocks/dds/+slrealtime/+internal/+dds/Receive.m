classdef Receive<matlab.System








%#codegen


    properties

    end


    properties(Nontunable)
        DDSTopic='';
        ParticipantName='';
        SubscriberName='';
        DataReaderPath='';
        DDSType='double';
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

        function obj=Receive(varargin)
            coder.allowpcode('plain');

            setProperties(obj,nargin,varargin{:})
        end
    end

    methods(Access=protected)
        function interface=getInterfaceImpl(obj)





            import matlab.system.interface.*;%#ok<EMIMP>
            coder.extrinsic('slrealtime.internal.dds.utils.BlockProperties.set');

            interface=Output("out1",Message);

            if coder.target('MATLAB')

                data=struct('TopicName',obj.DDSTopic,'ParticipantName',obj.ParticipantName,...
                'DDSType',obj.DDSType,'DataReaderPath',obj.DataReaderPath);
                slrealtime.internal.dds.utils.BlockProperties.set(bdroot(gcs),gcbh,'recv',data);
            end
        end


        function setupImpl(obj,busstruct)



            if coder.target('MATLAB')

            elseif coder.target('RtwForRapid')



                coder.internal.errorIf(true,'slrealtime:dds:rapidAccelNotSupported','DDS Receive');

            elseif coder.target('Rtw')

                obj.ddsStructPtr=uint64(0);
                coder.cinclude("slrealtime_fastdds_adapter.h");
                zeroDeliminatedParticipantName=[obj.ParticipantName,0];
                zeroDeliminatedSubscriberName=[obj.SubscriberName,0];

                obj.ddsStructPtr=coder.ceval('slrealtime_dds_init_sub',zeroDeliminatedParticipantName,...
                zeroDeliminatedSubscriberName);
            elseif coder.target('Sfun')





            else


                coder.internal.errorIf(true,'slrealtime:dds:unsupportedCodegenMode',coder.target);
            end
        end

        function outData=stepImpl(obj,busstruct)

            msg=coder.nullcopy(busstruct);
            if coder.target('MATLAB')

                outData=msg;

            elseif coder.target('Rtw')
                outData=[];
                isNewData=true;
                if coder.target('rtw')


                    while isNewData
                        isNewData=coder.ceval('slrealtime_dds_receive',obj.ddsStructPtr,coder.ref(msg));
                        if isNewData
                            outData=[outData,msg];%#ok<AGROW>
                        end
                    end
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

        function s=infoImpl(obj)

            s=struct([]);
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


            num=1;
        end

        function icon=getIconImpl(obj)

            icon=["Simulink Real-Time","DDS Receive"];
        end

        function varargout=getOutputSizeImpl(obj)

            varargout{1}=[1,1];
        end

        function varargout=getOutputDataTypeImpl(obj)

            varargout{1}=['Bus: ',obj.DDSType];
        end

        function varargout=isOutputComplexImpl(obj)

            varargout{1}=false;
        end

        function varargout=isOutputFixedSizeImpl(obj)

            varargout{1}=true;
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
            'Title','DDS Receive',...
            'Text','Receive DDS data from DDS Network.');
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
