
function generateInLineHDLCodeReport(~,flattening_pipe_file,title,~,p,JavaScriptBody)




    w=hdlhtml.reportingWizard(flattening_pipe_file,title);

    if~isempty(JavaScriptBody)
        w.setAttribute('onload',JavaScriptBody);
    end

    modelMarkedForFlattening=false;
    ntks=p.Networks;



    for i=length(ntks):-1:1
        flatten=ntks(i).hasUserFlattenedNics()||ntks(i).hasUserInLinedNics();
        if(strcmpi(ntks(i).getFlattenHierarchy(),'on')||flatten)
            modelMarkedForFlattening=true;
            break;
        end
    end


    if modelMarkedForFlattening
        section=w.createSectionTitle(DAStudio.message('hdlcoder:report:lateFlatteningStatus'));
        w.commitSection(section);
        w.addBreak(2);
        [inlineHdlCodeStatus,opportunitiesTobeInlined]=reportInLineHDLCodeinfo(w,p);
        if inlineHdlCodeStatus&&opportunitiesTobeInlined
            w.addFormattedText(DAStudio.message('hdlcoder:report:inliningGenCodeSuccess'),'b');
        else
            if~opportunitiesTobeInlined
                w.addFormattedText(DAStudio.message('hdlcoder:report:noOpportunitiesFound'),'b');
            end
        end
        w.addBreak(2);
    end

    w.addBreak;
    w.dump2ExistingHTML;
end


function[inlineHdlCodeStatus,opportunitiesTobeInlined]=reportInLineHDLCodeinfo(w,p)
    inlineHdlCodeStatus=true;
    opportunitiesTobeInlined=false;
    ntks=p.Networks;
    msglist={};
    linklist={};

    for i=length(ntks):-1:1
        if strcmpi(ntks(i).getFlattenHierarchy(),'on')
            [msg,link]=process(ntks(i),p);
            if~isempty(msg)
                msglist=[msglist,msg];%#ok<AGROW>
                linklist=[linklist,link];%#ok<AGROW>
                inlineHdlCodeStatus=false;
                opportunitiesTobeInlined=true;
            end
        end
    end

    topNtk=p.getTopNetwork;
    if~topNtk.hasUserInLinedNics()&&strcmpi(topNtk.getFlattenHierarchy(),'on')

        opportunitiesTobeInlined=false;
    end

    for i=length(ntks):-1:1

        if ntks(i).hasUserInLinedNics()
            opportunitiesTobeInlined=true;
            break;
        end
    end

    if(~isempty(msglist))

        table=w.createTable(length(msglist),3);
        table.setColHeading(1,DAStudio.message('hdlcoder:report:subsystemColumnHeading'));
        table.setColHeading(2,DAStudio.message('hdlcoder:report:reasonForFlatteningNotSuccessColumnHeading'));

        for i=1:length(msglist)
            table.createEntry(i,1,hdlhtml.reportingWizard.generateSystemLink(linklist{i}{1}));
            table.createEntry(i,2,msglist{i}{1});
        end
        w.commitTable(table);
        w.addBreak;
    end
end

function[msgList,link]=process(ntwk,p)
    msgList={};
    link={};

    for i=1:numel(ntwk.Components)
        comp=ntwk.Components(i);
        compList=[];
        if(comp.isNetworkInstance)
            refntwk=comp.ReferenceNetwork;
            if(refntwk.isRAM)
                compList=[compList,'<li>',DAStudio.message('hdlcoder:optimization:InLineRam'),'</li>'];%#ok<AGROW>
            elseif(refntwk.isNfpNetwork)
                compList=[compList,'<li>',DAStudio.message('hdlcoder:optimization:InLineNFP'),'</li>'];%#ok<AGROW>
            elseif(refntwk.dontTouch)
                compList=[compList,'<li>',DAStudio.message('hdlcoder:optimization:InLinePseudoElab'),'</li>'];%#ok<AGROW>
            elseif(refntwk.NumberOfPirGenericPorts>0)
                compList=[compList,'<li>',DAStudio.message('hdlcoder:optimization:InLineGenerics'),'</li>'];%#ok<AGROW>
            end
        end
        if~isempty(compList)
            path=[];%#ok<NASGU>
            msgList{end+1}={compList};%#ok<AGROW>   
            link{end+1}={p.getSimulinkPotentialName(comp,true)};%#ok<AGROW>
        end
    end
end

function mapinfo=generateMapFile(w,p)
    mapinfo=[];
    hDrv=slhdlcoder.HDLCoder;
    scriptGen=hdlshared.EDAScriptsBase(...
    p.getEntityNames,...
    p.getEntityPaths,...
    hDrv.TestBenchFilesList);

    if~isempty(scriptGen.entityFileNames)

        tablesize=numel(scriptGen.entityFileNames);
        table=w.createTable(tablesize,2);
        table.setColHeading(1,DAStudio.message('hdlcoder:report:subsystemColumnHeading'));
        table.setColHeading(2,DAStudio.message('hdlcoder:report:hdlFileColumnHeading'));
        pathlist=scriptGen.EntityPathList;
        fileNameList={};
        if(isempty(pathlist{end})&&hdlgetparameter('vhdl_package_required'))


            for i=1:numel(scriptGen.EntityPathList)-1
                fileNameList{i}=scriptGen.entityFileNames{i+1};%#ok<AGROW>
            end
        else
            fileNameList=scriptGen.entityFileNames;
        end
        for i=1:tablesize
            if~isempty(pathlist{i})
                table.createEntry(i,1,pathlist{i});
                link2File=sprintf('<a href="matlab:edit(''%s'');">%s</a>',...
                fullfile(scriptGen.CodeGenDirectory,fileNameList{i}),fileNameList{i});
                table.createEntry(i,2,link2File);
            end
        end
        w.commitTable(table);
        w.addBreak;
    end
end

