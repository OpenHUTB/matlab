classdef cosimulationConfiguration<handle&matlab.mixin.CustomDisplay



























































































    properties(SetAccess=private)



HDLSimulator




SubWorkflow
    end
    properties

HDLTopLevelName

























HDLFiles







HDLSimulatorPath









HDLCompilationCommand








HDLElaborationOptions











HDLSimulationOptions








HDLTimePrecision












HDLDebug













HDLTimeUnit









PreCosimulationRunTime










        AutoTimeScale=true;




















TimeScale








SampleTime








Connection









ClockPortRegularExpression












ResetPortRegularExpression














        UnusedPortRegularExpression=[];
    end
    properties(Hidden=true)




        VerilogExtensions={'.v','.sv'};





        VHDLExtensions={'.vhd','.vhdl'};







        ScriptExtensions={'.do','.sh'};

    end

    properties(SetAccess=private)









        InputDataPorts=table('Size',[0,1],...
        'VariableNames',{'Name'},...
        'VariableTypes',{'cellstr'});














        OutputDataPorts=table('Size',[0,5],...
        'VariableNames',{'Name','SampleTime','DataType','Signed','FractionLength'},...
        'VariableTypes',{'cellstr','double','cellstr','logical','double'});













        ClockPorts=table('Size',[0,3],...
        'VariableNames',{'Name','Edge','Period'},...
        'VariableTypes',{'cellstr','cellstr','double'});













        ResetPorts=table('Size',[0,3],...
        'VariableNames',{'Name','InitialValue','Duration'},...
        'VariableTypes',{'cellstr','double','double'});










        UnusedPorts=table('Size',[0,1],...
        'VariableNames',{'Name'},...
        'VariableTypes',{'cellstr'});
    end


    methods
        function obj=cosimulationConfiguration(varargin)
            if nargin==1
                restoredConfig=true;
                if isobject(varargin{1})
                    wizdata=varargin{1};
                else
                    wizsaved=load(varargin{1});
                    wizdata=wizsaved.cosimWizardInfo;
                end
                obj.convertWizardData(wizdata);
            elseif nargin==3
                restoredConfig=false;
                obj.HDLSimulator=varargin{1};
                obj.SubWorkflow=varargin{2};
                obj.HDLTopLevelName=varargin{3};
            else
                error('HDLV:Configuration:CosimCtor',...
                ['usage: cosimulationConfiguration(HDLSIM, SUBWORKFLOW, HDLTOP)',newline,...
                '       cosimulationConfiguration(WIZMATFILE)',newline]);
            end

            obj.wizH=CosimWizardPkg.CosimWizardDlg('',obj.SubWorkflow,'',obj.HDLSimulator);

            if~restoredConfig
                wizdata=obj.wizH.UserData;
                obj.initializeObjFromWizardData(wizdata);
            end
        end

        function runWorkflow(obj,varargin)































            p=inputParser;
            p.addParameter('RestartFromStep',0,@(x)(validateattributes(x,'numeric',{'nonnegative','integer'})));
            p.parse(varargin{:});
            if p.Results.RestartFromStep>1
                error('HDLV:Workflow:RestartStepNotSupported','Can only restart from Step 1 for now.');
            end
            if p.Results.RestartFromStep==0

            else
                obj.wizH.NextStepID=p.Results.RestartFromStep;
            end
            while(obj.wizH.NextStepID~=-1)

                obj.stepH=getStepHandle(obj.wizH);



                obj.wizH.StepID=obj.wizH.NextStepID;
                Description=getDescription(obj.stepH);

                currStepStr=num2str(obj.wizH.StepID);
                disp(['-------------------- Step ',currStepStr,'------------------',newline,Description]);

                feval(['l_Step',currStepStr],obj);
            end
            obj.wizH.NextStepID=1;
        end

        function specifyInput(obj,SignalList,varargin)










            p=inputParser;
            p.addRequired('SignalList',@(x)(isstring(x)||iscellstr(x)||ischar(x)));
            p.addOptional('DeleteEntryIfEmpty','notempty',@(x)(isempty(x)||strcmp(x,'notempty')));


            p.parse(SignalList,varargin{:});
            obj.checkForTableEntry(p.Results,'InputDataPorts');
            obj.updateTable(p.Results,'InputDataPorts');
        end

        function specifyOutput(obj,SignalList,varargin)

























            switch obj.SubWorkflow
            case 'Simulink',opdt='OutputPortDataTypeSimulink';
            otherwise,opdt='OutputPortDataTypeMATLAB';
            end
            od=obj.OutputDataPorts(ismember(obj.OutputDataPorts.Name,{'default_output_definition'}),:);
            p=inputParser;
            p.addRequired('SignalList',@(x)(isstring(x)||iscellstr(x)||ischar(x)));
            p.addOptional('DeleteEntryIfEmpty','notempty',@(x)(isempty(x)||strcmp(x,'notempty')));
            p.addParameter('SampleTime',od.SampleTime,@(x)(validateattributes(x,'numeric',{'positive','integer'})));
            p.addParameter('DataType',od.DataType{1},@(x)(isstring(x)||ischar(x)));
            p.addParameter('Signed',od.Signed,@(x)(islogical(x)));
            p.addParameter('FractionLength',od.FractionLength,@(x)(validateattributes(x,'numeric',{'nonnegative','integer'})));


            p.parse(SignalList,varargin{:});
            obj.checkForTableEntry(p.Results,'OutputDataPorts');
            adjResults=p.Results;
            adjResults.DataType=validatestring(adjResults.DataType,hdlv.vc.stringValues(opdt));
            obj.updateTable(adjResults,'OutputDataPorts');
        end

        function specifyClock(obj,SignalList,varargin)


















            cd=obj.ClockPorts(ismember(obj.ClockPorts.Name,{'default_clock_definition'}),:);
            p=inputParser;
            p.addRequired('SignalList',@(x)(isstring(x)||iscellstr(x)||ischar(x)));
            p.addOptional('DeleteEntryIfEmpty','notempty',@(x)(isempty(x)||strcmp(x,'notempty')));
            p.addParameter('Edge',cd.Edge{1},@(x)(isstring(x)||ischar(x)));
            p.addParameter('Period',cd.Period,@(x)(validateattributes(x,'numeric',{'positive','even'})));
            p.parse(SignalList,varargin{:});
            obj.checkForTableEntry(p.Results,'ClockPorts');
            adjResults=p.Results;
            adjResults.Edge=validatestring(adjResults.Edge,hdlv.vc.stringValues('ClockType'));
            obj.updateTable(adjResults,'ClockPorts');
        end

        function specifyReset(obj,SignalList,varargin)

















            rd=obj.ResetPorts(ismember(obj.ResetPorts.Name,{'default_reset_definition'}),:);
            p=inputParser;
            p.addRequired('SignalList',@(x)(isstring(x)||iscellstr(x)||ischar(x)));
            p.addOptional('DeleteEntryIfEmpty','notempty',@(x)(isempty(x)||strcmp(x,'notempty')));
            p.addParameter('InitialValue',rd.InitialValue,@(x)(any(find(x==hdlv.vc.integerValues('ResetType')))));
            p.addParameter('Duration',rd.Duration,@(x)(validateattributes(x,'numeric',{'nonnegative'})));
            p.parse(SignalList,varargin{:});
            obj.checkForTableEntry(p.Results,'ResetPorts');
            obj.updateTable(p.Results,'ResetPorts');
        end

        function specifyUnused(obj,SignalList,varargin)









            p=inputParser;
            p.addRequired('SignalList',@(x)(isstring(x)||iscellstr(x)||ischar(x)));
            p.addOptional('DeleteEntryIfEmpty','notempty',@(x)(isempty(x)||strcmp(x,'notempty')));
            p.parse(SignalList,varargin{:});
            obj.checkForTableEntry(p.Results,'UnusedPorts');
            obj.updateTable(p.Results,'UnusedPorts');
        end

        function portInterface(obj)



            fprintf('\n----- Input Data Ports -----\n');
            display(obj.InputDataPorts);
            fprintf('\n----- Output Data Ports -----\n');
            display(obj.OutputDataPorts);
            fprintf('\n----- Clock Ports -----\n');
            display(obj.ClockPorts);
            fprintf('\n----- Reset Ports -----\n');
            display(obj.ResetPorts);
            fprintf('\n----- Unused Ports -----\n');
            display(obj.UnusedPorts);
            fprintf('\n');
        end
    end


    methods
        function set.HDLSimulator(obj,val)
            validVal=validatestring(val,hdlv.vc.stringValues('HDLSimulator'));
            obj.HDLSimulator=validVal;
        end
        function set.SubWorkflow(obj,val)
            validVal=validatestring(val,hdlv.vc.stringValues('SubWorkflow'));
            obj.SubWorkflow=validVal;
        end
        function set.HDLTopLevelName(obj,val)

            matlab.internal.validation.mustBeASCIICharRowVector(val,'HDLTopLevelName');
            obj.HDLTopLevelName=val;
        end
        function set.HDLFiles(obj,val)


            validateattributes(val,{'string','char','cell'},{});
            obj.HDLFiles=val;
        end
        function set.HDLSimulatorPath(obj,val)

            validateattributes(val,{'string','char'},{});
            obj.HDLSimulatorPath=val;
        end
        function set.HDLCompilationCommand(obj,val)

            matlab.internal.validation.mustBeASCIICharRowVector(val,'HDLCompilationCommand');
            obj.HDLCompilationCommand=val;
        end
        function set.HDLSimulationOptions(obj,val)

            matlab.internal.validation.mustBeASCIICharRowVector(val,'HDLSimulationOptions');
            obj.HDLSimulationOptions=val;
        end
        function set.HDLTimeUnit(obj,val)
            validVal=validatestring(val,hdlv.vc.stringValues('HDLTimeUnit'));
            obj.HDLTimeUnit=validVal;
        end
        function set.PreCosimulationRunTime(obj,val)
            validateattributes(val,'numeric',{'nonnegative'});
            obj.PreCosimulationRunTime=val;
        end
        function set.AutoTimeScale(obj,val)
            validateattributes(val,{'logical','numeric'},{'scalar'});
            assert(val==0||val==1,...
            'HDLV:Workflow:AutoTimeScaleNotLogicalValue',...
            'AutoTimeScale requires a numeric 0, 1 or logical false or true value');
            obj.AutoTimeScale=logical(val);
        end
        function set.TimeScale(obj,val)
            validateattributes(val,{'cell'},{'size',[1,2]});
            time=val{1};
            unit=val{2};
            validateattributes(val{1},'numeric',{'nonnegative'});
            validUnit=validatestring(unit,hdlv.vc.stringValues('HDLTimeUnit'));
            obj.TimeScale={time,validUnit};
        end
        function set.SampleTime(obj,val)
            validateattributes(val,'numeric',{'nonnegative'});
            obj.SampleTime=val;
        end
        function set.Connection(obj,val)
            validVal=validatestring(val,hdlv.vc.stringValues('Connection'));
            obj.Connection=validVal;
        end
        function set.ClockPortRegularExpression(obj,val)

            matlab.internal.validation.mustBeASCIICharRowVector(val,'ClockPortRegularExpression');
            obj.ClockPortRegularExpression=val;
        end
        function set.ResetPortRegularExpression(obj,val)

            matlab.internal.validation.mustBeASCIICharRowVector(val,'ResetPortRegularExpression');
            obj.ResetPortRegularExpression=val;
        end
        function set.UnusedPortRegularExpression(obj,val)

            matlab.internal.validation.mustBeASCIICharRowVector(val,'UnusedPortRegularExpression');
            obj.UnusedPortRegularExpression=val;
        end

        function set.HDLTimePrecision(obj,val)
            validVal=validatestring(val,hdlv.vc.stringValues('HDLTimePrecision'));
            obj.HDLTimePrecision=validVal;
        end
        function set.HDLDebug(obj,val)
            validVal=validatestring(val,hdlv.vc.stringValues('HDLDebug'));
            obj.HDLDebug=validVal;
        end
    end

    methods(Access=private)
        function initializeObjFromWizardData(obj,wd)


















            obj.HDLElaborationOptions=wd.ElabOptions;
            obj.HDLSimulationOptions=wd.LoadOptions;
            if matches(wd.Simulator,'Vivado Simulator')
                obj.HDLTimePrecision=hdlv.vc.toString('HDLTimePrecision',wd.HdlResolution);
                obj.HDLDebug=wd.HdlDebug;
            end
            obj.AutoTimeScale=wd.TimeScaleOpt;
            obj.TimeScale={str2double(wd.TimingScaleFactor),wd.TimingMode};

            obj.Connection=wd.Connection;

            obj.ClockPortRegularExpression=wd.ClkPortRegEx;
            obj.ResetPortRegularExpression=wd.RstPortRegEx;
            obj.UnusedPortRegularExpression=wd.UnusedPortRegEx;

            obj.ClockPorts(end+1,:)={{'default_clock_definition'},{wd.ClkPortDefaults.Edge},str2double(wd.ClkPortDefaults.Period)};
            obj.ResetPorts(end+1,:)={{'default_reset_definition'},str2double(wd.RstPortDefaults.Initial),str2double(wd.RstPortDefaults.Duration)};
            opd=wd.OutputPortDefaults;
            switch obj.SubWorkflow
            case 'Simulink',opdt='OutputPortDataTypeSimulink';
            otherwise,opdt='OutputPortDataTypeMATLAB';
            end
            obj.OutputDataPorts(end+1,:)={{'default_output_definition'},str2double(opd.SampleTime),{hdlv.vc.toString(opdt,opd.DataType)},logical(opd.Sign),str2double(opd.FractionLength)};

            pfile=regexp(obj.HDLElaborationOptions,'parameter_.*\.cfg','match');
            if~isempty(pfile),fprintf('## Expecting parameter file ''%s'' for elaboration.\n',pfile{:});end
            pfile=regexp(obj.HDLSimulationOptions,'parameter_.*\.cfg','match');
            if~isempty(pfile),fprintf('## Expecting parameter file ''%s'' for simulation.\n',pfile{:});end

        end

        function checkForTableEntry(obj,result,tableProp)
            [newNames,deie]=deal(result.SignalList,result.DeleteEntryIfEmpty);
            if isempty(deie)

            else
                if~iscell(newNames),newNames={newNames};end

                allNames=containers.Map(...
                {'InputDataPorts','OutputDataPorts','ClockPorts','ResetPorts','UnusedPorts'},...
                {obj.InputDataPorts.Name',...
                setxor(obj.OutputDataPorts.Name,{'default_output_definition'})',...
                setxor(obj.ClockPorts.Name,{'default_clock_definition'})',...
                setxor(obj.ResetPorts.Name,{'default_reset_definition'})',...
                obj.UnusedPorts.Name'}...
                );
                allKeys=allNames.keys;
                otherTableKeys=allKeys(~contains(allKeys,tableProp));
                allOtherNames=allNames.values(otherTableKeys);
                m=matches(newNames,[allOtherNames{:}]);
                mlist=newNames(m);
                if length(mlist)>=1
                    error('HDLV:Workflow:SignalAlreadyInTables',...
                    'The following signals already have entries in the port tables. Remove existing entries first.\n%s',...
                    sprintf('\t%s\n',mlist{:}));
                end
            end
        end
        function updateTable(obj,result,tableProp)
            origtable=obj.(tableProp);
            [siglist,deie]=deal(result.SignalList,result.DeleteEntryIfEmpty);
            argvals=rmfield(result,'SignalList');
            argvals=rmfield(argvals,'DeleteEntryIfEmpty');
            if isempty(deie)
                newtable=origtable(~matches(origtable.Name,siglist),:);
                obj.(tableProp)=newtable;
            else
                if iscell(siglist)
                    scalarexpanded=cellfun(@(x)(setfield(argvals,'Name',{x})),siglist,'UniformOutput',false);
                else
                    scalarexpanded={setfield(argvals,'Name',{siglist})};%#ok<SFLD> 
                end
                newtable=struct2table([scalarexpanded{:}]);
                oldtable=origtable(~matches(origtable.Name,siglist),:);
                obj.(tableProp)=union(oldtable,newtable,'stable');
            end
        end
    end


    methods(Access=protected)
        function pg=getPropertyGroups(obj)
            pg=matlab.mixin.util.PropertyGroup.empty();
            pl={'HDLSimulator','SubWorkflow','HDLTopLevelName'};
            pg(end+1)=matlab.mixin.util.PropertyGroup(pl,'----- Workflow Selection -----');

            pl={'HDLFiles','HDLSimulatorPath','HDLCompilationCommand','HDLElaborationOptions','HDLSimulationOptions','HDLTimePrecision','HDLDebug'};
            switch obj.HDLSimulator
            case 'ModelSim',pl=setxor(pl,{'HDLElaborationOptions','HDLTimePrecision','HDLDebug'},'stable');
            case 'Xcelium',pl=setxor(pl,{'HDLTimePrecision','HDLDebug'},'stable');
            case 'Vivado Simulator',pl=setxor(pl,{'HDLElaborationOptions','HDLSimulationOptions'},'stable');
            end
            pg(end+1)=matlab.mixin.util.PropertyGroup(pl,'----- HDL Compilation -----');

            pl={'HDLTimeUnit','PreCosimulationRunTime','AutoTimeScale','TimeScale','SampleTime'};
            switch obj.SubWorkflow
            case 'Simulink',pl=setxor(pl,{'SampleTime'},'stable');
            case 'MATLAB System Object',pl=setxor(pl,{'AutoTimeScale','TimeScale'},'stable');
            end
            if~obj.AutoTimeScale
                pl=setxor(pl,{'TimeScale'},'stable');
            end
            pg(end+1)=matlab.mixin.util.PropertyGroup(pl,'----- HDL Timing -----');

            switch obj.HDLSimulator
            case{'ModelSim','Xcelium'}
                pl={'Connection','SocketPort'};
                pg(end+1)=matlab.mixin.util.PropertyGroup(pl,'----- HDL Simulator Connection -----');
            case 'Vivado Simulator'

            end

            pl={'ClockPortRegularExpression','ResetPortRegularExpression','UnusedPortRegularExpression','InputDataPorts','OutputDataPorts','ClockPorts','ResetPorts','UnusedPorts'};
            pg(end+1)=matlab.mixin.util.PropertyGroup(pl,'----- Port Interface Properties -----');
        end
    end









    methods(Access=private)

        function l_Step1(obj)
            if~isempty(obj.HDLSimulatorPath)
                obj.wizH.UserData.HdlPath=obj.HDLSimulatorPath;
                obj.wizH.UserData.PathOpt=1;
            else
                obj.wizH.UserData.PathOpt=0;
            end
            obj.stepH.EnterStep(obj.ddgH);
            obj.wizH.onNext(obj.ddgH);
        end








        function l_Step2(obj)
            switch obj.HDLSimulator
            case 'ModelSim',scriptVals='ModelSim macro file';
            case 'Xcelium',scriptVals='Shell script';
            case 'Vivado Simulator',scriptVals='Unknown';
            end
            typeKeys=[obj.VerilogExtensions,obj.VHDLExtensions,obj.ScriptExtensions];
            typeVals=[repmat({'Verilog'},size(obj.VerilogExtensions)),...
            repmat({'VHDL'},size(obj.VHDLExtensions)),...
            repmat({scriptVals},size(obj.ScriptExtensions))];
            typeMap=containers.Map(typeKeys,typeVals);

            if~iscell(obj.HDLFiles)
                isDirFileList=true;
                isTypedFileList=false;
                dirFileList={obj.HDLFiles};
            elseif iscell(obj.HDLFiles)&&numel(obj.HDLFiles)==1
                isDirFileList=true;
                isTypedFileList=false;
                dirFileList=obj.HDLFiles;
            else
                existVal=exist(obj.HDLFiles{2},'file');
                if existVal==2||existVal==7
                    isDirFileList=true;
                    isTypedFileList=false;
                    dirFileList=obj.HDLFiles;
                else
                    isDirFileList=false;
                    isTypedFileList=true;
                    dirFileList=obj.HDLFiles;
                end
            end

            assert(~isequal(dirFileList,{[]}),...
            'HDLV:Workflow:BadHDLFilesDetection',...
            'Expected either a file/dir list or a file/type list in HDLFiles property but saw neither.');

            assert(xor(isDirFileList,isTypedFileList),...
            'HDLV:Workflow:BadHDLFilesDetection',...
            'Expected either a file/dir list or a file/type list in HDLFiles property but saw neither.');

            if isTypedFileList
                assert(mod(length(dirFileList),2)==0,...
                'HDLV:Workflow:FileTypeListMustBeEven',...
                'When specifying a cell array of file/type pairs, the length of the cell array must be even.');
                allFilesAndTypes=dirFileList;

                for idx=(1:2:length(allFilesAndTypes))
                    [d,f,e]=fileparts(allFilesAndTypes{idx});
                    if isempty(d),file=['.',filesep,f,e];
                    else,file=[d,filesep,f,e];
                    end
                    allFilesAndTypes{idx}=file;
                end


                uniqueVals=unique(typeVals);
                validVals=cellfun(@(x)(validatestring(x,uniqueVals)),allFilesAndTypes(2:2:end),'UniformOutput',false);
                allFilesAndTypes(2:2:end)=validVals;
            elseif isDirFileList
                fullFileList=[];
                for dirfile=dirFileList
                    if exist(dirfile{1},'dir')


                        currDir=dirfile{1};
                        allEntries=dir(currDir);
                        allFileEntries=allEntries(arrayfun(@(x)(~x.isdir),allEntries));
                        filesInDir=strcat([currDir,filesep],{allFileEntries.name});
                        fullFileList=[fullFileList,filesInDir];%#ok<AGROW>
                    elseif exist(dirfile{1},'file')==2
                        filesInDir=dirfile{1};
                        fullFileList=[fullFileList,{filesInDir}];%#ok<AGROW> 
                    else
                        error('HDLV:Workflow:BadHDLFileSpec',...
                        'Specified file or dir ''%s'' does not exist.',...
                        dirfile{1});
                    end

                end
                allFilesAndTypes={};
                for idx=1:length(fullFileList)
                    file=fullFileList{idx};
                    [d,~,e]=fileparts(file);
                    if isempty(d),file=['.',filesep,file];end %#ok<AGROW> 
                    if typeMap.isKey(e)
                        type=typeMap(e);
                        allFilesAndTypes{end+1}=file;%#ok<AGROW> 
                        allFilesAndTypes{end+1}=type;%#ok<AGROW> 
                    else
                        warning('HDLV:Workflow:IgnoreUnknown',...
                        'Ignoring file ''%s'' because it has an unknown file type ''%s''',...
                        file,e);
                    end
                end
            end

            obj.wizH.UserData.HdlFiles=obj.convertCLIToGUIHdlFiles(obj.wizH.UserData.FileTypes,allFilesAndTypes);
            obj.stepH.EnterStep(obj.ddgH);
            obj.wizH.onNext(obj.ddgH);
        end




        function l_Step3(obj)
            obj.stepH.EnterStep(obj.ddgH);


            if isempty(obj.HDLCompilationCommand)
                obj.wizH.CompileCmd=obj.wizH.UserData.GeneratedCompileCmd;
            else
                obj.wizH.CompileCmd=obj.HDLCompilationCommand;
            end

            obj.wizH.onNext(obj.ddgH);



            if isempty(obj.wizH.UserData.ModulesFound)
                error('HDL compilation failed.  no modules found.');
            end
        end


        function l_Step4(obj)







            [ematch,eidx]=ismember(obj.HDLTopLevelName,obj.wizH.UserData.ModulesFound);
            [lmatch,lidx]=ismember(lower(obj.HDLTopLevelName),obj.wizH.UserData.ModulesFound);
            [umatch,uidx]=ismember(upper(obj.HDLTopLevelName),obj.wizH.UserData.ModulesFound);
            if ematch,obj.wizH.TopLevelName=obj.wizH.UserData.ModulesFound{eidx};
            elseif lmatch,obj.wizH.TopLevelName=obj.wizH.UserData.ModulesFound{lidx};
            elseif umatch,obj.wizH.TopLevelName=obj.wizH.UserData.ModulesFound{uidx};
            else
                error('HDLV:Workflow:TopNotInModules',...
                'Specified HDLTopLevelName ''%s'' not found as exact match, lower-case match, or upper-case match. Compiled modules include:\n%s',...
                obj.HDLTopLevelName,sprintf('  %s\n',obj.wizH.UserData.ModulesFound{:}));
            end







            if isempty(obj.HDLElaborationOptions)
                obj.wizH.ElabOptions=obj.wizH.UserData.ElabOptions;
            else
                obj.wizH.ElabOptions=obj.HDLElaborationOptions;
            end
            if isempty(obj.HDLSimulationOptions)
                obj.wizH.LoadOptions=obj.wizH.UserData.LoadOptions;
            else
                obj.wizH.LoadOptions=obj.HDLSimulationOptions;
            end


            if matches(obj.HDLSimulator,'Vivado Simulator')
                newElab=obj.wizH.UserData.createElabOptions(obj.wizH.UserData.TclQueryInfo.TopLanguage,obj.HDLDebug,obj.HDLTimePrecision);
                obj.wizH.UserData.HdlResolution=hdlv.vc.toInteger('HDLTimePrecision',obj.HDLTimePrecision);
                obj.wizH.UserData.HdlDebug=obj.HDLDebug;
                obj.wizH.ElabOptions=newElab;
                obj.HDLElaborationOptions=newElab;
            end

            obj.wizH.UserData.Connection=obj.Connection;



            obj.wizH.UserData.ClkPortRegEx=obj.ClockPortRegularExpression;
            obj.wizH.UserData.RstPortRegEx=obj.ResetPortRegularExpression;
            obj.wizH.UserData.UnusedPortRegEx=obj.UnusedPortRegularExpression;

            obj.stepH.EnterStep(obj.ddgH);
            obj.wizH.onNext(obj.ddgH);




            if~isempty(obj.HDLTimeUnit)
                if~ismember(obj.HDLTimeUnit,obj.wizH.UserData.HdlTimeUnitNames)
                    obj.wizH.NextStepID=4;
                    hdlPrecStr=CosimWizardPkg.CosimWizardData.precExpToStr(obj.wizH.UserData.HdlResolution);
                    error('HDLV:Workflow:InvalidTimeUnit',...
                    'Specified HDLTimeUnit ''%s'' is not allowed given the HDLTimePrecision of %s. Valid values include:\n%s',...
                    obj.HDLTimeUnit,hdlPrecStr,sprintf('  %s\n',obj.wizH.UserData.HdlTimeUnitNames{:}));
                end
                obj.wizH.UserData.HdlTimeUnit=obj.HDLTimeUnit;
            end
        end



        function l_Step5(obj)

            if~isempty(obj.ClockPorts)
                ctype='Clock';
                cnames=obj.ClockPorts.Name(~matches(obj.ClockPorts.Name,'default_clock_definition'));
                cellfun(@(n)(setTableItemValue(obj.wizH,'edaInPortList',n,'Type',ctype)),cnames);
            end
            if~isempty(obj.ResetPorts)
                rtype='Reset';
                rnames=obj.ResetPorts.Name(~matches(obj.ResetPorts.Name,'default_reset_definition'));
                cellfun(@(n)(setTableItemValue(obj.wizH,'edaInPortList',n,'Type',rtype)),rnames);
            end
            if~isempty(obj.UnusedPorts)
                utype='Unused';

                allins=cellfun(@(x)(x.Name),obj.wizH.UserData.InPortList,'UniformOutput',false);
                unamesIn=intersect(obj.UnusedPorts.Name,allins);
                cellfun(@(n)(setTableItemValue(obj.wizH,'edaInPortList',n,'Type',utype)),unamesIn);

                allouts=cellfun(@(x)(x.Name),obj.wizH.UserData.OutPortList,'UniformOutput',false);
                unamesOut=intersect(obj.UnusedPorts.Name,allouts);
                cellfun(@(n)(setTableItemValue(obj.wizH,'edaOutPortList',n,'Type',utype)),unamesOut);
            end

            obj.stepH.EnterStep(obj.ddgH);
            obj.wizH.onNext(obj.ddgH);
        end


        function l_Step6(obj)




            odpd=obj.OutputDataPorts(ismember(obj.OutputDataPorts.Name,{'default_output_definition'}),:);
            allouts=cellfun(@(x)(x.Name),obj.wizH.UserData.UsedOutPortList,'UniformOutput',false);
            cellfun(@(n)(setTableItemValue(obj.wizH,'edaUsedOutPortList',n,'Sign',odpd.Signed)),allouts);
            cellfun(@(n)(setTableItemValue(obj.wizH,'edaUsedOutPortList',n,'DataType',odpd.DataType{1})),allouts);
            cellfun(@(n)(setTableItemValue(obj.wizH,'edaUsedOutPortList',n,'FractionLength',odpd.FractionLength)),allouts);
            cellfun(@(n)(setTableItemValue(obj.wizH,'edaUsedOutPortList',n,'SampleTime',odpd.SampleTime)),allouts);



            odpo=obj.OutputDataPorts(~ismember(obj.OutputDataPorts.Name,{'default_output_definition'}),:);
            namecell=table2cell(odpo(:,{'Name'}));
            valuecell=table2cell(odpo(:,{'Signed'}));
            cellfun(@(n,v)(setTableItemValue(obj.wizH,'edaUsedOutPortList',n,'Sign',v)),namecell,valuecell);
            valuecell=table2cell(odpo(:,{'DataType'}));
            cellfun(@(n,v)(setTableItemValue(obj.wizH,'edaUsedOutPortList',n,'DataType',v)),namecell,valuecell);
            valuecell=table2cell(odpo(:,{'FractionLength'}));
            cellfun(@(n,v)(setTableItemValue(obj.wizH,'edaUsedOutPortList',n,'FractionLength',v)),namecell,valuecell);
            valuecell=table2cell(odpo(:,{'SampleTime'}));
            cellfun(@(n,v)(setTableItemValue(obj.wizH,'edaUsedOutPortList',n,'SampleTime',v)),namecell,valuecell);

            obj.stepH.EnterStep(obj.ddgH);
            obj.wizH.onNext(obj.ddgH);
        end

        function l_Step7(obj)





            cpd=obj.ClockPorts(ismember(obj.ClockPorts.Name,{'default_clock_definition'}),:);
            allclks=cellfun(@(x)(x.Name),obj.wizH.UserData.ClkList,'UniformOutput',false);
            cellfun(@(n)(setTableItemValue(obj.wizH,'edaClocks',n,'Edge',cpd.Edge{1})),allclks);
            cellfun(@(n)(setTableItemValue(obj.wizH,'edaClocks',n,'Period',cpd.Period)),allclks);



            cpo=obj.ClockPorts(~ismember(obj.ClockPorts.Name,{'default_clock_definition'}),:);
            namecell=table2cell(cpo(:,{'Name'}));
            valuecell=table2cell(cpo(:,{'Edge'}));
            cellfun(@(n,v)(setTableItemValue(obj.wizH,'edaClocks',n,'Edge',v)),namecell,valuecell);
            valuecell=table2cell(cpo(:,{'Period'}));
            cellfun(@(n,v)(setTableItemValue(obj.wizH,'edaClocks',n,'Period',v)),namecell,valuecell);




            rpd=obj.ResetPorts(ismember(obj.ResetPorts.Name,{'default_reset_definition'}),:);
            allrsts=cellfun(@(x)(x.Name),obj.wizH.UserData.RstList,'UniformOutput',false);
            cellfun(@(n)(setTableItemValue(obj.wizH,'edaResets',n,'Initial',rpd.InitialValue)),allrsts);
            cellfun(@(n)(setTableItemValue(obj.wizH,'edaResets',n,'Duration',rpd.Duration)),allrsts);



            rpo=obj.ResetPorts(~ismember(obj.ResetPorts.Name,{'default_reset_definition'}),:);
            namecell=table2cell(rpo(:,{'Name'}));
            valuecell=table2cell(rpo(:,{'InitialValue'}));
            cellfun(@(n,v)(setTableItemValue(obj.wizH,'edaResets',n,'Initial',v)),namecell,valuecell);
            valuecell=table2cell(rpo(:,{'Duration'}));
            cellfun(@(n,v)(setTableItemValue(obj.wizH,'edaResets',n,'Duration',v)),namecell,valuecell);

            obj.stepH.EnterStep(obj.ddgH);
            obj.wizH.onNext(obj.ddgH);
        end

        function l_Step8(obj)
            if~isempty(obj.PreCosimulationRunTime)
                obj.wizH.UserData.ResetRunTimeStr=num2str(obj.PreCosimulationRunTime);
            end


            onUpdatePlot(obj.wizH,obj.ddgH)

            obj.stepH.EnterStep(obj.ddgH);
            obj.wizH.onNext(obj.ddgH);
        end



        function l_Step9(obj)
            mdlName=strrep(obj.ModelArtifactName,'%<HDLTopLevelName>',obj.HDLTopLevelName);
            obj.wizH.workflowOverrideTargetSystem=mdlName;
            obj.wizH.UserData.TimeScaleOpt=obj.AutoTimeScale;
            if~obj.AutoTimeScale
                obj.wizH.UserData.TimingScaleFactor=num2str(obj.TimeScale{1});
                mustBeMember(obj.TimeScale{2},obj.wizH.UserData.HdlTimeUnitNames);
                obj.wizH.UserData.TimingMode=obj.TimeScale{2};
            else
                obj.wizH.UserData.TimingScaleFactor='1';
                obj.wizH.UserData.TimingMode='s';
            end
            obj.stepH.EnterStep(obj.ddgH);
            obj.wizH.onNext(obj.ddgH);
        end


        function l_Step12(obj)

            obj.stepH.EnterStep(obj.ddgH);

            if~isempty(obj.SampleTime)
                obj.wizH.SampleTimeOpt=num2str(obj.SampleTime);
            end

            obj.wizH.onNext(obj.ddgH);
        end
    end


    methods(Access=private)


        function convertWizardData(obj,wd)
















            obj.HDLSimulator=wd.Simulator;
            obj.SubWorkflow=wd.Workflow;
            obj.HDLTopLevelName=wd.TopLevelName;
            obj.HDLFiles=obj.convertGUIToCLIHdlFiles(wd.FileTypes,wd.HdlFiles);
            obj.HDLSimulatorPath=wd.HdlPath;

            if~strcmp(wd.CompileCmd,wd.GeneratedCompileCmd)
                obj.HDLCompilationCommand=wd.CompileCmd;
            end
            obj.HDLTimeUnit=wd.HdlTimeUnit;
            obj.PreCosimulationRunTime=str2double(wd.ResetRunTimeStr);
            obj.SampleTime=str2double(wd.SampleTimeOpt);


            obj.initializeObjFromWizardData(wd);



            [na,ed,pe]=cellfun(@(x)(deal(x.Name,x.Edge,str2double(x.Period))),wd.ClkList,'UniformOutput',false);
            t=cell2table([na',ed',pe'],'VariableNames',obj.ClockPorts.Properties.VariableNames);
            obj.ClockPorts=union(obj.ClockPorts,t,'stable');


            [na,iv,du]=cellfun(@(x)(deal(x.Name,str2double(x.Initial),str2double(x.Duration))),wd.RstList,'UniformOutput',false);
            t=cell2table([na',iv',du'],'VariableNames',obj.ResetPorts.Properties.VariableNames);
            obj.ResetPorts=union(obj.ResetPorts,t,'stable');


            na=cellfun(@(x)(x.Name),wd.UsedInPortList,'UniformOutput',false);
            t=cell2table(na','VariableNames',obj.InputDataPorts.Properties.VariableNames);
            obj.InputDataPorts=union(obj.InputDataPorts,t,'stable');






            switch obj.SubWorkflow
            case 'Simulink',opdt='OutputPortDataTypeSimulink';
            otherwise,opdt='OutputPortDataTypeMATLAB';
            end
            if~isempty(wd.UsedOutPortList)
                op=wd.UsedOutPortList{1};
                isStrFunc=@(x)(isstring(x)||iscellstr(x)||ischar(x));
                if isStrFunc(op.SampleTime),stConvFunc=@(x)(str2double(x));
                else,stConvFunc=@(x)(x);
                end
                if isStrFunc(op.DataType),dtConvFunc=@(x)(x);
                else,dtConvFunc=@(x)(hdlv.vc.toString(opdt,x));
                end
                if isStrFunc(op.Sign),siConvFunc=@(x)(logical(hdlv.vc.toInteger('OutputPortSigned',x)));
                else,siConvFunc=@(x)(logical(x));
                end
                if isStrFunc(op.FractionLength),flConvFunc=@(x)(str2double(x));
                else,flConvFunc=@(x)(x);
                end
            end
            [na,st,dt,si,fl]=cellfun(@(x)(deal(x.Name,stConvFunc(x.SampleTime),dtConvFunc(x.DataType),siConvFunc(x.Sign),flConvFunc(x.FractionLength))),wd.UsedOutPortList,'UniformOutput',false);
            t=cell2table([na',st',dt',si',fl'],'VariableNames',obj.OutputDataPorts.Properties.VariableNames);
            obj.OutputDataPorts=union(obj.OutputDataPorts,t,'stable');


            [ipln,iplt]=cellfun(@(x)(deal(x.Name,hdlv.vc.toString('InputPortType',x.Type))),wd.InPortList,'UniformOutput',false);
            unusedin=ipln(cellfun(@(x)(matches(x,'Unused')),iplt));
            [opln,oplt]=cellfun(@(x)(deal(x.Name,hdlv.vc.toString('OutputPortType',x.Type))),wd.OutPortList,'UniformOutput',false);
            unusedout=opln(cellfun(@(x)(matches(x,'Unused')),oplt));
            t=cell2table([unusedin,unusedout]','VariableNames',obj.UnusedPorts.Properties.VariableNames);
            obj.UnusedPorts=union(obj.UnusedPorts,t,'stable');

        end
        function newFiles=convertGUIToCLIHdlFiles(~,types,files)

            f2=files';
            newFiles=f2(:)';
            ftStr=types;ftInt=0:length(ftStr)-1;
            ftI2S=containers.Map(ftInt,ftStr);
            strFT=cellfun(@(x)(ftI2S(x)),newFiles(2:2:end),'UniformOutput',false);
            newFiles(2:2:end)=strFT;
        end
        function newFiles=convertCLIToGUIHdlFiles(~,types,files)
            ftStr=types;ftInt=0:length(ftStr)-1;
            ftS2I=containers.Map(ftStr,ftInt);
            intFT=cellfun(@(x)(ftS2I(x)),files(2:2:end),'UniformOutput',false);
            newFiles=cat(1,files(1:2:end),intFT)';
        end

    end


    properties(Access=private)
wizH
        ddgH='';
stepH
        ModelArtifactName='hdlverifier_wizard_%<HDLTopLevelName>';
    end
end
























































