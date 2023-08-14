function this=createDerivedData(this,lhs,rhs,op)




    cvdArray=[lhs,rhs];


    defaultValue=cvdArray(1);

    for i=2:length(cvdArray)
        if defaultValue.simMode~=cvdArray(i).simMode
            error(message('Slvnv:simcoverage:cvdata:IncompSimModes',...
            SlCov.CovMode.toString(defaultValue.simMode),SlCov.CovMode.toString(cvdArray(i).simMode)));
        end
    end

    if nargin==4&&ischar(op)
        this.codeCovData=SlCov.results.CodeCovData.performOp(lhs.codeCovData,rhs.codeCovData,op);
    end

    this.isDerivedData=true;
    this.traceOn=any([cvdArray.traceOn]);
    this.test=mergeTest([cvdArray.test]);
    this.dbVersion=defaultValue.dbVersion;

    this.filter=combineFilter({cvdArray.filter});

    cv.internal.cvdata.aggregateDescription(this,[],cvdArray);

    cv.coder.cvdatamgr.instance().addOrUpdate(this);


    function combined=combineFilter(fileNameArr)

        emptyIdx=cellfun(@isempty,fileNameArr);
        fileNameArr(emptyIdx)=[];

        if isempty(fileNameArr)
            combined='';
            return
        end


        for i=1:numel(fileNameArr)
            if~iscell(fileNameArr{i})
                fileNameArr{i}=fileNameArr(i);
            end
        end

        combined=unique([fileNameArr{:}]);


        if numel(fileNameArr)==1
            combined=fileNameArr{1};
        end


        function testSettings=mergeTestSettings(cvtArray)

            testSettingsArray=[cvtArray.settings];
            allMetrics=fields(testSettingsArray);
            testSettings=testSettingsArray(1);

            for i=2:numel(allMetrics)
                metric=allMetrics{i};
                testSettings.(metric)=any([testSettingsArray.(metric)]);
            end


            function cvt=mergeTest(cvtArray)

                cvt=cv.coder.cvtest();
                cvt.settings=mergeTestSettings(cvtArray);
                cvt.options=cvtArray(1).options;
                prop1=cvtArray.label;
                for ii=2:numel(cvtArray)
                    prop1=joinStrProp(prop1,cvtArray(ii).label);
                end
                cvt.label=prop1;


                function res=joinStrProp(prop1,prop2)
                    res=prop1;

                    if contains(prop1,prop2)
                        prop2='';
                    elseif contains(prop2,prop1)
                        prop1='';
                    end

                    if~isempty(prop1)&&~isempty(prop2)
                        res=[prop1,newline,prop2];
                    elseif~isempty(prop1)
                        res=prop1;
                    elseif~isempty(prop2)
                        res=prop2;
                    end


