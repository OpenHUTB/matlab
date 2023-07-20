




function typeReplData=getTypeReplacementVerification(datamgr,reportConfig)

    pTypeReplReport=slci.internal.Profiler('SLCI',...
    'TypeReplacementVerification',...
    '','');


    typeReplReader=datamgr.getReader('TYPEREPLACEMENT');
    typeReplObjects=typeReplReader.getObjects(typeReplReader.getKeys());



    typeReplData.SUMMARY=[];


    typeReplDetail=struct('SECTION',[],'TABLEDATA',[],'REASON',[]);


    typeReplDetail.SECTION.CONTENT='';


    numObjects=numel(typeReplObjects);
    assert(numObjects>0,...
    'Number of type replacement objects must be greater than zero');

    tableData(numObjects)=struct('CODEGENTYPE',[],...
    'REPLACEMENTNAME',[],...
    'STATUS',[],...
    'SOURCELIST',[]);
    for k=1:numObjects

        typeObject=typeReplObjects{k};


        tableData(k).CODEGENTYPE.CONTENT=typeObject.getCodeGenType();


        tableData(k).REPLACEMENTNAME.CONTENT=typeObject.getReplName();
        if isempty(tableData(k).REPLACEMENTNAME.CONTENT)
            tableData(k).REPLACEMENTNAME.CONTENT='-';
        end


        status=typeObject.getStatus();
        tableData(k).STATUS.CONTENT=reportConfig.getStatusMessage(status);
        tableData(k).STATUS.ATTRIBUTES=status;


        codeKeys=typeObject.getCodeObject();
        numCodeObjects=numel(codeKeys);
        if numCodeObjects>0
            codeReader=datamgr.getReader('CODE');
            codeObjects=codeReader.getObjects(codeKeys);
            tableData(k).SOURCELIST=slci.report.formatSourceCodeObjects(...
            codeObjects);
        else
            tableData(k).SOURCELIST.SOURCEOBJ.CONTENT='-';
        end
    end

    typeReplDetail.TABLEDATA=tableData;
    typeReplDetail.REASON=[];

    typeReplData.DETAIL.SECTIONLIST=typeReplDetail;

    pTypeReplReport.stop();
end
