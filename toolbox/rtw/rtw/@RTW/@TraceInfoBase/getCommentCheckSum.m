function[cSum]=getCommentCheckSum(~,fullFile,cSum,commInx)





    fullFile=regexprep(fullFile,'\',filesep);
    fullFile=regexprep(fullFile,'/',filesep);
    if(nargin==2)
        commInx=1;
        cSum(1).file{1}=fullFile;
    else
        cSum(1).file{end+1}=fullFile;
    end


    cSum(commInx).text={};
    cSum(commInx).cSum={};
    cSum(commInx).lineToIndex=[];



    fid=fopen(fullFile,'r');
    if(fid>0)
        fInfo=fread(fid,inf);
        fchar=char(fInfo');


        fclose(fid);


        [startIdx,endIdx,cSum(commInx).lineToIndex]=coder.report.internal.findComments(fchar);
        numComments=length(startIdx);
        cSum(commInx).text=cell(1,numComments);
        cSum(commInx).cSum=cell(1,numComments);
        LF=['',10,''];
        CR=['',13,''];
        for i=1:numComments
            cSum(commInx).text{i}=fchar(startIdx(i):endIdx(i));

            tmpStr=regexprep(cSum(commInx).text{i},'"','');
            tmpStr=regexprep(tmpStr,LF,'');
            tmpStr=regexprep(tmpStr,CR,'');
            res=CGXE.Utils.md5(tmpStr);
            cSum(commInx).cSum{i}=sprintf('CS_%9.0f%9.0f%9.0f%9.0f',...
            res(1),res(2),res(3),res(4));
        end
    end
end

