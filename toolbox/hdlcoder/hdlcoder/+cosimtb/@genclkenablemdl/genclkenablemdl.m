classdef genclkenablemdl<cosimtb.gencosim

















    methods








        function this=genclkenablemdl(varargin)
            this=this@cosimtb.gencosim(varargin{:});
        end



        function linkSuffix=getCurrentLinkOpt(~)
            linkSuffix='cegen';
        end



        function libName=getLibraryName(~)


            libName='dummy_xxx';
        end



        function hl=checkEDALinkLicense(~)
            hl=true;
        end



        function addFromDutToCosimSSOutput(~,~,~,~,~)
        end



        function createLinkBlock(~)
        end


        function addLaunchBox(~)
        end


        function configureCEModel(this)
            tbSys=this.getTestbenchSystem;
            cosimMdlDutPath=this.getCosimDutPath;
            cosimMdlDutH=get_param(cosimMdlDutPath,'handle');
            if this.hSLHDLCoder.DUTMdlRefHandle>0
                variants=get_param(cosimMdlDutH,'Variants');
                referredModel=variants(2).ModelName;

                save_system(referredModel,[],'OverWriteIfChangedOnDisk',true);

                set_param(cosimMdlDutH,'Variant','off');
                set_param(cosimMdlDutH,'ModelNameDialog',referredModel);

                set_param(cosimMdlDutH,'LoadFcn','');
            end

            if this.getDutHasTunableInputs
                error(message('hdlcoder:cosim:edacosimtunable'));
            end



            orientation=get_param(cosimMdlDutH,'Orientation');
            if strcmp(orientation,'left')
                orientation='right';
            else
                orientation='left';
            end
            set_param(cosimMdlDutH,'Orientation',orientation);


            newPos=this.getLinkBlockPos;
            set_param(cosimMdlDutPath,'Position',newPos);



            allGmBlocks=find_system(tbSys,'SearchDepth',1);
            allGmBlocks=allGmBlocks(~strcmp(allGmBlocks,tbSys));
            allGmBlocks=allGmBlocks(~strcmp(allGmBlocks,cosimMdlDutPath));

            allGmBlockH=zeros(1,numel(allGmBlocks));
            for ii=1:numel(allGmBlocks)
                allGmBlockH(ii)=get_param(allGmBlocks{ii},'handle');
            end
            Simulink.BlockDiagram.createSubSystem(allGmBlockH);


            allSS=find_system(tbSys,'SearchDepth',1,'BlockType','SubSystem');
            TBSS=allSS{~strcmp(allSS,cosimMdlDutPath)};

            add_block('built-in/EnablePort',[TBSS,'/clken']);




            allGmBlocks=find_system(cosimMdlDutH,'SearchDepth',1);
            allGmBlocks=allGmBlocks(allGmBlocks~=cosimMdlDutH);
            Simulink.BlockDiagram.createSubSystem(allGmBlocks);
            allSS=find_system(cosimMdlDutH,'SearchDepth',1,'BlockType','SubSystem');
            newSS=allSS(allSS~=cosimMdlDutH);
            set_param(newSS,'Name',this.getCosimDutName);



...
...
...
...
...
...
...
...
...
...
...
...
...

            ceName=this.hSLHDLCoder.getParameter('clockenablename');
            termName=[ceName,'_term'];
            dutCEPort=add_block('built-in/InPort',...
            [cosimMdlDutPath,'/',ceName],'Port','1');
            pos=get_param(dutCEPort,'Position');
            pos=pos+[0,-58,-20,-92];
            set_param(dutCEPort,'Position',pos)
            add_block('built-in/Terminator',...
            [cosimMdlDutPath,'/',termName],'Position',pos+[95,0,80,0]);
            add_line(cosimMdlDutPath,[ceName,'/1'],[termName,'/1']);


            origDUT=[cosimMdlDutPath,'/',this.getCosimDutName];
            hdlset_param(origDUT,'Architecture','BlackBox')
            hdlset_param(origDUT,'AddClockEnablePort','off')


            pos=get_param(cosimMdlDutPath,'Position');
            pos=[pos(1)-300,pos(2),pos(1)-270,pos(2)+30];
            st=this.hPir.getDutSampleTimes;
            st=st(1);
            unr=add_block('simulink/Sources/Uniform Random Number',...
            [tbSys,'/UNR'],'Position',pos,'Minimum','0',...
            'Maximum','10','SampleTime',sprintf('%g',st));


            pos=pos+[60,0,60,0];
            dtc=add_block('built-in/DataTypeConversion',[tbSys,'/DTC'],...
            'Position',pos,'OutDataTypeStr','fixdt(0,1,0)',...
            'RndMeth','Nearest','DoSatur','on','Name',[ceName,'_src']);
            dtcPort=[get_param(dtc,'Name'),'/1'];
            add_line(tbSys,[get_param(unr,'Name'),'/1'],dtcPort);



            di=this.getDutSrcAndSinkPorts(cosimMdlDutPath);
            add_line(tbSys,dtcPort,di{1},'autorouting','on');
            phan=get_param(TBSS,'PortHandles');
            enbPort=this.getPortParentNames({phan.Enable});
            add_line(tbSys,dtcPort,enbPort{:},'autorouting','on');
        end


        function doIt(this)
            hasLicense=this.checkEDALinkLicense;
            if hasLicense
                current_system=get_param(0,'CurrentSystem');

                this.validateModel;

                this.generateLinkModel;
                open_system(this.cosimMdlName);

                hdlresetgcb(current_system);
            else
                warning(message('hdlcoder:cosim:edacosimlicenseissue','generatecosimmodel'));
            end
        end
    end
end
