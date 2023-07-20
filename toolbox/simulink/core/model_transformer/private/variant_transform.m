function result=variant_transform(aTask)



    result={''};


    mdladvObj=aTask.MAObj;
    if~isa(mdladvObj.UserData,'slEnginePir.m2m')
        return;
    end
    m2m_obj=mdladvObj.UserData;


    wmsg=aTask.MAObj.getCheckResultData(aTask.ID);
    aTask.Check.Result=identify_candidate_result(m2m_obj,mdladvObj.SystemName,wmsg,1);
    aTask.Check.ResultInHTML=mdladvObj.formatCheckCallbackOutput(aTask.Check,{aTask.Check.Result},{''},1,false);

    inputParams=mdladvObj.getInputParameters;
    prefix=inputParams{2}.Value;

    prefix=checkfilename(prefix,'gen0_');
    if length([prefix,m2m_obj.fOriMdl])>63
        DAStudio.error('sl_pir_cpp:creator:IllegalName3');
    end

    ft0=ModelAdvisor.FormatTemplate('ListTemplate');
    setSubTitle(ft0,DAStudio.message('sl_pir_cpp:creator:XformedModel'));
    setInformation(ft0,DAStudio.message('sl_pir_cpp:creator:HyperLinkToXformedMdl'));
    ft1=ModelAdvisor.FormatTemplate('TableTemplate');
    setSubTitle(ft1,{DAStudio.message('sl_pir_cpp:creator:Bullet_If2varsrc')});
    setInformation(ft1,DAStudio.message('sl_pir_cpp:creator:HyperLinkToXformedBlk'));
    setTableTitle(ft1,{DAStudio.message('sl_pir_cpp:creator:Title_If2varsrc')});
    ft1.setColTitles({DAStudio.message('sl_pir_cpp:creator:From'),DAStudio.message('sl_pir_cpp:creator:To')});
    ft2=ModelAdvisor.FormatTemplate('TableTemplate');
    setSubTitle(ft2,{DAStudio.message('sl_pir_cpp:creator:Bullet_If2varsub')});
    setInformation(ft2,DAStudio.message('sl_pir_cpp:creator:HyperLinkToBlk'));
    setTableTitle(ft2,{DAStudio.message('sl_pir_cpp:creator:Title_If2varsub')});
    ft2.setColTitles({DAStudio.message('sl_pir_cpp:creator:From'),DAStudio.message('sl_pir_cpp:creator:To')});
    ft3=ModelAdvisor.FormatTemplate('TableTemplate');
    setSubTitle(ft3,{DAStudio.message('sl_pir_cpp:creator:Bullet_Sw2varsrc')});
    setInformation(ft3,DAStudio.message('sl_pir_cpp:creator:HyperLinkToBlk'))
    setTableTitle(ft3,{DAStudio.message('sl_pir_cpp:creator:Title_Sw2varsrc')});
    ft3.setColTitles({DAStudio.message('sl_pir_cpp:creator:From'),DAStudio.message('sl_pir_cpp:creator:To')});
    ft4=ModelAdvisor.FormatTemplate('TableTemplate');
    setSubTitle(ft4,{DAStudio.message('sl_pir_cpp:creator:ExcludedCands')});
    setInformation(ft4,DAStudio.message('sl_pir_cpp:creator:TableInfo_ExcludedCand'));
    setTableTitle(ft4,{DAStudio.message('sl_pir_cpp:creator:ExclusionReasons')});
    ft4.setColTitles({DAStudio.message('sl_pir_cpp:creator:ExcludedCands'),DAStudio.message('sl_pir_cpp:creator:Reason')});

    ME=MException('','');
    wmsg='';
    try
        m2m_obj.if2variant;
        m2m_obj.sw2varsrc;
        if isempty(prefix)
            wmsg=evalc('m2m_obj.genmodel(''gen0_'') ;');
        else
            wmsg=evalc('m2m_obj.genmodel(prefix) ;');
        end

        if isempty(m2m_obj.xform_commands)&&isempty(m2m_obj.skipped_xforms)
            resultText=ModelAdvisor.Text(DAStudio.message('sl_pir_cpp:creator:NoVariantTransform'));
            result=resultText.emitHTML;


        else
            if isempty(prefix)
                setListObj(ft0,{['gen0_',m2m_obj.mdl]});
            else
                setListObj(ft0,{[prefix,m2m_obj.mdl]});
            end
            xform_report=m2m_obj.xform_report;
            for i=1:length(xform_report)
                if strcmpi(xform_report(i).Operation,'if2varsrc')
                    ft1.addRow({xform_report(i).Before,xform_report(i).After});
                elseif strcmpi(xform_report(i).Operation,'if2varsub')
                    ft2.addRow({xform_report(i).Before,xform_report(i).After});
                else
                    ft3.addRow({xform_report(i).Before,xform_report(i).After});
                end
            end

            if isempty(m2m_obj.skipped_xforms)

            else
                mdladvObj.setCheckResultStatus(false);
                for ii=1:length(m2m_obj.skipped_xforms)
                    ft4.addRow({m2m_obj.skipped_xforms(ii).Block,m2m_obj.skipped_xforms(ii).Reason});
                end
            end


            result=cell([1,6]);
            result{1}=ft0;
            tmp=ft0.emitContent;
            if~isempty(ft1.TableInfo)
                result{2}=ft1;
                tmp=[tmp,ft1.emitContent];
            end
            if~isempty(ft2.TableInfo)
                result{3}=ft2;
                tmp=[tmp,ft2.emitContent];
            end
            if~isempty(ft3.TableInfo)
                result{4}=ft3;
                tmp=[tmp,ft3.emitContent];
            end
            if~isempty(ft4.TableInfo)
                result{5}=ft4;
                tmp=[tmp,ft4.emitContent];
            end
            if~isempty(wmsg)
                ft5=ModelAdvisor.FormatTemplate('ListTemplate');
                setSubTitle(ft5,DAStudio.message('sl_pir_cpp:creator:WarningMessage'));
                setInformation(ft5,wmsg);
                result{6}=ft5;
                tmp=[tmp,ft6.emitContent];
            end


            result=tmp;
        end
        saved_info=[];
        saved_info.xformed_mdl=m2m_obj.fXformedMdl;
        saved_info.traceability_map=m2m_obj.traceability_map;
        mdladvObj.setActionEnable(false);
        aTask.Check.Action.Enable=false;

    catch ME
        result=ME.message;

    end
end
