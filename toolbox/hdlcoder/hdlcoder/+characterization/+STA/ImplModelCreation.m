classdef ImplModelCreation<handle




    properties
        m_portRegisters;
        m_currentImplObj;
        m_modelInfo;
    end

    methods

        function self=ImplModelCreation()
            self.m_portRegisters=[];
            self.m_currentImplObj=[];
            self.m_modelInfo=struct();
        end

        function[status,msg]=createImplModel(self,sourceBlockPath,sourceBlockImpl,implComp)
            status=1;

            cd(self.m_folders.tempDir);



            self.createModelInfo(sourceBlockPath,sourceBlockImpl{1},implComp{1});


            [status,msg]=self.createModel();

            if status==0
                return;
            end


            self.saveModelToGoldDir();


            if exist([self.m_modelInfo.modelName,'.slx'],'file')
                delete([self.m_modelInfo.modelName,'.slx']);
            end
        end

        function[status]=updateModel(self)
            status=1;
            try

                self.drawAndConnectPorts();
                save_system(self.m_modelInfo.modelName)



                self.instrumentBlock();
                save_system(self.m_modelInfo.modelName);
            catch
                close_system(self.m_modelInfo.modelName,0);
                status=0;
            end

        end

    end

    methods(Access=private)

        function createModelInfo(self,sourceBlockPath,sourceBlockImpl,implComp)

            self.m_modelInfo.implementation=sourceBlockImpl;


            self.m_modelInfo.component=implComp;


            sourceBlockTokens=regexp(sourceBlockPath,'.*/([^/]*)$','tokens','once');
            try
                sourceBlockName=sourceBlockTokens{1};
            catch
            end
            self.m_modelInfo.blockName=sourceBlockName;


            self.m_modelInfo.blockSource=sourceBlockPath;


            self.m_modelInfo.modelName='characterization_model';


            self.m_modelInfo.topSubsystem='toplevel_Characterization';


            self.m_modelInfo.blockSubsystem='BlockSubsystem';


            self.m_modelInfo.blockPath=[self.m_modelInfo.modelName,'/'...
            ,self.m_modelInfo.topSubsystem,'/',self.m_modelInfo.blockSubsystem,'/'...
            ,self.m_modelInfo.blockName];
        end

        function[status,msg]=createModel(self)

            status=1;
            msg="NA";
            close_system(self.m_modelInfo.modelName,0);

            try
                load_system('simulink');
                lib=regexp(self.m_modelInfo.blockSource,'^([^/]*)','tokens','once');
                load_system(lib{:});
            catch
                status=0;
                msg=sprintf("\nError loading block's library: %s",self.m_modelInfo.blockSource);
                return;
            end


            try
                self.buildBasicModelWithBlock();
            catch
                status=0;
                msg=sprintf("\nError creating model with block: %s",self.m_modelInfo.blockSource);
                return;
            end


            try
                evalc("hdlsetup(self.m_modelInfo.modelName);");
                hdlset_param(self.m_modelInfo.modelName,'TreatRealsInGeneratedCodeAs','Warning');
                set_param(self.m_modelInfo.modelName,'FixedStep','0.1');
                set_param(self.m_modelInfo.modelName,'StopTime','1');
                hdlset_param(self.m_modelInfo.modelName,'HDLSubsystem',self.m_modelInfo.modelName);
            catch
                status=0;
                msg=sprintf("\nError setting up %s's model.",self.m_modelInfo.blockSource);
                return;
            end


            save_system(self.m_modelInfo.modelName);
            close_system(self.m_modelInfo.modelName,0);

        end

        function success=checkModel(self)
            success=true;
            output=checkhdl([self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem]);
            for i=1:length(output)
                if(strcmpi(output(i).level,'error'))
                    error(output(i).level);
                    success=false;
                    return;
                end
            end
        end

        function buildBasicModelWithBlock(self)

            new_system(self.m_modelInfo.modelName);
            load_system(self.m_modelInfo.modelName);


            add_block('built-in/SubSystem',[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem]);


            add_block('built-in/SubSystem',[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/'...
            ,self.m_modelInfo.blockSubsystem]);


            add_block(self.m_modelInfo.blockSource,self.m_modelInfo.blockPath);
        end

        function drawAndConnectPorts(self)




            input_ports=get_param(self.m_modelInfo.blockPath,'InputSignalNames');
            for portNum=1:length(input_ports)

                add_block('built-in/Inport',[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',self.m_modelInfo.blockSubsystem,'/','Inport_',num2str(portNum)]);
                if(isempty(input_ports{portNum}))
                    add_line([self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',self.m_modelInfo.blockSubsystem],['Inport_',num2str(portNum),'/1'],...
                    [self.m_modelInfo.blockName,'/',num2str(portNum)]);
                end
            end


            output_ports=get_param(self.m_modelInfo.blockPath,'OutputSignalNames');
            for portNum=1:length(output_ports)

                add_block('built-in/Outport',[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',self.m_modelInfo.blockSubsystem,'/','Outport_',num2str(portNum)]);
                if(isempty(output_ports{portNum}))
                    add_line([self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',self.m_modelInfo.blockSubsystem],[self.m_modelInfo.blockName,'/',num2str(portNum)],...
                    ['Outport_',num2str(portNum),'/1']);
                end
            end




            port_info=get_param([self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',self.m_modelInfo.blockSubsystem],'Ports');
            for portNum=1:port_info(1)

                portname=['Inport_',num2str(portNum)];
                add_block('built-in/Inport',[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',portname]);

                add_line([self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem],[portname,'/1'],[self.m_modelInfo.blockSubsystem,'/',num2str(portNum)]);

            end

            for portNum=1:port_info(2)

                portname=['Outport_',num2str(portNum)];
                add_block('built-in/Outport',[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',portname]);

                add_line([self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem],[self.m_modelInfo.blockSubsystem,'/',num2str(portNum)],[portname,'/1']);
            end




            port_info=get_param([self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',self.m_modelInfo.blockSubsystem],'Ports');

            for i=1:port_info(1)

                portname=['Inport_',num2str(i)];
                add_block('built-in/Inport',[self.m_modelInfo.modelName,'/',portname]);

                add_line([self.m_modelInfo.modelName],[portname,'/1'],[self.m_modelInfo.topSubsystem,'/',num2str(i)]);
            end

            for i=1:port_info(2)

                portname=['Outport_',num2str(i)];
                add_block('built-in/Outport',[self.m_modelInfo.modelName,'/',portname]);

                add_line([self.m_modelInfo.modelName],[self.m_modelInfo.topSubsystem,'/',num2str(i)],[portname,'/1']);
            end

        end

        function regPath=insertRegister(self,regName,lineHandle,srcId,destId)


            topSubsystem=[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem];
            regPath=[topSubsystem,'/',regName];
            add_block('built-in/UnitDelay',regPath);


            srcPortHandleName=strrep([getfullname(get(lineHandle,'SrcPortHandle')),int2str(srcId)],...
            [topSubsystem,'/'],'');
            destPortHandleName=strrep([getfullname(get(lineHandle,'DstPortHandle')),int2str(destId)],...
            [topSubsystem,'/'],'');


            delete_line(lineHandle);


            add_line(topSubsystem,srcPortHandleName,[regName,'/1']);
            add_line(topSubsystem,[regName,'/1'],destPortHandleName);
        end

        function instrumentBlock(self)

            blockSubsystemPath=[self.m_modelInfo.modelName,'/',self.m_modelInfo.topSubsystem,'/',self.m_modelInfo.blockSubsystem];

            t1=containers.Map('keyType','uint32','valueType','any');
            t2=containers.Map('keyType','uint32','valueType','any');
            self.m_portRegisters=struct('in',t1,'out',t2);


            lineHandles=get_param(blockSubsystemPath,'LineHandles');


            for lineHandleIndex=1:numel(lineHandles.Inport)
                regName=['CharacterizationRegisterInport_',int2str(lineHandleIndex-1),'_RED'];
                regFullName=self.insertRegister(regName,lineHandles.Inport(lineHandleIndex),1,lineHandleIndex);
                set_param(regFullName,'SampleTime','-1');
                t1(lineHandleIndex)=regName;
            end


            for lineHandleIndex=1:numel(lineHandles.Outport)
                regName=['CharacterizationRegisterOutport_',int2str(lineHandleIndex-1),'_RED'];
                regFullName=self.insertRegister(regName,lineHandles.Outport(lineHandleIndex),lineHandleIndex,1);
                set_param(regFullName,'SampleTime','-1');
                t2(lineHandleIndex)=regName;
            end

        end

        function saveModelToGoldDir(self,~)
            copyfile([self.m_modelInfo.modelName,'.slx'],self.m_folders.goldDir);
        end

    end
end



