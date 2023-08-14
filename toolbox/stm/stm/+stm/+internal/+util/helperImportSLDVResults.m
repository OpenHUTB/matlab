function helperImportSLDVResults(tc,inputFile,varargin)


    try


        if exist(inputFile,'file')~=2
            return;
        end


        if(isnumeric(tc))
            tc=sltest.testmanager.TestCase(true,tc);
        end


        [folderLoc,~,~]=fileparts(inputFile);


        dvData=load(inputFile);
        dataFields=fields(dvData);
        if length(dataFields)==1
            sldvData=dvData.(dataFields{1});

            if~isfield(sldvData,'TestCases')
                return;
            end
        else
            return;
        end



        if nargin==3
            idList=varargin{1};
            if(~isempty(idList))
                nIterations=length(idList);
                iterArray=repmat(sltest.testmanager.TestIteration,1,nIterations);
                for k=1:nIterations
                    iterArray(k)=sltest.testmanager.TestIteration();
                    iterArray(k).getIterationSettings(idList(k));
                end
            else
                iterArray=getIterations(tc);
            end
        else
            iterArray=getIterations(tc);
        end
        numIterations=size(sldvData.TestCases,2);


        isFolderCreated=false;

        folderName=folderLoc;


        if(length(iterArray)==numIterations)

            convertedData=Sldv.DataUtils.convertTestCasesToSLDataSet(sldvData);
            if isfield(convertedData.TestCases,'expectedOutput')
                firstBaselineCriteria=[];
                for i=1:numIterations
                    if~isFolderCreated
                        folderName=stm.internal.util.helperCreateUniqueFolder(folderLoc);
                        isFolderCreated=true;
                    end
                    expData=convertedData.TestCases(i).expectedOutput;
                    fName=fullfile(folderName,['TestCase_',num2str(i),'.mat']);
                    save(fName,'expData');
                    clear('expData');

                    bc=tc.addBaselineCriteria(fName,true);


                    if(i==1)
                        firstBaselineCriteria=bc;
                    end

                    setTestParam(iterArray(i),'Baseline',bc.Name);
                    update(iterArray(i));
                end


                if~isempty(firstBaselineCriteria)
                    firstBaselineCriteria.Active=true;
                end
            end
        end
    catch
    end
end

