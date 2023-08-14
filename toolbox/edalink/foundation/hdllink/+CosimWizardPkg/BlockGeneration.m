



classdef BlockGeneration<CosimWizardPkg.StepBase
    properties
        mdlName;
    end
    methods
        function obj=BlockGeneration(WizardData)
            obj=obj@CosimWizardPkg.StepBase(WizardData);
            obj.mdlName=WizardData.workflowOverrideTargetSystem;
        end

        function WidgetGroup=getDialogSchema(this)





            autorun.Type='checkbox';
            autorun.Name='Automatically determine timescale at start of simulation';
            autorun.ObjectProperty='TimeScaleOpt';
            autorun.RowSpan=[1,1];
            autorun.ColSpan=[1,6];
            autorun.Tag='edaTimeScaleOpt';
            autorun.DialogRefresh=true;
            autorun.Mode=1;
            autorun.Visible=true;

            slText.Type='text';
            slText.Name='1 second in Simulink corresponds to';
            slText.Tag='edaSlText';
            slText.RowSpan=[2,2];
            slText.ColSpan=[1,2];
            slText.Alignment=7;
            slText.Enabled=~this.Wizard.TimeScaleOpt;

            tscale.Type='edit';
            tscale.Tag='edaTimingScaleFactor';
            tscale.RowSpan=[2,2];
            tscale.ColSpan=[3,3];
            tscale.ObjectProperty='TimingScaleFactor';
            tscale.Alignment=7;
            tscale.Enabled=~this.Wizard.TimeScaleOpt;

            hdlUnit.Type='combobox';
            hdlUnit.Tag='edaTimingMode';
            hdlUnit.RowSpan=[2,2];
            hdlUnit.ColSpan=[4,4];
            hdlUnit.ObjectProperty='TimingMode';
            hdlUnit.Alignment=5;
            hdlUnit.Mode=1;
            hdlUnit.Enabled=~this.Wizard.TimeScaleOpt;
            hdlUnit.Entries=this.Wizard.UserData.HdlTimeUnitNames;

            hdlText.Type='text';
            hdlText.Name='in the HDL simulator';
            hdlText.Tag='edaHdlText';
            hdlText.RowSpan=[2,2];
            hdlText.ColSpan=[5,5];
            hdlText.Alignment=5;
            hdlText.Enabled=~this.Wizard.TimeScaleOpt;

            spacer=createSpacer([3,6],[1,7],'edaSpacerBlockGeneration');


            WidgetGroup.LayoutGrid=[6,7];
            WidgetGroup.Items={autorun,slText,tscale,hdlUnit,hdlText,spacer};


            this.Wizard.UserData.CurrentStep=9;
        end

        function Description=getDescription(this)

            if~isempty(this.Wizard.workflowOverride)
                firstBulletPointSentence=[' - Inserts an HDL Cosimulation block configured to your specifications '...
                ,'into the current system.\n'];
            else
                firstBulletPointSentence=[' - Creates and opens a new Simulink model containing an HDL Cosimulation block '...
                ,'configured to your specifications.\n'];
            end
            Description=sprintf([...
'When you click Finish, the Cosimulation Wizard performs the following actions:\n'...
            ,firstBulletPointSentence...
            ,' - Generates the scripts to compile your HDL code and launch the HDL simulator according '...
            ,'to the choices you made with this assistant.\n'...
            ,' - (If you check the box below) Configures the HDL Cosimulation block to assist '...
            ,'you in setting the simulation timescale when you cosimulate with the generated '...
            ,'block for the first time. If you do not check the box below, the timescale is '...
            ,'set to the default of 1 Simulink second = 1 second in the HDL simulator, or you '...
            ,'may change it below.']);
        end
        function onBack(this,~)
            hasClk=~isempty(this.Wizard.UserData.ClkList);
            hasRst=~isempty(this.Wizard.UserData.RstList);
            hasOutput=~isempty(this.Wizard.UserData.UsedOutPortList);

            if(hasRst||hasClk)
                this.Wizard.NextStepID=8;
            elseif(hasOutput)
                this.Wizard.NextStepID=6;
            else
                this.Wizard.NextStepID=5;
            end


            this.Wizard.UserData.TimeScaleOpt=this.Wizard.TimeScaleOpt;
            this.Wizard.UserData.TimingScaleFactor=this.Wizard.TimingScaleFactor;
            this.Wizard.UserData.TimingMode=this.Wizard.TimingMode;
        end
        function EnterStep(this,~)
            this.mdlName=this.Wizard.workflowOverrideTargetSystem;
            this.Wizard.TimeScaleOpt=this.Wizard.UserData.TimeScaleOpt;
            this.Wizard.TimingScaleFactor=this.Wizard.UserData.TimingScaleFactor;
            this.Wizard.TimingMode=this.Wizard.UserData.TimingMode;
        end
        function onNext(this,dlg)

            if(~this.Wizard.TimeScaleOpt)
                assert(str2double(this.Wizard.TimingScaleFactor)>0,message('HDLLink:CosimWizard:NegativeScale'));
            end

            displayStatusMessage(this.Wizard,dlg,'Generating blocks ... Please wait.');


            onCleanupObj=CosimWizardPkg.disableButtonSet(this.Wizard,dlg);


            NumInPort=numel(this.Wizard.UserData.UsedInPortList);
            NumOutPort=numel(this.Wizard.UserData.UsedOutPortList);
            srcData=cell(NumInPort+NumOutPort,5);

            InPortNames=cell(1,NumInPort);
            for m=1:NumInPort
                InPortNames{m}=['/',this.Wizard.UserData.ModuleName,'/',this.Wizard.UserData.UsedInPortList{m}.Name,';'];
                srcData{m,3}='-1';
                srcData{m,4}=-1;
                srcData{m,5}='0';
            end

            OutPortNames=cell(1,NumOutPort);
            for m=1:NumOutPort

                OutPortNames{m}=['/',this.Wizard.UserData.ModuleName,'/',this.Wizard.UserData.UsedOutPortList{m}.Name,';'];
                portIdx=m+NumInPort;

                srcData{portIdx,3}=this.Wizard.UserData.UsedOutPortList{m}.SampleTime;


                switch this.Wizard.UserData.UsedOutPortList{m}.DataType
                case 0
                    srcData{portIdx,4}=-1;
                case 2
                    srcData{portIdx,4}=2;
                case 3
                    srcData{portIdx,4}=3;
                otherwise
                    if this.Wizard.UserData.UsedOutPortList{m}.Sign==0
                        srcData{portIdx,4}=0;
                    else
                        srcData{portIdx,4}=1;
                    end
                end


                if(strcmp(this.Wizard.UserData.UsedOutPortList{m}.FractionLength,'Inherit'))
                    srcData{portIdx,5}='0';
                else
                    srcData{portIdx,5}=this.Wizard.UserData.UsedOutPortList{m}.FractionLength;
                end
            end

            PortPaths=[InPortNames{:},OutPortNames{:}];
            PortModes=['[',repmat('1 ',1,NumInPort),repmat('2 ',1,NumOutPort),']'];
            PortTimes=['[',sprintf('%s,',srcData{:,3})];
            PortTimes(end)=']';
            PortSigns=['[',sprintf('%d,',srcData{:,4}),']'];
            PortFracLengths=['[',sprintf('%s,',srcData{:,5})];
            PortFracLengths(end)=']';

            if(this.Wizard.TimeScaleOpt)
                RunAutoTimeScale='on';
            else
                RunAutoTimeScale='off';
            end



            isSelectedByDefault=false;

            if~isempty(this.Wizard.workflowOverride)



                isSelectedByDefault=true;
                newBlkName=[this.mdlName,'/',this.Wizard.UserData.ModuleName];

                switch(this.Wizard.UserData.Simulator)
                case 'ModelSim'
                    libraryBlock='modelsimlib/HDL Cosimulation';
                case 'Xcelium'
                    libraryBlock='lfilinklib/HDL Cosimulation';
                case 'Vivado Simulator'
                    libraryBlock='vivadosimlib/HDL Cosimulation';
                end



                private_sl_add_block(libraryBlock,this.mdlName,0);







                cosimBlockHandle=find_system(this.mdlName,'FirstResultOnly','on','LookInsideSubsystemReference',false,'LookUnderMasks','none','ReferenceBlock',libraryBlock,'selected','on');
                cosimBlockPosition=get_param(cosimBlockHandle,'position');
                cosimBlockPosition=cosimBlockPosition{:};
                set_param(cosimBlockHandle{:},'Name',this.Wizard.UserData.ModuleName);




                blockPixelWidth=153;
                blockPixelHeight=41;
                xPixelSpacing=110;
                yTopPixelSpacing=23;
                yBottomPixelSpacing=34;

                compileBlockPosition=[cosimBlockPosition(3)+xPixelSpacing,...
                cosimBlockPosition(2)-yTopPixelSpacing,...
                cosimBlockPosition(3)+xPixelSpacing+blockPixelWidth,...
                cosimBlockPosition(2)-yTopPixelSpacing+blockPixelHeight];
                launchBlockPosition=[cosimBlockPosition(3)+xPixelSpacing,...
                cosimBlockPosition(4)+yBottomPixelSpacing-blockPixelHeight,...
                cosimBlockPosition(3)+xPixelSpacing+blockPixelWidth,...
                cosimBlockPosition(4)+yBottomPixelSpacing];

            else

                hModel=new_system(this.mdlName,'FromTemplate','factory_default_model');
                this.mdlName=get_param(hModel,'name');


                newBlkName=[this.mdlName,'/',this.Wizard.UserData.ModuleName];
                cosimBlockPosition=[65,83,175,187];

                switch(this.Wizard.UserData.Simulator)
                case 'ModelSim'
                    load_system('modelsimlib');
                    add_block('modelsimlib/HDL Cosimulation',newBlkName,...
                    'Position',cosimBlockPosition);
                case 'Xcelium'
                    load_system('lfilinklib');
                    add_block('lfilinklib/HDL Cosimulation',newBlkName,...
                    'Position',cosimBlockPosition);
                case 'Vivado Simulator'
                    load_system('vivadosimlib');
                    add_block('vivadosimlib/HDL Cosimulation',newBlkName,...
                    'Position',cosimBlockPosition);
                end










                compileBlockPosition=[285,60,438,101];
                launchBlockPosition=[285,180,438,221];


                open_system(this.mdlName);
            end


            PreSimTclCmd=genPreSimTclCmd(this.Wizard.UserData);
            PostSimTclCmd=genPostSimTclCmd(this.Wizard.UserData);


            set_param(newBlkName,...
            'PortPaths',PortPaths,...
            'PortModes',PortModes,...
            'PortTimes',PortTimes,...
            'PortSigns',PortSigns,...
            'PortFracLengths',PortFracLengths,...
            'CommLocal','on',...
            'AllowDirectFeedthrough','on',...
            'TimingScaleFactor',this.Wizard.TimingScaleFactor,...
            'TimingMode',this.Wizard.TimingMode,...
            'RunAutoTimescale',RunAutoTimeScale,...
            'TclPreSimCommand',PreSimTclCmd,...
            'TclPostSimCommand',PostSimTclCmd,...
            'PreRunTime',this.Wizard.UserData.ResetRunTimeStr,...
            'PreRunTimeUnit',this.Wizard.UserData.getHdlTimeUnitName);

            if this.Wizard.UserData.useSocket
                set_param(newBlkName,...
                'CommSharedMemory','off',...
                'CommPortNumber',num2str(this.Wizard.UserData.SocketPort));
            else
                set_param(newBlkName,...
                'CommSharedMemory','on');
            end


            compileScriptName=this.Wizard.UserData.genCompileScript();


            launchScriptName=this.Wizard.UserData.genSlLaunchScript();

            if strcmp(this.Wizard.Simulator,'Vivado Simulator')
                evalCmd=sprintf('eval(''%s'');',launchScriptName);

                l_CreateBlocks(this.mdlName,'Generate DLL',...
                'disp([''Double-click to'' char(10) ''regenerate HDL design DLL''])',...
                launchBlockPosition,evalCmd,isSelectedByDefault);

            else

                evalCmd=sprintf('eval(''%s'');',compileScriptName);
                l_CreateBlocks(this.mdlName,'Compile HDL Design',...
                'disp([''Double-Click to'' char(10) ''compile HDL files''])',...
                compileBlockPosition,evalCmd,isSelectedByDefault);

                evalCmd=sprintf('eval(''%s'');',launchScriptName);

                l_CreateBlocks(this.mdlName,'Launch HDL Simulator',...
                'disp([''Double-Click to'' char(10) ''launch HDL simulator''])',...
                launchBlockPosition,evalCmd,isSelectedByDefault);

            end



            numClks=numel(this.Wizard.UserData.ClkList);
            clocks=cell(1,numClks);
            for m=1:numClks
                clocks{m}=[['/',this.Wizard.UserData.ModuleName,'/',this.Wizard.UserData.ClkList{m}.Name,' '],...
                this.Wizard.UserData.ClkList{m}.Period,' ',...
                getHdlTimeUnitName(this.Wizard.UserData),';'];
            end
            if(numClks)
                set_param(newBlkName,...
                'HdlClocks',[clocks{:}]);
            else
                set_param(newBlkName,...
                'HdlClocks','');
            end






            if strcmp(this.Wizard.Simulator,'Vivado Simulator')
                [xsiPV,blkPV,~]=this.Wizard.UserData.genBlockAndObjParamValues(this.Wizard.TimingScaleFactor,this.Wizard.TimingMode);
                xsiData=createXsiData(xsiPV{:});
                set_param(newBlkName,blkPV{:},'UserData',xsiData);
            end





            this.Wizard.UserData.TimeScaleOpt=this.Wizard.TimeScaleOpt;
            this.Wizard.UserData.TimingScaleFactor=this.Wizard.TimingScaleFactor;
            this.Wizard.UserData.TimingMode=this.Wizard.TimingMode;

            matFileName=['cosimWizard_',this.Wizard.UserData.TopLevelName];
            cosimWizardInfo=this.Wizard.UserData;
            save(matFileName,'cosimWizardInfo');

            delete(onCleanupObj);


            if isempty(dlg)
                close_system(this.mdlName,1);
                this.Wizard.NextStepID=-1;
            else

                delete(dlg);

            end
        end
    end
end

function l_CreateBlocks(newMdlName,newBlkName,displayCmd,Position,Cmd,isSelectedByDefault)
    ssName=[newMdlName,'/',newBlkName];
    h=add_block('built-in/Subsystem',ssName,'MakeNameUnique','on');
    set_param(ssName,'Position',Position);
    o=get_param(ssName,'object');
    o.BackgroundColor='cyan';
    o.MaskDisplay=displayCmd;
    o.OpenFcn=Cmd;
    if isSelectedByDefault
        set_param(h,'Selected','on');
    end
end

function widget=createSpacer(rowSpan,colSpan,Tag)
    widget.Type='panel';
    widget.Tag=Tag;
    widget.RowSpan=rowSpan;
    widget.ColSpan=colSpan;
end


