function makeModelVersionChapter(sddRpt)




















    import mlreportgen.report.*


    chap=Chapter();
    chap.Title=getString(message("slreportgen:StdRpt:SDD:versionSectTitle"));


    title=getString(message("slreportgen:StdRpt:SDD:versionSectVersion"));
    value=get_param(sddRpt.Model,"ModelVersion");
    makeDescriptionPara(title,value,chap);


    title=getString(message("slreportgen:StdRpt:SDD:versionSectModified"));
    value=get_param(sddRpt.Model,"LastModifiedDate");
    makeDescriptionPara(title,value,chap);


    title=getString(message("slreportgen:StdRpt:SDD:versionSectChecksum"));
    value=getChecksum(sddRpt.RootSystem);
    makeDescriptionPara(title,value,chap);


    append(sddRpt,chap);
end

function para=makeDescriptionPara(title,value,chap)





    import mlreportgen.dom.*


    para=Paragraph();
    para.WhiteSpace="preserve";


    titleObj=Text(strcat(title," "));
    titleObj.WhiteSpace="preserve";
    titleObj.StyleName="paragraphTitle";
    append(para,titleObj);


    valueObj=Text(value);
    append(para,valueObj);


    append(chap,para);
end

function checksum=getChecksum(system)

    sysClass=class(get_param(system,"Object"));

    sysChecksum=[];
    try
        switch sysClass
        case "Simulink.BlockDiagram"
            sysChecksum=Simulink.BlockDiagram.getChecksum(system);
        case "Simulink.SubSystem"
            sysChecksum=Simulink.SubSystem.getChecksum(system);
            sysChecksum=sysChecksum.Value;
        end

        if~isempty(sysChecksum)
            checksum=strjoin(string(sysChecksum));
        else
            checksum=...
            getString(message("slreportgen:StdRpt:SDD:checksumError",system));
        end
    catch
        checksum=...
        getString(message("slreportgen:StdRpt:SDD:checksumError",system));
    end
end