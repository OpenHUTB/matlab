classdef XilinxVivadoTvrParser
    methods(Static,Access=private)





























        function metaAndMap=linesToUnstructuredMap(timingPathPartition)
            import BA.New.ReportParser.XilinxVivadoTvrParser;
            import BA.New.Util;


            getVal=@(field,i,isNum)XilinxVivadoTvrParser.getValue(field,timingPathPartition{i},isNum);


            source=getVal(':SOURCE:',1,false);
            dest=getVal(':DESTINATION:',2,false);
            dataPathDelay=getVal(':DATAPATHDELAY:',3,true);
            clockPathDelay=getVal(':CLOCKPATHDELAY:',4,true);
            clockUncertainty=getVal(':CLOCKUNCERTAINTY:',5,true);


            timingPathMetadata=containers.Map(...
            {'source','dest','dataPathDelay','clockPathDelay','clockUncertainty'},...
            {source,dest,dataPathDelay,clockPathDelay,clockUncertainty}...
            );


            dataPaths=Util.partitionByBeginEnd(...
            @(lines)strcmp(lines,':DATAPATHSTART:'),...
            @(lines)strcmp(lines,':DATAPATHEND:'),...
timingPathPartition...
            );



            dataPath=dataPaths{1};















            dataPathPairs=Util.extractKeyValuePairsAcc(dataPath);

            metaAndMap=containers.Map({'metadata','data'},{timingPathMetadata,dataPathPairs});
        end










        function value=getValue(field,timingLine,isNumerical)
            import BA.New.Util;
            assert(startsWith(timingLine,field));


            value=timingLine(length(field)+1:end);
            if isNumerical

                value=Util.ifElse(isempty(value),@()0,@()str2double(value));
            end
        end
    end

    methods(Static,Access=private)

        function equals=unstructuredDataPathEq(a,b)
            import BA.New.ReportParser.XilinxVivadoTvrParser;
            import BA.New.Util;
            aDataPathNames=a{1};
            bDataPathNames=b{1};
            equals=length(aDataPathNames)==length(bDataPathNames)...
            &&Util.all(...
            @(i)strcmp(aDataPathNames{i},bDataPathNames{i}),...
            1:length(aDataPathNames)...
            );
        end


        function equals=unstructuredTimingPathEq(a,b)
            import BA.New.ReportParser.XilinxVivadoTvrParser;
            import BA.New.Util;

            aData=a('data');
            bData=b('data');
            aMeta=a('metadata');
            bMeta=b('metadata');

            getSource=@(meta)meta('source');
            getDest=@(meta)meta('dest');

            equals=strcmp(getSource(aMeta),getSource(bMeta))...
            &&strcmp(getDest(aMeta),getDest(bMeta))...
            &&length(aData)==length(bData)...
            &&XilinxVivadoTvrParser.unstructuredDataPathEq(aData,bData);
        end

        function uniq=uniqifyDataPaths(unstructuredTimingPathMap)
            import BA.New.ReportParser.XilinxVivadoTvrParser;
            import BA.New.Util;
            uniqDataPaths=Util.uniq(...
            @XilinxVivadoTvrParser.unstructuredDataPathEq,...
            unstructuredTimingPathMap('data')...
            );
            uniq=containers.Map({'data','metadata'},{uniqDataPaths,unstructuredTimingPathMap('metadata')});
        end

        function uniqTimingPaths=uniqifyTimingPaths(unstructuredMaps)
            import BA.New.ReportParser.XilinxVivadoTvrParser;
            import BA.New.Util;
            uniqTimingPaths=Util.uniq(@XilinxVivadoTvrParser.unstructuredTimingPathEq,unstructuredMaps);
        end

        function path=timingPath2Path(timingPath)
            import BA.New.ReportIR.Path;

            data=timingPath('data');
            components=data{1};
            delays=data{2};

            metadata=timingPath('metadata');
            path=Path(components,delays,metadata);
        end

    end

    methods(Static)










        function report=parse(timingFile)
            import BA.New.ReportParser.XilinxVivadoTvrParser;
            import BA.New.Util;
            import BA.New.ReportIR.Report;
            import BA.New.ReportIR.Path;


            timingPathPartitions=Util.partitionByBeginEnd(...
            @(lines)strcmp(lines,':TIMINGPATHSTART:'),...
            @(lines)strcmp(lines,':TIMINGPATHEND:'),...
            Util.readlines(timingFile)...
            );



            unstructuredTimingPaths=Util.map(...
            @XilinxVivadoTvrParser.linesToUnstructuredMap,...
timingPathPartitions...
            );


            unstructuredTimingPaths=Util.map(@(map)XilinxVivadoTvrParser.uniqifyDataPaths(map),unstructuredTimingPaths);
            unstructuredTimingPaths=XilinxVivadoTvrParser.uniqifyTimingPaths(unstructuredTimingPaths);

            paths=Util.map(@XilinxVivadoTvrParser.timingPath2Path,unstructuredTimingPaths);
            report=Report(paths);
        end
    end
end
