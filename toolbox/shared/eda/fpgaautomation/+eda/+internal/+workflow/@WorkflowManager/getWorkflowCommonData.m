function getWorkflowCommonData(h,wflowInput)




    wfInfo=[];








    wfInfo.userParam.workflow=l_getprop(wflowInput,'FPGAWorkflow');




    wfInfo.userParam.projectGenOutput=l_getprop(wflowInput,'FPGAProjectGenOutput');
    wfInfo.userParam.existingPath=l_getprop(wflowInput,'ExistingFPGAProjectPath');






    wfInfo.userParam.tclOption=l_getprop(wflowInput,'TclOptions');




    wfInfo.userParam.projectName=l_getprop(wflowInput,'FPGAProjectName');
    wfInfo.userParam.projectLoc=l_getprop(wflowInput,'FPGAProjectFolder');


    fpgaFamily=l_getprop(wflowInput,'FPGAFamily');
    wfInfo.userParam.projectTarget.family=getFPGAPartList(fpgaFamily,'vendorName');

    wfInfo.userParam.projectTarget.device=l_getprop(wflowInput,'FPGADevice');
    wfInfo.userParam.projectTarget.speed=l_getprop(wflowInput,'FPGASpeed');
    wfInfo.userParam.projectTarget.package=l_getprop(wflowInput,'FPGAPackage');


    userFiles=l_getprop(wflowInput,'UserFPGASourceFiles');
    wfInfo.userParam.projectUserFiles=l_getUserFiles(userFiles);


    propName=l_getprop(wflowInput,'FPGAProjectPropertyName');
    propValue=l_getprop(wflowInput,'FPGAProjectPropertyValue');
    propProcess=l_getprop(wflowInput,'FPGAProjectPropertyProcess');
    propStruct=l_getProjectProp(propName,propValue,propProcess);
    wfInfo.userParam.projectProperties=propStruct;




    genClkMod=l_getprop(wflowInput,'GenClockModule');
    wfInfo.userParam.genClockModule=strcmpi(genClkMod,'on');
    wfInfo.userParam.clkinPeriod=l_getprop(wflowInput,'FPGAInputClockPeriod');
    wfInfo.userParam.clkoutPeriod=l_getprop(wflowInput,'FPGASystemClockPeriod');




    wfInfo.tdkParam.tdkFiles={};

    wfInfo.tdkParam.clkModuleName='_clock_module';
    wfInfo.tdkParam.clkWrapperName='_wrapper';

    wfInfo.tdkParam.tclCmdFile='edalink.tcl';
    wfInfo.tdkParam.tclOutFile='edalink.txt';
    wfInfo.tdkParam.tclScriptName='_fpgaworkflow.tcl';



    wfInfo.tdkParam.projectExt='.xise';
    wfInfo.tdkParam.projectOldExt='.ise';



    h.mWorkflowInfo=wfInfo;


    function value=l_getprop(wflowInput,prop)

        if isa(wflowInput,'fpgaworkflowprops.FDHDLCoder')

            value=get(wflowInput,prop);
        else

            value=get_param(wflowInput,prop);
        end


        function userFiles=l_getUserFiles(userFiles)

            if~isempty(userFiles)


                userFiles=textscan(userFiles,'%s','Delimiter',char(10));
                userFiles=userFiles{1};




                userFiles=strtrim(userFiles);


                idx=find(cellfun(@(f)~isempty(f),userFiles));
                if isempty(idx)
                    userFiles='';
                else
                    userFiles=userFiles(idx);
                end
            end


            function propStruct=l_getProjectProp(propName,propValue,propProcess)



                propName=strread(propName,'%s','delimiter',';');
                propValue=strread(propValue,'%s','delimiter',';');
                propProcess=strread(propProcess,'%s','delimiter',';');




                if~isequal(length(propName),length(propValue),length(propProcess))
                    error(message('EDALink:WorkflowManager:getWorkflowCommonData:projectpropsize'));
                end

                propStruct=struct([]);
                for n=1:length(propName)

                    if~isempty(propName{n})||~isempty(propValue{n})||~isempty(propProcess{n})
                        propStruct(end+1).name=propName{n};
                        propStruct(end).value=propValue{n};
                        propStruct(end).process=propProcess{n};
                    end
                end


