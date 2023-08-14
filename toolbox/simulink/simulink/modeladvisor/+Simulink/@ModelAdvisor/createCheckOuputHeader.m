function htmlOut=createCheckOuputHeader(this,firstCheckToRun,currentCheckIndex)%#ok<INUSL>
    htmlOut='';



    if firstCheckToRun&&this.CmdLine
        htmlOut=[htmlOut,'<p><hr /></p>'];
    end

    if currentCheckIndex>0
        CheckObj=this.CheckCellArray{currentCheckIndex};

        DefineNameStr=['CheckRecord_',num2str(CheckObj.Index)];
        currentCheckTitle=CheckObj.Title;

        htmlOut=[htmlOut,'<a name="',DefineNameStr,'"></a>'];


        checkHeader=ModelAdvisor.Element('div','class','CheckHeader',...
        'id',['Header_',CheckObj.ID]);
        checkHeader.addContent('<!-- Model Advisor Image Link Placeholder -->');
        checkHeading=ModelAdvisor.Element('span','class','CheckHeading',...
        'id',['Heading_',CheckObj.ID]);
        checkHeading.addContent(currentCheckTitle);
        checkHeader.addContent(checkHeading);

    else
        DefineNameStr='CheckRecord_-1';
        currentCheckTitle='unknown';

        htmlOut=[htmlOut,'<a name="',DefineNameStr,'"></a>'];


        checkHeader=ModelAdvisor.Element('div','class','CheckHeader',...
        'id','Header_unknown');
        checkHeader.addContent('<!-- Model Advisor Image Link Placeholder -->');
        checkHeading=ModelAdvisor.Element('span','class','CheckHeading',...
        'id','Heading_unknown');
        checkHeading.addContent(currentCheckTitle);
        checkHeader.addContent(checkHeading);
    end


    htmlOut=[htmlOut,'<!-- Model Advisor Check Content div placeholder -->',checkHeader.emitHTML];
end