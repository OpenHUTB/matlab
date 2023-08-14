function generateContents(this,contents_file,title,model)





    w=hdlhtml.reportingWizard(contents_file,title,false);

    w.setFormatting('bgcolor','#eeeeee');


    this.createTOC(w,title,model);


    w.addBreak;


    createHiliteNav(w);


    hDrv=hdlcurrentdriver;
    if hDrv.mdlIdx==numel(hDrv.AllModels)
        createSubmodelLinks(w,hDrv);
    end

    w.dumpHTML;

end


function createHiliteNav(w)

    fontSection=w.createSection(DAStudio.message('hdlcoder:report:highlightNavigation'),'font');
    fontSection.setAttribute('color','#000000');
    boldSection=w.createSection(fontSection.getHTML,'b');


    table=w.createTable(2,1,'',false);
    table.setBorder(0);
    table.setAttribute('style','display: none; margin-top: 10px; margin-bottom: 10px');
    table.setAttribute('cellspacing','0');
    table.setAttribute('cellpadding','1');
    table.setAttribute('width','100%');
    table.setAttribute('bgcolor','#ffffff');
    table.setAttribute('id','rtwIdTracePanel');


    table.createEntry(1,1,boldSection.getHTML);


    prevButtonSection=w.createSection('','input');
    prevButtonSection.setAttribute('type','button');
    prevButtonSection.setAttribute('value','Previous');
    prevButtonSection.setAttribute('style','width: 85');
    prevButtonSection.setAttribute('id','rtwIdButtonPrev');
    prevButtonSection.setAttribute('onClick','if (top.rtwGoPrev) top.rtwGoPrev();');
    prevButtonSection.setAttribute('disabled','disabled');


    nextButtonSection=w.createSection('','input');
    nextButtonSection.setAttribute('type','button');
    nextButtonSection.setAttribute('value','Next');
    nextButtonSection.setAttribute('style','width: 85');
    nextButtonSection.setAttribute('id','rtwIdButtonNext');
    nextButtonSection.setAttribute('onClick','if (top.rtwGoNext) top.rtwGoNext();');
    nextButtonSection.setAttribute('disabled','disabled');


    table.createEntry(2,1,[prevButtonSection.getHTML,nextButtonSection.getHTML]);
    w.commitTable(table);


    w.addText('<!--REPLACE_WITH_GENERATED_FILES-->');
end

function createSubmodelLinks(w,hDrv)
    fontSection=w.createSection(DAStudio.message('hdlcoder:report:referencedModels'),'font');
    fontSection.setAttribute('color','#000000');
    boldSection=w.createSection(fontSection.getHTML,'b');
    numMdls=numel(hDrv.AllModels);


    table=w.createTable(numMdls,1,'',false);
    table.setBorder(0);
    table.setAttribute('style','margin-top: 10px; margin-bottom: 10px');
    table.setAttribute('cellspacing','0');
    table.setAttribute('cellpadding','1');
    table.setAttribute('width','100%');
    table.setAttribute('bgcolor','#ffffff');
    table.setAttribute('id','rtwIdRefModelsPanel');


    table.createEntry(1,1,boldSection.getHTML);

    for ii=1:numMdls-1
        mdlName=hDrv.AllModels(ii).modelName;
        linkedSection=w.createSection(mdlName,'a');
        linkedSection.setAttribute('href',['../',mdlName,'/html/',mdlName,'_codegen_rpt.html']);
        linkedSection.setAttribute('target','_top');
        linkedSection.setAttribute('class','extern');
        linkedSection.setAttribute('name','external_link');
        table.createEntry(ii+1,1,linkedSection.getHTML);
    end

    w.commitTable(table);
end


