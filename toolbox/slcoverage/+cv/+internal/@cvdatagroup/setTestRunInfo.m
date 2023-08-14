function setTestRunInfo(this,testRunIfno)




    cvds=getAll(this);
    for idx=1:numel(cvds)
        ccvd=cvds{idx};

        for cidx=1:numel(ccvd)
            ccvd(cidx).testRunInfo=testRunIfno;
        end
    end
end
