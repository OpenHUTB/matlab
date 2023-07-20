function generateRecommendationsSerialization(this,ser_file,title,model,p,JavaScriptBody)





    w=hdlhtml.reportingWizard(ser_file,title);
    w.setHeader(title);
    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end
    w.addBreak(3);



    [streamingSucc,sharingSucc]=reportSummary(w,p);

    colorMap=containers.Map({1,2,3,4,5,6,7},{'yellow','red','blue','lightblue','magenta','green','gray'});


    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:streamingReport'));
    w.commitSection(section);

    w.addBreak(2);

    if(streamingSucc)

        reportStreamingInfo(this,w,p,colorMap);
    else
        w.addText(DAStudio.message('hdlcoder:report:noSubsystemWithStreamingFactor'));
        w.addBreak;
    end

    w.addLine;


    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:sharingReport'));
    w.commitSection(section);

    w.addBreak(2);

    if(sharingSucc)

        reportSharingInfo(this,w,p,colorMap);
    else
        w.addText(DAStudio.message('hdlcoder:report:noSubsystemWithSharingFactor'));
        w.addBreak;
    end

    w.addBreak;

    if hdlgetparameter('generatevalidationmodel')
        reportGeneratedModel(w,model);
        w.addBreak
    end

    hDrv=hdlcurrentdriver;
    if hDrv.mdlIdx==numel(hDrv.AllModels)

        if(isprop(hDrv.BackEnd,'OutModelFile'))
            this.publishGeneratedModelLink(w,hDrv.BackEnd.OutModelFile);
        end
    else

        genMdlName=getGeneratedModelName(hDrv.getParameter('generatedmodelnameprefix'),...
        p.ModelName,false);
        this.publishGeneratedModelLink(w,genMdlName);
    end
    w.addBreak;
    w.dumpHTML;
end


function reportGeneratedModel(w,model)

    table=w.createTable(1,2);
    table.createEntry(1,1,DAStudio.message('hdlcoder:report:validationModel'));
    driver=hdlmodeldriver(model);
    genModel=driver.CoverifyModelName;
    alink=Simulink.report.ReportInfo.getMatlabCallHyperlink(sprintf('matlab:coder.internal.code2model(''%s'')',genModel));
    table.createEntry(1,2,[alink{1},genModel,alink{2}]);
    w.commitTable(table);
end

function msg=getFeedbackHighlightMessage(this,feedbackmsg,turnonmsg)
    if hdlgetparameter('HighlightFeedbackLoops')
        filstr=hdlgetparameter('HighlightFeedbackLoopsFile');
        [~,v]=fileattrib(fullfile(hdlGetCodegendir(this),[filstr,'.m']));
        filename=v.Name;
        linkstr=sprintf('<a href="matlab:run(''%s'')">%s</a>',filename,filename);

        msg=DAStudio.message(feedbackmsg);
        msg=[msg,linkstr];
    else
        msg=DAStudio.message(turnonmsg);
    end

end


function[streamingFlag,sharingFlag]=reportSummary(w,p)
    ntks=p.Networks;
    validNtks=[];
    for i=length(ntks):-1:1
        ntk=ntks(i);
        if ntk.getStreamingFactor>0||ntk.getSharingFactor>0
            validNtks=[validNtks,ntk];%#ok<AGROW>
        end
    end
    if~isempty(validNtks)

        table=w.createTable(length(validNtks),3);
        table.setColHeading(1,DAStudio.message('hdlcoder:report:subsystemColumnHeading'));
        table.setColHeading(2,DAStudio.message('hdlcoder:report:streamingFactorColumnHeading'));
        table.setColHeading(3,DAStudio.message('hdlcoder:report:sharingFactorColumnHeading'));
        for i=1:length(validNtks)
            ntk=validNtks(i);
            if~isempty(ntk.FullPath)
                table.createEntry(i,1,hdlhtml.reportingWizard.generateSystemLink(ntk.FullPath));
            else
                table.createEntry(i,1,ntk.Name);
            end
            table.createEntry(i,2,num2str(ntk.getStreamingFactor));
            table.createEntry(i,3,num2str(ntk.getSharingFactor));
        end
        w.commitTable(table);
        w.addBreak(2);
    end

    streamingFlag=p.localStreamingRequested;
    sharingFlag=p.localSharingRequested;
end


function reportStreamingInfo(this,w,p,colorMap)
    bclearHighlighting=false;
    vN=p.Networks;

    for ii=1:length(vN)
        hN=vN(ii);
        sf=hN.getStreamingFactor;
        if sf>0
            nwpath=hN.FullPath;
            if(length(hN.instances)>1)
                w.addFormattedText(DAStudio.message('hdlcoder:report:subsystems',this.getAtomicSubsystems(hN)),'b');
                w.addBreak;
                w.addText(DAStudio.message('hdlcoder:report:atomic_subsystems',hdlhtml.reportingWizard.generateSystemLink(nwpath)));
            else
                w.addFormattedText(DAStudio.message('hdlcoder:report:subsystem',hdlhtml.reportingWizard.generateSystemLink(nwpath)),'b');
            end
            w.addBreak(2);
            w.addText([DAStudio.message('hdlcoder:report:streamingFactor',''),num2str(hN.getStreamingFactor)]);
            w.addBreak(2);
            filename=getHighlightingFilename(hN,'Streaming');
            linkstr=sprintf('matlab:run(''%s'')',filename);
            if hN.streamingSuccess()
                w.addLink(DAStudio.message('hdlcoder:report:HighlightStreamingGroupsAndDiagnostics'),linkstr);
                w.addBreak(2);
                streamingInfo=containers.Map('KeyType','uint32','ValueType','any');
                streamingInfo=getStreamingInfo(hN,streamingInfo);
                if(~isempty(streamingInfo))
                    nGroups=streamingInfo.Count;
                    table=w.createTable(nGroups,3);
                    table.setColHeading(1,DAStudio.message('hdlcoder:report:streaming_group'));
                    table.setColHeading(2,DAStudio.message('hdlcoder:report:streaming_inferredfactor'));
                    keys=streamingInfo.keys;
                    for jj=1:nGroups
                        table.createEntry(jj,1,getBlockLinks(streamingInfo(keys{jj}).gmhandles,jj,colorMap));
                        table.createEntry(jj,2,num2str(streamingInfo(keys{jj}).Factor));
                    end
                    w.commitTable(table);
                    w.addBreak;
                end
                bclearHighlighting=true;
            else
                w.addText(DAStudio.message('hdlcoder:report:streamingOptimizationUnsuccessful'));
                w.addBreak(2);
                msg=hN.streamingStatusMsg;
                if hN.streamingStatusId==p.srsFeedbackId
                    msg=getFeedbackHighlightMessage(this,'hdlcoder:report:streamingfeedbackloopmsg','hdlcoder:report:streamingturnonhighlightfeedbackloops');
                end

                if isempty(msg)
                    msg='none';
                end
                if isempty(hN.getStreamingCulprit)
                    w.addText([DAStudio.message('hdlcoder:report:reason',''),msg]);
                else


                    w.addLink(DAStudio.message('hdlcoder:report:HighlightStreamingDiagnostics'),linkstr);
                    bclearHighlighting=true;
                end
            end
            w.addBreak(2);

            sHint=hN.getStreamingHint;

            if sHint<=0
                w.addText(DAStudio.message('hdlcoder:report:noLegalStreamingFactor'));
                w.addBreak(3);
            end

        end
    end

    if(bclearHighlighting)
        generateClearHighlightingLink(w);
    end

end



function reportSharingInfo(this,w,p,colorMap)
    vN=p.Networks;
    bclearHighlighting=false;
    for ii=1:length(vN)
        hN=vN(ii);
        sf=hN.getSharingFactor;
        if sf>0
            nwpath=hN.FullPath;
            if(length(hN.instances)>1)
                w.addFormattedText(DAStudio.message('hdlcoder:report:subsystems',this.getAtomicSubsystems(hN)),'b');
                w.addBreak;
                w.addText(DAStudio.message('hdlcoder:report:atomic_subsystems',hdlhtml.reportingWizard.generateSystemLink(nwpath)));
            else
                w.addFormattedText(DAStudio.message('hdlcoder:report:subsystem',hdlhtml.reportingWizard.generateSystemLink(nwpath)),'b');
            end
            w.addBreak(2);
            w.addText([DAStudio.message('hdlcoder:report:sharingFactor',''),num2str(hN.getSharingFactor)]);
            w.addBreak(2);
            filename=getHighlightingFilename(hN,'Sharing');
            linkstr=sprintf('matlab:run(''%s'')',filename);
            if hN.sharingSuccess()


                w.addLink(DAStudio.message('hdlcoder:report:HighlightSharedResourcesAndDiagnostics'),linkstr);
                w.addBreak(2);
                sharingInfo=getSharingInfo(hN,[],colorMap);
                if(~isempty(sharingInfo))
                    nGroups=length(sharingInfo);
                    table=w.createTable(nGroups,6);
                    table.setColHeading(1,DAStudio.message('hdlcoder:report:sharing_groupid'));
                    table.setColHeading(2,DAStudio.message('hdlcoder:report:sharing_resourcetype'));
                    table.setColHeading(3,DAStudio.message('hdlcoder:report:sharing_iowordlengths'));
                    table.setColHeading(4,DAStudio.message('hdlcoder:report:sharing_groupsize'));
                    table.setColHeading(5,DAStudio.message('hdlcoder:report:blockname'));
                    table.setColHeading(6,DAStudio.message('hdlcoder:report:sharing_colorlegend'));
                    cmd=['run(''',getClearHighlightingFullName(),''');'];
                    for jj=1:nGroups
                        table.createEntry(jj,1,num2str(sharingInfo(jj).SharingGroupId));
                        table.createEntry(jj,2,sharingInfo(jj).Type);
                        table.createEntry(jj,3,sharingInfo(jj).Bitwidth);
                        table.createEntry(jj,4,num2str(sharingInfo(jj).GroupSize));
                        linkstr=sprintf('<a href="matlab:%s">%s</a>',[cmd,sharingInfo(jj).SharedResourcesLinks],num2str(sharingInfo(jj).Name));
                        table.createEntry(jj,5,linkstr);
                        colorstr=sprintf('<table><td style="background-color: %s;color:%s">&nbsp</td></table>',colorMap(sharingInfo(jj).colorid),colorMap(sharingInfo(jj).colorid));
                        table.createEntry(jj,6,colorstr);
                    end
                    w.commitTable(table);
                end
                bclearHighlighting=true;
            else
                w.addText(DAStudio.message('hdlcoder:report:sharingOptimizationUnsuccessful'));
                w.addBreak(2);
                msg=hN.sharingStatusMsg;

                if hN.sharingStatusId==p.srsFeedbackId
                    msg=getFeedbackHighlightMessage(this,'hdlcoder:report:sharingfeedbackloopmsg','hdlcoder:report:sharingturnonhighlightfeedbackloops');
                end

                if isempty(msg)
                    msg='none';
                end

                if isempty(hN.getSharingCulprit)
                    w.addText([DAStudio.message('hdlcoder:report:reason',''),msg]);
                else


                    w.addLink(DAStudio.message('hdlcoder:report:HighlightSharingDiagnostics'),linkstr);
                    bclearHighlighting=true;
                end
            end
            w.addBreak(2);

            sHint=hN.getSharingHint;

            if sHint<=0
                w.addText(DAStudio.message('hdlcoder:report:noLegalSharingFactor'));
                w.addBreak(3);
            end

        end
    end

    if(bclearHighlighting)
        generateClearHighlightingLink(w);
    end

end



function linkstr=getBlockLinks(handles,groupid,colorMap)
    color=colorMap(mod(groupid-1,length(colorMap))+1);
    highlightStr=['run(''',getClearHighlightingFullName(),''');'];
    highlightStr=[highlightStr,'cs.HiliteType = ''user1'';'];
    highlightStr=[highlightStr,'cs.ForegroundColor = ''black'';'];
    highlightStr=[highlightStr,'cs.BackgroundColor = ''',color,''';'];
    highlightStr=[highlightStr,'set_param(0, ''HiliteAncestorsData'', cs);'];
    count=length(handles);
    for jj=1:count
        if(handles(jj)>0)
            highlightStr=[highlightStr,'hilite_system(''',getfullname(handles(jj)),''',''user1'');'];
        end
    end
    linkstr=sprintf('<a href="matlab:%s">%s</a>',highlightStr,num2str(groupid));
end


function fullname=generateClearHighlightingLink(w)
    fullname=getClearHighlightingFullName();
    linkstr=sprintf('matlab:run(''%s'')',fullname);
    w.addLink(DAStudio.message('hdlcoder:report:ClearHighlighting'),linkstr);
    w.addBreak;
end


function fullname=getClearHighlightingFullName()
    hDrv=hdlcurrentdriver;
    fname=hDrv.getParameter('ClearHighlightingFile');
    baseCodeGenDir=hDrv.hdlGetBaseCodegendir();
    fullname=fullfile(baseCodeGenDir,[fname,'.m']);
end


function streamingInfo=getStreamingInfo(hN,sInfo)
    vComps=hN.Components;
    numComps=length(vComps);
    for i=1:numComps
        hC=vComps(i);
        grpid=hC.getStreamingGroupId;
        if(grpid>=0)
            if(hC.isNetworkInstance)
                sInfo=getStreamingInfo(hC.ReferenceNetwork,sInfo);
            else
                if(~isKey(sInfo,grpid))
                    sInfo(grpid)=[];
                end
                val=sInfo(grpid);
                if(isfield(val,'gmhandles'))
                    val.gmhandles(end+1)=hC.getGMHandle;
                else
                    val.gmhandles=hC.getGMHandle;
                end
                val.Factor=hC.getActualStreamingFactor;
                sInfo(grpid)=val;
            end
        end
    end
    streamingInfo=sInfo;
end


function sharingInfo=getSharingInfo(hN,sInfo,colorMap)
    vComps=hN.Components;
    numComps=length(vComps);
    for i=1:numComps
        hC=vComps(i);
        grpid=hC.getSharingGroupId;
        if grpid>=length(colorMap)
            grpid=mod(grpid,length(colorMap));
        end
        grpid=grpid+1;
        if(grpid>0)
            count=length(sInfo)+1;
            if(hC.isNetworkInstance&&~hC.ReferenceNetwork.isShared)
                sInfo=getSharingInfo(hC.ReferenceNetwork,sInfo,colorMap);
            else
                sInfo(count).GroupSize=hC.getSharingGroupSize;
                if(hC.getGMHandle>0)
                    [sInfo(count).Bitwidth,sInfo(count).Type]=getIOBitwidth(hC);
                    sInfo(count).SharedResourcesLinks=getSharedResourcesLinks(hC,colorMap(grpid));
                else
                    sInfo(count).Type='';
                    sInfo(count).Bitwidth='';
                    sInfo(count).SharedResourcesLinks='';
                end
                sInfo(count).Name=hC.Name;
                sInfo(count).colorid=grpid;
                sInfo(count).SharingGroupId=hC.getSharingGroupId+1;
            end
        end
    end
    sharingInfo=sInfo;
end


function[bitwidth,blockType]=getIOBitwidth(hC)
    bitwidth='';
    if(hC.getIsTarget)
        blockType=get_param([get_param(hC.getGMHandle,'Parent'),'/',get_param(hC.getGMHandle,'Name'),'/',hC.Name],'BlockType');
    else
        blockType=get_param(hC.getGMHandle,'BlockType');
    end
    inputs=hC.NumberOfPirInputPorts;
    outputs=hC.NumberOfPirOutputPorts;
    switch hC.ClassName
    case{'mul_comp'}
        if(inputs==2&&outputs==1)
            input(1)=hC.PirInputSignals(1).Type.getLeafType.WordLength;
            input(2)=hC.PirInputSignals(2).Type.getLeafType.WordLength;
            output=hC.PirOutputSignals(1).Type.getLeafType.WordLength;
            bitwidth=[num2str(input(1)),'x',num2str(input(2)),' -> ',num2str(output)];
        end
    case{'add_comp'}
        if(inputs==2&&outputs==1)
            signs='++';
            signs=get_param(hC.getGMHandle,'Inputs');

            input(1)=hC.PirInputSignals(1).Type.getLeafType.WordLength;
            input(2)=hC.PirInputSignals(2).Type.getLeafType.WordLength;
            output=hC.PirOutputSignals(1).Type.getLeafType.WordLength;
            bitwidth=[num2str(input(1)),signs(2),num2str(input(2)),' -> ',num2str(output)];
            if(signs(1)=='-')
                bitwidth=[signs(1),bitwidth];
            end
        end
    case{'gain_comp'}
        if(isa(hC.getGainValue,'embedded.fi'))
            wordlen=num2str(hC.getGainValue.WordLength);
        elseif(isa(hC.getGainValue,'double'))
            wordlen='64';
        elseif(isa(hC.getGainValue,'single'))
            wordlen='32';
        else
            wordlen='unknown';
        end
        bitwidth=[num2str(hC.PirInputSignals(1).Type.getLeafType.WordLength),'x',wordlen,' -> ',num2str(hC.PirOutputSignals(1).Type.getLeafType.WordLength)];
    case{'scalarmac_comp'}
        signs=get_param(hC.getGMHandle,'Function');
        signs=strrep(signs,'a',num2str(hC.PirInputSignals(1).Type.getLeafType.WordLength));
        signs=strrep(signs,'b',num2str(hC.PirInputSignals(2).Type.getLeafType.WordLength));
        signs=strrep(signs,'c',num2str(hC.PirInputSignals(3).Type.getLeafType.WordLength));
        bitwidth=[signs,' -> ',num2str(hC.PirOutputSignals(1).Type.getLeafType.WordLength)];
        blockType='Multiply-Add';
    case{'ntwk_instance_comp'}
        if(hC.ReferenceNetwork.isSFHolder)
            blockType='MATLAB Function Block';
        end
    end
end


function linkstr=getSharedResourcesLinks(hC,color)
    linkstr='cs.HiliteType = ''user1'';';
    linkstr=[linkstr,'cs.ForegroundColor = ''black'';'];
    linkstr=[linkstr,'cs.BackgroundColor = ''',color,''';'];
    linkstr=[linkstr,'set_param(0, ''HiliteAncestorsData'', cs);'];
    linkstr=[linkstr,'hilite_system(''',getfullname(hC.getGMHandle),''',''user1'');'];
    hOrigBlock=hC.getSharingOrigCompsHandles;
    if(~isempty(hOrigBlock))
        hOrigBlocks=str2double(strsplit(hOrigBlock,'|'));
        for ii=1:length(hOrigBlocks)
            h=hOrigBlocks(ii);
            if(h>0)
                linkstr=[linkstr,'hilite_system(''',getfullname(h),''',''user1'');'];
            end
        end
    end
end


function filename=getHighlightingFilename(hN,type)
    hDrv=hdlcurrentdriver;
    baseCodeGenDir=hDrv.hdlGetBaseCodegendir();

    filename=[hN.getCtxName,hN.RefNum(2:end)];
    filename=strrep(filename,' ','_');
    filename=strcat('highlight',type,filename);
    [~,v]=fileattrib(fullfile(baseCodeGenDir,[filename,'.m']));
    filename=v.Name;
end






