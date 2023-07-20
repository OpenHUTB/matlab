function execute(obj)




    ccm=obj.Data;
    obj.initMessages();
    if isempty(ccm.FcnInfoMap)
        ccm.createFcnInfoMap();
    end

    obj.addMetaData();
    if~strcmp(ccm.LatestStatus.Status,'successful')
        obj.generateErrorReport();
    else
        obj.IntroductionContent=obj.getHTMLIntroduction();
        obj.AddSectionToToc=true;

        fileTable=obj.getHTMLFileInfo();
        obj.addSection('sec_file_info',obj.msgs.file_info,'',fileTable);

        globalvar_table=obj.getHTMLGlobalVariable();
        obj.addSection('sec_globalvar_info',obj.msgs.glbvar_info,obj.msgs.glb_var_msg,globalvar_table);

        fcnTable=obj.getHTMLFcnInfo();
        obj.addSection('sec_fcn_info',obj.msgs.fcn_info,[obj.msgs.fcnInfo_msg,' ',obj.msgs.stack_msg],fcnTable);
        if ccm.PolySpaceForCodeMetrics&&ccm.targetisCPP

            classMember_table=obj.getHTMLClassMember();
            obj.addSection('sec_classmember_info',obj.msgs.classMember_info,obj.msgs.classMember_msg,classMember_table);
        end
    end
end


