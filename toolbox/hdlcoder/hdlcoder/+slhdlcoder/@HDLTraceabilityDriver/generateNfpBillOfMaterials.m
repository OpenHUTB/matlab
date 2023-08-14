function generateNfpBillOfMaterials(this,bom_content_file,title,model,p,tcgInventory,JavaScriptBody)%#ok<INUSL>





    w=hdlhtml.reportingWizard(bom_content_file,title);

    w.addCollapsibleJS;

    w.setHeader(DAStudio.message('hdlcoder:report:res_report_nfp_title',model));


    w.addBreak(3);




    ntks=p.Networks;


    hDrv=hdlcurrentdriver();


    characHandleCached=hDrv.nfp_stats(hDrv.ModelName);


    if isKey(hDrv.nfp_stats,model)&&~strcmp(hDrv.ModelName,model)
        if isa(hDrv.nfp_stats(model),'hdlcoder.characterization')
            characHandleCached=hDrv.nfp_stats(model);
        end
    end

    nfpOpers={...
    {'hdlcoder:report:number_of_target_abs_comp',characHandleCached.getTotalFrequency('target_abs_comp')},...
    {'hdlcoder:report:number_of_target_add_comp',characHandleCached.getTotalFrequency('target_add_comp')},...
    {'hdlcoder:report:number_of_target_sub_comp',characHandleCached.getTotalFrequency('target_sub_comp')},...
    {'hdlcoder:report:number_of_target_dtc_comp',characHandleCached.getTotalFrequency('target_dtc_comp')},...
    {'hdlcoder:report:number_of_target_hdl_recip_comp',characHandleCached.getTotalFrequency('target_hdl_recip_comp')},...
    {'hdlcoder:report:number_of_target_math_log_comp',characHandleCached.getTotalFrequency('target_math_log_comp')},...
    {'hdlcoder:report:number_of_target_math_exp_comp',characHandleCached.getTotalFrequency('target_math_exp_comp')},...
    {'hdlcoder:report:number_of_target_math_recip_comp',characHandleCached.getTotalFrequency('target_math_recip_comp')},...
    {'hdlcoder:report:number_of_target_math_mod_comp',characHandleCached.getTotalFrequency('target_math_mod_comp')},...
    {'hdlcoder:report:number_of_target_math_rem_comp',characHandleCached.getTotalFrequency('target_math_rem_comp')},...
    {'hdlcoder:report:number_of_target_math_log10_comp',characHandleCached.getTotalFrequency('target_math_log10_comp')},...
    {'hdlcoder:report:number_of_target_math_pow10_comp',characHandleCached.getTotalFrequency('target_math_pow10_comp')},...
    {'hdlcoder:report:number_of_target_math_comp',characHandleCached.getTotalFrequency('target_math_comp')},...
    {'hdlcoder:report:number_of_target_mul_comp',characHandleCached.getTotalFrequency('target_mul_comp')+characHandleCached.getTotalFrequency('target_gain_comp')},...
    {'hdlcoder:report:number_of_target_div_comp',characHandleCached.getTotalFrequency('target_div_comp')},...
    {'hdlcoder:report:number_of_target_relop_comp',characHandleCached.getTotalFrequency('target_relop_comp')},...
    {'hdlcoder:report:number_of_target_sqrt_comp',characHandleCached.getTotalFrequency('target_sqrt_comp')},...
    {'hdlcoder:report:number_of_target_rsqrt_comp',characHandleCached.getTotalFrequency('target_rsqrt_comp')},...
    {'hdlcoder:report:number_of_target_trig_comp',characHandleCached.getTotalFrequency('target_trig_comp')+characHandleCached.getTotalFrequency('target_trig2_comp')+characHandleCached.getTotalFrequency('target_trig3_comp')},...
    {'hdlcoder:report:number_of_target_trig_sin_comp',characHandleCached.getTotalFrequency('target_trig_sin_comp')},...
    {'hdlcoder:report:number_of_target_trig_cos_comp',characHandleCached.getTotalFrequency('target_trig_cos_comp')},...
    {'hdlcoder:report:number_of_target_trig_tan_comp',characHandleCached.getTotalFrequency('target_trig_tan_comp')},...
    {'hdlcoder:report:number_of_target_trig_asin_comp',characHandleCached.getTotalFrequency('target_trig_asin_comp')},...
    {'hdlcoder:report:number_of_target_trig_acos_comp',characHandleCached.getTotalFrequency('target_trig_acos_comp')},...
    {'hdlcoder:report:number_of_target_trig_atan_comp',characHandleCached.getTotalFrequency('target_trig_atan_comp')},...
    {'hdlcoder:report:number_of_target_trig_sinh_comp',characHandleCached.getTotalFrequency('target_trig_sinh_comp')},...
    {'hdlcoder:report:number_of_target_trig_cosh_comp',characHandleCached.getTotalFrequency('target_trig_cosh_comp')},...
    {'hdlcoder:report:number_of_target_trig_tanh_comp',characHandleCached.getTotalFrequency('target_trig_tanh_comp')},...
    {'hdlcoder:report:number_of_target_trig_asinh_comp',characHandleCached.getTotalFrequency('target_trig_asinh_comp')},...
    {'hdlcoder:report:number_of_target_trig_acosh_comp',characHandleCached.getTotalFrequency('target_trig_acosh_comp')},...
    {'hdlcoder:report:number_of_target_trig_atanh_comp',characHandleCached.getTotalFrequency('target_trig_atanh_comp')},...
    {'hdlcoder:report:number_of_target_trig2_sincos_comp',characHandleCached.getTotalFrequency('target_trig2_sincos_comp')},...
    {'hdlcoder:report:number_of_target_trig3_atan2_comp',characHandleCached.getTotalFrequency('target_trig3_atan2_comp')},...
    {'hdlcoder:report:number_of_target_gain_pow2_comp',characHandleCached.getTotalFrequency('target_gain_pow2_comp')},...
    {'hdlcoder:report:number_of_target_uminus_comp',characHandleCached.getTotalFrequency('target_uminus_comp')},...
    {'hdlcoder:report:number_of_target_round_comp',characHandleCached.getTotalFrequency('target_round_comp')},...
    {'hdlcoder:report:number_of_target_fix_comp',characHandleCached.getTotalFrequency('target_fix_comp')},...
    {'hdlcoder:report:number_of_target_ceil_comp',characHandleCached.getTotalFrequency('target_ceil_comp')},...
    {'hdlcoder:report:number_of_target_floor_comp',characHandleCached.getTotalFrequency('target_floor_comp')},...
    {'hdlcoder:report:number_of_target_signum_comp',characHandleCached.getTotalFrequency('target_signum_comp')},...
    };

    info=addResourceItems(nfpOpers);


    hdlDrv=hdlcurrentdriver;
    hdlDrv.cgInfo.NFPresourceInfo=info;


    addSummarySection(w,info);


    w.addBreak(2);


    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:detailed_report'));
    w.commitSection(section);

    w.addBreak(2);


    w.addLine;

    jsCmds='';


    comp_order={'add','sub','mul','div','recip','sqrt','rsqrt','abs','exp','log','gain_pow2','relop','sin','cos',...
    'conv','uminus','hdlrecip','floor','ceil','round','fix','pow10','log10','mod','rem',...
    'pow','hypot','tan','asin','acos','sinh','cosh','tanh','atan','asinh','acosh','atanh','atan2',...
    'sincos','cast','signum'};
    nfp_ntks=[];
    pos_perms=[];


    for i=1:length(ntks)
        thisNtk=ntks(i);


        NFP_tag=thisNtk.getNFPSource();
        if isempty(NFP_tag)
            continue;
        end


        nfp_ntks{end+1}=thisNtk;%#ok<AGROW>        
    end


    for pos=1:length(comp_order)
        curr_comp_class=['_',comp_order{pos}];
        for itr=1:length(nfp_ntks)
            thisNtk=nfp_ntks{itr};
            NFP_tag=thisNtk.getNFPSource();
            if any(strfind(NFP_tag,curr_comp_class))
                pos_perms(end+1)=itr;%#ok<AGROW>
            end
        end
    end


    if(length(pos_perms)<length(nfp_ntks))
        pos_perms=[pos_perms,setdiff(1:length(nfp_ntks),pos_perms)];
    end

    for i=1:length(nfp_ntks)
        thisNtk=nfp_ntks{pos_perms(i)};
        NFP_tag=thisNtk.getNFPSource();
        assert(~isempty(NFP_tag));
        characHandle=hdlcoder.characterization.create();
        characHandle.doitOnNetworkOnly(thisNtk);


        bom=characHandle.getBillOfMaterials(thisNtk);
        if isempty(bom)
            continue;
        end

        ntkInstances=thisNtk.instances;
        numInstances=length(ntkInstances);
        if~isempty(ntkInstances)
            path2Ntk=thisNtk.FullPath;
            linkedPath=hdlhtml.reportingWizard.generateSystemLink(path2Ntk);
        elseif(false)

            for j=1:numInstances
                nicComp=ntkInstances(j);
                if(j==1)
                    linkedPath=hdlhtml.reportingWizard.generateSystemLink(getCompPath(p,nicComp));
                else
                    linkedPath=[linkedPath,', '...
                    ,hdlhtml.reportingWizard.generateSystemLink(getCompPath(p,nicComp))];%#ok<AGROW>
                end
            end
        else
            linkedPath='';
        end


        isUserDefined=false;

        jsCmds=emitNFPBomResources(p,...
        w,...
        {characHandle,bom},...
        {thisNtk,['<!-- ',linkedPath,'-->',' ',thisNtk.Name]},...
        thisNtk.getNFPReportComment,...
        jsCmds,...
        isUserDefined);


        w.addLine();
    end

    jsCmds=[JavaScriptBody,jsCmds];
    if~isempty(jsCmds)
        w.setAttribute('onload',jsCmds);
    end


    w.dumpHTML();



end


function info=addResourceItems(resources)

    linearResources=[resources{:}];

    compTitle=cellfun(@DAStudio.message,{linearResources{1:2:length(linearResources)}},'UniformOutput',false);
    compFreq={linearResources{2:2:length(linearResources)}};

    nonZeroLI=cellfun(@gt,compFreq,num2cell(zeros(size(compFreq))));
    compTitleNonZero=compTitle(nonZeroLI);
    compFreqNonZero=compFreq(nonZeroLI);

    [compTitleSorted,sortIndex]=sort(compTitleNonZero);
    compFreqSorted=compFreqNonZero(sortIndex);

    info=cellfun(@(title,freq){title,freq},compTitleSorted,compFreqSorted,'UniformOutput',false);
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

function info=getCharacterizationInfo(characHandle)
    info={};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_multipliers'),characHandle.getTotalFrequency('mul_comp')};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_adders_subtractors'),characHandle.getTotalFrequency('add_comp')...
    +characHandle.getTotalFrequency('sub_comp')};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_registers'),characHandle.getTotalFrequency('reg_comp')};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_flipflops'),characHandle.getTotalFlipflops()};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_rams'),characHandle.getTotalFrequency('mem_comp')};
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_multiplexers'),characHandle.getTotalFrequency('mux_comp')};

    total_static_shift_operators=characHandle.getTotalStaticShiftOps();
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_staticshift_operators'),total_static_shift_operators};

    total_dynamic_shift_operators=characHandle.getTotalDynamicShiftOps();
    info{end+1}={DAStudio.message('hdlcoder:report:number_of_dynamicshift_operators'),total_dynamic_shift_operators};

    return;
end


function jsCmds=emitNFPBomResources(p,w,characHandle_and_bom,ntkId_tag,comment,jsCmds,isUserDefined)%#ok<INUSD,INUSL>

    section=w.createSection(DAStudio.message('hdlcoder:report:nfp_res_report_subtitle',ntkId_tag{2}),5);
    w.commitSection(section);

    w.addText(comment);

    info=getCharacterizationInfo(characHandle_and_bom{1});
    numResources=length(info);
    table=w.createTable(numResources,2);
    for i=1:numResources
        table.createEntry(i,1,info{i}{1});
        table.createEntry(i,2,num2str(info{i}{2}),'center');
    end
    w.commitTable(table);

end


function addSummarySection(w,info)
    section=w.createSectionTitle(DAStudio.message('hdlcoder:report:summary_nfp'));
    w.commitSection(section);

    w.addBreak(2);
    numResources=length(info);

    if numResources~=0
        table=w.createTable(numResources,2);
        for i=1:numResources
            table.createEntry(i,1,info{i}{1});
            table.createEntry(i,2,num2str(info{i}{2}),'center');
        end
        w.commitTable(table);
    else
        sectionBody=w.createSection(DAStudio.message('hdlcoder:report:summary_nfp_no_resources'),'span');
        w.commitSection(sectionBody);
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

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...



