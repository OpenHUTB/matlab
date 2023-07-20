classdef(Sealed,Hidden)VMUtils






    methods(Static,Hidden)

        function paramVals=i_getParamArgumentValuesStruct(variant,modelChoice)
            paramVals=struct();

            names=get_param(modelChoice,'ParameterArgumentNames');
            vals=variant.ParameterArgumentValues;

            nameList=strsplit(names,',');
            valList=slInternal('parseParameterArgumentValuesString',vals);

            numNames=length(nameList);
            numVals=length(valList);
            numToSet=min(numNames,numVals);

            for i=1:numToSet
                name=nameList{i};
                val=valList{i};

                if~isempty(name)
                    paramVals.(name)=val;
                end
            end
        end






        function err=getMsgStrWithCauses(ex)
            err=ex.message;
            causes=ex.cause;
            causeMsg='';
            if~isempty(causes)
                causeMsg=causes{1}.message;
            end
            for ii=2:numel(causes)
                if isa(causes{ii},'MException')
                    causeMsg=sprintf('%s\n%s',causeMsg,causes{ii}.message);
                end
            end
            if~isempty(causeMsg)
                errmsgConcatObj=message('Simulink:Variants:CausedBy');
                err=sprintf('%s\n%s\n%s',err,errmsgConcatObj.getString(),causeMsg);
            end
        end

        function val=hasControlPorts(block)









            ports=get_param(block,'Ports');

            val=any(logical([ports(3:5),ports(8:9)]));

        end

        function isPhysmod=isPhysmodBlock(block)







            ports=get_param(block,'Ports');


            isPhysmod=any(logical(ports(6:7)));

        end

        function[iNames,oNames,cNamesAndTypes]=getSubsystemPortNames(blockH)





            pH=get_param(blockH,'PortHandles');
            iPH=pH.Inport;
            cPH=[pH.Enable,pH.Trigger,...
            pH.Ifaction,pH.Reset];
            cPHType={};
            if~isempty(pH.Enable)
                cPHType{end+1}='Enable';
            end
            if~isempty(pH.Trigger)
                cPHType{end+1}='Trigger';
            end
            if~isempty(pH.Ifaction)
                cPHType{end+1}='Ifaction';
            end
            if~isempty(pH.Reset)
                cPHType{end+1}='Reset';
            end
            oPH=[pH.Outport,pH.State,pH.LConn,pH.RConn];

            iNames=cell(1,length(iPH));
            cNamesAndTypes.Names=cell(1,length(cPH));
            cNamesAndTypes.Types=cell(1,length(cPH));
            cNamesAndTypes.Subtypes=cell(1,length(cPH));
            oNames=cell(1,length(oPH));

            choicePortToPortBlkMap=Simulink.internal.vmgr.VMUtils.portToPortBlock(blockH);

            for i=1:length(iPH)
                iNames{i}=Simulink.internal.vmgr.VMUtils.getPortBlockName(choicePortToPortBlkMap(iPH(i)));
            end

            for i=1:length(cPH)
                cNamesAndTypes.Names{i}=Simulink.internal.vmgr.VMUtils.getPortBlockName(choicePortToPortBlkMap(cPH(i)));
                cNamesAndTypes.Types{i}=cPHType{i};
                if strcmp(cPHType{i},'Trigger')
                    cNamesAndTypes.Subtypes{i}=...
                    get_param(choicePortToPortBlkMap(cPH(i)),'TriggerType');
                end
            end

            for i=1:length(oPH)
                oNames{i}=Simulink.internal.vmgr.VMUtils.getPortBlockName(choicePortToPortBlkMap(oPH(i)));
            end
        end



        function blks=findNonChoiceBlocksInCurrentGraph(parentH,blockType,varargin)
            blks=find_system(parentH,'SearchDepth',1,...
            'FollowLinks','On','LookUnderMasks','all',...
            'MatchFilter',@Simulink.match.allVariants,...
            varargin{:},...
            'BlockType',blockType);
        end

        function blkH=portBlockOf(portH,connSide,connPNum)

            parentH=get_param(get_param(portH,'Parent'),'Handle');
            pTypeKeys={'inport','outport','enable','trigger','state','ifaction','Reset','connection'};
            pBlkTypes={'Inport','Outport','EnablePort','TriggerPort','StatePort','ActionPort','ResetPort','PMIOPort'};
            pMap=containers.Map(pTypeKeys,pBlkTypes);
            pType=get_param(portH,'PortType');
            switch pType
            case{'inport','outport'}
                pNum=get_param(portH,'PortNumber');
                blkH=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(parentH,pMap(pType),'Port',num2str(pNum));


                if numel(blkH)>1
                    blkH=blkH(1);
                end


            case{'enable','trigger','state','ifaction','Reset'}
                blkH=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(parentH,pMap(pType));
            case 'connection'
                Simulink.variant.utils.assert(nargin==3);

                blksH=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(parentH,pMap(pType),'Side',connSide);
                portNums=get(blksH,'Port');

                if ischar(portNums)

                    portNums={portNums};
                end
                [~,sIdx]=sort(portNums);
                blksH=blksH(sIdx);
                blkH=blksH(connPNum);
            otherwise
                blkH=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(parentH,pMap(connPNum));
            end
        end

        function ReDrawLines(vssHandle,blockH,connectivityCacheBef,connectivityCacheAfter)


            vssPortToPortBlkMap=...
            Simulink.internal.vmgr.VMUtils.portToPortBlock(vssHandle);
            if vssPortToPortBlkMap.Count~=0
                vssPortBlkToPortMap=...
                containers.Map(values(vssPortToPortBlkMap),keys(vssPortToPortBlkMap));
            else
                vssPortBlkToPortMap=containers.Map();
            end


            lines=[];
            lCnt=1;
            pH=get_param(blockH,'PortHandles');
            iPH=[pH.Inport,pH.Enable,pH.Trigger,...
            pH.Ifaction,pH.Reset];
            for i=1:length(iPH)
                srcInfo=connectivityCacheBef(iPH(i));
                src=srcInfo.SrcPort;
                if src~=-1
                    lines(lCnt).start=src;%#ok<AGROW>
                    lines(lCnt).end=vssPortBlkToPortMap(connectivityCacheAfter(iPH(i)).SrcBlock);%#ok<AGROW>
                    lCnt=lCnt+1;
                end
            end



            pFlatList=[pH.Inport,pH.Outport,...
            pH.Enable,pH.Trigger,...
            pH.State,pH.LConn,...
            pH.RConn,pH.Ifaction,...
            pH.Reset];
            oPH=[pH.Outport,pH.State,pH.LConn,pH.RConn];
            for i=1:length(oPH)
                dstInfo=connectivityCacheBef(oPH(i));
                dsts=dstInfo.DstPort;
                src=vssPortBlkToPortMap(connectivityCacheAfter(oPH(i)).DstBlock(1));
                for j=1:length(dsts)
                    if dsts(j)~=-1
                        lines(lCnt).start=src;%#ok<AGROW>
                        dst=pFlatList(pFlatList==dsts(j));
                        if~isempty(dst)
                            dstInfo=connectivityCacheAfter(dst);



                            if isempty(dstInfo.SrcBlock)
                                dst=vssPortBlkToPortMap(dstInfo.DstBlock);
                            else
                                dst=vssPortBlkToPortMap(dstInfo.SrcBlock);
                            end
                        else
                            dst=dsts(j);
                        end
                        lines(lCnt).end=dst;%#ok<AGROW>
                        lCnt=lCnt+1;
                    end
                end
            end

            Simulink.internal.vmgr.VMUtils.redrawDataLines(get_param(vssHandle,'parent'),lines);
        end

        function DeleteConnectedLines(blockH)

            linesH_orig=get_param(blockH,'PortHandles');
            todelete=[linesH_orig.Inport,linesH_orig.Outport,...
            linesH_orig.Enable,linesH_orig.Trigger,...
            linesH_orig.State,linesH_orig.LConn,...
            linesH_orig.RConn,linesH_orig.Ifaction,...
            linesH_orig.Reset];
            for i1=1:numel(todelete)




                try

                    delete_line(get_param(todelete(i1),'Line'));
                catch

                end

            end
        end

































        function connMap=GetConnectionMapping(blkH)
            pH=get_param(blkH,'PortHandles');
            pFlatH=[pH.Inport,pH.Enable,pH.Trigger,...
            pH.Ifaction,pH.Reset,...
            pH.Outport,pH.State,pH.LConn,...
            pH.RConn];
            pC=get_param(blkH,'PortConnectivity');
            connMap=containers.Map('KeyType','double','ValueType','any');
            if~isempty(pFlatH)
                for i=1:length(pFlatH)


                    if~isempty(pC(i).SrcBlock)&&pC(i).SrcBlock~=-1
                        srcBlkPH=get_param(pC(i).SrcBlock,'PortHandles');

                        if pC(i).SrcPort>=length(srcBlkPH.Outport)
                            Simulink.variant.utils.assert(length(srcBlkPH.State)==1);
                            pC(i).SrcPort=srcBlkPH.State(1);
                        else





                            portNum=pC(i).SrcPort+1;
                            pC(i).SrcPort=srcBlkPH.Outport(portNum);
                        end
                    end

                    if~isempty(pC(i).DstBlock)
                        for j=1:length(pC(i).DstBlock)


                            if pC(i).DstPort(j)==0||~ishandle(pC(i).DstPort(j))
                                dstBlkH=pC(i).DstBlock(j);
                                dstBlkPH=get_param(dstBlkH,'PortHandles');
                                dstBlkFlatPH=[dstBlkPH.Inport,dstBlkPH.Enable,...
                                dstBlkPH.Trigger,dstBlkPH.Ifaction,...
                                dstBlkPH.Reset];


                                dstPortNum=pC(i).DstPort(j)+1;
                                pC(i).DstPort(j)=dstBlkFlatPH(dstPortNum);
                            end
                        end
                    end
                    connMap(pFlatH(i))=pC(i);
                end

            end
        end

        function mapOfPortToBlock=portToPortBlock(subsysH)
            pHs=get_param(subsysH,'PortHandles');
            pKeys=[pHs.Inport,pHs.Outport,pHs.Enable,pHs.Trigger,pHs.State,pHs.Ifaction,pHs.Reset];
            pValues=[];
            if(numel(pKeys)>0)
                pValues(numel(pKeys))=-1;
                for i=1:numel(pKeys)
                    pValues(i)=Simulink.internal.vmgr.VMUtils.portBlockOf(pKeys(i));
                end
            end

            nTotalPorts=numel(pKeys);
            for i=1:numel(pHs.LConn)
                pKeys(nTotalPorts+i)=pHs.LConn(i);
                pValues(nTotalPorts+i)=Simulink.internal.vmgr.VMUtils.portBlockOf(pKeys(nTotalPorts+i),'Left',i);%#ok<AGROW>
            end
            nTotalPorts=numel(pKeys);
            for i=1:numel(pHs.RConn)
                pKeys(nTotalPorts+i)=pHs.RConn(i);
                pValues(nTotalPorts+i)=Simulink.internal.vmgr.VMUtils.portBlockOf(pKeys(nTotalPorts+i),'Right',i);%#ok<AGROW>
            end
            if~isempty(pKeys)
                mapOfPortToBlock=containers.Map(pKeys,pValues);
            else
                mapOfPortToBlock=containers.Map();
            end
        end

        function portNames=getPortNames(blockH,type)




            portBlks=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(blockH,type);
            nPortBlks=numel(portBlks);

            portNames={};

            for i=1:nPortBlks
                portNum=str2double(get_param(portBlks(i),'Port'));
                if~strcmp(type,'PMIOPort')


                    portName=get_param(portBlks(i),'PortName');
                else

                    portName=get_param(portBlks(i),'Name');
                end
                portNames{portNum}=portName;%#ok<AGROW>
            end
        end

        function err=errorIfRefModelNotFound(mdlBlkH)





            variants=get_param(mdlBlkH,'Variants');
            choiceBlks={variants.ModelName};
            errArray={};
            err='';




            for i=1:numel(choiceBlks)
                if isempty(Simulink.variant.utils.resolveBDFile(choiceBlks{i}))
                    errid='Simulink:Variants:ConvertToVariantForModelBlockWithNoReferredModelNotSupported';
                    errArray{end+1}=MException(message(errid,choiceBlks{i},get_param(mdlBlkH,'Name')));%#ok<AGROW>
                end
            end



            if numel(errArray)>1
                err=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
                err=Simulink.variant.utils.addValidationCausesToDiagnostic(err,errArray);
            elseif~isempty(errArray)
                err=errArray{:};
            end
        end

        function errorIfRefModelHasControlPorts(mdlBlkH)




            variants=get_param(mdlBlkH,'Variants');
            choiceBlks={variants.ModelName};




            for i=1:numel(choiceBlks)

                modelFile=Simulink.variant.utils.resolveBDFile(choiceBlks{i});
                [~,name,~]=fileparts(modelFile);
                slInternal('CheckIfMdlVariantHasControlPorts',name,mdlBlkH);
            end
        end

        function err=errorIfRefModelHasIRTPorts(mdlBlkH,miMap)




            variants=get_param(mdlBlkH,'Variants');
            choiceBlks={variants.ModelName};
            errArray={};
            err='';




            for i=1:numel(choiceBlks)

                mi=Simulink.internal.vmgr.VMUtils.getModelInterface(choiceBlks{i},miMap);



                if~isempty(mi.ResetEvents)||...
                    mi.HasInitializeEvent||...
                    mi.HasTerminateEvent
                    errid='Simulink:Variants:ReferredModelHasIRTPorts';
                    errArray{end+1}=MException(message(errid,choiceBlks{i},get_param(mdlBlkH,'Name')));%#ok<AGROW>
                end
            end



            if numel(errArray)>1
                err=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
                err=Simulink.variant.utils.addValidationCausesToDiagnostic(err,errArray);
            elseif~isempty(errArray)
                err=errArray{:};
            end
        end

        function errorIfRefModelHasOldModels(mdlBlkH,miMap)


            variants=get_param(mdlBlkH,'Variants');
            if isempty(variants)




                return;
            end
            choiceBlks={variants.ModelName};


            for i=1:numel(choiceBlks)

                mi=Simulink.internal.vmgr.VMUtils.getModelInterface(choiceBlks{i},miMap);
                if isempty(mi)
                    DAStudio.error('Simulink:Variants:ConvertToVariantwithOldModelDef',getfullname(mdlBlkH));
                end
            end
        end

        function[iBlock,oBlock]=getBlocksWithMostIO(vss,miMap)







            variants=get_param(vss,'Variants');
            choiceBlks={variants.BlockName};
            iMax=1;
            oMax=1;
            [icNames,ocNames,ictNamesAndTypes]=...
            Simulink.internal.vmgr.VMUtils.getPortNamesOfSubsysOrMdlRef(...
            get_param(choiceBlks{1},'Handle'),miMap);
            icNames=[icNames,ictNamesAndTypes.Names];
            iNum=numel(icNames);
            oNum=numel(ocNames);
            for i=2:numel(choiceBlks)
                [iNames,oNames,cNamesAndTypes]=...
                Simulink.internal.vmgr.VMUtils.getPortNamesOfSubsysOrMdlRef(...
                get_param(choiceBlks{i},'Handle'),miMap);
                iNames=[iNames,cNamesAndTypes.Names];
                if(iNum<numel(iNames))
                    iMax=i;
                    iNum=numel(iNames);
                end

                if oNum<numel(oNames)
                    oMax=i;
                    oNum=numel(oNames);
                end
            end

            iBlock=choiceBlks{iMax};
            oBlock=choiceBlks{oMax};
        end



        function[inPortNames,outPortNames]=getPortNamesFromSimulink(blockHandle)



            phan=get_param(blockHandle,'PortHandles');
            inPortNames=cell(1,length(phan.Inport));
            outPortNames=cell(1,length(phan.Outport));


            inportnamestruct=get_param(blockHandle,'InputPortNames');
            outportnamestruct=get_param(blockHandle,'OutputPortNames');


            for n=1:length(phan.Inport)
                iport=get(get_param(phan.Inport(n),'Object'),'PortNumber');
                portn=['port',num2str(iport-1)];
                inPortNames{n}=inportnamestruct.(portn);
            end

            for n=1:length(phan.Outport)
                oport=get(get_param(phan.Outport(n),'Object'),'PortNumber');
                portn=['port',num2str(oport-1)];
                outPortNames{n}=outportnamestruct.(portn);
            end
        end

        function dInter=createDummyInterface()
            dInter.Inports=struct(blanks(0)');
            dInter.Outports=struct(blanks(0)');
            dInter.Enableports=struct(blanks(0)');
            dInter.Trigports=struct(blanks(0)');
            dInter.HasInitializeEvent=0;
            dInter.HasTerminateEvent=0;
            dInter.ResetEvents=struct(blanks(0)');
        end

        function portNames=getPortNamesOfType(portBlks,bType)

            portNames(length(portBlks)).Name='';
            cnt=1;
            for i=1:length(portBlks)
                if strcmp(bType,get_param(portBlks{i},'BlockType'))
                    portNames(cnt).Name=get_param(portBlks{i},'Name');
                    cnt=cnt+1;
                end
            end
            portNames(cnt:length(portBlks))=[];
            portNames=portNames';
        end

        function portNames=getDataPortPropertiesOfType(portBlks,bType)

            portNames(length(portBlks)).Name='';
            portNames(length(portBlks)).BusObject='';
            cnt=1;
            for i=1:length(portBlks)
                if strcmp(bType,get_param(portBlks{i},'BlockType'))
                    portNames(cnt).Name=get_param(portBlks{i},'Name');


                    busObjectStr=get_param(portBlks{i},'OutDataTypeStr');
                    try
                        bO=split(busObjectStr,':');
                        if numel(bO)==2&&strcmpi(bO{1},'Bus')
                            portNames(cnt).BusObject=strtrim(bO{2});
                        end
                    catch
                    end
                    cnt=cnt+1;
                end
            end
            portNames(cnt:length(portBlks))=[];
            portNames=portNames';
        end

        function dInter=covertToModelInterface(portBlks)

            dInter.Inports=Simulink.internal.vmgr.VMUtils.getDataPortPropertiesOfType(portBlks,'Inport');
            dInter.Outports=Simulink.internal.vmgr.VMUtils.getDataPortPropertiesOfType(portBlks,'Outport');

            dInter.Enableports=Simulink.internal.vmgr.VMUtils.getPortNamesOfType(portBlks,'Enable');
            dInter.Trigports=Simulink.internal.vmgr.VMUtils.getPortNamesOfType(portBlks,'Trigger');

            dInter.HasInitializeEvent=0;
            dInter.HasTerminateEvent=0;
            dInter.ResetEvents=struct(blanks(0)');
        end



        function valid=areValidPortNames(mi)

            valid=true;
            for i=1:length(mi.Inports)
                if isempty(mi.Inports(i).Name)
                    valid=false;
                    return;
                end
            end
            for i=1:length(mi.Enableports)
                if isempty(mi.Enableports(i).Name)
                    valid=false;
                    return;
                end
            end
            for i=1:length(mi.Trigports)
                if isempty(mi.Trigports(i).Name)
                    valid=false;
                    return;
                end
            end

            for i=1:length(mi.Outports)
                if isempty(mi.Outports(i).Name)
                    valid=false;
                    return;
                end
            end
        end


        function bOMap=getBusInfo(blockH,miMap)
            bOMap=containers.Map();
            modelFile=get_param(blockH,'ModelFile');
            mi=Simulink.internal.vmgr.VMUtils.getModelInterface(modelFile,miMap);
            inPorts=mi.Inports;
            for i=1:length(inPorts)
                inPort=inPorts(i);
                bOMap(inPort.Name)=inPort.BusObject;
            end
            outPorts=mi.Outports;
            for i=1:length(outPorts)
                outPort=outPorts(i);
                bOMap(outPort.Name)=outPort.BusObject;
            end
        end



        function mdlinterface=getModelInterface(filename,miMap)
            if miMap.isKey(filename)
                mdlinterface=miMap(filename);
                return;
            end
            try
                mdlInfo=Simulink.MDLInfo(filename);
                mdlinterface=mdlInfo.Interface;
            catch

                mdlinterface=Simulink.internal.vmgr.VMUtils.createDummyInterface();
            end


            if~isempty(mdlinterface)&&~Simulink.internal.vmgr.VMUtils.areValidPortNames(mdlinterface)
                load_system(filename);
                [~,name,~]=fileparts(filename);
                finishup=onCleanup(@()close_system(name,0));
                allBlks=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(name,...
                '(In|Out|Trigger|Enable)[Pp]ort','RegExp','on');
                mdlinterface=...
                Simulink.internal.vmgr.VMUtils.covertToModelInterface(allBlks);

            end
            miMap(filename)=mdlinterface;%#ok<NASGU>
        end

        function[iNames,oNames,cNamesAndTypes]=getPortNamesOfSubsysOrMdlRef(blockH,miMap)
            iNames={};
            oNames={};
            cNamesAndTypes.Names={};
            cNamesAndTypes.Types={};
            cNamesAndTypes.Subtypes={};
            if strcmp(get_param(blockH,'BlockType'),'ModelReference')
                mdlFile=get_param(blockH,'ModelFile');
                if isempty(mdlFile)
                    return;
                end
                mi=Simulink.internal.vmgr.VMUtils.getModelInterface(mdlFile,miMap);
                iNames=cell(1,length(mi.Inports));
                if(~isempty(mi.Enableports)||~isempty(mi.Trigports))
                    cNamesAndTypes.Names=cell([1,~isempty(mi.Enableports)+...
                    ~isempty(mi.Trigports)]);
                    cNamesAndTypes.Types=cell([1,~isempty(mi.Enableports)+...
                    ~isempty(mi.Trigports)]);
                end

                for i=1:length(mi.Inports)
                    iNames{i}=mi.Inports(i).Name;
                end
                p=1;
                for i=1:length(mi.Enableports)
                    cNamesAndTypes.Names{p}=mi.Enableports(i).Name;
                    cNamesAndTypes.Types{p}='Enable';
                    cNamesAndTypes.Subtypes{p}='';
                    p=p+1;
                end

                for i=1:length(mi.Trigports)
                    cNamesAndTypes.Names{p}=mi.Trigports(i).Name;
                    cNamesAndTypes.Types{p}='Trigger';
                    cNamesAndTypes.Subtypes{p}=mi.Trigports.TriggerType;
                    p=p+1;
                end

                oNames=cell([1,length(mi.Outports)]);
                for i=1:length(mi.Outports)
                    oNames{i}=mi.Outports(i).Name;
                end
            elseif strcmp(get_param(blockH,'BlockType'),'SubSystem')

                [iNames,oNames,cNamesAndTypes]=Simulink.internal.vmgr.VMUtils.getSubsystemPortNames(blockH);
            end
        end

        function name=getPortBlockName(portBlkHandle)
            if isfield(get_param(portBlkHandle,'ObjectParameters'),'PortName')
                name=get_param(portBlkHandle,'PortName');
            else
                name=get_param(portBlkHandle,'Name');
            end
        end

        function hasGapPorts(blockH,miMap)








            pH=get_param(blockH,'PortHandles');
            isSubsysH=strcmp(get_param(blockH,'BlockType'),'SubSystem');
            iPH=pH.Inport;


            oPH=pH.Outport;

            if isSubsysH

                for i=1:length(iPH)
                    if isempty(Simulink.internal.vmgr.VMUtils.portBlockOf(iPH(i)))
                        DAStudio.error('Simulink:Engine:BadInportNum',get_param(bdroot(blockH),'Name'),i);
                    end
                end


                for i=1:length(oPH)
                    if isempty(Simulink.internal.vmgr.VMUtils.portBlockOf(oPH(i)))
                        DAStudio.error('Simulink:Engine:BadOutportNum',get_param(bdroot(blockH),'Name'),i);
                    end
                end
            else
                [iNames,oNames,cNamesAndTypes]=Simulink.internal.vmgr.VMUtils.getPortNamesOfSubsysOrMdlRef(blockH,miMap);
                iNames=[iNames,cNamesAndTypes.Names];

                for i=1:numel(iNames)
                    if isempty(iNames{i})
                        DAStudio.error('Simulink:Engine:BadInportNum',get_param(bdroot(blockH),'Name'),i);
                    end
                end


                for i=1:numel(oNames)
                    if isempty(oNames{i})
                        DAStudio.error('Simulink:Engine:BadOutportNum',get_param(bdroot(blockH),'Name'),i);
                    end
                end
            end
        end

        function mappings=GetSignalMappings(blockH)
            origPH=get_param(blockH,'PortHandles');
            mappings=cell(numel(origPH.Outport),1);
            if slfeature('AutoMigrationIM')>0
                mdlMappings=Simulink.CodeMapping.getCurrentMapping(bdroot(blockH));
                if isempty(mdlMappings)||...
                    ~(isa(mdlMappings,'Simulink.CoderDictionary.ModelMapping')||...
                    isa(mdlMappings,'Simulink.CoderDictionary.ModelMappingSLC'))

                    return
                end
                for i=1:numel(origPH.Outport)
                    origMapping=mdlMappings.Signals.findobj('PortHandle',origPH.Outport(i));
                    if isempty(origMapping)
                        continue
                    end
                    origMappedTo=origMapping.MappedTo;
                    if isempty(origMappedTo)
                        continue
                    end
                    if~isempty(origMappedTo.StorageClass)
                        if isempty(origMappedTo.StorageClass.UUID)
                            mappings{i}.UUID='';
                        else
                            mappings{i}.UUID=origMappedTo.StorageClass.UUID;
                            mappings{i}.CSCAttributes=origMappedTo.CSCAttributes;
                        end
                    end
                    mappings{i}.Identifier=origMappedTo.Identifier;
                end
            end
        end

        function checkMdlRefVarConsistentControlports(mdlRefVarBlkH,miMap)






            variants=get_param(mdlRefVarBlkH,'Variants');



            if numel(variants)<1
                return;
            end



            for i=1:numel(variants)
                interfaces(i)={Simulink.internal.vmgr.VMUtils.getModelInterface(variants(i).ModelName,miMap)};%#ok
            end


            fintrf=interfaces{1};

            inconEnab.areInconPorts=false;
            inconEnab.hasInconNames=false;
            inconEnab.id=1;
            for i=2:numel(interfaces)
                cintrf=interfaces{i};

                if isempty(fintrf.Enableports)&&isempty(cintrf.Enableports)
                    continue;
                elseif(isempty(fintrf.Enableports)&&~isempty(cintrf.Enableports))||(~isempty(fintrf.Enableports)&&isempty(cintrf.Enableports))
                    inconEnab.areInconPorts=true;
                    inconEnab.id=i;
                    break;
                elseif strcmp(fintrf.Enableports.Name,cintrf.Enableports.Name)~=1
                    inconEnab.hasInconNames=true;
                    inconEnab.id=i;
                    break;
                end
                inconEnab.isTrue=true;
                inconEnab.id=i;
                break;
            end



            if inconEnab.areInconPorts
                DAStudio.error('Simulink:Variants:C2VMixControlPorts',...
                [get_param(mdlRefVarBlkH,'Parent'),'/',get_param(mdlRefVarBlkH,'Name')]);
            end
            if inconEnab.hasInconNames
                DAStudio.error('Simulink:Variants:C2VDiffControlPortNames',...
                [get_param(mdlRefVarBlkH,'Parent'),'/',get_param(mdlRefVarBlkH,'Name')]);
            end



            inconTrig.areInconPorts=false;
            inconTrig.hasInconNames=false;
            inconTrig.id=1;

            for i=2:numel(interfaces)
                cintrf=interfaces{i};

                if isempty(fintrf.Trigports)&&isempty(cintrf.Trigports)
                    continue;
                elseif(isempty(fintrf.Trigports)&&~isempty(cintrf.Trigports))||(~isempty(fintrf.Trigports)&&isempty(cintrf.Trigports))
                    inconTrig.areInconPorts=true;
                    inconTrig.id=i;
                    break;
                elseif strcmp(fintrf.Trigports.Name,cintrf.Trigports.Name)~=1
                    inconTrig.hasInconNames=true;
                    inconTrig.id=i;
                    break;
                end
                inconTrig.isTrue=true;
                inconTrig.id=i;
                break;
            end



            if inconTrig.areInconPorts
                DAStudio.error('Simulink:Variants:C2VMixControlPorts',...
                [get_param(mdlRefVarBlkH,'Parent'),'/',get_param(mdlRefVarBlkH,'Name')]);
            end
            if inconTrig.hasInconNames
                DAStudio.error('Simulink:Variants:C2VDiffControlPortNames',...
                [get_param(mdlRefVarBlkH,'Parent'),'/',get_param(mdlRefVarBlkH,'Name')]);
            end



            if~isempty(fintrf.Trigports)

                triggTypes=cell(1,numel(interfaces));
                for i=1:numel(interfaces)
                    cintrf=interfaces{i};
                    if~isempty(cintrf.Trigports)
                        triggTypes(i)={cintrf.Trigports.TriggerType};
                    else
                        triggTypes(i)={''};
                    end
                end










                numfcnelem=numel(triggTypes(strcmp(triggTypes,'function-call')));

                isValidCase=(numfcnelem==numel(triggTypes))||numfcnelem==0;
                if~isValidCase

                    DAStudio.error('Simulink:Variants:C2VDiffTriggType',...
                    [get_param(mdlRefVarBlkH,'Parent'),'/',get_param(mdlRefVarBlkH,'Name')]);
                end

            end

            if isempty(fintrf.Trigports)&&isempty(fintrf.Enableports)
                return;
            end



            bestintrf=fintrf;
            for i=2:numel(interfaces)
                cintrf=interfaces{i};
                if numel(cintrf.Inports)>numel(bestintrf.Inports)
                    temp=bestintrf;
                    bestintrf=cintrf;
                    cintrf=temp;
                end

                for j=1:numel(cintrf.Inports)
                    if~strcmp(cintrf.Inports(j).Name,bestintrf.Inports(j).Name)
                        DAStudio.error('Simulink:Variants:C2VDiffPortNumber',...
                        [get_param(mdlRefVarBlkH,'Parent'),'/',get_param(mdlRefVarBlkH,'Name')]);
                    end
                end
            end


            bestintrf=fintrf;
            for i=2:numel(interfaces)
                cintrf=interfaces{i};
                if numel(cintrf.Outports)>numel(bestintrf.Outports)
                    temp=bestintrf;
                    bestintrf=cintrf;
                    cintrf=temp;
                end

                for j=1:numel(cintrf.Outports)
                    if~strcmp(cintrf.Outports(j).Name,bestintrf.Outports(j).Name)
                        DAStudio.error('Simulink:Variants:C2VDiffPortNumber',...
                        [get_param(mdlRefVarBlkH,'Parent'),'/',get_param(mdlRefVarBlkH,'Name')]);
                    end
                end
            end

        end


        function makeVSSInterfaceConsistentForChoiceBlocks(vssBlk,portHs,miMap)


            variants=get_param(vssBlk,'Variants');
            EnTrigInfo=[~isempty(portHs.Enable),~isempty(portHs.Trigger)];
            choiceBlks={variants.BlockName};

            vc={variants.Name};
            vssBlkH=get_param(vssBlk,'Handle');
            makeChoicesNV=strcmp(get_param(vssBlkH,'VariantControlMode'),'expression')&&strcmp(get_param(vssBlkH,'GeneratePreprocessorConditionals'),'on');



            slInternal('SetAsVariantSubystem',vssBlkH,'off');
            finishup=onCleanup(@()slInternal('SetAsVariantSubystem',vssBlkH,'on'));

            [vssInC,vssOutC,vssCtrlAndTypes]=Simulink.internal.vmgr.VMUtils.getPortNamesOfSubsysOrMdlRef(vssBlkH,miMap);
            vssInC=[vssInC,vssCtrlAndTypes.Names];


            vssIn=strtrim(vssInC);

            vssIn=loc_updateInportNames(vssIn,EnTrigInfo);
            vssOut=strtrim(vssOutC);

















            vssInMax=vssIn;
            vssOutMax=vssOut;
            newChoicesH=[];
            originalChoicesH=[];
            chsEnTrigInfo=[0,0];

            for iCh=1:numel(choiceBlks)
                choiceH=get_param(choiceBlks{iCh},'Handle');
                chPortHs=get_param(choiceBlks{iCh},'PortHandles');
                chEnTrigInfo=[~isempty(chPortHs.Enable),~isempty(chPortHs.Trigger)];
                chsEnTrigInfo=chEnTrigInfo|chsEnTrigInfo;
                [iNames,oNames,cNamesAndTypes]=...
                Simulink.internal.vmgr.VMUtils.getPortNamesOfSubsysOrMdlRef(choiceH,miMap);


                iNames=[cNamesAndTypes.Names,iNames];%#ok<AGROW>


                if isempty(iNames)&&isempty(oNames)
                    continue;
                end

                iNames=loc_updateInportNames(iNames,chEnTrigInfo);



                iNamesTrimmed=strtrim(iNames);
                oNamesTrimmed=strtrim(oNames);


                consistentINames=1;

                if length(iNamesTrimmed)<=length(vssIn)
                    for iNs=1:length(iNamesTrimmed)
                        if~strcmp(iNamesTrimmed(iNs),vssIn(iNs))
                            consistentINames=0;
                            break;
                        end
                    end
                else
                    for iNs=1:length(vssIn)
                        if~strcmp(iNamesTrimmed(iNs),vssIn(iNs))
                            consistentINames=0;
                            break;
                        end
                    end
                end

                consistentONames=1;

                if length(oNamesTrimmed)<=length(vssOut)

                    for oNs=1:length(oNamesTrimmed)
                        if~strcmp(oNamesTrimmed(oNs),vssOut(oNs))
                            consistentONames=0;
                            break;
                        end
                    end
                else

                    for oNs=1:length(vssOut)
                        if~strcmp(oNamesTrimmed(oNs),vssOut(oNs))
                            consistentONames=0;
                            break;
                        end
                    end
                end


                if~consistentINames||~consistentONames
                    newChoicesH(end+1)=...
                    createWrapperSubsystemChoice(choiceH,...
                    makeChoicesNV,vc{iCh});
                    originalChoicesH(end+1)=choiceH;
                end






                if length(iNamesTrimmed)>length(vssIn)
                    if consistentINames
                        lvssIn=length(vssIn);
                        lchIn=length(iNamesTrimmed);
                        for iEN=lvssIn+1:lchIn
                            vssIn(end+1)=iNamesTrimmed(iEN);
                        end
                    else
                        if length(vssInMax)<length(iNamesTrimmed)
                            vssInMax=iNamesTrimmed;
                        end
                    end
                end

                if length(oNamesTrimmed)>length(vssOut)
                    if consistentONames
                        lvssOut=length(vssOut);
                        lchOut=length(oNamesTrimmed);
                        for oEN=lvssOut+1:lchOut
                            vssOut(end+1)=oNamesTrimmed(oEN);
                        end
                    else
                        if length(vssOutMax)<length(oNamesTrimmed)
                            vssOutMax=oNamesTrimmed;
                        end
                    end
                end
            end


            for i=length(vssIn)+1:length(vssInMax)
                vssIn(end+1)=vssInMax(i);
            end
            for i=length(vssOut)+1:length(vssOutMax)
                vssOut(end+1)=vssOutMax(i);
            end



            [enableP,triggerP,vssIn]=loc_splitCtrlNdInPortNames(vssIn,EnTrigInfo);





            enableP1={};
            if chsEnTrigInfo(1)==1&&EnTrigInfo(1)~=chsEnTrigInfo(1)
                enableP1={'Enable'};
            end

            triggerP1={};
            if chsEnTrigInfo(2)==1&&EnTrigInfo(2)~=chsEnTrigInfo(2)
                triggerP1={'Trigger'};
            end
            vssInNew=matlab.lang.makeUniqueStrings(...
            [enableP,triggerP,vssIn,enableP1,triggerP1]);
            vssOut=matlab.lang.makeUniqueStrings(vssOut);




            loc_adjustVSSPortNames(vssBlk,vssInNew,vssOut);



            if~isempty(enableP)
                if~isempty(triggerP)
                    enableP=vssInNew(1);
                    triggerP=vssInNew(2);
                    vssInNew(1:2)=[];
                else
                    enableP=vssInNew(1);
                    vssInNew(1)=[];
                    if~isempty(triggerP1)
                        triggerP=vssInNew(end);
                        vssInNew(end)=[];
                    end
                end
            else
                if~isempty(triggerP)
                    triggerP=vssInNew(1);
                    vssInNew(1)=[];
                    if~isempty(enableP1)
                        enableP=vssInNew(end);
                        vssInNew(end)=[];
                    end
                else
                    if~isempty(triggerP1)
                        triggerP=vssInNew(end);
                        vssInNew(end)=[];
                    end
                    if~isempty(enableP1)
                        enableP=vssInNew(end);
                        vssInNew(end)=[];
                    end
                end
            end

            for i=1:length(newChoicesH)
                chPortHs=get_param(originalChoicesH(i),'PortHandles');
                chEnTrigInfo=[~isempty(chPortHs.Enable),~isempty(chPortHs.Trigger)];
                loc_renamePortsOfInsertedSubsystems(...
                newChoicesH(i),chEnTrigInfo,...
                enableP,triggerP,vssInNew,vssOut);
            end
        end

        function createMdlBlocksForMdlrefVariants(origBlk,vssBlk,signalMappings)









            hasSlTestLicense=true;


            hasreqLinks=true;
            blockH=get_param(origBlk,'Handle');
            try

                reqLinks=rmi('get',blockH);
            catch
                hasreqLinks=false;
            end



            if~(strcmp(get_param(blockH,'BlockType'),'ModelReference')&&strcmp(get_param(blockH,'Variant'),'on'))
                return;
            end
            try

                mMdlObj=Simulink.Mask.get(blockH);
                if~isempty(mMdlObj)
                    varPar=mMdlObj.getParameter('Variant');
                    if~isempty(varPar)&&strcmp(varPar.ReadOnly,'on')
                        varPar.ReadOnly='off';
                    end
                end
            catch

            end


            mi=get_param(bdroot(blockH),'DataLoggingOverride');



            mdlRefVar=get_param(blockH,'Variants');
            if isempty(mdlRefVar)



                set_param(blockH,'Variant','off');
                return;
            end



            loc_moveSignalMappings(blockH,vssBlk,signalMappings);


            varPos=get_param(origBlk,'Position');




            modelChoicesH=zeros(1,numel(mdlRefVar));

            try

                harnSet=sltest.harness.find(getfullname(blockH));
            catch
                hasSlTestLicense=false;
            end




            callbacks={'ClipboardFcn','CloseFcn','ContinueFcn','CopyFcn','DeleteFcn',...
            'DestroyFcn','InitFcn','LoadFcn','ModelCloseFcn','MoveFcn','NameChangeFcn',...
            'OpenFcn','ParentcloseFcn','PauseFcn','PostSaveFcn','PreCopyFcn','PreDeleteFcn'...
            ,'PreSaveFcn','StartFcn','StopFcn','UndoDeleteFcn'};
            cellfun(@(x)set_param(blockH,x,''),callbacks);

            for i=1:numel(mdlRefVar)

                path=[vssBlk,'/',mdlRefVar(i).ModelName];






                hBlk=add_block(blockH,path,'MakeNameUnique','on',...
                'Position',varPos,...
                'LinkStatus','none',...
                'Variant','off');

                loc_requirementDebug(hBlk,...
                'Requirements link not found for copied block',...
                'Requirements link found for copied block');

                modelChoicesH(i)=hBlk;

                bottom=varPos(4)-varPos(2);
                varPos(2)=varPos(4)+50;
                varPos(4)=varPos(2)+bottom;

                try
                    set_param(hBlk,'ModelName',mdlRefVar(i).ModelName,...
                    'VariantControl',mdlRefVar(i).Name,...
                    'SimulationMode',mdlRefVar(i).SimulationMode);




                    argVals=Simulink.internal.vmgr.VMUtils.i_getParamArgumentValuesStruct(mdlRefVar(i),hBlk);
                    set_param(hBlk,'ParameterArgumentValues',argVals);
                catch
                    slInternal('setMRVParams',...
                    hBlk,...
                    mdlRefVar(i).ModelName,...
                    mdlRefVar(i).Name,...
                    mdlRefVar(i).ParameterArgumentNames,...
                    mdlRefVar(i).ParameterArgumentValues,...
                    mdlRefVar(i).SimulationMode);
                end


                mObj=Simulink.Mask.get(hBlk);
                if~isempty(mObj)


                    try


                        mObj.delete;
                    catch
                    end
                end
                if hasSlTestLicense
                    loc_restoreHarness(vssBlk,blockH,harnSet,hBlk,mdlRefVar(i).Name);
                end
                if hasreqLinks
                    reqLinks1=rmi('get',hBlk);
                    if isempty(reqLinks1)&&~isempty(reqLinks)
                        rmi('set',hBlk,reqLinks);
                    end

                    loc_requirementDebug(hBlk,...
                    'Requirements link not set for copied block',...
                    'Requirements link set for copied block');

                end
            end





            oldBlkMaskObj=Simulink.Mask.get(origBlk);
            if~isempty(oldBlkMaskObj)
                newBlkMaskObj=Simulink.Mask.create(vssBlk);
                try
                    newBlkMaskObj.copy(oldBlkMaskObj);
                catch ME
                    MSLDiagnostic(ME).reportAsWarning;
                end
            end


            s=warning('error','Simulink:Harness:HarnessDeletedForBlock');%#ok<CTPCT>
            oC=onCleanup(@()warning(s));
            try

                delete_block(origBlk);
            catch ME
                if strcmpi(ME.identifier,'Simulink:Harness:HarnessDeletedForBlock')
                    MSLDiagnostic('Simulink:Variants:MRVTestHarnessMoveWarn',getfullname(vssBlk)).reportAsWarning;
                end
            end


            mi=i_updateModelSignalInfo(mi,vssBlk,modelChoicesH);
            set_param(bdroot(vssBlk),'DataLoggingOverride',mi);
        end

        function redrawDataLines(parentSystem,lines)

            for i=1:numel(lines)
                if lines(i).start~=-1&&lines(i).end~=-1
                    try
                        add_line(parentSystem,lines(i).start,lines(i).end,'autorouting','on');
                    catch

                    end
                end
            end
        end



        function renameBlock(blk2Rename,newName)
            changeOtherBlockName=false;
            try
                set_param(blk2Rename,'Name',newName);
            catch
                changeOtherBlockName=true;
            end
            if changeOtherBlockName

                parent=get_param(blk2Rename,'parent');
                bpath=[parent,'/',newName];
                otherblkH=get_param(bpath,'Handle');

                newNameTemp=[newName,' '];
                attemptTimes=1;
                while(attemptTimes<1000)
                    try

                        set_param(otherblkH,'Name',newNameTemp);
                        break;
                    catch
                        newNameTemp=[newNameTemp,' '];%#ok<AGROW>
                    end
                    attemptTimes=attemptTimes+1;
                end
                set_param(blk2Rename,'Name',newName);
            end
        end
    end

    methods(Static)

        function vars=getValuesOfControlVariables(rootModelName,varNames,specialVarsInfoManager)




            numVars=length(varNames);
            if numVars>0
                vars=repmat(Simulink.internal.vmgr.VMUtils.getEmptyCtrlVarsStruct(),numVars,1);
            else
                vars=[];
            end
            found=false;

            for varsIdx=1:numVars
                try

                    name=varNames{varsIdx};

                    if contains(name,'.')
                        outerVarName=strsplit(name,'.');
                        outerVarName=outerVarName{1};
                    else
                        outerVarName=name;
                    end
                    found=specialVarsInfoManager.getIsVariable(outerVarName);
                    source=specialVarsInfoManager.getVariableSource(outerVarName);
                    globalSourceType=Simulink.internal.vmgr.VMUtils.getSourceType(source);





                    if found
                        if contains(name,'.')
                            valToReturn=Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope(rootModelName,name);
                        else
                            valToReturn=specialVarsInfoManager.getVariableValue(name);
                        end
                    else
                        valToReturn=0;
                    end
                catch excep %#ok
                    valToReturn=0;
                    [source,globalSourceType]=Simulink.internal.vmgr.VMUtils.getDefaultSourceAndSourceType(rootModelName);
                end
                vars(varsIdx,1).Name=name;
                vars(varsIdx,1).Value=valToReturn;
                vars(varsIdx,1).Exists=found;
                vars(varsIdx,1).Source=source;
                vars(varsIdx,1).SourceType=globalSourceType;
            end
        end


        function ctrlVarsStruct=getEmptyCtrlVarsStruct()
            ctrlVarsStruct=struct(...
            'Name','',...
            'Value',[],...
            'Exists',false,...
            'Source','',...
            'SourceType','');
        end

        function[source,sourceType]=getDefaultSourceAndSourceType(rootModelName)
            ddSpec=get_param(rootModelName,'DataDictionary');
            source=slvariants.internal.config.utils.getGlobalWorkspaceName(ddSpec);
            sourceType=Simulink.internal.vmgr.VMUtils.getSourceType(source);
        end

        function sourceType=getSourceType(source)
            bwksSource=slvariants.internal.config.utils.getGlobalWorkspaceName('');
            if strcmp(source,bwksSource)
                sourceType=bwksSource;
            else
                sourceType='data dictionary';
            end
        end
    end
end





function loc_renamePortsOfInsertedSubsystems(...
    choiceSubsys,chCtrlInfo,enableP,triggerP,inputPortNames,outputPortNames)


    iPorts=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(choiceSubsys,'Inport');
    startCh=sum(chCtrlInfo);
    if chCtrlInfo(1)==1&&chCtrlInfo(2)==1
        Simulink.internal.vmgr.VMUtils.renameBlock(iPorts(1),enableP{1});
        Simulink.internal.vmgr.VMUtils.renameBlock(iPorts(2),triggerP{1});
    elseif chCtrlInfo(1)==1
        Simulink.internal.vmgr.VMUtils.renameBlock(iPorts(1),enableP{1});
    elseif chCtrlInfo(2)==1
        Simulink.internal.vmgr.VMUtils.renameBlock(iPorts(1),triggerP{1});
    end

    for eachPort=1:length(iPorts)-startCh
        Simulink.internal.vmgr.VMUtils.renameBlock(iPorts(eachPort+startCh),inputPortNames{eachPort});
    end


    oPorts=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(choiceSubsys,'Outport');
    for eachPort=1:length(oPorts)
        Simulink.internal.vmgr.VMUtils.renameBlock(oPorts(eachPort),outputPortNames{eachPort});
    end
end

function newChoicesH=createWrapperSubsystemChoice(choiceH,gpcOn,vc)

    Simulink.BlockDiagram.createSubSystem(choiceH);
    newSubsys=get_param(choiceH,'Parent');
    set_param(newSubsys,'Name',get_param(choiceH,'Name'));

    newSubsys=get_param(choiceH,'Parent');

    set_param(newSubsys,'VariantControl',vc);


    if~isempty(gpcOn)
        set_param(newSubsys,'TreatAsAtomicUnit','on');
    end
    newChoicesH=get_param(newSubsys,'handle');
end

function loc_adjustVSSPortNames(vssBlk,vssNewIns,vssNewOuts)

    iPorts=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(get_param(vssBlk,'Handle'),'Inport');


    if numel(iPorts)>0
        inpos=get_param(iPorts(end),'Position');
    else

        inpos(1)=-235;
        inpos(2)=0;
        inpos(3)=-205;
        inpos(4)=20;
    end

    inpos(2)=inpos(2)+50;
    inpos(4)=inpos(4)+50;


    for i=1:numel(iPorts)
        set_param(iPorts(i),'Name',vssNewIns{i});
    end

    for i=numel(iPorts)+1:numel(vssNewIns)

        add_block('simulink/Sources/In1',[vssBlk,'/',vssNewIns{i}],'MakeNameUnique','on','Position',inpos);


        inpos(2)=inpos(2)+50;
        inpos(4)=inpos(4)+50;
    end


    oPorts=Simulink.internal.vmgr.VMUtils.findNonChoiceBlocksInCurrentGraph(get_param(vssBlk,'Handle'),'Outport');

    if numel(oPorts)>0
        outpos=get_param(oPorts(end),'Position');
    else

        outpos(1)=305;
        outpos(2)=0;
        outpos(3)=335;
        outpos(4)=20;
    end

    outpos(2)=outpos(2)+50;
    outpos(4)=outpos(4)+50;


    for i=1:numel(oPorts)
        set_param(oPorts(i),'Name',vssNewOuts{i});
    end

    for i=numel(oPorts)+1:numel(vssNewOuts)

        add_block('simulink/Sinks/Out1',[vssBlk,'/',vssNewOuts{i}],'MakeNameUnique','on','Position',outpos);


        outpos(2)=outpos(2)+50;
        outpos(4)=outpos(4)+50;
    end

end

function inPorts=loc_updateInportNames(inPorts,EnTrigInfo)

    if EnTrigInfo(1)~=1&&EnTrigInfo(2)~=1
        inPorts=[{'dummyEnPrt1'},{'dummyTrPrt1'},inPorts];
    elseif EnTrigInfo(1)~=1
        inPorts=[{'dummyEnPrt1'},inPorts];
    elseif EnTrigInfo(2)~=1
        inPorts=[inPorts(1),{'dummyTrPrt1'},inPorts(2:end)];
    end
end

function[enablePrt,triggerPrt,inPorts]=loc_splitCtrlNdInPortNames(inPorts,EnTrigInfo)

    enablePrt={};
    triggerPrt={};
    if EnTrigInfo(1)==1&&EnTrigInfo(2)==1
        enablePrt=inPorts(1);
        triggerPrt=inPorts(2);
    elseif EnTrigInfo(1)==1
        enablePrt=inPorts(1);
    elseif EnTrigInfo(2)==1
        triggerPrt=inPorts(2);
    end
    inPorts=inPorts(3:end);
end

function mi=i_updateModelSignalInfo(mi,vssH,choicesH)
    logdSignals=mi.LogAsSpecifiedByModels;

    fndPath=logdSignals(strcmp(vssH,logdSignals));
    if isempty(fndPath)




        return;
    end



    logdSignals=logdSignals(~strcmp(vssH,logdSignals));

    for i=1:length(choicesH)
        choicePath=[get_param(choicesH(i),'Parent'),'/',get_param(choicesH(i),'Name')];
        logdSignals=[logdSignals,choicePath];%#ok<AGROW>
    end
    mi.LogAsSpecifiedByModels=logdSignals;
end



function loc_restoreHarness(vssBlk,harnessOwnerH,harnessSet,choicePathH,overrideChoice)
    if isempty(harnessSet)
        return;
    end
    harnessOwnerPath=getfullname(harnessOwnerH);
    choicePath=getfullname(choicePathH);
    for i=1:numel(harnessSet)
        harness=harnessSet(i);
        set_param(vssBlk,'LabelModeActiveChoice',overrideChoice);
        sltest.harness.clone(harnessOwnerPath,harness.name,'DestinationOwner',choicePath);
    end
end

function loc_requirementDebug(blockH,fmsg,pmsg)
    if slsvTestingHook('ConvertToVSSDebug')==1
        disp(['Choice Model ',get_param(blockH,'Parent'),get_param(blockH,'Name'),':']);
        reqLinks=rmi('get',blockH);
        if isempty(reqLinks)
            disp(fmsg);
        else
            disp(pmsg);
        end
    end
end

function loc_moveSignalMappings(blockH,vssBlk,signalMappings)
    mdlMappings=Simulink.CodeMapping.getCurrentMapping(bdroot(blockH));
    vssPH=get_param(vssBlk,'PortHandles');
    for i=1:numel(vssPH.Outport)
        origMapping=signalMappings{i};
        if isempty(origMapping)
            continue
        end

        mdlMappings.addSignal(vssPH.Outport(i));
        vssMapping=mdlMappings.Signals.findobj('PortHandle',vssPH.Outport(i));
        if isfield(origMapping,'UUID')
            vssMapping.map(origMapping.UUID);
            if isfield(origMapping,'CSCAttributes')
                vssMapping.MappedTo.CSCAttributes=origMapping.CSCAttributes;
            end
        end
        if isfield(origMapping,'Identifier')
            vssMapping.MappedTo.Identifier=origMapping.Identifier;
        end


    end
end









