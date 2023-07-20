function createProxyTaskEventSourceFile(modelName,fName)




    import soc.internal.*

    allData=[];
    theMap=connectivity.getTaskManagerEventSources(modelName);
    keys=theMap.keys;
    for idx=1:numel(keys)
        thisTask=keys{idx};
        theEventSrc=theMap(thisTask);
        if theEventSrc.IsFromFile
            h=socFileReader(theEventSrc.DatasetName);
            data=h.getData(theEventSrc.SourceName);
        elseif theEventSrc.IsFromTimeseriesObject
            data=soc.internal.getTimeseriesObject(theEventSrc.ObjectName);
        else
            continue
        end
        semIdx=double(getProxyTaskSemaphoreIdx(modelName,thisTask));
        d=[data.Time,semIdx*ones(length(data.Time),1)];
        if isempty(allData)
            allData=d;
        else
            allData=[allData;d];%#ok<AGROW>
        end
    end
    if~isempty(allData)
        allData=sortrows(allData,1);

        hdrFile=[fName,'.h'];
        fid=fopen(hdrFile,'w');
        fprintf(fid,'#define SOC_MAXEVENTSRCCOUNTER %d\n',length(allData));
        fclose(fid);

        srcFile=[fName,'.c'];
        fid=fopen(srcFile,'w');
        fprintf(fid,'#include "mw_cpuloadgenerator.h"\n');
        fprintf(fid,'#include "%s"\n',hdrFile);
        fprintf(fid,'SOC_eventSourceDataType SOC_eventSourceData[] = {\n');
        for i=1:length(allData)
            if(i<length(allData)),sep=',';else,sep='';end
            fprintf(fid,'{%f, %d}%s\n',allData(i,1),allData(i,2),sep);
        end
        fprintf(fid,'};\n');
        fclose(fid);
    end
end
