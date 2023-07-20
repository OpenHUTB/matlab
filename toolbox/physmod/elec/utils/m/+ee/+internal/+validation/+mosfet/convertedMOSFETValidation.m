function[outputStruct1,outputStruct2]=convertedMOSFETValidation(fileName,varargin)































































































































    defaultVt=1.4;
    defaultVds=20;
    defaultCheckIdvgs=1;
    defaultCheckIdvds=1;
    defaultCheckQiss=0;
    defaultCiss=440e-12;
    defaultCheckQoss=0;
    defaultCoss=30e-12;
    defaultCheckBreakdown=0;
    defaultRelTol=1e-9;
    defaultAbsTol=1e-9;
    defaultVnTol=1e-9;
    defaultAbsErrTol=1e-3;
    defaultRelErrTol=1e-2;
    defaultGeneratePlots=0;
    defaultn=2;
    defaultSPICEPath="C:\Program Files\LTC\LTspiceXVII\XVIIx64.exe";
    defaultSPICETool="LTspice";
    defaultSimscapeFile=string.empty;
    defaultSPICEFile=string.empty;
    defaultSubcircuit=string.empty;
    defaultRawFile=string.empty;
    defaultTestFile=string.empty;
    parseObj=inputParser;
    validScalarPosNum=@(x)isnumeric(x)&&isscalar(x)&&(x>0);
    validBoolean=@(x)(x==0)||(x==1);
    validstringorchar=@(x)(isstring(x)||ischar(x));
    addRequired(parseObj,"filename",validstringorchar);
    addParameter(parseObj,"SPICEFile",defaultSPICEFile,validstringorchar);
    addParameter(parseObj,"SimscapeFile",defaultSimscapeFile,validstringorchar);
    addParameter(parseObj,"Subcircuit",defaultSubcircuit,validstringorchar);
    addParameter(parseObj,"SPICETool",defaultSPICETool,validstringorchar);
    addParameter(parseObj,"SPICEPath",defaultSPICEPath,validstringorchar);
    addParameter(parseObj,"Vt",defaultVt,validScalarPosNum);
    addParameter(parseObj,"Vds",defaultVds,validScalarPosNum);
    addParameter(parseObj,"RelTol",defaultRelTol,validScalarPosNum);
    addParameter(parseObj,"AbsTol",defaultAbsTol,validScalarPosNum);
    addParameter(parseObj,"VnTol",defaultVnTol,validScalarPosNum);
    addParameter(parseObj,"Ciss",defaultCiss,validScalarPosNum);
    addParameter(parseObj,"Coss",defaultCoss,validScalarPosNum);
    addParameter(parseObj,"CheckIdVgs",defaultCheckIdvgs,validBoolean);
    addParameter(parseObj,"CheckIdVds",defaultCheckIdvds,validBoolean);
    addParameter(parseObj,"CheckQiss",defaultCheckQiss,validBoolean);
    addParameter(parseObj,"CheckQoss",defaultCheckQoss,validBoolean);
    addParameter(parseObj,"CheckBreakdown",defaultCheckBreakdown,validBoolean);
    addParameter(parseObj,"AbsErrTol",defaultAbsErrTol,validScalarPosNum);
    addParameter(parseObj,"RelErrTol",defaultRelErrTol,validScalarPosNum);
    addParameter(parseObj,"GeneratePlots",defaultGeneratePlots,validBoolean);
    addParameter(parseObj,"BreakdownScalingForVds",defaultn,validScalarPosNum);
    addParameter(parseObj,"Rawfile_idvgstj27",defaultRawFile,validstringorchar);
    addParameter(parseObj,"Rawfile_idvgstj75",defaultRawFile,validstringorchar);
    addParameter(parseObj,"Rawfile_idvds",defaultRawFile,validstringorchar);
    addParameter(parseObj,"Rawfile_qiss",defaultRawFile,validstringorchar);
    addParameter(parseObj,"Rawfile_qoss",defaultRawFile,validstringorchar);
    addParameter(parseObj,"Rawfile_breakdown",defaultRawFile,validstringorchar);
    addParameter(parseObj,"file2header_IdVgstj27",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2_IdVgstj27",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3header_IdVgstj27",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3_IdVgstj27",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4header_IdVgstj27",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4_IdVgstj27",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2header_IdVgstj75",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2_IdVgstj75",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3header_IdVgstj75",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3_IdVgstj75",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4header_IdVgstj75",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4_IdVgstj75",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2header_IdVds",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2_IdVds",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3header_IdVds",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3_IdVds",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4header_IdVds",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4_IdVds",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2header_Qiss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2_Qiss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3header_Qiss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3_Qiss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4header_Qiss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4_Qiss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2header_Qoss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2_Qoss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3header_Qoss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3_Qoss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4header_Qoss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4_Qoss",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2header_Breakdown",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file2_Breakdown",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3header_Breakdown",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file3_Breakdown",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4header_Breakdown",defaultTestFile,validstringorchar);
    addParameter(parseObj,"file4_Breakdown",defaultTestFile,validstringorchar);
    parse(parseObj,fileName,varargin{:});
    [~,~,fileExtension]=fileparts(which(fileName));
    fileId=fopen(which(fileName));
    if fileId==-1
        pm_error("physmod:ee:spice2ssc:CannotOpenFile",fileName);
    end
    fclose(fileId);
    finishup=onCleanup(@()CleanupFunc(fileId));
    switch lower(fileExtension)
    case ".ssc"
        if isempty(parseObj.Results.SPICEFile)

            fileContents=fileread(which(fileName));
            q=regexp(fileContents,'nodes.*?end','match');
            for i=1:length(q)
                if isempty(regexp(char(q(i)),"nodes\s*(.*?end","match"))
                    nodeLines=regexp(char(q(i)),"\r?\n","split");
                end
            end
            [newNodeLines]=ee.internal.validation.mosfet.formatNodelines(nodeLines);
            newNodeLines(1)=[];
            newNodeLines(end)=[];
            for m=1:length(newNodeLines)
                newNodeLines(m)=strtok(newNodeLines(m),"=");
                newNodeLines(m)=strrep(newNodeLines(m),' ','');
            end
            nodes=strtok(newNodeLines);
            numberOfNodes=length(nodes);
            if~((numberOfNodes==3)||(numberOfNodes==4)||(numberOfNodes==5)||(numberOfNodes==6))
                pm_error("physmod:ee:SPICE2sscvalidation:NodesError",numberOfNodes);
            end
            test=ee.internal.validation.mosfet.generateTests(numberOfNodes,parseObj.Results.CheckIdVgs,parseObj.Results.CheckIdVds,parseObj.Results.CheckQiss,parseObj.Results.CheckQoss,...
            parseObj.Results.CheckBreakdown,parseObj.Results.Vt,parseObj.Results.Vds,parseObj.Results.Ciss,parseObj.Results.Coss,parseObj.Results.BreakdownScalingForVds);
            for structArrayIndex=1:length(test)
                [outputStruct_runSimscapeSimulation,SimscapeVoltages,SimscapeCurrents,SimscapeTime,qissValid,qossValid]=ee.internal.validation.mosfet.runSimscapeSimulation...
                (parseObj.Results.filename,test,structArrayIndex,nodes);
                outputStruct1.plots_Simscape(structArrayIndex).results=outputStruct_runSimscapeSimulation.plots(structArrayIndex).results;
                if(parseObj.Results.GeneratePlots==1)
                    plotWithSPICE=0;
                    [outputStruct_plotSimscapeResults]=ee.internal.validation.mosfet.plotSimscapeResults(fileName,SimscapeVoltages,SimscapeCurrents,SimscapeTime,test,structArrayIndex,nodes,parseObj.Results.Vt,...
                    parseObj.Results.Vds,plotWithSPICE,qissValid,qossValid);
                    outputStruct2.Simscapeplots(structArrayIndex)=outputStruct_plotSimscapeResults.Simscapeplots(structArrayIndex);
                end
            end

            if isempty(which(fileName))
                outputStruct1.Simscape_file=fileName;
            else
                outputStruct1.Simscape_file=which(fileName);
            end
            outputStruct1.Simscape_file_timestamp=dir(outputStruct1.Simscape_file).date;
        else
            if not(ispc)
                pm_error("physmod:ee:SPICE2sscvalidation:PlatformError");
            else
                if isempty(parseObj.Results.Subcircuit)
                    pm_error("physmod:ee:SPICE2sscvalidation:SubcircuitError");
                end
                netlistStringArray=spiceNetlist2String(parseObj.Results.SPICEFile);
                subcircuit=spiceSubckt(netlistStringArray,parseObj.Results.Subcircuit);
                numberOfNodes=length(subcircuit.nodes);
                if(numberOfNodes==0)
                    pm_error("physmod:ee:SPICE2sscvalidation:SubcircuitNameError",parseObj.Results.Subcircuit);
                elseif~((numberOfNodes==3)||(numberOfNodes==4)||(numberOfNodes==5)||(numberOfNodes==6))
                    pm_error("physmod:ee:SPICE2sscvalidation:NodesError",numberOfNodes);
                end
                test=ee.internal.validation.mosfet.generateTests(numberOfNodes,parseObj.Results.CheckIdVgs,parseObj.Results.CheckIdVds,parseObj.Results.CheckQiss,parseObj.Results.CheckQoss,...
                parseObj.Results.CheckBreakdown,parseObj.Results.Vt,parseObj.Results.Vds,parseObj.Results.Ciss,parseObj.Results.Coss,parseObj.Results.BreakdownScalingForVds);
                for structArrayIndex=1:length(test)
                    if(parseObj.Results.SPICETool=="LTspice")
                        [outputStruct_compareSPICEWithSimscape,SPICEVoltages,SPICECurrents,SPICETime,SimscapeVoltages,SimscapeCurrents,SimscapeTime,qissValid,qossValid]=...
                        ee.internal.validation.mosfet.compareSPICEWithSimscape(parseObj.Results.filename,parseObj.Results.SPICEFile,parseObj.Results.Subcircuit,subcircuit,test,structArrayIndex,...
                        parseObj.Results.SPICETool,parseObj.Results.SPICEPath,parseObj.Results.RelTol,parseObj.Results.AbsTol,parseObj.Results.VnTol,parseObj.Results.AbsErrTol,...
                        parseObj.Results.RelErrTol,parseObj.Results.Rawfile_idvgstj27,parseObj.Results.Rawfile_idvgstj75,parseObj.Results.Rawfile_idvds,parseObj.Results.Rawfile_qiss,...
                        parseObj.Results.Rawfile_qoss,parseObj.Results.Rawfile_breakdown);
                        outputStruct1.plots_SPICEToolvsSimscape(structArrayIndex).results=outputStruct_compareSPICEWithSimscape.plots(structArrayIndex).results;
                        if(parseObj.Results.GeneratePlots==1)
                            [outputStruct_plotSPICEToolResults,legends,handle]=ee.internal.validation.mosfet.plotSPICEToolResults(parseObj.Results.Subcircuit,parseObj.Results.SPICETool,...
                            SPICEVoltages,SPICECurrents,SPICETime,test,structArrayIndex,subcircuit.nodes,qissValid,qossValid);
                            outputStruct2.SPICEplots(structArrayIndex)=outputStruct_plotSPICEToolResults.SPICEplots(structArrayIndex);
                            plotWithSPICE=1;
                            [outputStruct_plotSimscapeResults]=ee.internal.validation.mosfet.plotSimscapeResults(parseObj.Results.Subcircuit,SimscapeVoltages,SimscapeCurrents,SimscapeTime,...
                            test,structArrayIndex,subcircuit.nodes,parseObj.Results.Vt,parseObj.Results.Vds,plotWithSPICE,qissValid,qossValid,legends,handle);
                            outputStruct2.Simscapeplots(structArrayIndex)=outputStruct_plotSimscapeResults.Simscapeplots(structArrayIndex);
                        end
                    elseif(parseObj.Results.SPICETool=="SIMetrix")
                        [outputStruct_compareSIMetrixWithSimscape,SIMetrixVoltages,SIMetrixCurrents,SIMetrixTime,SimscapeVoltages,SimscapeCurrents,SimscapeTime,qissValid,qossValid]=...
                        ee.internal.validation.mosfet.compareSIMetrixWithSimscape(parseObj.Results.filename,parseObj.Results.SPICEFile,parseObj.Results.Subcircuit,subcircuit,test,structArrayIndex,...
                        parseObj.Results.SPICETool,parseObj.Results.SPICEPath,parseObj.Results.RelTol,parseObj.Results.AbsTol,parseObj.Results.VnTol,parseObj.Results.AbsErrTol,...
                        parseObj.Results.RelErrTol,parseObj.Results.file2header_IdVgstj27,parseObj.Results.file2_IdVgstj27,parseObj.Results.file3header_IdVgstj27,...
                        parseObj.Results.file3_IdVgstj27,parseObj.Results.file4header_IdVgstj27,parseObj.Results.file4_IdVgstj27,parseObj.Results.file2header_IdVgstj75,...
                        parseObj.Results.file2_IdVgstj75,parseObj.Results.file3header_IdVgstj75,parseObj.Results.file3_IdVgstj75,parseObj.Results.file4header_IdVgstj75,...
                        parseObj.Results.file4_IdVgstj75,parseObj.Results.file2header_IdVds,parseObj.Results.file2_IdVds,parseObj.Results.file3header_IdVds,parseObj.Results.file3_IdVds,...
                        parseObj.Results.file4header_IdVds,parseObj.Results.file4_IdVds,parseObj.Results.file2header_Qiss,parseObj.Results.file2_Qiss,parseObj.Results.file3header_Qiss,...
                        parseObj.Results.file3_Qiss,parseObj.Results.file4header_Qiss,parseObj.Results.file4_Qiss,parseObj.Results.file2header_Qoss,parseObj.Results.file2_Qoss,parseObj.Results.file3header_Qoss,parseObj.Results.file3_Qoss,...
                        parseObj.Results.file4header_Qoss,parseObj.Results.file4_Qoss,parseObj.Results.file2header_Breakdown,parseObj.Results.file2_Breakdown,parseObj.Results.file3header_Breakdown,...
                        parseObj.Results.file3_Breakdown,parseObj.Results.file4header_Breakdown,parseObj.Results.file4_Breakdown);
                        outputStruct1.plots_SPICEToolvsSimscape(structArrayIndex).results=outputStruct_compareSIMetrixWithSimscape.plots(structArrayIndex).results;
                        if(parseObj.Results.GeneratePlots==1)
                            [outputStruct_plotSPICEToolResults,legends,handle]=ee.internal.validation.mosfet.plotSPICEToolResults(parseObj.Results.Subcircuit,parseObj.Results.SPICETool,...
                            SIMetrixVoltages,SIMetrixCurrents,SIMetrixTime,test,structArrayIndex,subcircuit.nodes,qissValid,qossValid);
                            outputStruct2.SIMetrixplots(structArrayIndex)=outputStruct_plotSPICEToolResults.SIMetrixplots(structArrayIndex);
                            plotwithSIMetrix=1;
                            [outputStruct_plotSimscapeResults]=ee.internal.validation.mosfet.plotSimscapeResults(parseObj.Results.Subcircuit,SimscapeVoltages,SimscapeCurrents,SimscapeTime,test,...
                            structArrayIndex,subcircuit.nodes,parseObj.Results.Vt,parseObj.Results.Vds,plotwithSIMetrix,qissValid,qossValid,legends,handle);
                            outputStruct2.Simscapeplots(structArrayIndex)=outputStruct_plotSimscapeResults.Simscapeplots(structArrayIndex);
                        end
                    else
                        pm_error("physmod:ee:SPICE2sscvalidation:SPICEToolError");
                    end
                end
                if isempty(which(parseObj.Results.SPICEFile))
                    outputStruct1.SPICE_library_file=parseObj.Results.SPICEFile;
                else
                    outputStruct1.SPICE_library_file=which(parseObj.Results.SPICEFile);
                end
                outputStruct1.SPICE_library_file_timestamp=dir(outputStruct1.SPICE_library_file).date;
                if isempty(which(parseObj.Results.filename))
                    outputStruct1.Simscape_file=parseObj.Results.filename;
                else
                    outputStruct1.Simscape_file=which(parseObj.Results.filename);
                end
                outputStruct1.Simscape_file_timestamp=dir(outputStruct1.Simscape_file).date;
            end
        end
    otherwise
        pm_error("physmod:ee:SPICE2sscvalidation:FirstArgumentError");
    end
end

function CleanupFunc(f)
    if fopen(f)
        p=fopen(f);
        fclose(f);
        delete(p);
    end
end