function[ResultDescription,ResultDetails]=utilDisplayResult(inputTxt,...
    ResultDescription,ResultDetails,fullTextMode)






    if nargin<4
        fullTextMode=false;
    end

    if fullTextMode

        htmpPre=strfind(inputTxt,'<a href=');
        htmpPos=strfind(inputTxt,'</a>');
        numLink=length(htmpPre);

        if(numLink~=0)
            linkStr=cell(1,numLink);
            for i=1:numLink
                linkStr{i}=inputTxt(htmpPre(i):(htmpPos(i)+3));
            end


            numRemainStr=numLink+1;

            remainStr=cell(1,numRemainStr);

            remainStr{1}=inputTxt(1:(htmpPre(1)-1));

            remainStr{numRemainStr}=inputTxt((htmpPos(numLink)+4):length(inputTxt));


            for i=2:numLink
                beginIndex=htmpPos(i-1)+4;
                endIndex=htmpPre(i)-1;
                remainStr{i}=inputTxt(beginIndex:endIndex);
            end

            for i=1:numRemainStr

                remainStr{i}=strrep(remainStr{i},'&','&amp;');
                remainStr{i}=strrep(remainStr{i},'\''','&apos;');
                remainStr{i}=strrep(remainStr{i},'<','&lt;');
                remainStr{i}=strrep(remainStr{i},'>','&gt;');
                remainStr{i}=strrep(remainStr{i},'\"','&quot;');
            end


            inputTxt='';
            for i=1:numLink
                inputTxt=[inputTxt,remainStr{i},linkStr{i}];%#ok<AGROW>
            end
            inputTxt=[inputTxt,remainStr{numRemainStr}];
        else

            inputTxt=strrep(inputTxt,'&','&amp;');
            inputTxt=strrep(inputTxt,'\''','&apos;');
            inputTxt=strrep(inputTxt,'<','&lt;');
            inputTxt=strrep(inputTxt,'>','&gt;');
            inputTxt=strrep(inputTxt,'\"','&quot;');
        end



        ResultDescription{end+1}=sprintf('<pre>%s</pre>',inputTxt);
        ResultDetails{end+1}='';

    else


        lineStrs=regexp(inputTxt,char(10),'split');

        if~isempty(lineStrs)


            lineLen=length(lineStrs);
            emptyStrs=cell(1,lineLen);
            for ii=1:lineLen
                emptyStrs{ii}='';
            end


            ResultDescription=[ResultDescription,lineStrs];
            ResultDetails=[ResultDetails,emptyStrs];

        end

    end
