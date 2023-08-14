classdef QuartusTclProjectManager<eda.internal.workflow.FPGAProjectManager




    properties(SetAccess=protected)
mToolInfo
STAFile
    end

    methods
        function h=QuartusTclProjectManager

            h.mToolInfo=eda.internal.workflow.QuartusInfo;




            key=cellfun(@(x)x{1},h.mToolInfo.FPGABuildProcess,'UniformOutput',false);
            val=cellfun(@(x)x{2},h.mToolInfo.FPGABuildProcess,'UniformOutput',false);
            h.ToolProcessMap=containers.Map(key,val);

            h.ProjectExt=h.mToolInfo.ProjectFileExt;
        end

        function initialize(h)

            h.TclCmdQueue=[];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'load_package flow'];
            h.StatusMsg='';
            h.NewProject=[];
        end

        function result=get.STAFile(h)
            if isempty(h.ProjectName)
                result='';
            else
                result=[h.ProjectName,'.sta.rpt'];
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
        end

        function deleteExistingProject(h)




            h.validateProjectFile;

            proj=fullfile(h.ProjectFolder,...
            [h.ProjectName,h.mToolInfo.ProjectFileExt]);
            if exist(proj,'file')==2
                delete(proj);
            end

        end


        function createProject(h,varargin)
            h.validateProjectFile;
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'project_new -overwrite ',h.ProjectName];

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

            h.TclCmdQueue{end+1}=[h.TclPrefix,'project_open ',h.ProjectFile];
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

            h.TclCmdQueue{end+1}=[h.TclPrefix,'project_close'];
            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end

        function cleanProject(~,varargin)

        end


        function setTopLevel(h,entityName,varargin)
            validateattributes(entityName,{'char'},{'nonempty'});
            h.parseProjParam(varargin{:});

            h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name TOP_LEVEL_ENTITY ',entityName];
            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
        end

        function setTargetDevice(h,target,varargin)
            validateattributes(target,{'struct'},{'nonempty'});
            h.parseProjParam(varargin{:});

            if h.DispStat
                if h.CustomLabel
                    str=h.LabelStr;
                else
                    str='Target Device:';
                end
                h.addStatus(str,2);
                h.addStatus([target.family,' ',target.device],3);
            end

            h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name FAMILY  {',target.family,'}'];
            h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name DEVICE  {',target.device,'}'];
        end



        function runHDLCompilation(h,varargin)
            h.runProcess('compile',varargin{:});
        end

        function runSynthesis(h,varargin)
            h.runProcess('map',varargin{:});
        end

        function runPlaceAndRoute(h,varargin)
            h.runProcess('map',varargin{:});
            h.runProcess('fit',varargin{:});
            h.runProcess('sta',varargin{:});
        end

        function runBitGeneration(h,varargin)
            h.runProcess('bitgen',varargin{:});
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

        function runProcess(h,process,varargin)
            validateattributes(process,{'char'},{'nonempty'});
            if h.ToolProcessMap.isKey(process)
                h.parseProcessParam(varargin{:});

                h.TclCmdQueue{end+1}=[h.TclPrefix,h.ToolProcessMap(process)];














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

            if isempty(h.STAFile)

                return;

            end

            cmd=sprintf([...
            '_#_set sta_file "',strrep(h.STAFile,'\','/'),'"\n'...
            ,'_#_set ',rtnVar,' ""\n'...
            ,'_#_if { [catch {open $sta_file r} par_fid] } {\n'...
            ,'_#_      set ',rtnVar...
            ,'_#_ "Warning: Skipped timing check because STA report does not exist."\n'...
            ,'_#_} else {\n'...
            ,'_#_   set sta_str [read $par_fid]\n'...
            ,'_#_   close $par_fid\n'...
            ,'_#_   set result [regexp {Critical Warning.*: Timing requirements not met} $sta_str match]\n'...
            ,'_#_   if {$result > 0} {\n'...
            ,'_#_      set ',rtnVar...
            ,'_#_ "Warning: Design does not meet all timing constraints.\\n'...
            ,'_#_Check STA report \\"',strrep(h.STAFile,'\','/'),'\\" for details."\n'...
            ,'_#_   }\n'...
            ,'_#_}']);
            h.TclCmdQueue{end+1}=strrep(cmd,'_#_',h.TclPrefix);

            if h.DispStat&&h.CustomLabel
                h.addStatus(h.LabelStr,2);
            end
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
                h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name '...
                ,h.addPathQuote(prop(n).name),' ',h.addPathQuote(prop(n).value)];
                if h.DispStat
                    h.addStatus([prop(n).name,' = ',prop(n).value],3);
                end
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
                h.TclCmdQueue{end+1}=['set_global_assignment -name SEARCH_PATH ',n{:}];
            end


            for n=1:length(filePath)
                if h.DispStat
                    h.addStatus(filePath{n},3);
                end

                file=strrep(filePath{n},'\','/');
                file=h.addPathQuote(file);

                switch fileType{n}
                case 'VHDL'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name VHDL_FILE ',file];
                case 'Verilog'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name VERILOG_FILE ',file];
                case 'QSYS'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name QSYS_FILE ',file];
                case 'EDIF netlist'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name EDIF_FILE ',file];
                case 'VQM netlist'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name VQM_FILE ',file];
                case 'QSF file'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'source ',file];
                case 'Constraints'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name SDC_FILE ',file];
                case 'Tcl script'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name TCL_SCRIPT_FILE ',file];
                case 'Others'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name MISC_FILE ',file];
                case 'HEX file'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name HEX_FILE ',file];
                case 'IP file'
                    h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name IP_FILE ',file];
                end
                if~isempty(fileLib)&&~isempty(fileLib{n})
                    h.TclCmdQueue{end}=[h.TclCmdQueue{end},' -library ',fileLib{n}];
                end
            end
            h.TclCmdQueue{end+1}=[h.TclPrefix,'set_global_assignment -name USE_TIMEQUEST_TIMING_ANALYZER ON'];
        end

    end

end


