classdef(Sealed=true)SLDVCompileService<handle


    properties(Access='private')
sldv_opts
sldv_checks
sldv_use_gui

sldv_data
sldv_timeout
sldv_status
sldv_msg
    end

    methods(Access='protected')



        function obj=SLDVCompileService()
            obj.initVals();
        end
    end

    methods(Static=true)

        function singleObj=getInstance()
            persistent localStaticObj;
            if isempty(localStaticObj)||~isvalid(localStaticObj)
                localStaticObj=Advisor.SLDVCompileService;
            end
            singleObj=localStaticObj;
        end

        function status=runSLDV(hModel,varargin)
            Advisor.SLDVCompileService.getInstance.init(hModel);
            opts=Advisor.SLDVCompileService.getInstance.getRegisteredOptions();
            isShowGUI=Advisor.SLDVCompileService.getInstance.getSLDVUseGui;
            [status,result,~,msg]=sldvrun(hModel,opts,isShowGUI);

            if isShowGUI
                try

                    handles=get_param(hModel,'AutoVerifyData');
                    if isfield(handles,'ui')
                        handles.ui.delete;
                    end
                    if isfield(handles,'modelView')
                        handles.modelView.delete;
                    end
                catch e %#ok<NASGU>
                end
            end

            Advisor.SLDVCompileService.getInstance.setSLDVStatus(status);
            Advisor.SLDVCompileService.getInstance.setSLDVErrors(msg);

            if status
                Advisor.SLDVCompileService.getInstance.setSLDVData(result.DataFile);
            else




                error(strjoin({msg(:).msg},[newline,newline]));
            end

        end

        function reset()
            Advisor.SLDVCompileService.getInstance.term();
        end
    end

    methods(Access='public')

        function init(this,rootModel)
            opts=sldvoptions(rootModel);
            this.sldv_opts=opts.deepCopy;

            this.sldv_opts.Mode='DesignErrorDetection';
            this.sldv_opts=Sldv.utils.disableDedChecks(this.sldv_opts);

            this.sldv_opts.DisplayReport='off';

            this.sldv_opts.SaveHarnessModel='off';
            this.sldv_opts.MakeOutputFilesUnique='on';

            if~isempty(this.sldv_timeout)
                this.sldv_opts.MaxProcessTime=this.sldv_timeout;
            end

            this.collectOptions();
        end

        function collectOptions(this)

            ma=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

            for ii=1:numel(this.sldv_checks)
                checkObj=ma.getCheckObj(this.sldv_checks{ii});

                if~isa(checkObj,'ModelAdvisor.SLDVCheck')
                    continue;
                end

                optsCell=checkObj.optToRun;

                for jj=1:size(optsCell,1)
                    param=optsCell{jj,1};
                    val=optsCell{jj,2};


                    if strcmp(param,'DetectBlockConditions')
                        this.sldv_opts.DetectBlockConditions=[this.sldv_opts.DetectBlockConditions,' ',val];
                    elseif strcmp(param,'UseGUI')
                        this.sldv_use_gui=val;
                    else
                        this.sldv_opts.(param)=val;
                    end
                end
            end
        end

        function term(this)

            this.initVals();
        end

        function initVals(this)
            this.sldv_opts=[];
            this.sldv_data=[];
            this.sldv_checks={};
            this.sldv_timeout=[];
            this.sldv_status=false;
            this.sldv_msg=[];
            this.sldv_use_gui=false;
        end

        function opts=getRegisteredOptions(this)
            opts=this.sldv_opts;
        end

        function[data,status,msg]=getSLDVData(this)
            data=this.sldv_data;
            status=this.sldv_status;
            msg=this.sldv_msg;
        end

        function setSLDVData(this,data)
            this.sldv_data=data;
        end

        function registerSLDVChecks(this,checkIDs)
            this.sldv_checks=[this.sldv_checks,checkIDs];
        end

        function setSLDVTimeout(this,timout)
            if ischar(timout)
                timout=str2double(timout);
            end
            this.sldv_timeout=timout;
        end

        function bGui=getSLDVUseGui(this)
            ma=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
            if ma.cmdLine



                bGui=false;
            else
                bGui=this.sldv_use_gui;
            end
        end

        function setSLDVStatus(this,status)
            this.sldv_status=status;
        end

        function setSLDVErrors(this,errors)
            this.sldv_msg=errors;
        end


    end
end
