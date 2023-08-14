function resourceUsage=generateResourceUsageFPF(megafunctionModule,cmd,deviceFamily)



    import matlab.io.xml.dom.*

    resourceUsage=[];
    if~hdlgetparameter('resourceReport')
        return;
    end

    resourceReportFile=fullfile(alteratarget.getExtraDir(cmd,deviceFamily),[megafunctionModule,'_report.xml']);
    if(exist(resourceReportFile,'file')==2)
        fstr=fileread(resourceReportFile);
        fstr=strrep(fstr,'<freqeuncy>','</frequency>');
        fstr=strrep(fstr,['<luts>',10],['</luts>',10]);
        fid=fopen(resourceReportFile,'w');
        assert(fid~=-1);
        fprintf(fid,'%s',fstr);
        fclose(fid);
        xmlFile=fullfile(resourceReportFile);
        rootDOM=parseFile(Parser,xmlFile);
        luts=getResourceCount(rootDOM,'luts');
        mbits=getResourceCount(rootDOM,'mbits');
        mblocks=getResourceCount(rootDOM,'mblocks');
        multipliers=getResourceCount(rootDOM,'multiplies');
        resourceUsage=sprintf('%d luts;%d mbits;%d mblocks;%d multipliers',luts,mbits,mblocks,multipliers);
    else
        resourceUsage=[];
    end

end

function count=getResourceCount(rootDOM,tagName)
    element=rootDOM.getElementsByTagName(tagName);
    count=str2double(element.item(0).getTextContent);
end


