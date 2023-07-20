function generateBillOfMaterials(this,bom_content_file,title,model,p,tcgInventory,JavaScriptBody)





    w=hdlhtml.reportingWizard(bom_content_file,title);

    w.addCollapsibleJS;

    w.setHeader(DAStudio.message('hdlcoder:report:res_report_title',model));

    if~isempty(tcgInventory)
        w.addBreak(2);
        w.addFormattedText(DAStudio.message('hdlcoder:report:note_about_device_specific_resources'),'bi');
    end


    w.addBreak(3);


    characHandle=hdlcoder.characterization.create();
    characHandle.doit(p);


    addFilterBom(characHandle,p);


    ntks=p.Networks;

    ResourceSummary.multipliers=characHandle.getTotalFrequency('mul_comp');
    ResourceSummary.addersSubtractors=characHandle.getTotalFrequency('add_comp')+characHandle.getTotalFrequency('sub_comp');
    ResourceSummary.registers=characHandle.getTotalFrequency('reg_comp');
    ResourceSummary.oneBitRegisters=characHandle.getTotalFlipflops();
    ResourceSummary.rams=characHandle.getTotalFrequency('mem_comp');
    ResourceSummary.multiplexers=characHandle.getTotalFrequency('mux_comp');
    [ResourceSummary.IOBits,dut_port_info]=slhdlcoder.HDLTraceabilityDriver.calcIOPinsForDut(p);
    ResourceSummary.staticShiftOperators=characHandle.getTotalStaticShiftOps();
    ResourceSummary.dynamicShiftOperators=characHandle.getTotalDynamicShiftOps();

    splitBomContentFile=strsplit(bom_content_file,filesep);
    hdlcodegenstatusFile=fullfile(strjoin(splitBomContentFile(1:end-2),filesep),'hdlcodegenstatus.mat');



    if~strncmpi(bom_content_file,hdlcodegenstatusFile,2)&&strncmpi(bom_content_file,[filesep,filesep],2)
        hdlcodegenstatusFile=[filesep,hdlcodegenstatusFile];
    end

    if isfile(hdlcodegenstatusFile)

        s=load(hdlcodegenstatusFile);
        s.ResourceSummary=ResourceSummary;
        s=orderfields(s);
        save(hdlcodegenstatusFile,'-struct','s');
    else
        save(hdlcodegenstatusFile,'ResourceSummary');
    end

    info={};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_multipliers'),ResourceSummary.multipliers};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_adders_subtractors'),ResourceSummary.addersSubtractors};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_registers'),ResourceSummary.registers};

    info{end+1}={DAStudio.message('hdlcoder:report:number_of_flipflops'),ResourceSummary.oneBitRegisters};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_rams'),ResourceSummary.rams};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_multiplexers'),ResourceSummary.multiplexers};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_io_pins'),ResourceSummary.IOBits};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_staticshift_operators'),ResourceSummary.staticShiftOperators};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_dynamicshift_operators'),ResourceSummary.dynamicShiftOperators};


    hdlDrv=hdlcurrentdriver;
    hdlDrv.cgInfo.resourceInfo=info;


    addSummarySection(w,info);


    w.addBreak(2);


    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:detailed_report'));
    w.commitSection(section);

    w.addBreak(2);





    w.addLine;



    forEachMap=containers.Map;

    topNtk=p.getTopNetwork();
    ntkId=1;
    jsCmds='';

    for i=length(ntks):-1:1
        thisNtk=ntks(i);


        bom=characHandle.getBillOfMaterials(thisNtk);

        skip_bom=isempty(bom)||~isValidNtk(bom);
        isTopNetwork=isequal(topNtk.SimulinkHandle,thisNtk.SimulinkHandle)...
        &&isequal(topNtk.FullPath,thisNtk.FullPath);

        if~isTopNetwork&&skip_bom
            continue;
        end

        ntkInstances=thisNtk.instances;
        numInstances=length(ntkInstances);
        if isempty(ntkInstances)
            path2Ntk=thisNtk.FullPath;
            if~isempty(path2Ntk)
                linkedPath=hdlhtml.reportingWizard.generateSystemLink(path2Ntk);
            else
                linkedPath=thisNtk.Name;
            end
        else
            for j=1:numInstances
                nicComp=ntkInstances(j);
                if(j==1)
                    linkedPath=hdlhtml.reportingWizard.generateSystemLink(getCompPath(p,nicComp));
                else
                    linkedPath=[linkedPath,', '...
                    ,hdlhtml.reportingWizard.generateSystemLink(getCompPath(p,nicComp))];%#ok<AGROW>
                end
            end
        end

        descStr='Subsystem';

        isUserDefined=checkForUserDefinedFcns(bom);
        if isUserDefined
            descStr=DAStudio.message('hdlcoder:report:userDefinedBlock');
        end


        if isempty(linkedPath)

            msg=DAStudio.message('hdlcoder:report:subsystem_report',descStr,num2str(ntkId));
        elseif isempty(findstr(linkedPath,','))%#ok<FSTR>

            [forEachStruct,forEachMap]=getForEachStruct(p,thisNtk,forEachMap);


            if~isempty(forEachStruct.name)
                descStr=DAStudio.message('hdlcoder:report:forEachSubsystem');
            end

            msg=DAStudio.message('hdlcoder:report:subsystem_report_1',descStr,linkedPath);



            if length(forEachStruct.parents)==1
                msg=DAStudio.message('hdlcoder:report:for_each_subsystem_one_parent',...
                msg,forEachStruct.parents{1});
            elseif length(forEachStruct.parents)>1
                msg=DAStudio.message('hdlcoder:report:for_each_subsystem_multiple_parents',...
                msg,strjoin(forEachStruct.parents,', '));
            end


            if forEachStruct.replications>1
                msg=DAStudio.message('hdlcoder:report:for_each_subsystem_instantiations',...
                msg,num2str(forEachStruct.replications));
            end
        else

            msg=DAStudio.message('hdlcoder:report:multiply_instantiated_identical',descStr,num2str(numInstances),linkedPath);
        end

        section=w.createSection(msg,5);
        w.commitSection(section);

        if~skip_bom

            jsCmds=emitBomMultipliers(p,w,bom,ntkId,jsCmds,isUserDefined);


            jsCmds=emitBomAddSubs(p,w,bom,ntkId,jsCmds,isUserDefined);


            jsCmds=emitBomRegisters(p,w,bom,ntkId,jsCmds,isUserDefined);


            jsCmds=emitBomMemory(p,w,bom,ntkId,jsCmds,isUserDefined);


            jsCmds=emitBomMuxes(p,w,bom,ntkId,jsCmds,isUserDefined);


            jsCmds=emitShiftOps(p,w,bom,ntkId,jsCmds,isUserDefined);

        end


        if isTopNetwork
            jsCmds=this.emitIOPortInfo(p,w,dut_port_info,jsCmds);
        end


        w.addLine;


        ntkId=ntkId+1;
    end
    jsCmds=[JavaScriptBody,jsCmds];
    if~isempty(jsCmds)
        w.setAttribute('onload',jsCmds);
    end


    reportUnanalyzableBlocks(w,p)


    w.dumpHTML;


    hdlcoder.characterization.destroy(characHandle);
end


function flag=checkForUserDefinedFcns(bom)
    flag=false;
    if isempty(bom)
        return;
    end

    compInfoSet=bom.getCompInfoSet('add_comp');
    if isempty(compInfoSet)
        compInfoSet=bom.getCompInfoSet('sub_comp');
    end
    if isempty(compInfoSet)
        compInfoSet=bom.getCompInfoSet('mul_comp');
    end
    if isempty(compInfoSet)
        compInfoSet=bom.getCompInfoSet('reg_comp');
    end
    if isempty(compInfoSet)
        compInfoSet=bom.getCompInfoSet('mux_comp');
    end
    if isempty(compInfoSet)
        return;
    end
    compInfo=compInfoSet(1);
    comp=compInfo.getCompVector;
    flag=~isempty(comp)&&(length(comp)==1)&&comp.isSF;
end


function reportUnanalyzableBlocks(w,p)
    unanalyzables=[];
    ntks=p.Networks;
    for i=length(ntks):-1:1
        thisNtk=ntks(i);
        components=thisNtk.Components;
        for j=1:length(components)
            thisComp=components(j);
            if(thisComp.isBlackBox)&&thisComp.SimulinkHandle~=-1&&~isFilterComp(thisComp)
                unanalyzables=[unanalyzables,thisComp];%#ok<AGROW>
            end
        end
    end
    if~isempty(unanalyzables)
        section=w.createSectionTitle(DAStudio.message('hdlcoder:report:unanalyzable_blocks'));
        w.commitSection(section);
        list=w.createList;
        for i=1:length(unanalyzables)
            thisComp=unanalyzables(i);
            path=getCompPath(p,thisComp);
            if isempty(path)
                path=[thisComp.Owner.FullPath,'/',thisComp.Name];

                h=thisComp.SimulinkHandle;
                if~isempty(h)
                    list.createEntry(hdlhtml.reportingWizard.generateSystemLink(path,h));
                else
                    list.createEntry(path);
                end
            else
                list.createEntry(hdlhtml.reportingWizard.generateSystemLink(path));
            end
        end
        w.commitList(list);
    end
end


function createExpandCollapseAll(w,numNtks,numCmps)%#ok<DEFNU>

    section=w.createSection(DAStudio.message('hdlcoder:report:expand_all'),'span');
    section.setAttribute('style','font-family:monospace');
    section.setAttribute('onclick',['hdlTableExpandAll(this, ',num2str(numNtks),', ',num2str(numCmps),')']);
    section.setAttribute('onmouseover','this.style.cursor = ''pointer''');
    w.commitSection(section);
    w.addBlank;

    section=w.createSection(DAStudio.message('hdlcoder:report:collapse_all'),'span');
    section.setAttribute('style','font-family:monospace');
    section.setAttribute('onclick',['hdlTableCollapseAll(this, ',num2str(numNtks),', ',num2str(numCmps),')']);
    section.setAttribute('onmouseover','this.style.cursor = ''pointer''');
    w.commitSection(section);
end


function jsCmds=emitBomMultipliers(p,w,bom,ntkId,jsCmds,isUserDefined)
    totalMuls=bom.getTotalFrequency('mul_comp');
    if totalMuls==0
        return;
    end
    section=w.createSection(DAStudio.message('hdlcoder:report:create_section_multipliers',num2str(totalMuls)),5);
    w.commitSection(section);


    compInfoSet=bom.getCompInfoSet('mul_comp');
    for j=1:length(compInfoSet)
        compInfo=compInfoSet(j);
        jsCmd=addCompEntry(p,w,DAStudio.message('hdlcoder:report:create_section_multipliers_multiply'),compInfo,ntkId,j,isUserDefined);
        if~isempty(jsCmd)
            jsCmds=[jsCmds,jsCmd,';'];%#ok<AGROW>
        end
    end
end


function jsCmds=emitBomAddSubs(p,w,bom,ntkId,jsCmds,isUserDefined)
    totalAddSubs=bom.getTotalFrequency('add_comp')...
    +bom.getTotalFrequency('sub_comp');
    if totalAddSubs==0
        return;
    end
    section=w.createSection(DAStudio.message('hdlcoder:report:create_section_addsubs',num2str(totalAddSubs)),5);
    w.commitSection(section);


    compInfoSet=bom.getCompInfoSet('add_comp');
    for j=1:length(compInfoSet)
        compInfo=compInfoSet(j);
        jsCmd=addCompEntry(p,w,DAStudio.message('hdlcoder:report:create_section_addsubs_adder'),compInfo,ntkId,j,isUserDefined);
        if~isempty(jsCmd)
            jsCmds=[jsCmds,jsCmd,';'];%#ok<AGROW>
        end
    end


    compInfoSet=bom.getCompInfoSet('sub_comp');
    for j=1:length(compInfoSet)
        compInfo=compInfoSet(j);
        jsCmd=addCompEntry(p,w,DAStudio.message('hdlcoder:report:create_section_addsubs_subtractor'),compInfo,ntkId,j,isUserDefined);
        if~isempty(jsCmd)
            jsCmds=[jsCmds,jsCmd,';'];%#ok<AGROW>
        end
    end
end


function jsCmds=emitBomRegisters(p,w,bom,ntkId,jsCmds,isUserDefined)
    totalRegs=bom.getTotalFrequency('reg_comp');
    if totalRegs==0
        return;
    end
    section=w.createSection(DAStudio.message('hdlcoder:report:create_section_registers',num2str(totalRegs)),5);
    w.commitSection(section);


    compInfoSet=bom.getCompInfoSet('reg_comp');
    for j=1:length(compInfoSet)
        compInfo=compInfoSet(j);
        jsCmd=addCompEntry(p,w,DAStudio.message('hdlcoder:report:create_section_registers_register'),compInfo,ntkId,j,isUserDefined);
        if~isempty(jsCmd)
            jsCmds=[jsCmds,jsCmd,';'];%#ok<AGROW>
        end
    end
end


function jsCmds=emitBomMemory(p,w,bom,ntkId,jsCmds,isUserDefined)
    totalMems=bom.getTotalFrequency('mem_comp');
    if totalMems==0
        return;
    end
    section=w.createSection(DAStudio.message('hdlcoder:report:create_section_rams',num2str(totalMems)),5);
    w.commitSection(section);


    compInfoSet=bom.getCompInfoSet('mem_comp');
    for j=1:length(compInfoSet)
        compInfo=compInfoSet(j);
        jsCmd=addCompEntry(p,w,DAStudio.message('hdlcoder:report:create_section_rams_ram'),compInfo,ntkId,j,isUserDefined);
        if~isempty(jsCmd)
            jsCmds=[jsCmds,jsCmd,';'];%#ok<AGROW>
        end
    end
end


function jsCmds=emitBomMuxes(p,w,bom,ntkId,jsCmds,isUserDefined)
    totalMuxes=bom.getTotalFrequency('mux_comp');
    if totalMuxes==0
        return;
    end
    section=w.createSection(DAStudio.message('hdlcoder:report:create_section_multiplexers',num2str(totalMuxes)),5);
    w.commitSection(section);


    compInfoSet=bom.getCompInfoSet('mux_comp');
    for j=1:length(compInfoSet)
        compInfo=compInfoSet(j);
        jsCmd=addCompEntry(p,w,DAStudio.message('hdlcoder:report:create_section_multiplexers_multiplexer'),compInfo,ntkId,j,isUserDefined);
        if~isempty(jsCmd)
            jsCmds=[jsCmds,jsCmd,';'];%#ok<AGROW>
        end
    end
end


function jsCmds=emitShiftOps(p,w,bom,ntkId,jsCmds,isUserDefined)
    totalShiftOps=bom.getTotalShiftOps();
    if totalShiftOps==0
        return;
    end
    section=w.createSection(DAStudio.message('hdlcoder:report:create_section_shift_operators',int2str(totalShiftOps)),5);
    w.commitSection(section);


    function report_static_shift(compInfoSet,shift_dir)
        for j=1:length(compInfoSet)
            compInfo=compInfoSet(j);
            jsCmd=addCompEntry(p,w,DAStudio.message(['hdlcoder:report:static_shift_operators_',shift_dir]),compInfo,ntkId,j,isUserDefined);
            if~isempty(jsCmd)
                jsCmds=[jsCmds,jsCmd,';'];%#ok<AGROW>
            end
        end
    end

    compInfoSet_L=bom.getCompInfoSet('static_left_shift_comp');
    compInfoSet_R=bom.getCompInfoSet('static_right_shift_comp');

    report_static_shift(compInfoSet_L,'Left');
    report_static_shift(compInfoSet_R,'Right');


    function report_dynamic_shift(compInfoSet,shift_dir)
        for j=1:length(compInfoSet)
            compInfo=compInfoSet(j);
            jsCmd=addCompEntry(p,w,DAStudio.message(['hdlcoder:report:dynamic_shift_operators_',shift_dir]),compInfo,ntkId,j,isUserDefined);
            if~isempty(jsCmd)
                jsCmds=[jsCmds,jsCmd,';'];%#ok<AGROW>
            end
        end
    end

    compInfoSet_dynL=bom.getCompInfoSet('dyn_left_shift_comp');
    compInfoSet_dynR=bom.getCompInfoSet('dyn_right_shift_comp');

    report_dynamic_shift(compInfoSet_dynL,'Left');
    report_dynamic_shift(compInfoSet_dynR,'Right');

end


function addSummarySection(w,info)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:summary'));
    w.commitSection(section);

    w.addBreak(2);
    numResources=length(info);
    table=w.createTable(numResources,2);
    for i=1:numResources
        table.createEntry(i,1,info{i}{1});
        table.createEntry(i,2,num2str(info{i}{2}),'center');
    end
    w.commitTable(table);
end


function jsCmd=addCompEntry(p,w,opType,compInfo,id1,id2,isUserDefined)
    [list,numElem]=createCompList(p,w,opType,compInfo);
    formattedCompInfo=formatCompInfo(opType,compInfo);
    typeid=[opType,'_',num2str(id1),'_',num2str(id2)];
    jsCmd=addOnclickEvent(w,formattedCompInfo,numElem,typeid,isUserDefined);
    if~isUserDefined

        addCompLinks(w,list,numElem,typeid);
    end
    w.addBreak;
end


function formattedCompInfo=formatCompInfo(prefix,compInfo)
    numInputs=compInfo.getNumInputs;
    realType=false;
    for i=1:numInputs
        if compInfo.getInputBitwidth(i)==0
            realType=true;
            break;
        end
    end

    if numInputs==1
        if realType

            formattedCompInfo=sprintf('real %s \t\t\t\t\t\t\t: %s',...
            prefix,num2str(compInfo.getFrequency));
        else
            formattedCompInfo=sprintf('%s-bit %s \t\t\t\t\t\t\t: %s',...
            num2str(compInfo.getInputBitwidth(1)),prefix,num2str(compInfo.getFrequency));
        end
        return;
    end


    if strncmpi(prefix,'Dynamic Shift',length('Dynamic Shift'))
        formattedCompInfo=sprintf('%s-bit %s \t\t\t\t\t\t\t: %s',...
        int2str(compInfo.getInputBitwidth(1)),prefix,int2str(compInfo.getFrequency));
        return;
    elseif strncmpi(prefix,'Static Shift',length('Static Shift'))
        formattedCompInfo=sprintf('%s \t\t\t\t\t\t\t: %s',...
        prefix,int2str(compInfo.getFrequency));
        return;
    end

    if realType
        if strcmpi(prefix,'Multiplexer')
            formattedCompInfo=sprintf('real %s-to-1 Multiplexer \t\t\t\t\t\t\t: %s',...
            num2str(compInfo.getInputBitwidth(1)),num2str(compInfo.getFrequency));
            return;
        end

        formattedCompInfo='real ';
        for i=2:numInputs
            formattedCompInfo=[formattedCompInfo,'x',' real '];%#ok<AGROW>
        end
        formattedCompInfo=sprintf('%s %s \t\t\t\t\t\t\t: %s',...
        formattedCompInfo,prefix,num2str(compInfo.getFrequency));
    else
        if strcmpi(prefix,'Multiplexer')
            formattedCompInfo=sprintf('%s-bit %s-to-1 Multiplexer \t\t\t\t\t\t\t: %s',...
            num2str(compInfo.getInputBitwidth(2)),num2str(compInfo.getInputBitwidth(1)),num2str(compInfo.getFrequency));
            return;
        end
        bitwidth1=compInfo.getInputBitwidth(1);

        if strcmpi(prefix,'RAM')
            bitwidth1=2.^bitwidth1;
        end
        formattedCompInfo=num2str(bitwidth1);

        for i=2:numInputs
            formattedCompInfo=[formattedCompInfo,'x',num2str(compInfo.getInputBitwidth(i))];%#ok<AGROW>
        end
        formattedCompInfo=sprintf('%s-bit %s \t\t\t\t\t\t\t: %s',...
        formattedCompInfo,prefix,num2str(compInfo.getFrequency));
    end
end


function flag=isInsideMask(p,subsystemPath)
    flag=false;
    subsysNtk=p.findNetwork('fullname',subsystemPath);
    if isempty(subsysNtk)||subsysNtk.SimulinkHandle==-1
        flag=true;
    end
end


function comp=findComp(p,subsystemPath,compName)
    if isInsideMask(p,subsystemPath)
        comp='';
        return;
    end
    comp=find_system(subsystemPath,'SearchDepth',1,'Name',compName);
    if~isempty(comp)
        comp=[subsystemPath,'/',compName];
    else
        comp='';
    end
end


function[list,numElem]=createCompList(p,w,opType,compInfo)

    numElem=0;
    list=w.createList;
    comps=compInfo.getCompVector;
    for i=1:length(comps)
        comp=comps(i);
        if~isempty(comp.Owner.FullPath)
            compPath=getCompPath(p,comp);
            if~isempty(compPath)
                linkedPath=hdlhtml.reportingWizard.generateSystemLink(compPath);
                list.createEntry(linkedPath);
                numElem=numElem+1;
            else
                compPath=[comp.Owner.FullPath,'/',comp.Name];
                slbh=comp.SimulinkHandle;
                if slbh==-1&&strcmpi(opType,'RAM')
                    slbh=comp.getGMHandle;
                end
                if slbh~=-1
                    linkedPath=hdlhtml.reportingWizard.generateSystemLink(compPath,slbh);
                    list.createEntry(linkedPath);
                    numElem=numElem+1;
                end
            end
        end
    end
end


function path=getCompPath(p,comp)
    if~comp.Synthetic
        path=getfullname(comp.SimulinkHandle);
    elseif~isempty(comp.getOriginalComponentTag())
        path=comp.getOriginalComponentTag();
    else
        ntkPath=comp.Owner.FullPath;
        if comp.isSF
            ntkPath=fileparts(ntkPath);
        end
        path=findComp(p,ntkPath,hdlcoder.SimulinkData.getSimulinkName(comp));
    end
end


function addCompLinks(w,list,numElem,typeid)
    if(numElem)>0
        section=w.createSection('','span');
        section.setAttribute('name',typeid);
        section.setAttribute('id',typeid);
        section.createEntry(list);
        w.commitSection(section);
    end
end


function jsCmd=addOnclickEvent(w,compInfo,numElem,typeid,isUserDefined)
    jsCmd='';
    if numElem>0&&~isUserDefined
        jsCmd=['hdlTableShrink(this, ''',typeid,''')'];
        section=w.createSection('[+]','span');
        section.setAttribute('name','collapsible');
        section.setAttribute('id','collapsible');
        section.setAttribute('style','font-family:monospace');
        section.setAttribute('onclick',jsCmd);
        section.setAttribute('onmouseover','this.style.cursor = ''pointer''');
        w.commitSection(section);
    end

    section=w.createSection(compInfo,'span');
    section.setAttribute('style','font-family:monospace');
    w.commitSection(section);
end


function flag=isValidNtk(bom)
    mulInfo=bom.getCompInfoSet('mul_comp');
    if~isempty(mulInfo)
        flag=true;
        return;
    end
    addInfo=bom.getCompInfoSet('add_comp');
    if~isempty(addInfo)
        flag=true;
        return;
    end
    subInfo=bom.getCompInfoSet('sub_comp');
    if~isempty(subInfo)
        flag=true;
        return;
    end
    regInfo=bom.getCompInfoSet('reg_comp');
    if~isempty(regInfo)
        flag=true;
        return;
    end
    memInfo=bom.getCompInfoSet('mem_comp');
    if~isempty(memInfo)
        flag=true;
        return;
    end
    muxInfo=bom.getCompInfoSet('mux_comp');
    if~isempty(muxInfo)
        flag=true;
        return;
    end
    shiftops=bom.getTotalShiftOps();
    if shiftops>0
        flag=true;
        return;
    end
    flag=false;
end


function flag=isFilterComp(thisComp)
    resrc=PersistentHDLResource;
    flag=false;
    if~isempty(resrc)
        thisCompPath=[thisComp.Owner.Fullpath,'/',thisComp.Name];
        for i=1:length(resrc)
            filtComp=resrc(i).comp;
            filtCompPath=[filtComp.Owner.Fullpath,'/',filtComp.Name];
            if strcmpi(filtCompPath,thisCompPath)
                flag=true;
                return;
            end
        end
    end
end


function[forEachStruct,forEachMap]=getForEachStruct(p,thisNtk,forEachMap)

    forEachStruct=struct('replications',1,'parents',[],'name','');

    ntkInstances=thisNtk.instances;
    if isempty(ntkInstances)
        path=thisNtk.FullPath;


        if forEachMap.isKey(path)
            forEachStruct=forEachMap(path);
        else
            forEachMap(path)=forEachStruct;
        end
    else
        if length(ntkInstances)>1


            return
        end
        comp=ntkInstances(1);
        path=getCompPath(p,comp);



        if forEachMap.isKey(path)
            forEachStruct=forEachMap(path);
            return
        end


        [parentStruct,forEachMap]=getForEachStruct(p,comp.Owner,forEachMap);

        forEachStruct.replications=parentStruct.replications;
        forEachStruct.parents=parentStruct.parents;




        if~isempty(parentStruct.name)
            forEachStruct.parents{end+1}=parentStruct.name;
        end




        if thisNtk.isForEachSubsystem
            forEachStruct.name=hdlhtml.reportingWizard.generateSystemLink(path);
            forEachStruct.replications=parentStruct.replications*comp.getForEachNumReplications;
        end


        forEachMap(path)=forEachStruct;
    end
end





