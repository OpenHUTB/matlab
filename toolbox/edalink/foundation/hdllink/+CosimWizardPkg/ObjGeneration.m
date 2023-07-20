

classdef ObjGeneration<CosimWizardPkg.StepBase
    properties
        mdlName;
    end
    methods
        function obj=ObjGeneration(WizardData)
            obj=obj@CosimWizardPkg.StepBase(WizardData);
            obj.mdlName='untitled';
        end

        function WidgetGroup=getDialogSchema(this)

            selectTimeUnit=getHdlTimeUnitName(this.Wizard.UserData);

            stime.Type='edit';
            stime.Name=['HDL Simulator sampling period (',selectTimeUnit,'):'];
            stime.Tag='edaSampleTimeOpt';
            stime.RowSpan=[2,2];
            stime.ColSpan=[1,1];
            stime.ObjectProperty='SampleTimeOpt';
            stime.Alignment=7;

            spacer=createSpacer([3,6],[1,7],'edaSpacerMlObjGeneration');


            WidgetGroup.LayoutGrid=[6,7];
            WidgetGroup.Items={stime,spacer};


            this.Wizard.UserData.CurrentStep=9;
        end

        function Description=getDescription(~)

            Description=sprintf([...
'When you click Finish, the Cosimulation Wizard performs the following actions:\n'...
            ,' - Creates a derived HDL Cosimulation system object class configured to your specifications.\n'...
            ,' - Generates the scripts to compile your HDL code and launch the HDL simulator according '...
            ,'to the choices you made with this assistant.\n']);
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
        end
        function EnterStep(this,~)
            this.Wizard.SampleTimeOpt=getHdlBaseRatePeriod(this.Wizard.UserData);
            return;
        end
        function onNext(this,dlg)

            assert(str2double(this.Wizard.SampleTimeOpt)>=0,message('HDLLink:CosimWizard:NegativeScale'));


            displayStatusMessage(this.Wizard,dlg,'Generating system object ... Please wait.');


            onCleanupObj=CosimWizardPkg.disableButtonSet(this.Wizard,dlg);


            NumInPort=numel(this.Wizard.UserData.UsedInPortList);
            NumOutPort=numel(this.Wizard.UserData.UsedOutPortList);

            InputSignalsStr='''''';%#ok<*NASGU> 
            if(NumInPort)
                InputSignalsStr='{';
                for m=1:NumInPort
                    SignalStr=['''/',this.Wizard.UserData.ModuleName,'/',this.Wizard.UserData.UsedInPortList{m}.Name,''''];
                    InputSignalsStr=[InputSignalsStr,SignalStr];%#ok<*AGROW> 
                    if(m~=NumInPort)
                        InputSignalsStr=[InputSignalsStr,','];
                    end
                end
                InputSignalsStr=[InputSignalsStr,'}'];
            end

            OutputSignalsStr='''''';
            OutputDataTypesStr='''''';
            OutputSignedStr='false';
            OutputFractionLengthsStr='0';

            if(NumOutPort)

                OutputSignalsStr='{';
                OutputDataTypesStr='{';
                OutputSignedStr='[';
                OutputFractionLengthsStr='[';

                for m=1:NumOutPort
                    SignalStr=['''/',this.Wizard.UserData.ModuleName,'/',this.Wizard.UserData.UsedOutPortList{m}.Name,''''];
                    switch this.Wizard.UserData.UsedOutPortList{m}.DataType
                    case 0
                        DataTypeStr='''fixedpoint''';
                    case 1
                        DataTypeStr='''double''';
                    case 2
                        DataTypeStr='''single''';
                    otherwise
                        DataTypeStr='''fixedpoint''';
                    end

                    if cast(this.Wizard.UserData.UsedOutPortList{m}.Sign,'logical')
                        SignStr='true';
                    else
                        SignStr='false';
                    end
                    FracStr=this.Wizard.UserData.UsedOutPortList{m}.FractionLength;

                    OutputSignalsStr=[OutputSignalsStr,SignalStr];
                    OutputDataTypesStr=[OutputDataTypesStr,DataTypeStr];
                    OutputSignedStr=[OutputSignedStr,SignStr];
                    OutputFractionLengthsStr=[OutputFractionLengthsStr,FracStr];

                    if(m~=NumOutPort)
                        OutputSignalsStr=[OutputSignalsStr,','];
                        OutputDataTypesStr=[OutputDataTypesStr,','];
                        OutputSignedStr=[OutputSignedStr,','];
                        OutputFractionLengthsStr=[OutputFractionLengthsStr,','];
                    end
                end

                OutputSignalsStr=[OutputSignalsStr,'}'];
                OutputSignedStr=[OutputSignedStr,']'];
                OutputDataTypesStr=[OutputDataTypesStr,'}'];
                OutputFractionLengthsStr=[OutputFractionLengthsStr,']'];
            end

            hdlTimeUnit=this.Wizard.UserData.getHdlTimeUnitName;

            SampleTimeStr=['{',this.Wizard.SampleTimeOpt,',''',hdlTimeUnit,'''}'];
            PreRunTimeStr=['{',this.Wizard.UserData.ResetRunTimeStr,',''',hdlTimeUnit,'''}'];

            if strcmp(this.Wizard.UserData.Simulator,'Vivado Simulator')





                [xsiPV,~,sysobjRawClkInfo]=this.Wizard.UserData.genBlockAndObjParamValues(this.Wizard.SampleTimeOpt,this.Wizard.UserData.getHdlTimeUnitName);


                xsiHeader={
'% The parameters and properties in this file were derived from running the '
'% cosimulation wizard.'
'%'
'% The following information should not be changed here but rather should be'
'% updated by reinvoking the wizard to create a new system object creation script:'
'% - The call to createXsiData and the resulting xsiData object.'
'% - HDLSimulator, XSIData properties'
'% - InputSignals, OutputSignals, ClockResetSignals properties'
'%'
'% The following properties are changeable here though rerunning the wizard'
'% is still recommended:'
'% - OutputSigned, OutputDataTypes, OutputFraciontLengths'
'% - ClockResetTypes, ClockResetTimes'
'% - PreRunTime, SampleTime'
'%'
'% To change the debug instrumentation of the HDL design DLL, edit the debug'
'% option in the ''hdlverifier_gendll.tcl'' script and reinvoke its MATLAB'
'% wrapper function ''hdlverifier_gendll_<TOP>.m''. Note that debug instrumentation '
'% will impact performance and could even lead to machine stability issues for'
'% very large designs.'
'% - ''off''  : no debug instrumentation'
'% - ''wave'' : data values for all ports and internal signals will be captured'
'%              to the waveform db file'
                };
                xsiAsStringMap=containers.Map(...
                {'design','lang','prec','types','dims','rstnames','rstvals','rstdurs'},...
                {'string','string','string','cellOfStrings','cellOfMat','cellOfStrings','cellOfNums','cellOfNums'});

                xsiPVStr=sprintf('%s\n',xsiHeader{:});
                xsiPVStr=[xsiPVStr,'xsiData = createXsiData( ...',newline];
                for idx=1:2:length(xsiPV)
                    p=xsiPV{idx};
                    v=xsiPV{idx+1};
                    xsiPVStr=[xsiPVStr,sprintf('\t''%s'', %s, ...\n',p,l_asString(v,xsiAsStringMap(p)))];
                end
                xsiPVStr(end-5)=' ';
                xsiPVStr=[xsiPVStr,');',newline];


                [crsi,crty,crti]=deal(sysobjRawClkInfo{:});


                crtyStrVals=cellfun(@(x)(hdllinkddg.ClockResetRowSource.convertPropValue('edge',x)),crty,'UniformOutput',false);


                crtiWithUnits=cellfun(@(x)({x,hdlTimeUnit}),crti,'UniformOutput',false);

                if isempty(crsi)
                    ClockResetSignalsStr=l_asString('','string');
                else
                    ClockResetSignalsStr=l_asString(crsi,'cellOfStrings');
                end
                if isempty(crtyStrVals)
                    ClockResetTypesStr=l_asString('','string');
                else
                    ClockResetTypesStr=l_asString(crtyStrVals,'cellOfStrings');
                end
                if isempty(crtiWithUnits)
                    ClockResetTimesStr=l_asString('','string');
                else
                    ClockResetTimesStr=l_asString(crtiWithUnits,'cellOfCellOfTimes');
                end

                XSIDataStr='xsiData';
            else
                PreSimTclCmd=genPreSimTclCmd(this.Wizard.UserData);
                PreSimTclCmd=strrep(PreSimTclCmd,newline,' ');
                TCLPreSimulationCommandStr=['''',PreSimTclCmd,''''];
                PostSimTclCmd=genPostSimTclCmd(this.Wizard.UserData);
                PostSimTclCmd=strrep(PostSimTclCmd,newline,' ');
                TCLPostSimulationCommandStr=['''',PostSimTclCmd,''''];

                if this.Wizard.UserData.useSocket
                    ConnectionStr=['{''Socket'',',num2str(this.Wizard.UserData.SocketPort),'}'];
                else
                    ConnectionStr='{''SharedMemory''}';
                end


            end

            HdlTopLevel=this.Wizard.UserData.ModuleName;
            FuncName=['hdlcosim_',this.Wizard.UserData.ModuleName];
            FileName=[FuncName,'.m'];

            TemplateFileName=fullfile(matlabroot,'toolbox','edalink',...
            'foundation','hdllink','hdlcosim_template.m');
            TemplateContent=fileread(TemplateFileName);
            TemplateContent=regexprep(TemplateContent,'hdlcosim_template',FuncName);
            TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_HDL_TOPLEVEL',HdlTopLevel);
            TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_FILENAME',FileName,'once');
            TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_DATESTR',datestr(now),'once');





            HDLSimulatorStr=this.Wizard.UserData.Simulator;
            switch(HDLSimulatorStr)
            case 'Vivado Simulator'
                propList=[{'HDLSimulator'},hdlverifier.VivadoHDLCosimulation.getDisplayPropertiesImpl];
                TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_XSIDATA_INST',xsiPVStr,'once');
            otherwise
                propList=hdlverifier.HDLCosimulation.getDisplayPropertiesImpl;
                TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_XSIDATA_INST','','once');
            end
            HDLSimulatorStr=['''',HDLSimulatorStr,''''];
            pvListCell=cellfun(@(x)(sprintf('''%s'', %s, ...',x,evalin('caller',[x,'Str']))),propList,'UniformOutput',false);
            pvListStr=sprintf('\t%s\n',pvListCell{:});
            pvListStr=strip(pvListStr,'right');
            pvListStr(end-4:end)='  ...';
            TemplateContent=regexprep(TemplateContent,'REPLACE_WITH_SYSOBJ_INST_PV_PAIRS',pvListStr,'once');



            Overwrite=true;
            if(exist(fullfile(pwd,FileName),'file')==2)
                if isempty(dlg)
                    Overwrite=false;
                else
                    Question=['File ',FileName,' exists in current directory. '...
                    ,'Do you want to overwrite it?'];

                    Answer=questdlg(Question,'Overwrite Existing File','Yes','No','No');
                    if(strcmp(Answer,'No'))
                        Overwrite=false;
                    end
                end
            end
            if(Overwrite)
                [fid,msg]=fopen(FileName,'w');
                assert(fid~=-1,...
                message('HDLLink:CosimWizard:OpenFileFailure',msg));
                fprintf(fid,'%s',TemplateContent);
                fclose(fid);

                if(exist(FileName,'file')~=2)
                    pause(1);
                end

                if~isempty(dlg)
                    edit(FileName);
                end
            else
                warning('HDLLink:CosimWizard:NoOverwrite',['The file to instantiate the System object, ''',FileName,''' already exists. Not overwriting. To get new content based on the Wizard, delete the file and re-run the wizard.']);
            end

            genCompileScript(this.Wizard.UserData);


            launchScriptName=genSlLaunchScript(this.Wizard.UserData);
            if~isempty(dlg)
                edit([launchScriptName,'.m']);
            end





            this.Wizard.UserData.SampleTimeOpt=this.Wizard.SampleTimeOpt;

            matFileName=['cosimWizard_',this.Wizard.UserData.TopLevelName];
            cosimWizardInfo=this.Wizard.UserData;
            save(matFileName,'cosimWizardInfo');

            delete(onCleanupObj);

            if isempty(dlg)
                this.Wizard.NextStepID=-1;
            else


                delete(dlg);

            end
        end
    end
end

function widget=createSpacer(rowSpan,colSpan,Tag)
    widget.Type='panel';
    widget.Tag=Tag;
    widget.RowSpan=rowSpan;
    widget.ColSpan=colSpan;
end

function str=l_asString(orig,kind)
    switch(kind)
    case 'string'
        str=['''',orig,''''];
    case 'cellOfStrings'
        str=['{',sprintf('''%s'' ',orig{:}),'}'];
    case 'cellOfNums'
        str=['{',sprintf('[%d] ',orig{:}),'}'];
    case 'cellOfMat'
        matStr=cellfun(@(x)(mat2str(x)),orig,'UniformOutput',false);
        str=['{',sprintf('%s ',matStr{:}),'}'];
    case 'arrayOfNums'
        str=mat2str(orig);
    case 'cellOfCellOfTimes'
        tmp=cellfun(@(x)(['{',sprintf('%d,''%s''',x{:}),'}']),orig,'UniformOutput',false);
        str=['{',sprintf('%s ',tmp{:}),'}'];
    otherwise
        error('(internal) asString: bad kind.');
    end
end




