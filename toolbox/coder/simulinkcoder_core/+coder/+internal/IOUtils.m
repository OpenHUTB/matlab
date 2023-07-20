classdef IOUtils<handle




    methods(Static,Access=public)

        function[strPorts,error_occ,error_code,exc]=GetSubsystemIOPorts(ssBlkH)
            strPorts=[];
            error_occ=0;
            error_code='';
            exc=[];



            try
                strGotoFrom=coder.internal.GotoFromChecks.checkFromBlks(ssBlkH);
            catch exc
                error_code='CheckFailed';
                error_occ=1;
                return;
            end



            try
                portH=get_param(ssBlkH,'PortHandles');
                strPorts.numOfInports=length(portH.Inport);
                strPorts.numOfOutports=length(portH.Outport);
                strPorts.numOfEnablePorts=length(portH.Enable);
                strPorts.numOfTriggerPorts=length(portH.Trigger);
                strPorts.numOfStateEnablePorts=0;
                if slfeature('ResettableSubsystem')>0
                    strPorts.numOfResetPorts=length(portH.Reset);
                else
                    strPorts.numOfResetPorts=0;
                end
                strPorts.numOfFromBlks=strGotoFrom.NumFromBlks;
                strPorts.numOfGotoBlks=strGotoFrom.NumGotoBlks;
                strPorts.numOfScopeBlks=strGotoFrom.NumScopeBlks;
                strPorts.fromBlks=strGotoFrom.fromBlks;
                strPorts.gotoBlks=strGotoFrom.gotoBlks;
                strPorts.scopeBlks=strGotoFrom.scopeBlks;
                strPorts.numOfDataStoreBlks=0;
                strPorts.dataStoreBlks=[];
            catch exc
                error_code='GetPortHandles';
                error_occ=1;
                return;
            end
        end


        function strPorts=SetStrPortsField(strPorts,fieldName,value)
            for i=1:strPorts.numOfInports
                strPorts.Inport{i}=coder.internal.BusUtils.setBusStructField(strPorts.Inport{i},fieldName,value);
            end
            for i=1:strPorts.numOfOutports
                strPorts.Outport{i}=coder.internal.BusUtils.setBusStructField(strPorts.Outport{i},fieldName,value);
            end
            for i=1:strPorts.numOfEnablePorts
                strPorts.Enable{i}=coder.internal.BusUtils.setBusStructField(strPorts.Enable{i},fieldName,value);
            end
            for i=1:strPorts.numOfTriggerPorts
                strPorts.Trigger{i}=coder.internal.BusUtils.setBusStructField(strPorts.Trigger{i},fieldName,value);
            end
            for i=1:strPorts.numOfStateEnablePorts
                strPorts.StateEnable{i}=coder.internal.BusUtils.setBusStructField(strPorts.StateEnable{i},fieldName,value);
            end
            for i=1:strPorts.numOfResetPorts
                strPorts.Reset{i}=coder.internal.BusUtils.setBusStructField(strPorts.Reset{i},fieldName,value);
            end
            for i=1:strPorts.numOfFromBlks
                strPorts.From{i}=coder.internal.BusUtils.setBusStructField(strPorts.From{i},fieldName,value);
            end
            for i=1:strPorts.numOfGotoBlks
                strPorts.Goto{i}=coder.internal.BusUtils.setBusStructField(strPorts.Goto{i},fieldName,value);
            end
        end


        function rOutPortH=LocalSetInPortNonAutoSCOrUdi(modelName,outPortH,strucBus,portNumber)
            if~strcmp(strucBus.prm.RTWStorageClass,'Auto')||~isempty(strucBus.prm.SignalObject)
                numSignals=coder.internal.IOUtils.ResetStorageClassByPrm(modelName,strucBus.prm);%#ok
                Simulink.ModelReference.Conversion.PortUtils.setOutportRTWStorageClass(outPortH,strucBus.prm);

                sigName=strucBus.name;
                rtwName=strucBus.prm.RTWSignalIdentifier;

                if~isempty(sigName)&&~strcmp(rtwName,sigName)
                    rOutPortH=coder.internal.IOUtils.InsertDummyBlk(outPortH,modelName,portNumber,strucBus);
                    set_param(rOutPortH,'Name',sigName);
                else
                    rOutPortH=outPortH;
                end
            else
                rOutPortH=outPortH;
            end
        end


        function rOutPortH=LocalSetOutPortNonAutoSCOrUdi(modelName,outPortH,strucBus,portNumber)
            if~strcmp(strucBus.prm.RTWStorageClass,'Auto')||...
                ~isempty(strucBus.prm.SignalObject)
                numSignals=coder.internal.IOUtils.ResetStorageClassByPrm(modelName,strucBus.prm);

                sigName=strucBus.name;
                rtwName=strucBus.prm.RTWSignalIdentifier;


                if(~isempty(sigName)&&~strcmp(rtwName,sigName))||(numSignals>0)
                    rOutPortH=coder.internal.IOUtils.InsertDummyBlk(outPortH,modelName,portNumber,strucBus);
                    if~strcmp(get_param(get_param(outPortH,'Parent'),'BlockType'),'BusSelector')
                        set_param(outPortH,'Name',sigName);
                    end
                else
                    rOutPortH=outPortH;
                end
                Simulink.ModelReference.Conversion.PortUtils.setOutportRTWStorageClass(rOutPortH,strucBus.prm);
            else
                rOutPortH=outPortH;
            end
        end
    end


    methods(Static,Access=private)
        function rOutPortH=InsertDummyBlk(outPortH,modelName,portNumber,strucBus)
            pos=get_param(outPortH,'Position');
            outPortPos=[pos(1)+100,pos(2)-5,pos(1)+140,pos(2)+5];
            if strucBus.type==1&&strucBus.prm.CompiledPortDimensions(1)<2
                specBlkH=add_block('built-in/Demux',...
                sprintf('%s/xxInSigSpecxx_%d',...
                modelName,portNumber),...
                'Outputs','1','Position',rtwprivate('sanitizePosition',outPortPos));
            else
                load_system('rtw_ssgen_lib');
                specBlkH=add_block('rtw_ssgen_lib/RenameSignal',...
                sprintf('%s/xxInSigSpecxx_%d',...
                modelName,portNumber),...
                'Position',rtwprivate('sanitizePosition',outPortPos));
            end


            tempSID=Simulink.ID.getSID(specBlkH);


            origSID=[modelName,':0'];




            rtwprivate('rtwattic','addToSIDMap',tempSID,origSID);

            coder.internal.slBus('LocalSetName',specBlkH,['SigSpec_',strucBus.name],'SigSpecGate');
            portH=get_param(specBlkH,'PortHandles');
            add_line(modelName,outPortH,portH.Inport);
            rOutPortH=portH.Outport;
        end


        function numSignals=ResetStorageClassByPrm(modelName,prm)


            sigH=find_system(modelName,'FindAll','on',...
            'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
            'LookUnderMasks','on','Type','port','Name',prm.RTWSignalIdentifier);
            numSignals=length(sigH);

            for i=1:length(sigH)


                set_param(sigH(i),'RTWStorageTypeQualifier','');
                set_param(sigH(i),'RTWStorageClass','Auto');
                set_param(sigH(i),'MustResolveToSignalObject','off')
                set_param(sigH(i),'SignalObject',[])
            end
        end
    end
end
