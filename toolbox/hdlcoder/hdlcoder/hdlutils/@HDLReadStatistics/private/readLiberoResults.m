function[resultsTable,metadata]=readLiberoResults(this,verboseMode)


    if this.loadFromMAT&&this.testMode

        if verboseMode
            verboseModeStr='true';
        else
            verboseModeStr='false';
        end

        customSuffixStr=['Please rerun the ''readResults'' method in test mode with ''loadFromMAT'' set to ''false'' in the following manner:',newline,newline,'>> parserObj = HDLReadStatistics(''',this.dutName,''', ''TargetDir'', ''',this.targetDir,''', ''SynthTool'', ''',this.synthTool,''', ''ModelName'', ''',this.mdlName,''');',newline,'>> parserObj.loadFromMAT = false;',newline,'>> parserObj.readResults(',verboseModeStr,', ''TestMode'', true);'];

        [metadata.MATFileName,temp]=systemFindUnique(this,this.MATFileName,'auto-generated MAT file',customSuffixStr);

        load(metadata.MATFileName);

        metadata.MATFileTimeStamp=temp;
    else


        [timing,synarea,metadata]=this.readLiberoResultsFromFile;


        this.createLiberoSynthesisTable(timing,synarea);
        resultsTable=this.summary.Libero;


        metadata.mdlName=this.mdlName;
        metadata.expectedDutName=this.dutName;
        metadata.synthTool=this.synthTool;
        metadata.targetDir=pwd;


        if this.testMode
            metadata.MATFileName=fullfile(metadata.targetDir,this.MATFileName);

            if(exist(metadata.MATFileName,'file')==2)
                warning('HDLReadStatistics:FileOverwrite',['MAT file: ''',strrep(metadata.MATFileName,'\','\\'),''' detected on the current path. This file will be overwritten.']);
            end
            save(metadata.MATFileName,'metadata','resultsTable');

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
        disp(['Synthesis Tool:   ',metadata.synthTool])
        disp(['Target directory: ',metadata.targetDir])
        if this.testMode&&this.readTiming
            disp(['Latency Filename: ',metadata.latencyFileName,' last modified on: ',datestr(metadata.latencyFileTimeStamp)])
        end
        if this.testMode
            disp(['Results Storage MAT Filename:                ',metadata.MATFileName,' last modified on: ',datestr(metadata.MATFileTimeStamp)])
        end

        if this.readTiming
            disp(['Libero Synthesis Report Filename:            ',metadata.liberoSythRpt,' last modified on: ',datestr(metadata.liberoSythRptTimestamp)])
        end

        if this.readResources
            disp(['Libero PR Log Filename:                      ',metadata.PRlogFile,' last modified on: ',datestr(metadata.PRlogFileTimestamp)])
            disp(['Libero Resource Utilization Report Filename: ',metadata.resourceUtilRptFileLibero,' last modified on: ',datestr(metadata.resourceUtilRptFileLiberoTimestamp)])
        end
        disp(newline)
    end


    if isempty(resultsTable)
        if this.loadFromMAT&&this.testMode
            warning('HDLReadStatistics:NoParsedResultsInMAT',['No parsed results were stored in the MAT File: ',strrep(metadata.MATFileName,'\','\\'),'. ',customSuffixStr]);
        else
            warning('HDLReadStatistics:NoParsedResultsFromFile',['Results could not be parsed for Libero Workflow. Please ensure that you have run the required steps in the Workflow advisor for the specfied DUT. Also, ensure that the target directory: ''',strrep(metadata.targetDir,'\','\\'),''' contains the required reports for the specified DUT.']);
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