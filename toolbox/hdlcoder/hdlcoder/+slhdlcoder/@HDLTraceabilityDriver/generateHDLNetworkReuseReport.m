
function generateHDLNetworkReuseReport(this,reuse_file,title,model,p,JavaScriptBody)





    w=hdlhtml.reportingWizard(reuse_file,title);
    w.setHeader(title);
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end


    w.addBreak(3);




    hDrv=hdlcurrentdriver;
    NoReuseInlineParamsOff=hDrv.FrontEnd.NoReuseInlineParamsOff;
    if NoReuseInlineParamsOff
        w.addText(DAStudio.message('hdlcoder:report:NRInlineParams'))
    end


    if~NoReuseInlineParamsOff
        [AnyReuse]=reportHDLNetworkReuseInfo(w,p);
        w.addBreak(2);
    end

    if~NoReuseInlineParamsOff
        [AnyUnreusable]=reportUnreusable(w,p);
        w.addBreak(2);
    end


    w.dumpHTML;

end




function AnyUnreusable=reportUnreusable(w,p)

    hDrv=hdlcurrentdriver;
    NoReuseTunableMaskParams=hDrv.FrontEnd.NoReuseTunableMaskParams;
    NoReuseReadOnlySubsystems=hDrv.FrontEnd.NoReuseReadOnlySubsystems;


    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:potentialCodeReuse'));
    w.commitSection(section);
    w.addBreak(1);

    if isempty(NoReuseTunableMaskParams)&&isempty(NoReuseReadOnlySubsystems)

        w.addText(DAStudio.message('hdlcoder:report:noMissedOpportunitiesDetected'));
        AnyUnreusable=false;
        return
    else
        AnyUnreusable=true;
    end



    nrows=height(NoReuseTunableMaskParams)+numel(NoReuseReadOnlySubsystems);
    table=w.createTable(nrows,2);
    table.setAttribute('width','100%');
    table.setColHeading(1,DAStudio.message('hdlcoder:report:subsystemColumnHeading'));
    table.setColHeading(2,DAStudio.message('hdlcoder:report:reasonColumnHeading'));

    if(~isempty(NoReuseTunableMaskParams))

        TunablePaths=NoReuseTunableMaskParams.name;
        trows=height(NoReuseTunableMaskParams);
        for ii=1:trows

            ssPath=hdlhtml.reportingWizard.generateSystemLink(TunablePaths{ii},[],true);
            message=['<li>',ssPath,'</li>'];


            table.createEntry(ii,1,message);


            table.createEntry(ii,2,DAStudio.message('hdlcoder:report:detectingTunableMaskedParameters'));
        end
    end

    if(~isempty(NoReuseReadOnlySubsystems))

        trows=height(NoReuseTunableMaskParams);
        rorows=numel(NoReuseReadOnlySubsystems);
        for ii=1:rorows

            blkPath=getfullname(NoReuseReadOnlySubsystems(ii));
            ssPath=hdlhtml.reportingWizard.generateSystemLink(blkPath,[],true);
            message=['<li>',ssPath,'</li>'];


            table.createEntry(trows+ii,1,message);


            table.createEntry(trows+ii,2,DAStudio.message('hdlcoder:report:NRReadOnlySubsystems'));
        end
    end

    w.commitTable(table);

end


function AnyReuse=reportHDLNetworkReuseInfo(w,p)

    hDrv=hdlcurrentdriver;
    record=hDrv.FrontEnd.ReusedSSReport;


    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:NRReuseSummary'));
    w.commitSection(section);
    w.addBreak(1);


    if isempty(record)
        w.addText(DAStudio.message('hdlcoder:report:NRNoCloneFound'));
        w.addBreak(1);
        AnyReuse=false;
        return
    else
        AnyReuse=true;
    end


    ngroups=length(record);


    table=w.createTable(ngroups,2);
    table.setAttribute('width','100%');
    table.setColHeading(1,DAStudio.message('hdlcoder:report:subsystemColumnHeading'));
    table.setColHeading(2,DAStudio.message('hdlcoder:report:count'));


    for ii=1:ngroups
        grp=record{ii};


        messageList=[];
        for jj=1:length(grp)
            ssPath=hdlhtml.reportingWizard.generateSystemLink(grp{jj},[],true);
            messageList=[messageList,'<li>',ssPath,'</li>'];
        end


        table.createEntry(ii,1,messageList);


        table.createEntry(ii,2,string(length(grp)));
    end

    w.commitTable(table);

end
