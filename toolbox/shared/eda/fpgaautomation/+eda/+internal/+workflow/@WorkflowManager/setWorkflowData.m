function setWorkflowData(h,initialParam,mode)








    currentParam=h.mWorkflowInfo.userParam;

    model=h.mWorkflowInfo.tdkParam.model;
    cs=getActiveConfigSet(model);


    if strcmpi(mode,'associate')
        l_setProjectAssoc(cs,initialParam,currentParam);
    end


    if strcmpi(mode,'import')

        disp(' ');
        hdldisp('Updating configuration parameters in current model');


        supported=l_checkFpgaTarget(currentParam.projectTarget);

        if supported

            changed=l_setFpgaTarget(cs,initialParam.projectTarget,currentParam.projectTarget);

            if changed
                hdldisp('   "Target Device" has been updated.');
            else
                hdldisp('   "Target Device" is up-to-date.');
            end
        else
            disp(' ');
            warning(message('EDALink:WorkflowManager:setWorkflowData:unsupportedtarget'));
            disp(' ');
        end


        changed=l_setUserFiles(cs,initialParam.projectUserFiles,currentParam.projectUserFiles);

        if changed
            hdldisp('   "Additional Source Files" has been updated.');
        else
            hdldisp('   "Additional Source Files" is up-to-date.');
        end

        disp(' ');
    end


    function supported=l_checkFpgaTarget(target)

        s=getFPGAPartList(target.family,target.device,'speed');
        p=getFPGAPartList(target.family,target.device,'package');
        if isempty(s)||isempty(p)


            supported=false;
        else

            supported=any(strcmp(target.speed,s))&&any(strcmp(target.package,p));
        end


        function l_setProjectAssoc(cs,initialParam,currentParam)

            if~isequal(initialParam.assocExist,currentParam.assocExist)
                set_param(cs,'HasAssociatedFPGAProject',currentParam.assocExist);
            end

            if~isequal(initialParam.assocProjPath,currentParam.assocProjPath)
                set_param(cs,'AssociatedFPGAProjectPath',currentParam.assocProjPath);
            end


            function changed=l_setFpgaTarget(cs,orgTarget,curTarget)

                changed=0;



                family_v=getFPGAPartList(curTarget.family,'vendorName');

                if~isequal(orgTarget.family,family_v)
                    changed=1;
                    set_param(cs,'FPGAFamily',curTarget.family);
                end

                if~isequal(orgTarget.device,curTarget.device)
                    changed=1;
                    set_param(cs,'FPGADevice',curTarget.device);
                end

                if~isequal(orgTarget.speed,curTarget.speed)
                    changed=1;
                    set_param(cs,'FPGASpeed',curTarget.speed);
                end

                if~isequal(orgTarget.package,curTarget.package)
                    changed=1;
                    set_param(cs,'FPGAPackage',curTarget.package);
                end


                function changed=l_setUserFiles(cs,orgUserFiles,curUserFiles)

                    changed=0;





                    if~isequal(orgUserFiles,curUserFiles)

                        if isempty(curUserFiles)
                            usrfiles='';
                        else
                            usrfiles=sprintf(['%s',char(10)],curUserFiles{:});
                        end

                        changed=1;
                        set_param(cs,'UserFPGASourceFiles',usrfiles);
                    end

