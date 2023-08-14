classdef ISETclProjectManager<eda.internal.workflow.FPGAProjectManager









    properties
        TopLevelEntityName='';
    end
    properties(SetAccess=protected)
mToolInfo
PARFile
    end

    methods
        function h=ISETclProjectManager

            h.mToolInfo=eda.internal.workflow.ISEInfo;




            key=cellfun(@(x)x{1},h.mToolInfo.FPGABuildProcess,'UniformOutput',false);
            val=cellfun(@(x)x{2},h.mToolInfo.FPGABuildProcess,'UniformOutput',false);
            h.ToolProcessMap=containers.Map(key,val);

            h.ProjectExt=h.mToolInfo.ProjectFileExt;
        end


        function initialize(h)
            h.TclCmdQueue=[];
            h.StatusMsg='';
            h.NewProject=[];
        end

        function result=get.PARFile(h)
            if isempty(h.ProjectName)
                result='';
            else
                result=[h.ProjectName,'.par'];
            end
        end













        function removeFiles(h,srcfiles,varargin)



            if~iscell(srcfiles)||~all(cellfun(@ischar,srcfiles))
                error(message('EDALink:ISETclProjectManager:InvalidFileInput'));
            end
            h.parseProjParam(varargin{:});

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Removed Source Files:';
                end
                h.addStatus(str,2);
            end

            for n=1:length(srcfiles)
                file=char(srcfiles(n));
                if h.DispStat
                    h.addStatus(file,3);
                end

                file=strrep(file,'\','/');
                file=h.addPathQuote(file);
                h.TclCmdQueue{end+1}=[h.TclPrefix,'xfile remove ',file];
            end
        end

        function[result,projPath]=isExistingProject(h)




            h.validateProjectFile;

            result=false;projPath={};
            proj=fullfile(h.ProjectFolder,...
            [h.ProjectName,h.mToolInfo.ProjectFileExt]);
            if exist(proj,'file')==2
                result=true;
                projPath{end+1}=proj;
            end
            proj=fullfile(h.ProjectFolder,...
            [h.ProjectName,h.mToolInfo.OldProjectFileExt]);
            if exist(proj,'file')==2
                result=true;
                projPath{end+1}=proj;
            end
        end

        function deleteExistingProject(h)




            h.validateProjectFile;

            proj=fullfile(h.ProjectFolder,...
            [h.ProjectName,h.mToolInfo.ProjectFileExt]);
            if exist(proj,'file')==2
                delete(proj);
            end
            proj=fullfile(h.ProjectFolder,...
            [h.ProjectName,h.mToolInfo.OldProjectFileExt]);
            if exist(proj,'file')==2
                delete(proj);
            end
        end


        function createProject(h,varargin)
            h.validateProjectFile;
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'project new ',h.ProjectName];
            h.NewProject=true;

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Project:';
                end
                h.addStatus(str,2);
                h.addStatus('_PROJPATH__',3);
            end
        end

        function openProject(h,varargin)
            h.validateProjectFile;
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'project open ',h.ProjectName];
            h.NewProject=false;

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Project:';
                end
                h.addStatus(str,2);
                h.addStatus('_PROJPATH__',3);
            end
        end

        function closeProject(h,varargin)
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'project close'];
            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end

        function cleanProject(h,varargin)
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'project clean'];
            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end


        function setTopLevel(h,entityName,varargin)
            validateattributes(entityName,{'char'},{'nonempty'});
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'project set top ',entityName];
            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end

        function setTargetDevice(h,target,varargin)
            validateattributes(target,{'struct'},{'nonempty'});
            h.parseProjParam(varargin{:});
            emitCmt=~isempty(h.TclPrefix);



            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Target Device:';
                end
                h.addStatus(str,2);
                familyName=getFPGAPartList(target.family,'customerName');
                h.addStatus([familyName,' '...
                ,target.device,target.speed,target.package],3);
            end

            prop=struct('name',{'family','device','package','speed'},...
            'value',{target.family,target.device,target.package,target.speed},...
            'process','');
            h.setProperties(prop,'StatusDisplay',false,...
            'EmitAsComment',emitCmt);
        end

        function setProperties(h,prop,varargin)
            validateattributes(prop,{'struct'},{'nonempty'});
            h.parseProjParam(varargin{:});

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Property Settings:';
                end
                h.addStatus(str,2);
            end

            for n=1:length(prop)
                if~isempty(prop(n).process)
                    opt=[' -process ',h.addPathQuote(prop(n).process)];
                    optstat=[' (',prop(n).process,')'];
                else
                    opt='';
                    optstat='';
                end
                h.TclCmdQueue{end+1}=[h.TclPrefix,'project set '...
                ,h.addPathQuote(prop(n).name),' ',h.addPathQuote(prop(n).value),opt];
                if h.DispStat
                    h.addStatus([prop(n).name,' = ',prop(n).value,optstat],3);
                end
            end
        end


        function runHDLCompilation(h,varargin)
            h.runProcess('compile',varargin{:});
        end

        function runSynthesis(h,varargin)
            h.runProcess('synthesize',varargin{:});
        end

        function runPlaceAndRoute(h,varargin)
            h.runProcess('implement',varargin{:});
        end

        function runBitGeneration(h,varargin)
            h.runProcess('generateBit',varargin{:});
        end

        function runProcess(h,process,varargin)
            validateattributes(process,{'char'},{'nonempty'});
            if h.ToolProcessMap.isKey(process)
                h.parseProcessParam(varargin{:});

                h.TclCmdQueue{end+1}=[h.TclPrefix,'process run '...
                ,h.ToolProcessMap(process)];
                if h.AssertProcErr
                    if strcmpi(process,'compile')
                        errCondition='$result == "errors"';
                    else
                        errCondition='$result == "errors" || $result == "never_run"';
                    end
                    cmd=sprintf([...
                    '_#_set result [process get %s status]\n',...
                    '_#_if {',errCondition,'} {\n'...
                    ,'_#_   exit 2\n'...
                    ,'_#_}'],h.ToolProcessMap(process));
                    h.TclCmdQueue{end+1}=strrep(cmd,'_#_',h.TclPrefix);
                end
                if h.DispStat
                    h.addStatus('',1);
                    if h.CustomLabel
                        str=h.LabelStr;
                    else
                        str=['Running ',h.ToolProcessMap(process)];
                    end
                    h.addStatus(str,1);
                end
            else
                error(message('EDALink:ISETclProjectManager:UndefinedProcessKey',process));
            end
        end

        function getTimingResult(h,rtnVar,varargin)
            validateattributes(rtnVar,{'char'},{'nonempty'});
            h.parseProjParam(varargin{:});

            if isempty(h.PARFile)
                error(message('EDALink:ISETclProjectManager:UndefinedPARFile'));
            end

            cmd=sprintf([...
            '_#_set par_file "',strrep(h.PARFile,'\','/'),'"\n'...
            ,'_#_set ',rtnVar,' ""\n'...
            ,'_#_if { [catch {open $par_file r} par_fid] } {\n'...
            ,'_#_      set ',rtnVar...
            ,'_#_ "Warning: Skipped timing check because PAR report does not exist."\n'...
            ,'_#_} else {\n'...
            ,'_#_   set par_str [read $par_fid]\n'...
            ,'_#_   close $par_fid\n'...
            ,'_#_   set result [regexp {[1-9]\\d* constraints? not met} $par_str match]\n'...
            ,'_#_   if {$result > 0} {\n'...
            ,'_#_      set ',rtnVar...
            ,'_#_ "Warning: Design does not meet all timing constraints.\\n'...
            ,'_#_Check PAR report \\"',strrep(h.PARFile,'\','/'),'\\" for details."\n'...
            ,'_#_   }\n'...
            ,'_#_}']);
            h.TclCmdQueue{end+1}=strrep(cmd,'_#_',h.TclPrefix);

            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end
    end


    methods(Access=protected)

        function setProjectAction(h)
            h.initialize;
        end

        function addFullPathFiles_priv(h,filePath,fileType,fileLib,varargin)



            h.parseProjParam(varargin{:});

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Added Source Files:';
                end
                h.addStatus(str,2);
            end


            uniqueLibs=containers.Map;
            for n=1:numel(fileLib)
                if~isempty(fileLib{n})&&~uniqueLibs.isKey(fileLib{n})
                    uniqueLibs(fileLib{n})=1;
                end
            end
            for n=uniqueLibs.keys
                h.TclCmdQueue{end+1}=['lib_vhdl new ',n{:}];
            end

            for n=1:length(filePath)
                if h.DispStat
                    h.addStatus(filePath{n},3);
                end

                file=strrep(filePath{n},'\','/');
                file=h.addPathQuote(file);



                if strcmpi(fileType{n},'netlist')
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'file copy -force ',file,' .'];
                elseif strcmpi(fileType{n},'Tcl script')
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'source ',file];
                else
                    if~isempty(h.xfileaddcmdswitch)
                        h.TclCmdQueue{end+1}=[h.TclPrefix,'xfile add ',file,' ',h.xfileaddcmdswitch];
                    else
                        h.TclCmdQueue{end+1}=[h.TclPrefix,'xfile add ',file];
                    end
                    if~isempty(fileLib)&&~isempty(fileLib{n})
                        h.TclCmdQueue{end}=[h.TclCmdQueue{end},' -lib_vhdl ',fileLib{n}];
                    end
                end
            end
        end


        function parseProcessParam(h,varargin)
            h.AssertProcErr=false;
            if mod(nargin,2)~=1
                error(message('EDALink:ISETclProjectManager:OddNumberInputArg'));
            end
            paramName='ProcessErrorAssertion';
            idx=find(strcmpi(paramName,varargin),1,'last');
            if~isempty(idx)

                if(mod(idx,2)~=1)
                    error(message('EDALink:ISETclProjectManager:ParamInEvenPos',paramName));
                end

                if~islogical(varargin{idx+1})
                    error(message('EDALink:ISETclProjectManager:InvalidParamValue',paramName));
                end

                h.AssertProcErr=varargin{idx+1};

                varargin(idx)=[];
                varargin(idx)=[];
            end
            h.parseProjParam(varargin{:});
        end

    end

end


