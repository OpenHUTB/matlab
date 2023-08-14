function out=execute(this,d,varargin)





    if this.StepRequirements&&rmiLicenseYok()
        out=d.createComment(getString(message('Slvnv:reqmgt:licenseCheckoutFailed')));
        return;
    end

    out=d.createDocumentFragment();


    [testSeqs,indxToLinkPath]=rptgen_stm.cstm_testseq.findTestSeq;

    nTestSeq=numel(testSeqs);
    for indx=1:nTestSeq


        currTestSequence=testSeqs(indx);


        manager=Stateflow.STT.StateEventTableMan(currTestSequence.Id);


        states=manager.viewManager.chartDataDetails();



        randNo=rand;
        blockPath=[num2str(randNo),'/',getTestSeqPath(this,currTestSequence)];


        if isKey(indxToLinkPath,indx)

            titleText=indxToLinkPath(indx);
            linkText=['('...
            ,getString(message('RptgenSL:rstm_cstm_testseq:libraryLink'))...
            ,' ',getTitle(this,currTestSequence),')'];
        else
            titleText=getTitle(this,currTestSequence);
            linkText='';
        end


        title=createElement(d,'title',titleText);
        sect=createElement(d,'simplesect');
        appendChild(sect,title);


        if~isempty(linkText)
            subTitle=createElement(d,'emphasis',linkText);
            appendChild(sect,subTitle);
        end

        if~strcmp(this.StepContent,'none')||~this.StepRequirements

            getDataSymbols(this,d,sect,currTestSequence);


            getStateList(this,d,sect,states,blockPath);
        end


        getStateData(this,d,sect,states,blockPath);

        appendChild(out,sect);
    end
end

function result=rmiLicenseYok()

    if~builtin('_license_checkout','Simulink_Requirements','quiet')
        result=false;
    else

        result=builtin('_license_checkout','SL_Requirements_Management','quiet');
    end
end
