classdef SIMetrix2MatlabInternal








































    properties(Access=public)
        title;
        warnings;
        analysis;
    end

    properties(Access=private)
        scaleFactors=struct(...
        't',1e12,...
        'g',1e9,...
        'meg',1e6,...
        'k',1e3,...
        'mil',25.4e-6,...
        'm',1e-3,...
        'u',1e-6,...
        'n',1e-9,...
        'p',1e-12,...
        'f',1e-15);
    end
    methods
        function this=SIMetrix2MatlabInternal(filename,varargin)

            filename=strtrim(filename);

            [~,~,ext]=fileparts(filename);
            if~strcmp(ext,".out")

                pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:FileShouldHaveExtensionOut');
            end

            fid=fopen(filename,'r','n');
            if fid<3

                pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:CanNotFind',filename);
            end

            SIMetrixOut=split(fileread(filename),newline);
            fclose(fid);


            if~strncmpi(SIMetrixOut{3},"*** SIMetrix",12)

                pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:FileMustBeGeneratedBySIMetrix');
            end


            [~,titleLine]=this.getExpression(SIMetrixOut,"\*\*\* TITLE\:");
            if length(titleLine)~=1

                pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
            end
            [~,titleStart]=regexp(SIMetrixOut{titleLine},"\*\*\* TITLE:\s*");
            title=SIMetrixOut{titleLine}(titleStart+1:end-1);
            titleEnd=regexp(title,"\*\*\*");
            i=1;
            while isempty(titleEnd)
                title=[title,SIMetrixOut{titleLine+i}];
                titleEnd=regexp(title,"\*\*\*");
                i=i+1;
            end
            this.title=title(1:titleEnd-1);


            warnings=this.getExpression(SIMetrixOut,"(?<=\*\*\* Warning \*\*\*)[^\*]+");
            warnings=unique(warnings);
            if isempty(warnings)

                this.warnings{1}="No";
            else
                this.warnings=unique(warnings);
            end





            [~,startTimeLine]=this.getExpression(SIMetrixOut,"(?<=\*\*\*\s)Starting\s(\w+\s)+analysis at\s\d+\:\d+");

            [~,anaylysisStatisticsLine]=this.getExpression(SIMetrixOut,"Analysis statistics");

            if length(startTimeLine)==length(anaylysisStatisticsLine)
                if~all(anaylysisStatisticsLine>startTimeLine)

                    pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
                end
            else

                pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
            end


            jj=0;
            for ii=1:length(startTimeLine)

                analysisRaw=SIMetrixOut(startTimeLine(ii):anaylysisStatisticsLine(ii));

                [analysisCard,analysisCardLine]=this.getExpression(analysisRaw,'(?<=\*\*\*\sAnalysis card\:\s)[^\"\*]+\S+(?=\s*\*\*\*)');

                if length(analysisCard)~=1||analysisCardLine~=3

                    pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
                end


                simulationType=regexp(lower(analysisCard{1}),"(?<=\.)[a-z]+",'match');
                if length(simulationType)==1
                    switch simulationType{1}
                    case "tran"
                        jj=jj+1;

                        this.analysis{jj}.type="Transient";
                        this.analysis{jj}.card=analysisCard{1};


                        [~,simulationOptionsLine]=this.getExpression(analysisRaw,"(?<=\*\*\*\s+)Simulation Options");

                        [~,starLine]=this.getExpression(analysisRaw,"\*{80,}");

                        simulationOptionsLineStart=starLine(find(starLine>simulationOptionsLine,1))+1;
                        simulationOptionsLineEnd=starLine(find(starLine>simulationOptionsLineStart,1))-1;

                        options=analysisRaw(simulationOptionsLineStart:simulationOptionsLineEnd);
                        this.analysis{jj}.options=options(~cellfun(@isempty,regexp(options,"\w+")));


                        [~,tabulatedVectorsLine]=this.getExpression(analysisRaw,"(?<=\*\*\*\s+)Tabulated Vectors");


                        tabulatedVectorsLineInSIMetrixOut=startTimeLine(ii)+tabulatedVectorsLine-1;


                        cardCheck=regexp(analysisRaw{tabulatedVectorsLine+2},'(?<=\*\*\*\s+Analysis card\:\s*\")[^\"]+','match');
                        if isempty(cardCheck)

                            pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
                        else
                            if~strncmp(cardCheck{1},this.analysis{jj}.card,length(this.analysis{jj}.card))

                                pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
                            end
                        end


                        printError=this.getExpression(analysisRaw,"Cannot evaluate \S+");
                        if isempty(printError)

                            this.analysis{jj}.errors{1}="No";
                        else
                            this.analysis{jj}.errors=unique(printError);
                        end


                        tabulatedVectors=analysisRaw(tabulatedVectorsLine:end);


                        [sweepVariable,sweepVariableLine]=this.getExpression(tabulatedVectors,"(?<=\*\*\s)\w+\=\S+");


                        [variablesName,variablesNameLine]=this.getExpression(tabulatedVectors,"^Time(\w|\W)*");

                        if isempty(sweepVariableLine)

                            numberOfSimulation=1;

                            numberOfPrintLine=length(variablesNameLine);
                        else

                            sweepName=this.getExpression(sweepVariable,"\w+(?=\=)");
                            sweepName=unique(sweepName);
                            sweepVec=this.getExpression(sweepVariable,"(?<=\=)\S+");

                            unitNames=fieldnames(this.scaleFactors);
                            sweepVec=regexprep(sweepVec,"(?i)(?<![a-z]\d*|\_\d*)(\.?\d++(e[+-]?\d++)?)+"...
                            +unitNames,"($1*"+cellfun(@(x)(this.scaleFactors.(x)),unitNames)+")");

                            if length(sweepName)~=1
                                pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
                            end

                            this.analysis{jj}.sweepName=sweepName{1};
                            this.analysis{jj}.sweepVectors=cellfun(@str2num,sweepVec);


                            numberOfSimulation=length(sweepVariableLine);

                            numberOfPrintLine=length(variablesNameLine)/length(sweepVariableLine);
                        end


                        varialbe=unique(variablesName,'stable');
                        if length(varialbe)~=numberOfPrintLine
                            pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
                        end


                        for kk=1:numberOfPrintLine

                            splitedVarialbe=split(varialbe{kk});
                            splitedVarialbe=splitedVarialbe(~cellfun(@isempty,splitedVarialbe));


                            if~strcmp(splitedVarialbe{1},"Time")
                                pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:OuputFileFormatError');
                            end

                            this.analysis{jj}.variableName{1}=splitedVarialbe{1};
                            this.analysis{jj}.variableName(end+1:end+length(splitedVarialbe)-1)=splitedVarialbe(2:end);
                        end

                        fid=fopen(filename,'r','n');

                        for ll=1:numberOfSimulation

                            if ll~=numberOfSimulation


                                for kk=1:numberOfPrintLine

                                    if kk~=numberOfPrintLine





                                        dataStart=tabulatedVectorsLineInSIMetrixOut+variablesNameLine(numberOfPrintLine*(ll-1)+kk);
                                        dataEnd=tabulatedVectorsLineInSIMetrixOut+variablesNameLine(numberOfPrintLine*(ll-1)+kk+1)-2;
                                    else




                                        dataStart=tabulatedVectorsLineInSIMetrixOut+variablesNameLine(numberOfPrintLine*(ll-1)+kk);
                                        dataEnd=tabulatedVectorsLineInSIMetrixOut+sweepVariableLine(ll+1)-3;
                                    end


                                    dataLinNum1=split(SIMetrixOut{dataStart});
                                    dataLinNum1=dataLinNum1(~cellfun(@isempty,dataLinNum1));

                                    formatSpec=char(2*length(dataLinNum1));
                                    for i=1:length(dataLinNum1)
                                        formatSpec(2*i-1:2*i)='%f';
                                    end
                                    frewind(fid);
                                    dataCell=textscan(fid,formatSpec,dataEnd-dataStart+1,'Headerlines',dataStart-1,'CollectOutput',true);
                                    dataMat=dataCell{1};


                                    if kk==1
                                        dataMatCombined=dataMat;
                                    else
                                        [~,dataMatWidth]=size(dataMat);
                                        dataMatCombined(:,end+1:end+dataMatWidth-1)=dataMat(:,2:dataMatWidth);
                                    end
                                end

                            else

                                for kk=1:numberOfPrintLine

                                    if kk~=numberOfPrintLine





                                        dataStart=tabulatedVectorsLineInSIMetrixOut+variablesNameLine(numberOfPrintLine*(ll-1)+kk);
                                        dataEnd=tabulatedVectorsLineInSIMetrixOut+variablesNameLine(numberOfPrintLine*(ll-1)+kk+1)-2;
                                    else




                                        dataStart=tabulatedVectorsLineInSIMetrixOut+variablesNameLine(numberOfPrintLine*(ll-1)+kk);
                                        dataEnd=tabulatedVectorsLineInSIMetrixOut+length(tabulatedVectors)-3;
                                    end


                                    dataLinNum1=split(SIMetrixOut{dataStart});
                                    dataLinNum1=dataLinNum1(~cellfun(@isempty,dataLinNum1));

                                    formatSpec=char(2*length(dataLinNum1));
                                    for i=1:length(dataLinNum1)
                                        formatSpec(2*i-1:2*i)='%f';
                                    end
                                    frewind(fid);
                                    dataCell=textscan(fid,formatSpec,dataEnd-dataStart+1,'Headerlines',dataStart-1,'CollectOutput',true);
                                    dataMat=dataCell{1};


                                    if kk==1
                                        dataMatCombined=dataMat;
                                    else
                                        [~,dataMatWidth]=size(dataMat);
                                        dataMatCombined(:,end+1:end+dataMatWidth-1)=dataMat(:,2:dataMatWidth);
                                    end
                                end
                            end
                            this.analysis{jj}.variableVectors{ll}=dataMatCombined;
                        end
                        fclose(fid);

                    otherwise

                        pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:AnalysisTypeAreNotSupported');
                    end
                else

                    pm_error('physmod:ee:utilities:spice:SIMetrix2Matlab:AnalysisTypeAreNotSupported');
                end
            end
        end

        function[strings,line]=getExpression(this,raw,expression)


            strings=regexp(raw,expression,'ignorecase','match');
            line=find(~cellfun(@isempty,strings));
            strings=strings(line);
            strings=cellfun(@(x)x{1},strings,'UniformOutput',false);
        end
    end
end