



classdef ModelGeneration<handle


    properties

        hTurnkey=[];


        usrMdlName='';
        tifMdlName='';
        usrDutPath='';
        tifDutPath='';


        libName='';
        libPath='';
        blockName='';
        blockPath='';


        hPir=[];
    end

    properties(Constant)

        setupBlkPosition=[100,10,200,60];
        interfaceBlkOffset=[300,200,300,200];
        inportBlkOffset=[-200,-7,-170,7];
        outportBlkOffset=[200,-7,230,7];
        constBlkOffset=[-200,-10,-170,10];
    end

    properties(Access=protected)

        current_system='';


        messageString='';
        maskString='';


        MdlNamePostfix='interface';
    end

    properties(Access=protected)
        RemoveUnusedPorts=false;
    end

    properties(Constant,Hidden)

        BlockSpace=40;
        BlockWidth=70;
        BlockHeight=40;
        BlockWidthSmall=24;
        BlockHeightSmall=24;
    end

    methods
        function obj=ModelGeneration(hTurnkey)

            obj.hTurnkey=hTurnkey;
        end
    end

    methods(Abstract)

        [status,result]=generateModelWithoutLibraryBlock(obj)
    end

    methods

        function[status,result,validateCell]=generateModel(obj)





            hDI=obj.hTurnkey.hD;
            validateCell={};
            if hDI.isSLRTWorkflow
                [status,result]=obj.generateModelWithoutLibraryBlock;
            elseif strcmpi(hdlfeature('IPCoreSoftwareInterfaceLibrary'),'on')
                [status,result]=obj.generateModelWithLibraryBlock;
            else
                [status,result,validateCell]=obj.generateModelWithoutLibraryBlock;
            end
        end


        function[status,result,validateCell]=generateHostModel(obj)
            obj.MdlNamePostfix='Hostinterface';
            obj.messageString='Host Interface';
            obj.maskString='Host Interface';
            [status,result,validateCell]=obj.generateHostModelWithoutLibraryBlock;
        end





        function name=getTIFDutBlkPath(obj,dutBlkName)

            name=[obj.tifDutPath,'/',dutBlkName];
        end

        function name=getTIFMdlBlkPath(obj,mdlBlkName)

            name=[obj.tifMdlName,'/',mdlBlkName];
        end

        function ipcoreinfo=getIPCoreInfo(obj)

            ipcoreinfo=obj.generateIPCoreInfo;
        end

        function isit=isUnusedPortRemoved(obj)
            isit=obj.RemoveUnusedPorts;
        end

        function isit=isCommandLineDisplay(obj)
            isit=obj.hTurnkey.hD.cmdDisplay;
        end

        function[subsysBlkPath,subsysBlkName]=addSliceConcatBlk(obj,blkName,wordLength,dimLen,addrLength,refBlkPath,refBlkName)






            dataSections=ceil(double(wordLength)/32);
            assert(dimLen*dataSections==addrLength);

            if strcmp(blkName,'slice')



                [subsysBlkPath,subsysBlkName]=addBlockR(obj,'built-in/Subsystem',getTIFDutBlkPath(obj,blkName),refBlkPath,false,true);
                [inBlkPath,inBlkName]=addBlockUnique(obj,'built-in/Inport',[subsysBlkPath,'/in']);
                [outBlkPath,outBlkName]=addBlockR(obj,'built-in/Outport',[subsysBlkPath,'/out'],inBlkPath,false,true);
                add_line(obj.tifDutPath,[refBlkName,'/1'],[subsysBlkName,'/1'],'Autorouting','on');


                [muxBlkPath,muxBlkName]=addSLLibBlk(obj,'mux','left',outBlkPath,outBlkName,subsysBlkName);
                set_param(muxBlkPath,'Inputs',num2str(addrLength));


                msb=uint32(wordLength-1);
                lsb=uint32(wordLength-32);
                for ii=1:dataSections

                    [sliceBlkPath,sliceBlkName]=addSLLibBlk(obj,'bitslice','right',inBlkPath,inBlkName,subsysBlkName);
                    set_param(sliceBlkPath,'lidx',num2str(msb));
                    set_param(sliceBlkPath,'ridx',num2str(lsb));


                    [dtcBlkPath,dtcBlkName]=addSLLibBlk(obj,'dtc','right',sliceBlkPath,sliceBlkName,subsysBlkName);
                    set_param(dtcBlkPath,'OutDataTypeStr','uint32');
                    set_param(dtcBlkPath,'ConvertRealWorld','Stored Integer (SI)');



                    [demxuBlkPath,demxuBlkName]=addSLLibBlk(obj,'demux','right',dtcBlkPath,dtcBlkName,subsysBlkName);
                    set_param(demxuBlkPath,'Outputs',num2str(dimLen));

                    for jj=0:dimLen-1









                        demuxPortNum=jj+1;
                        muxPortNum=dataSections*jj+ii;
                        add_line(subsysBlkPath,[demxuBlkName,'/',num2str(demuxPortNum)],[muxBlkName,'/',num2str(muxPortNum)],'Autorouting','on');
                    end


                    msb=msb-32;
                    lsb=lsb-32;
                end
            elseif strcmp(blkName,'concat')



                [subsysBlkPath,subsysBlkName]=addBlockLeft(obj,'built-in/Subsystem',getTIFDutBlkPath(obj,blkName),refBlkPath,false,true);
                [inBlkPath,inBlkName]=addBlockUnique(obj,'built-in/Inport',[subsysBlkPath,'/in']);
                [outBlkPath,outBlkName]=addBlockRight(obj,'built-in/Outport',[subsysBlkPath,'/out'],inBlkPath,false,true);
                add_line(obj.tifDutPath,[subsysBlkName,'/1'],[refBlkName,'/1'],'Autorouting','on');



                [demxuBlkPath,demxuBlkName]=addSLLibBlk(obj,'demux','right',inBlkPath,inBlkName,subsysBlkName);
                set_param(demxuBlkPath,'Outputs',num2str(addrLength));


                [muxBlkPath,muxBlkName]=addSLLibBlk(obj,'mux','left',outBlkPath,outBlkName,subsysBlkName);
                set_param(muxBlkPath,'Inputs',num2str(dimLen));


                for ii=0:dimLen-1

                    muxPortNum=ii+1;
                    [concatBlkPath,concatBlkName]=addSLLibBlk(obj,'bitconcat','left',muxBlkPath,muxBlkName,subsysBlkName,muxPortNum);
                    set_param(concatBlkPath,'numInputs',num2str(dataSections));

                    msb=uint32(wordLength-1);
                    lsb=uint32(wordLength-32);
                    for jj=1:dataSections


                        sliceDataType=fixdt(0,msb-lsb+1,0);
                        demuxPortNum=dataSections*ii+jj;
                        [dtcBlkPath,dtcBlkName]=addSLLibBlk(obj,'dtc','right',demxuBlkPath,demxuBlkName,subsysBlkName,demuxPortNum);
                        set_param(dtcBlkPath,'OutDataTypeStr',fixdt(sliceDataType));
                        set_param(dtcBlkPath,'ConvertRealWorld','Stored Integer (SI)');


                        add_line(subsysBlkPath,[dtcBlkName,'/1'],[concatBlkName,'/',num2str(jj)],'Autorouting','on');


                        msb=msb-32;
                        lsb=lsb-32;
                    end
                end
            end

        end

    end

    methods(Access=protected)

        function[ipcoreinfo,validateCell]=generateIPCoreInfo(obj)


            ipcoreinfo=obj.hTurnkey.modelgeninfo;
            validateCell=ipcoreinfo.validateCell;


            ipcoreinfo.CModelDutPath=obj.tifDutPath;


            ipcoreinfo.HDLModelDutPath=obj.usrDutPath;


            ipcoreinfo.OperatingSystem=obj.hTurnkey.hD.hIP.getOperatingSystem;

        end



        function[status,result]=generateModelWithLibraryBlock(obj)

            [status,result]=obj.generateLibraryBlock;


            [status,result]=obj.initModelGen(status,result);


            [status,result]=obj.addLibraryBlockToModel(status,result);
            [status,result]=obj.addTunableConstToModel(status,result);
            [status,result]=obj.addOutportTerminationToModel(status,result);



            [status,result]=obj.finishModelGen(status,result);

        end




        function[status,result]=initLibraryBlockGen(obj)






            status=true;
            result='';

            hDI=obj.hTurnkey.hD;


            obj.current_system=get_param(0,'CurrentSystem');
            obj.usrDutPath=hDI.hCodeGen.getDutName;
            dutName=get_param(obj.usrDutPath,'Name');
            obj.usrMdlName=hDI.hCodeGen.ModelName;
            obj.libName=sprintf('gm_%s_lib',obj.usrMdlName);

            obj.blockName=sprintf('%s_%s',dutName,obj.MdlNamePostfix);
            obj.blockPath=[obj.libName,'/',obj.blockName];


            obj.tifMdlName=obj.libName;
            obj.tifDutPath=obj.blockPath;


            try
                close_system(obj.libName,0);
                new_system(obj.libName,'Library');
            catch
                msg=message('hdlcommon:workflow:ModelGenMsgUseExistingLibrary',obj.libName);
                if hDI.cmdDisplay
                    hdldisp(msg);
                else
                    result=sprintf('%s\n%s',result,msg.getString);
                end
            end

            load_system(obj.libName);


            try
                add_block('built-in/Subsystem',obj.blockPath)
            catch
                msg=message('hdlcommon:workflow:ModelGenMsgReplaceExistingLibBlock',obj.blockPath);
                if hDI.cmdDisplay
                    hdldisp(msg);
                else
                    result=sprintf('%s\n%s',result,msg.getString);
                end

                delete_block(obj.blockPath);
                add_block('built-in/Subsystem',obj.blockPath)
            end


            link=sprintf('<a href="matlab:open_system(''%s'');hilite_system(''%s'')">%s</a>',obj.libName,obj.blockPath,obj.blockPath);
            msg=message('hdlcommon:workflow:ModelGenMsgGenerateLibBlock',obj.messageString,link);
            if hDI.cmdDisplay
                hdldisp(msg);
            else
                result=sprintf('%s\n%s',result,msg.getString);
            end




            inports=find_system(obj.usrDutPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Inport');





            for i=1:numel(inports)
                name=get_param(inports{i},'Name');
                h=add_block(inports{i},[obj.blockPath,'/',name]);
                set_param(h,'Position',[15,15+50*i,15+30,15+50*i+13])
            end




            outports=find_system(obj.usrDutPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Outport');


            for j=1:numel(outports)
                name=get_param(outports{j},'Name');
                h=add_block(outports{j}',[obj.blockPath,'/',name]);
                set_param(h,'Position',[215,15+50*j,215+30,15+50*j+13])
            end



            tunableParamPortList=obj.hTurnkey.hTable.hTunableParamPortList;
            tunableParamNames=tunableParamPortList.TunableParamNameList;
            k=0;
            if~isempty(tunableParamNames)
                for k=1:numel(tunableParamNames)
                    name=tunableParamNames{k};
                    type=tunableParamPortList.TunableParamSLTypeMap(name);
                    h=add_block('built-in/Inport',[obj.blockPath,'/',name]);
                    set_param(h,'Position',[15,15+50*(i+k),15+30,15+50*(i+k)+13])
                    set_param(h,'OutDataTypeStr',type.viadialog);
                end
            end



            set_param(gcb,'Position',[15,15,215,15+max(i+k,j)*50])



        end

        function[status,result]=finishLibraryBlockGen(obj,status,result)

            hDI=obj.hTurnkey.hD;












            save_system(obj.libName);
            open_system(obj.libName);


            msg=message('hdlcommon:workflow:ModelGenMsgFinishLibBlock',obj.messageString);
            if hDI.cmdDisplay
                hdldisp(msg);
            else
                result=sprintf('%s\n%s',result,msg.getString);
            end

        end

        function[status,result]=addLibraryBlockToModel(obj,status,result)


            h=add_block(obj.blockPath,[obj.tifDutPath,'/',obj.blockName]);
            p=get_param(h,'Position');
            set_param(h,'Position',p+obj.interfaceBlkOffset);


            p=get_param([obj.tifDutPath,'/',obj.blockName],'PortHandles');




            inports=find_system(obj.tifDutPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Inport');
            for i=1:numel(inports)
                name=get_param(inports{i},'Name');
                h=find_system([obj.tifDutPath,'/',obj.blockName,'/',name]);
                if isempty(h)
                    continue;
                end
                num=str2double(get_param([obj.tifDutPath,'/',obj.blockName,'/',name],'Port'));
                pos=get_param(p.Inport(num),'Position');
                set_param(inports{i},'Position',[pos,pos]+obj.inportBlkOffset);
                add_line(obj.tifDutPath,[name,'/1'],[obj.blockName,'/',num2str(num)]);
            end




            outports=find_system(obj.tifDutPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','Outport');
            for j=1:numel(outports)
                name=get_param(outports{j},'Name');
                h=find_system([obj.tifDutPath,'/',obj.blockName,'/',name]);
                if isempty(h)
                    continue;
                end
                num=str2double(get_param([obj.tifDutPath,'/',obj.blockName,'/',name],'Port'));
                pos=get_param(p.Outport(num),'Position');
                set_param(outports{j},'Position',[pos,pos]+obj.outportBlkOffset);
                add_line(obj.tifDutPath,[obj.blockName,'/',num2str(num)],[name,'/1']);
            end

        end

        function[status,result]=addTunableConstToModel(obj,status,result)
            tunableParamPortList=obj.hTurnkey.hTable.hTunableParamPortList;
            tunableParamNames=tunableParamPortList.TunableParamNameList;

            p=get_param([obj.tifDutPath,'/',obj.blockName],'PortHandles');
            for i=1:numel(tunableParamNames)
                name=tunableParamNames{i};
                h=find_system([obj.tifDutPath,'/',obj.blockName,'/',name]);
                if isempty(h)
                    continue;
                end
                num=str2double(get_param([obj.tifDutPath,'/',obj.blockName,'/',name],'Port'));
                pos=get_param(p.Inport(num),'Position');


                h=add_block('built-in/Constant',[obj.tifDutPath,'/tunable_const'],'MakeNameUnique','on');
                set_param(h,'Position',[pos,pos]+obj.constBlkOffset);
                name=get_param(h,'Name');
                add_line(obj.tifDutPath,[name,'/1'],[obj.blockName,'/',num2str(num)]);
            end
        end

        function[status,result]=addOutportTerminationToModel(obj,status,result)
        end




        function[status,result]=initModelGen(obj,status,result)


            hDI=obj.hTurnkey.hD;


            obj.current_system=get_param(0,'CurrentSystem');












            obj.hPir=pir(obj.current_system);



            obj.createTIFMdl;


            obj.cleanupTIFDUT;


            link=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',obj.tifMdlName,obj.tifMdlName);
            msg=message('hdlcommon:workflow:ModelGenMsgGenerateModel',obj.messageString,link);
            if hDI.cmdDisplay
                hdldisp(msg);
            else
                result=sprintf('%s\n%s',result,msg.getString);
            end
        end

        function[status,result]=finishModelGen(obj,status,result)


            hDI=obj.hTurnkey.hD;


            obj.setDefaultTIFMdlParams;


            obj.annotateTIFMdl;


            obj.openTIFModel;


            hdlresetgcb(obj.current_system);

            runInterfaceSpecificModelGeneration(obj);


            if status&&hDI.isIPCoreGen
                [status2,log2]=hdlturnkey.plugin.runCallbackPostSWInterface(hDI);
                if hDI.cmdDisplay
                    if status2
                        if~isempty(log2)
                            hdldisp(log2);
                        end
                    else
                        msg=message('hdlcommon:workflow:ReferenceDesignPostSWCallback',log2);
                        error(msg);
                    end
                elseif~isempty(log2)
                    result=sprintf('%s\n%s\n',result,log2);
                end
                status=status&&status2;
            end



            if status
                [status2,log2]=hdlturnkey.plugin.runBoardCallbackPostSWInterface(hDI);
                if hDI.cmdDisplay
                    if status2
                        if~isempty(log2)
                            hdldisp(log2);
                        end
                    else
                        msg=message('hdlcommon:workflow:BoardPostSWCallback',log2);
                        error(msg);
                    end
                elseif~isempty(log2)
                    result=sprintf('%s\n%s\n',result,log2);
                end
                status=status&&status2;
            end


            msg=message('hdlcommon:workflow:ModelGenMsgFinishModel',obj.messageString);
            if hDI.cmdDisplay
                hdldisp(msg);
            else
                result=sprintf('%s\n%s',result,msg.getString);
            end
        end

        function[status,result]=finishHostModelGen(obj,status,result)


            hDI=obj.hTurnkey.hD;


            obj.setDefaultTIFMdlParams;


            obj.annotateTIFMdl;


            obj.openTIFModel;


            hdlresetgcb(obj.current_system);


            msg=message('hdlcommon:workflow:ModelGenMsgFinishModel',obj.messageString);
            msg2=message('hdlcommon:workflow:HostInterfaceModelDataTypeCast');
            if hDI.cmdDisplay
                hdldisp(msg);
                hdldisp(msg2);
            else
                result=sprintf('%s\n%s\n%s',result,msg.getString,msg2.getString);
            end
        end

        function validateCell=generateInterfaceDrivers(obj)














            validateCell={};

            interfaceIDList=obj.hTurnkey.getSoftwareInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hHostInterface=obj.hTurnkey.getSoftwareInterface(interfaceID);
                validateCellInterface=hHostInterface.generateModelDriver(obj);
                validateCell=[validateCell,validateCellInterface];%#ok<AGROW>
            end
        end

        function validateCell=generateHostInterfaceDrivers(obj)
            validateCell={};

            interfaceIDList=obj.hTurnkey.getHostInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hHostInterface=obj.hTurnkey.getHostInterface(interfaceID);
                validateCellInterface=hHostInterface.generateHostModelDriver(obj);
                validateCell=[validateCell,validateCellInterface];%#ok<AGROW>
            end
        end

        function runInterfaceSpecificModelGeneration(obj)


            interfaceIDList=obj.hTurnkey.getSupportedInterfaceIDList;

            for ii=1:length(interfaceIDList)
                interfaceID=interfaceIDList{ii};
                hInterface=obj.hTurnkey.getInterface(interfaceID);

                if(hInterface.isInterfaceInUse(obj.hTurnkey))
                    hInterface.runInterfaceSpecificModelGeneration(obj);
                end
            end
        end

        function createTIFMdl(obj)





            obj.usrMdlName=obj.hTurnkey.hD.hCodeGen.ModelName;
            obj.tifMdlName=sprintf('gm_%s_%s',obj.usrMdlName,obj.MdlNamePostfix);


            hb=slhdlcoder.SimulinkBackEnd(obj.hPir,...
            'InModelFile',obj.usrMdlName,...
            'OutModelFile',obj.tifMdlName,...
            'ShowModel','no');


            emitMessage=false;
            isInterfaceModel=true;
            hb.createAndInitTargetModel(isInterfaceModel);


            obj.tifMdlName=hb.OutModelFile;


            obj.usrDutPath=obj.hTurnkey.hD.hCodeGen.getDutName;
            obj.tifDutPath=obj.getTIFDutPath;



            drawSrcModelDut=true;
            hb.drawTestBench(drawSrcModelDut,emitMessage);



            if downstream.tool.isDUTModelReference(obj.usrDutPath)


                inMdl=get_param(obj.usrDutPath,'ModelName');
                load_system(inMdl);
                hb=slhdlcoder.SimulinkBackEnd(obj.hPir,...
                'InModelFile',inMdl,...
                'OutModelFile',obj.tifDutPath,...
                'ShowModel','no');
                hb.createAndInitTargetModel(isInterfaceModel);
                hb.drawTestBench(drawSrcModelDut,emitMessage);
                dutName=getGmDutName(obj);
                set_param(dutName,'ModelName',hb.OutModelFile);
            end
        end

        function cleanupTIFDUT(obj)














            tifDutObj=get_param(obj.tifDutPath,'Object');


            dutTopLevelBlks=tifDutObj.Blocks;


            for ii=1:length(dutTopLevelBlks)
                dutTopBlk=obj.fixBlockName(dutTopLevelBlks{ii});

                dutTopBlkPath=obj.getTIFDutBlkPath(dutTopBlk);
                blockType=obj.findBlockType(dutTopBlkPath);


                if strcmp(blockType,'Inport')||strcmp(blockType,'Outport')
                    continue;
                else
                    delete_block(dutTopBlkPath);
                end
            end


            dutTopLevelLines=tifDutObj.Lines;


            for ii=1:length(dutTopLevelLines)
                line=dutTopLevelLines(ii);
                delete_line(line.Handle);
            end
        end

        function setDefaultTIFMdlParams(obj)



            set_param(obj.getTIFDutMdlName,'HardwareBoardFeatureSet','EmbeddedCoderHSP');
        end


        function annotateTIFMdl(obj)



            noteBlkPath=obj.getTIFDutBlkPath('note');
            obj.insertNoteBlk(noteBlkPath);


            noteBlkPath=obj.getTIFMdlBlkPath('note');
            obj.insertNoteBlk(noteBlkPath);
        end

        function insertNoteBlk(obj,noteBlkPath)
            blkName=sprintf('Generated by HDL Workflow Advisor on %s',datestr(now));
            setupBlkPos=obj.setupBlkPosition;
            noteBlkPos=[setupBlkPos(1)+400,35,setupBlkPos(3)+600,35];
            add_block('built-in/Note',noteBlkPath,'Name',blkName,'Position',noteBlkPos);
        end

        function createSubsystemOnTopLevel(obj)

            cmodelDutPath=obj.tifDutPath;
            if downstream.tool.isDUTTopLevel(cmodelDutPath)
                allBlks=find_system(cmodelDutPath,'SearchDepth',1);
                allBlksExTop=allBlks(~strcmp(allBlks,cmodelDutPath));
                blkHandles=get_param(allBlksExTop,'handle');

                Simulink.BlockDiagram.createSubSystem([blkHandles{:}]);

                postSubsys=find_system(cmodelDutPath,'SearchDepth',1,'BlockType','SubSystem','ReferenceBlock','');
                postSubsystem=postSubsys{1};
                hwmodelName=obj.usrMdlName;
                set_param(postSubsystem,'Name',hwmodelName);

                newSubsys=find_system(cmodelDutPath,'SearchDepth',1,'BlockType','SubSystem','ReferenceBlock','');
                obj.tifDutPath=newSubsys{1};
            end
        end

        function dutPath=addTestPointPortsOnDUT(obj)






            dutPath=obj.tifDutPath;

            hTestPointPortList=obj.hTurnkey.hTable.hTestPointPortList;

            if~isempty(hTestPointPortList)

                hTestPointPorts=hTestPointPortList.TestPointPorts;
                numTestPointPorts=numel(hTestPointPorts);

                if numTestPointPorts>0






                    allBlks=find_system(dutPath,'SearchDepth',1);

                    allBlksExceptDUT=allBlks(~strcmp(allBlks,dutPath));

                    blkHandles=get_param(allBlksExceptDUT,'handle');

                    Simulink.BlockDiagram.createSubSystem([blkHandles{:}]);

                    subSystems=find_system(dutPath,'SearchDepth',1,'BlockType','SubSystem');

                    newSubsystemPath=subSystems(~strcmp(subSystems,dutPath));
                    newSubsystemPath=newSubsystemPath{1};

                    pos=get_param(newSubsystemPath,'Position');


                    portRateMap=containers.Map('KeyType','double','ValueType','any');
                    for ii=1:numTestPointPorts


                        hOutport=add_block('built-in/Outport',[newSubsystemPath,'/',hTestPointPorts{ii}.PortName]);

                        mapKey=hTestPointPorts{ii}.PortRate;
                        if isKey(portRateMap,mapKey)
                            mapVal=portRateMap(mapKey);
                            mapVal{end+1}=get_param(hOutport,'Port');%#ok<AGROW>
                            portRateMap(mapKey)=mapVal;
                        else
                            mapVal={get_param(hOutport,'Port')};
                            portRateMap(mapKey)=mapVal;
                        end
                    end


                    mapKeys=keys(portRateMap);
                    for ii=1:numel(mapKeys)

                        mapVals=portRateMap(mapKeys{ii});

                        hScope=add_block('simulink/Sinks/Scope',[dutPath,'/Scope',num2str(ii)],...
                        'NumInputPorts',num2str(numel(mapVals)),...
                        'Commented','on');
                        for jj=1:numel(mapVals)


                            add_line(dutPath,[get_param(newSubsystemPath,'Name'),'/',mapVals{jj}],...
                            [get_param(hScope,'Name'),'/',num2str(jj)],'autorouting','on');
                        end
                    end

                    obj.tifDutPath=newSubsystemPath;
                end
            end
        end

        function dutPath=createTunableConstantsUnderDUT(obj)

            dutPath=obj.tifDutPath;

            tunableParamPortList=obj.hTurnkey.hTable.hTunableParamPortList;

            tunableParamNames=tunableParamPortList.TunableParamNameList;

            if~isempty(tunableParamNames)



                allBlks=find_system(dutPath,'SearchDepth',1);

                allBlksExceptDUT=allBlks(~strcmp(allBlks,dutPath));

                blkHandles=get_param(allBlksExceptDUT,'handle');

                Simulink.BlockDiagram.createSubSystem([blkHandles{:}]);



                subSystems=find_system(dutPath,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'BlockType','SubSystem');
                newSubsystemPath=subSystems{2};


                newSubsystemPos=get_param(newSubsystemPath,'Position');
                newSubsystemPos(4)=newSubsystemPos(4)+10*numel(tunableParamNames);
                set_param(newSubsystemPath,'Position',newSubsystemPos);

                tunablePorts=containers.Map();


                for ii=1:numel(tunableParamNames)

                    portName=[newSubsystemPath,'/',tunableParamNames{ii}];
                    portHandle=add_block('built-in/Inport',portName);

                    dataType=tunableParamPortList.TunableParamSLTypeMap(tunableParamNames{ii});


                    portInfo=struct('SLPortHandle',portHandle,'dataType',dataType);

                    tunablePorts(tunableParamNames{ii})=portInfo;
                end



                slpir.PIR2SL.drawTunableConstBlocks(tunablePorts,get_param(newSubsystemPath,'Name'),dutPath);

                obj.tifDutPath=newSubsystemPath;
            end
        end


        function openTIFModel(obj)
            open_system(obj.tifMdlName);
        end

        function dutName=getGmDutName(obj)

            dutName=regexprep(obj.usrDutPath,obj.usrMdlName,...
            obj.tifMdlName,'once');
        end

        function dutName=getTIFDutPath(obj)


            if downstream.tool.isDUTModelReference(obj.usrDutPath)
                dutName=sprintf('gm_%s_%s',...
                get_param(obj.usrDutPath,'ModelName'),obj.MdlNamePostfix);
            else
                dutName=getGmDutName(obj);
            end
        end

        function mdlName=getTIFDutMdlName(obj)



            if downstream.tool.isDUTModelReference(obj.usrDutPath)
                mdlName=obj.getTIFDutPath;
            else
                mdlName=obj.tifMdlName;
            end
        end

        function blkName=fixBlockName(~,name)%#ok<*MANU>




            blkName=strrep(name,'/','//');
        end

        function blockType=findBlockType(~,blk)
            libBlocks=['SubSystem',' S-Function',' M-S-Function'];
            blockType=get_param(blk,'BlockType');
            if strfind(blockType,libBlocks)
                blockType=get_param(blk,'ReferenceBlock');
            end
        end

        function blkLibPath=getSLLibBlkPath(~,blkName)
            if strcmpi(blkName,'dtc')
                blkLibPath='built-in/DataTypeConversion';
            elseif strcmpi(blkName,'terminator')
                blkLibPath='built-in/Terminator';
            elseif strcmpi(blkName,'ground')
                blkLibPath='built-in/Ground';
            elseif strcmpi(blkName,'goto')
                blkLibPath='built-in/Goto';
            elseif strcmpi(blkName,'from')
                blkLibPath='built-in/From';
            elseif strcmpi(blkName,'note')
                blkLibPath='built-in/Note';
            else
                error(message('hdlcommon:workflow:UnsupportedMdlGenBlk',blkName));
            end
        end

        function[newBlkPath,newBlkName]=addBlockUnique(~,blkType,tgtBlkPath)

            blkH=add_block(blkType,tgtBlkPath,'MakeNameUnique','on');
            newBlkPath=getfullname(blkH);
            newBlkName=get_param(blkH,'Name');
        end

        function[newBlkPath,newBlkName]=addBlock(obj,srcBlkPath,destBlkPath,destBlkPos)

            [newBlkPath,newBlkName]=addBlockUnique(obj,srcBlkPath,destBlkPath);


            set_param(newBlkPath,'Position',destBlkPos);
            set_param(newBlkPath,'ShowName','off');
        end

        function tagName=getTagName(~,portName)

            tagName=sprintf('%s_tag',regexprep(portName,'\W','_'));
        end

        function addMaskOnDeviceUnderTestBlock(obj,dutPath)
            ipCoreName=obj.hTurnkey.hD.hIP.getIPCoreName;
            modelPath=obj.usrDutPath;


            set_param(dutPath,'MaskDescription',...
            sprintf(['This is an automatically generated subsystem block.\n'...
            ,'This contains the AXI interface blocks that communicate with the %s IPCore generated from %s subsystem.'],ipCoreName,modelPath),...
            'BackgroundColor','Cyan','ForegroundColor','Magenta');


            set_param(dutPath,'MaskDisplay',sprintf('disp(sprintf(''%s''));',obj.maskString));

            set_param(dutPath,'MaskIconOpaque','off');
            set_param(dutPath,'MaskHelp','');
            set_param(dutPath,'MaskType','AXI4-Lite/AXI4 Interface');

            set_param(dutPath,'Mask','on');
        end

        function customGMConfig(obj)



            hRD=obj.hTurnkey.hD.hIP.getReferenceDesignPlugin;
            rdPath=obj.hTurnkey.hD.hIP.getReferenceDesignPath;%#ok<NASGU>
            modelName=bdroot(obj.tifDutPath);%#ok<NASGU>

            if downstream.plugin.PluginBase.existPluginFile(...
                hRD.PluginPath,'plugin_gm_config')
                cmdStr=sprintf('%s.%s',hRD.PluginPackage,'plugin_gm_config(modelName, rdPath)');
                try
                    eval(cmdStr);
                catch me
                    rethrow(me);
                end
            end
        end

        function[status,result]=callCustomCallback(obj,ipcoreinfo,status,result)
            hDI=obj.hTurnkey.hD;
            [status2,log]=hdlturnkey.plugin.runCallbackSWModelGeneration(hDI,ipcoreinfo);
            if hDI.cmdDisplay
                if status2
                    hdldisp(log);
                else
                    warning(log);
                end
            else
                status=status&&status2;
                result=sprintf('%s\n%s\n',result,log);
            end
        end


    end


    methods
        function portPath=getTIFDutPort(obj,portName)
            portPath=obj.getTIFDutBlkPath(portName);
        end
    end


    methods(Static)
        function newBlockPath=addEmptySubSystemBlock(direction,refBlockPath,subSystemBlockName)


            subSystemLibBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('subsystem');
            subSystemBlockParams={};
            varargin={'ConnectBlocks',false,...
            'BlockName',subSystemBlockName};
            newBlockPath=hdlturnkey.backend.ModelGeneration.addLibraryBlock(subSystemLibBlock,direction,refBlockPath,subSystemBlockParams,varargin{:});
        end

        function newBlockPath=addBusElementPort(portDirection,refBlockPath,elementName,elementField)


            if strcmpi(portDirection,'In')
                busElementLibBlock='simulink/Signal Routing/Bus Element In';
            elseif strcmpi(portDirection,'Out')
                busElementLibBlock='simulink/Signal Routing/Bus Element Out';
            else
                error('Port direction must be ''In'' or ''Out''.');
            end
            busElementBlockPath=[refBlockPath,'/',elementName];
            busElementBlockParams={'Element',elementField};
            newBlockPath=hdlturnkey.backend.ModelGeneration.addBlockAtPath(busElementLibBlock,busElementBlockPath,busElementBlockParams);
        end
    end


    methods(Static)





















        function[newBlockPath,hLine]=addGroundBlock(direction,refBlockPath,varargin)
            hdlturnkey.backend.ModelGeneration.validateDirection(direction,'Left');

            groundLibBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('ground');
            groundBlockParams={};
            [newBlockPath,hLine]=hdlturnkey.backend.ModelGeneration.addLibraryBlock(groundLibBlock,direction,refBlockPath,groundBlockParams,varargin{:});
        end

        function[newBlockPath,hLine]=addTerminatorBlock(direction,refBlockPath,varargin)
            hdlturnkey.backend.ModelGeneration.validateDirection(direction,'Right');

            termLibBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('terminator');
            termBlockParams={};
            [newBlockPath,hLine]=hdlturnkey.backend.ModelGeneration.addLibraryBlock(termLibBlock,direction,refBlockPath,termBlockParams,varargin{:});
        end

        function[newBlockPath,hLine]=addConstantBlock(direction,refBlockPath,value,outputDataType,varargin)
            hdlturnkey.backend.ModelGeneration.validateDirection(direction,'Left');

            constLibBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('constant');
            constBlockParams={...
            'Value',num2str(value),...
            'OutDataTypeStr',fixdt(outputDataType),...
            'SampleTime','-1'};
            [newBlockPath,hLine]=hdlturnkey.backend.ModelGeneration.addLibraryBlock(constLibBlock,direction,refBlockPath,constBlockParams,varargin{:});
        end

        function[newBlockPath,hLine]=addDTCBlock(direction,refBlockPath,outputDataType,varargin)
            dtcLibBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('dtc');
            dtcBlockParams={...
            'OutDataTypeStr',fixdt(outputDataType),...
            'ConvertRealWorld','Stored Integer (SI)'};

            [newBlockPath,hLine]=hdlturnkey.backend.ModelGeneration.addLibraryBlock(dtcLibBlock,direction,refBlockPath,dtcBlockParams,varargin{:});
        end

        function[newBlockPath,hLine]=addFloatTypecastBlock(direction,refBlockPath,varargin)
            floattypecastLibBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('floattypecast');
            [newBlockPath,hLine]=hdlturnkey.backend.ModelGeneration.addLibraryBlock(floattypecastLibBlock,direction,refBlockPath,varargin{:});
        end

        function[newBlockPath,hLine]=addBitConcatBlock(direction,refBlockPath,numInputs,varargin)
            concatLibBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('bitconcat');
            concatBlockParams={...
            'numInputs',num2str(numInputs)};

            [newBlockPath,hLine]=hdlturnkey.backend.ModelGeneration.addLibraryBlock(concatLibBlock,direction,refBlockPath,concatBlockParams,varargin{:});
        end

        function[newBlockPath,hLine]=addBitSliceBlock(direction,refBlockPath,msb,lsb,varargin)
            sliceLibBlock=hdlturnkey.backend.ModelGeneration.getLibBlockPath('bitslice');
            sliceBlockParams={...
            'lidx',num2str(msb),...
            'ridx',num2str(lsb)};

            [newBlockPath,hLine]=hdlturnkey.backend.ModelGeneration.addLibraryBlock(sliceLibBlock,direction,refBlockPath,sliceBlockParams,varargin{:});
        end

        function[newBlockPath,hLine]=addLibraryBlock(libPath,direction,refBlockPath,newBlockParams,varargin)
            if nargin<4
                newBlockParams={};
            end

            p=inputParser;
            p.KeepUnmatched=true;
            p.addParameter('SourceBlockPort',1);
            p.addParameter('DestBlockPort',1);
            p.addParameter('BlockParams',{});
            p.addParameter('ConnectBlocks',true);

            p.parse(varargin{:});

            srcBlockPortNum=p.Results.SourceBlockPort;
            destBlockPortNum=p.Results.DestBlockPort;
            additionalBlockParams=p.Results.BlockParams;
            connectBlocks=p.Results.ConnectBlocks;

            extraArgs=p.Unmatched;


            blockParams=[newBlockParams,additionalBlockParams];
            if strcmpi(direction,'Left')

                newBlockPath=hdlturnkey.backend.ModelGeneration.addBlockLeft(libPath,refBlockPath,blockParams,extraArgs);

                if connectBlocks
                    hLine=hdlturnkey.backend.ModelGeneration.connectBlocks(newBlockPath,refBlockPath,srcBlockPortNum,destBlockPortNum);
                end
            elseif strcmpi(direction,'Right')

                newBlockPath=hdlturnkey.backend.ModelGeneration.addBlockRight(libPath,refBlockPath,blockParams,extraArgs);

                if connectBlocks
                    hLine=hdlturnkey.backend.ModelGeneration.connectBlocks(refBlockPath,newBlockPath,srcBlockPortNum,destBlockPortNum);
                end
            else
                error('Direction must be ''Left'' or ''Right''.');
            end


        end
    end













    methods(Static)

        function hLine=connectBlocks(srcBlockPath,destBlockPath,srcBlkPortNum,destBlkPortNum,autorouteOption)
            if nargin<5
                autorouteOption='smart';
            end
            if nargin<4
                destBlkPortNum=1;
            end
            if nargin<3
                srcBlkPortNum=1;
            end



            srcBlkSysPath=hdlturnkey.backend.ModelGeneration.getSurroundingSystemName(srcBlockPath);
            srcBlkPorts=get_param(srcBlockPath,'PortHandles');

            destBlkSysPath=hdlturnkey.backend.ModelGeneration.getSurroundingSystemName(destBlockPath);
            destBlkPorts=get_param(destBlockPath,'PortHandles');

            assert(isequal(srcBlkSysPath,destBlkSysPath),'The source and destination blocks must at the same level in the system to connect them with a signal line.');

            srcBlockPort=srcBlkPorts.Outport(srcBlkPortNum);
            destBlockPort=destBlkPorts.Inport(destBlkPortNum);
            hLine=add_line(srcBlkSysPath,srcBlockPort,destBlockPort,'Autorouting',autorouteOption);
        end

        function newBlockPath=addBlockLeft(libPath,refBlockPath,newBlockParams,varargin)

            if nargin<3
                newBlockParams={};
            end


            newBlockPath=hdlturnkey.backend.ModelGeneration.addBlockInDirection(libPath,'Left',refBlockPath,newBlockParams,varargin{:});
        end

        function newBlockPath=addBlockRight(libPath,refBlockPath,newBlockParams,varargin)

            if nargin<3
                newBlockParams={};
            end


            newBlockPath=hdlturnkey.backend.ModelGeneration.addBlockInDirection(libPath,'Right',refBlockPath,newBlockParams,varargin{:});
        end

        function newBlockPath=addBlockInDirection(libPath,direction,refBlockPath,newBlockParams,varargin)
            if nargin<4
                newBlockParams={};
            end

            p=inputParser;
            p.addParameter('BlockName',hdlturnkey.backend.ModelGeneration.getNewBlockName(libPath));
            p.addParameter('BlockSpace',hdlturnkey.backend.ModelGeneration.BlockSpace);
            p.addParameter('BlockSize',[hdlturnkey.backend.ModelGeneration.BlockHeight,hdlturnkey.backend.ModelGeneration.BlockWidth]);

            p.parse(varargin{:});

            blockName=p.Results.BlockName;
            blockSpace=p.Results.BlockSpace;
            blockSize=p.Results.BlockSize;


            refBlockPos=get_param(refBlockPath,'Position');
            newBlockPos=hdlturnkey.backend.ModelGeneration.calculateBlockPosition(refBlockPos,direction,blockSpace,blockSize);
            newBlockParams=[newBlockParams,{'Position',newBlockPos}];


            newBlockPath=hdlturnkey.backend.ModelGeneration.getNewBlockPath(blockName,refBlockPath);
            showName=~any(strcmp(p.UsingDefaults,'BlockName'));
            newBlockPath=hdlturnkey.backend.ModelGeneration.addBlockAtPath(libPath,newBlockPath,newBlockParams,showName);
        end

        function newBlockPath=addBlockAtPath(libPath,newBlockPath,newBlockParams,showName)





            if nargin<4
                showName=false;
            end

            if nargin<3
                newBlockParams={};
            end

            blkH=add_block(libPath,newBlockPath,'MakeNameUnique','on');
            newBlockPath=getfullname(blkH);


            if~isempty(newBlockParams)
                set_param(newBlockPath,newBlockParams{:});
            end


            if~showName
                set_param(newBlockPath,'ShowName','off');
            end
        end

        function removeBlock(blockPath)
            delete_block(blockPath);
        end

        function newBlockPos=calculateBlockPosition(refBlockPos,direction,blockSpace,blockSize)




            smallBlock=false;
            if nargin<4
                if smallBlock
                    blockHeight=hdlturnkey.backend.ModelGeneration.BlockHeightSmall;
                    blockWidth=hdlturnkey.backend.ModelGeneration.BlockWidthSmall;
                else
                    blockHeight=hdlturnkey.backend.ModelGeneration.BlockHeight;
                    blockWidth=hdlturnkey.backend.ModelGeneration.BlockWidth;
                end
            else
                blockHeight=blockSize(1);
                blockWidth=blockSize(2);
            end


            if nargin<3
                blockSpace=hdlturnkey.backend.ModelGeneration.BlockSpace;
            end


            refSizeHeight=refBlockPos(4)-refBlockPos(2);
            refCenterHeightPos=refBlockPos(2)+floor(refSizeHeight/2);
            newBlockPosUp=refCenterHeightPos-floor(blockHeight/2);
            newBlockPosDown=refCenterHeightPos+floor(blockHeight/2);


            if strcmpi(direction,'Left')
                newBlockPosLeft=refBlockPos(1)-blockSpace-blockWidth;
                newBlockPosRight=refBlockPos(1)-blockSpace;
            elseif strcmpi(direction,'Right')
                newBlockPosLeft=refBlockPos(3)+blockSpace;
                newBlockPosRight=refBlockPos(3)+blockSpace+blockWidth;
            else
                error('Direction must be ''Left'' or ''Right''.');
            end


            newBlockPos=[newBlockPosLeft,newBlockPosUp,newBlockPosRight,newBlockPosDown];
        end


        function subsysPath=createSubsystem(blockList,subsysName,autoArrange)








            if isempty(blockList)
                subsysPath='';
                return;
            end

            if nargin<2
                subsysName='';
            end

            if nargin<3
                autoArrange=false;
            end



            surroundingSystem=hdlturnkey.backend.ModelGeneration.getSurroundingSystemName(blockList);
            assert(length(unique(surroundingSystem))==1,'All blocks must be at the same level in the system to convert them to a subsystem.');


            blockHandleList=get_param(blockList,'handle');
            blockHandleList=[blockHandleList{:}];


            Simulink.BlockDiagram.createSubsystem(blockHandleList);





            inportBlocks=strcmp(get_param(blockHandleList,'BlockType'),'Inport');
            outportBlocks=strcmp(get_param(blockHandleList,'BlockType'),'Outport');
            nonPortBlocks=blockHandleList(~(inportBlocks|outportBlocks));
            subsysPath=get_param(nonPortBlocks(1),'Parent');


            if~isempty(subsysName)
                subsysHandle=get_param(subsysPath,'handle');
                set_param(subsysHandle,'Name',subsysName);
                subsysPath=getfullname(subsysHandle);
            end


            if autoArrange
                hdlturnkey.backend.ModelGeneration.arrangeSystem(subsysPath);
            end
        end

        function arrangeSystem(sysPath)
            Simulink.BlockDiagram.arrangeSystem(sysPath);
        end



        function sysName=getSurroundingSystemName(blockPath)










            sysName=get_param(blockPath,'Parent');









        end

        function blockName=getBlockNameFromPath(blockPath)










            blockName=get_param(blockPath,'Name');









        end

        function blockPath=getBlockPathFromName(sysName,blockName)


            blockPath=[sysName,'/',blockName];
        end

        function blockLibPath=getLibBlockPath(blockName)
            if strcmpi(blockName,'dtc')




                blockLibPath='simulink/Signal Attributes/Data Type Conversion';
            elseif strcmpi(blockName,'terminator')
                blockLibPath='built-in/Terminator';
            elseif strcmpi(blockName,'ground')
                blockLibPath='built-in/Ground';
            elseif strcmpi(blockName,'constant')
                blockLibPath='built-in/Constant';
            elseif strcmpi(blockName,'goto')
                blockLibPath='built-in/Goto';
            elseif strcmpi(blockName,'from')
                blockLibPath='built-in/From';
            elseif strcmpi(blockName,'note')
                blockLibPath='built-in/Note';
            elseif strcmpi(blockName,'mux')
                blockLibPath='built-in/Mux';
            elseif strcmpi(blockName,'demux')
                blockLibPath='built-in/Demux';
            elseif strcmpi(blockName,'subsystem')
                blockLibPath='built-in/Subsystem';
            elseif strcmpi(blockName,'bitslice')
                blockLibPath='hdlsllib/Logic and Bit Operations/Bit Slice';
            elseif strcmpi(blockName,'bitconcat')
                blockLibPath='hdlsllib/Logic and Bit Operations/Bit Concat';
            elseif strcmpi(blockName,'floattypecast')
                blockLibPath='hdlsllib/HDL Floating Point Operations/Float Typecast';
            else
                error(message('hdlcommon:workflow:UnsupportedMdlGenBlk',blockName));
            end
        end

        function newBlockPath=getNewBlockPath(newBlockName,refBlockPath)








            topSystem=hdlturnkey.backend.ModelGeneration.getSurroundingSystemName(refBlockPath);



            newBlockPath=hdlturnkey.backend.ModelGeneration.getBlockPathFromName(topSystem,newBlockName);
        end

        function newBlockName=getNewBlockName(refBlockPath)



            try
                newBlockName=hdlturnkey.backend.ModelGeneration.getBlockNameFromPath(refBlockPath);
            catch




                [~,newBlockName]=fileparts(refBlockPath);
            end

            newBlockName=matlab.lang.makeValidName(newBlockName);
        end
    end


    methods(Static,Access=protected)
        function validateDirection(direction,requiredDirection)
            assert(strcmpi(direction,requiredDirection),'Direction must be %s.',requiredDirection);
        end
    end
end





