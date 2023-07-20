



function verifyInputCodeLines(obj,msgData)


    datManagerObj=obj.getCacheDataManagerObj();
    inspectedFiles=datManagerObj.getMetaData('InspectedCodeFiles');

    shortToFullFileName=containers.Map('KeyType','char','ValueType','char');
    for i=1:numel(inspectedFiles.sourceFiles)
        fileNameList=regexp(inspectedFiles.sourceFiles(i),filesep,'split');
        fileNameLists=[char(fileNameList{1,1}(end))];
        shortToFullFileName(fileNameLists)=char(inspectedFiles.sourceFiles(i));
    end


    codeTabSummary="";




    splitFileName=string(regexp(msgData.CodeLines,':','split'));
    inputFileName=char(splitFileName(1));
    linelist=split(splitFileName(2),',');

    inputLines=getCodelinesList(linelist);
















    if~isKey(shortToFullFileName,inputFileName)
        codeTabSummary=DAStudio.message('Slci:slcireview:JustificationCodeInvalidFileName');
    else

        codeLocations=slci.internal.ReportUtil.parseCode(shortToFullFileName(inputFileName));
        for i=1:numel(inputLines)
            num_of_rows=size(codeLocations,1);
            if~(str2double(inputLines(i))>=1&&str2double(inputLines(i))<=num_of_rows)
                codeTabSummary=DAStudio.message('Slci:slcireview:JustificationCodeInvalidCodeLines');
                break;
            end
        end
    end


    msg.Summary=codeTabSummary;
    msg.msgID='getVerifyInputCodeLines';
    msg.type='getVerifyInputCodeLines';
    message.publish(obj.getChannel,msg);
end


function codeLines=getCodelinesList(linelist)
    codeLines=[];
    for j=1:length(linelist)
        if contains(linelist(j),'-')
            str=linelist(j);
            bounds=split(str,'-');
            for k=str2num(string(bounds(1))):str2num(string(bounds(2)))
                codeLines=[codeLines,k];
            end
        else
            codeLines=[codeLines,linelist(j)];
        end
    end

end