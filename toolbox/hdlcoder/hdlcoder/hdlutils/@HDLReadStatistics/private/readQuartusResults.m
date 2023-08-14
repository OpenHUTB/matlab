function[resultsTable,metadata]=readQuartusResults(this,stage,verboseMode)

    resultsTable=[];
    metadata=[];


    if this.loadFromMAT

        stageOld='';

        if verboseMode
            verboseModeStr='true';
        else
            verboseModeStr='false';
        end

        customSuffixStr=['Please rerun the ''readResults'' method in test mode with ''loadFromMAT'' set to ''false'' in the following manner:',newline,newline,'>> parserObj = HDLReadStatistics(''',this.dutName,''', ''TargetDir'', ''',this.targetDir,''', ''SynthTool'', ''',this.synthTool,''');',newline,'>> parserObj.loadFromMAT = false;',newline,'>> parserObj.readResults(''',stage,''', ',verboseModeStr,', ''TestMode'', true);'];

        [metadata.MATFileName,temp]=systemFindUnique(this,this.MATFileName,'auto-generated MAT file',customSuffixStr);

        load(metadata.MATFileName);

        metadata.MATFileTimeStamp=temp;

        if~contains(stage,stageOld,'IgnoreCase',true)
            warning('HDLReadStatistics:StageMismatch',['Stage mismatch. MAT File was saved with stage: ''',stageOld,''', you are currently trying to get results for stage: ''',stage,'''. ',customSuffixStr,newline,newline,'Please note that the stored results that are currently being read may not be correct.']);
        end

    else


        [timing,synarea,metadata]=this.readQuartusResultsFromFile(stage);


        this.createAlteraSynthesisTable(timing,synarea);
        resultsTable=this.summary.Altera;

        metadata.mdlName=this.mdlName;
        metadata.expectedDutName=this.dutName;
        metadata.synthTool=this.synthTool;
        metadata.targetDir=pwd;


        stageOld=stage;


        if this.testMode
            metadata.MATFileName=fullfile(metadata.targetDir,this.MATFileName);

            if(exist(metadata.MATFileName,'file')==2)
                warning('HDLReadStatistics:FileOverwrite',['MAT file: ''',strrep(metadata.MATFileName,'\','\\'),''' detected on the current path. This file will be overwritten.']);
            end
            save(metadata.MATFileName,'metadata','stageOld','resultsTable');

            metadata.MATFileTimeStamp=now;
        end
    end


    if verboseMode
        disp(newline)
        disp('================================')
        disp('  Values used during parsing:')
        disp('================================')
        if~isempty(metadata.mdlName)
            disp(['Model Name:       ',metadata.mdlName])
        end
        disp(['DUT Name:         ',metadata.expectedDutName])
        disp(['Chip Details:     ',metadata.chipName,' (',metadata.deviceName,')'])
        disp(['Synthesis Tool:   ',metadata.synthTool,' (',metadata.synthTool,')'])
        disp(['Target directory: ',metadata.targetDir])
        if this.testMode&&this.readTiming
            disp(['Latency Filename: ',metadata.latencyFileName,' last modified on: ',datestr(metadata.latencyFileTimeStamp)])
        end
        if this.testMode
            disp(['Results Storage MAT Filename: ',metadata.MATFileName,' last modified on: ',datestr(metadata.MATFileTimeStamp)])
        end

        if contains(stageOld,'synth','IgnoreCase',true)&&this.readResources
            disp(['Altera Analysis & Synthesis Report Filename: ',metadata.RPTFileName,' last modified on: ',datestr(metadata.RPTFileTimestamp)])
            disp(newline)

        elseif contains(stageOld,'map','IgnoreCase',true)

            if this.readResources
                disp(['Altera Analysis & Synthesis Report Filename:  ',metadata.RPTFileName,' last modified on: ',datestr(metadata.RPTFileTimestamp)])
            end

            if this.readTiming
                disp(['Altera Pre-Route Timing Report Filename:      ',metadata.TQRFileName,' last modified on: ',datestr(metadata.TQRFileTimestamp)])

                if this.testMode
                    disp(['Altera Perform Mapping Workflow Log Filename: ',metadata.LOGFileName,' last modified on: ',datestr(metadata.LOGFileTimestamp)])
                end
            end
            disp(newline)

        else
            if this.readResources
                disp(['Altera Fitter Report Filename:                ',metadata.RPTFileName,' last modified on: ',datestr(metadata.RPTFileTimestamp)])
            end

            if this.readTiming
                disp(['Altera Post-Route Timing Report Filename:     ',metadata.TQRFileName,' last modified on: ',datestr(metadata.TQRFileTimestamp)])

                if this.testMode
                    disp(['Altera Place And Route Workflow Log Filename: ',metadata.LOGFileName,' last modified on: ',datestr(metadata.LOGFileTimestamp)])
                end
            end
            disp(newline)
        end
    end


    if isempty(metadata.dut)||~strcmpi(metadata.expectedDutName,metadata.dut)
        warning('HDLReadStatistics:DUTMismatch',['The DUT name specified: ''',metadata.expectedDutName,''' does not match the DUT name in the report: ''',metadata.dut,'''. Please ensure that you have run the required steps in the Workflow advisor for the specfied DUT. Also, ensure that the target directory: ''',strrep(metadata.targetDir,'\','\\'),''' contains the required reports for the specified DUT. Please note that the parsed results might not be the correct results.']);
    end

    if isempty(resultsTable)
        if this.loadFromMAT&&this.testMode
            warning('HDLReadStatistics:NoParsedResultsInMAT',['No parsed results were stored in the MAT File: ',strrep(metadata.MATFileName,'\','\\'),'. ',customSuffixStr]);
        else
            warning('HDLReadStatistics:NoParsedResultsFromFile',['Results could not be parsed for Altera Workflow. Please ensure that you have run the required steps in the Workflow advisor for the specfied DUT. Also, ensure that the target directory: ''',strrep(metadata.targetDir,'\','\\'),''' contains the required reports for the specified DUT.']);
        end
    else

        if verboseMode
            if this.loadFromMAT&&this.testMode
                disp('Results read from the MAT File are:')
            else
                disp('Parsed results are:')
            end
            disp(newline)
            disp(resultsTable)
        end
    end
end