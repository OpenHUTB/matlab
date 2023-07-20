function genSTMCallback(ofile,callbackList,type,varargin)








    tcObj=[];
    if(nargin>3)
        tcObj=varargin{1};
    end

    testId=0;
    if(nargin>4)
        testId=varargin{2};
    end

    iterationId=0;
    if(nargin>5)
        iterationId=varargin{3};
    end


    pLoad='';
    if(nargin>6)
        pLoad=varargin{4};
    end

    fid=fopen(ofile,'w');


    if(~isempty(tcObj))

        itName='';
        if(iterationId>0)
            iter=sltest.internal.TestIterationWrapper(iterationId,testId);
            itName=iter.Name;
        end


        iterationNameScript=['sltest_iterationName =''',helperFixString(itName),''';'];
        fprintf(fid,'%s\n\n',iterationNameScript);


        testCaseString=['sltest_testCase.Name =''',helperFixString(tcObj.Name),''';'];
        testCaseString=[testCaseString,'sltest_testCase.TestType =''',tcObj.TestType,''';'];
        testCaseString=[testCaseString,'sltest_testCase.Description =''',helperFixString(tcObj.Description),''';'];
        testCaseString=[testCaseString,'sltest_testCase.Enabled =',num2str(tcObj.Enabled),';'];


        tagCellArrayString='{';
        tags=tcObj.Tags;
        for i=1:length(tags)
            tagCellArrayString=[tagCellArrayString,'''',helperFixString(tags{i}),''' '];%#ok
        end

        tagCellArrayString=[tagCellArrayString,'}'];

        testCaseString=[testCaseString,'sltest_testCase.Tags =',tagCellArrayString,';'];



        fprintf(fid,'%s\n\n',testCaseString);

        if(type==0)


        elseif(type==1)

            pLoadString=['sltest_bdroot =''',pLoad.sltest_bdroot,''';'];
            pLoadString=[pLoadString,'sltest_sut = sprintf(''',helperFixString(pLoad.sltest_sut),''');'];
            pLoadString=[pLoadString,'sltest_isharness =',num2str(pLoad.sltest_isharness),';'];
            fprintf(fid,'%s\n\n',pLoadString);
        elseif(type==2)

        end
    end

    for k=1:length(callbackList)
        fprintf(fid,'%s\n\n',callbackList{k});
    end
    fclose(fid);

end

function str=helperFixString(str)
    str=strrep(str,'''','''''');
end
