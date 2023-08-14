function viewReport(this,mode)













    if nargin==1
        mode='web';
    elseif~strcmpi(mode,'web')&&~strcmpi(mode,'MA')&&~strcmpi(mode,'cmd')
        DAStudio.error('ModelAdvisor:engine:CmdAPIviewReportInputError');
    end
    if isempty(this.mdladvinfo)
        DAStudio.error('ModelAdvisor:engine:CmdAPIviewReportIncompleteRun',this.report);
    end
    if strcmpi(mode,'cmd')
        this.displaySummary;
        return;
    end
    if strcmpi(mode,'MA')
        idx=strfind(this.system,'/');
        if~isempty(idx)
            model=this.system(1:idx(1)-1);
        else
            model=this.system;
        end

        fNames=fieldnames(this.mdladvinfo);
        open_system(model);
        WorkDir=ModelAdvisor.getWorkDir(this.system,'_modeladvisor_',false);
        srcPicture=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private','*.png');
        if~exist(fullfile(WorkDir,'folder.png'),'file')
            copyfile(srcPicture,WorkDir);

            vandvMatSrc=fullfile(matlabroot,'toolbox','simulink','simulink','private','sigbuilder_images.mat');
            if exist(vandvMatSrc,'file')==2
                load(vandvMatSrc);
                imwrite(stvbmp.vnv_btn,fullfile(WorkDir,'vandv.png'),'PNG');
            else
                copyfile(fullfile(WorkDir,'vandvback.png'),fullfile(WorkDir,'vandv.png'));
            end
            fileattrib(fullfile(WorkDir,'*.png'),'+w');
        end

        overWrite=true;
        if overWrite
            DatabaseHandle=ModelAdvisor.Repository(fullfile(WorkDir,'ModelAdvisorData'));
            propValuePairs=cell(1,2*length(fNames));
            for i=1:length(fNames)
                propValuePairs{i*2-1}=fNames{i};
                propValuePairs{i*2}=this.mdladvinfo.(fNames{i});
            end
            DatabaseHandle.overwriteLatestData('MdladvInfo',propValuePairs);

            fNames=fieldnames(this.geninfo);
            propValuePairs=cell(1,2*length(fNames));
            for i=1:length(fNames)
                propValuePairs{i*2-1}=fNames{i};
                propValuePairs{i*2}=this.geninfo.(fNames{i});
            end
            DatabaseHandle.overwriteLatestData('geninfo',propValuePairs);

            fid=fopen([WorkDir,filesep,'report.html'],'w');
            fclose(fid);
        end

        if~isempty(this.mdladvinfo.ConfigFilePathInfo.name)
            maObj=Simulink.ModelAdvisor.getModelAdvisor(this.system,'new','','configuration',this.mdladvinfo.ConfigFilePathInfo.name);
            maObj.displayExplorer;
        else
            maObj=Simulink.ModelAdvisor.getModelAdvisor(this.system,'new');
            taskObj={};
            for i=1:length(this.CheckResultObjs)
                tObjs=maObj.getTaskObj(this.CheckResultObjs(i).checkID,'-type','CheckID');
                if~isempty(tObjs)
                    switch this.CheckResultObjs(i).status
                    case 'Pass'
                        tObjs{1}.State=ModelAdvisor.CheckStatus.Passed;
                    case 'Warning'
                        tObjs{1}.State=ModelAdvisor.CheckStatus.Warning;
                    case 'Fail'
                        tObjs{1}.State=ModelAdvisor.CheckStatus.Failed;
                    end
                    tObjs{1}.changeSelectionStatus(true);
                    taskObj{end+1}=tObjs{1};%#ok<AGROW>
                end
            end
            MARoot=ModelAdvisor.Group('CommandLineRun');
            MARoot.Selected=1;
            MARoot.ChildrenObj=taskObj;
            MARoot.DisplayName=[DAStudio.message('ModelAdvisor:engine:CmdAPICmdLineRun'),' : ',datestr(this.geninfo.generateTime,2)];
            MARoot.MAObj=maObj;
            MARoot.StateIcon='toolbox/simulink/simulink/modeladvisor/private/icon_folder.png';
            maObj.TaskAdvisorRoot=MARoot;
            maObj.displayExplorer;
        end
    else
        fileGenCfg=Simulink.fileGenControl('getConfig');
        rootBDir=fileGenCfg.CacheFolder;
        WorkDir=rtwprivate('rtw_create_directory_path',rootBDir,'slprj','modeladvisor',this.mdladvinfo.path{end:-1:1});
        fid=fopen([WorkDir,'/report.html'],'w','n','utf-8');
        fwrite(fid,this.htmlreport,'char');
        fclose(fid);
        srcPicture=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private','*.png');
        if~exist(fullfile(WorkDir,'folder.png'),'file')
            copyfile(srcPicture,WorkDir);

            vandvMatSrc=fullfile(matlabroot,'toolbox','simulink','simulink','private','sigbuilder_images.mat');
            if exist(vandvMatSrc,'file')==2
                load(vandvMatSrc);
                imwrite(stvbmp.vnv_btn,fullfile(WorkDir,'vandv.png'),'PNG');
            else
                copyfile(fullfile(WorkDir,'vandvback.png'),fullfile(WorkDir,'vandv.png'));
            end
            fileattrib(fullfile(WorkDir,'*.png'),'+w');
        end
        web([WorkDir,'/report.html']);
    end
end
