










































classdef Config<rtw.pil.Config

    properties(GetAccess='public',SetAccess='protected')
        LogMode;
        Connectivity;
    end
    properties(GetAccess='public',SetAccess='protected',Hidden)
        OutPortSignalNames={};
        CheckOutports;
    end
    properties(Access='protected')
        DeviceType;
    end


    methods
        function this=Config(model,varargin)



            validParams={{'ComponentType',{'modelblock','topmodel'}},...
            {'Connectivity',{'sim','normal','sil','pil','custom'}},...
            {'LogMode',{'SaveOutput','SignalLogging'}},...
            {'SaveModel',{'on','off'}},...
            {'ReportOnly',{'on','off'}},...
            {'CheckOutports',{'on','off'}}};


            displayParams={{'ComponentType',{'modelblock','topmodel'}},...
            {'Connectivity',{'sim','normal','sil','pil'}},...
            {'LogMode',{'SaveOutput','SignalLogging'}},...
            {'SaveModel',{'on','off'}},...
            {'ReportOnly',{'on','off'}},...
            {'CheckOutports',{'on','off'}}};

            args=cgv.Config.checkArgs(2,'cgv.Config',validParams,displayParams,varargin);


            baseVarargs={};
            if isfield(args,'componenttype')
                component=args.componenttype;
                baseVarargs{end+1}='componenttype';
                baseVarargs{end+1}=component;
            end
            if isfield(args,'connectivity')
                connectivity=args.connectivity;
            else
                connectivity='normal';
            end
            if isfield(args,'logmode')
                logmode=args.logmode;
            else
                logmode='';
            end


            if isfield(args,'savemodel')
                baseVarargs{end+1}='savemodel';
                baseVarargs{end+1}=args.savemodel;
            end
            if isfield(args,'reportonly')
                baseVarargs{end+1}='reportOnly';
                baseVarargs{end+1}=args.reportonly;
            end

            if isfield(args,'checkoutports')
                checkoutports=args.checkoutports;
            else
                checkoutports='on';
            end


            devType='';

            this@rtw.pil.Config(model,baseVarargs{:});

            this.DeviceType=devType;
            this.Connectivity=connectivity;
            this.LogMode=logmode;
            this.CheckOutports=checkoutports;
        end

        function configModel(this)

            switch lower(this.Connectivity)
            case{'sim','normal'}
                configModel@rtw.pil.Config(this);
                this.configPilSilToAccel();
            case{'pil','custom'}
                configModel@rtw.pil.Config(this);
            case 'sil'
                this.configModelForSIL();
            otherwise

                DAStudio.error('RTW:cgv:BadTarget',this.Connectivity);
            end

            thisModel=this.TopModel;
            if this.ReportOnly
                if~isempty(this.LogMode)
                    if strcmpi(this.LogMode,'SignalLogging')
                        this.applyParam(this.CsModified{end},'SignalLogging','on');
                        this.applyParam(this.CsModified{end},'SaveOutput','off');
                    else
                        this.applyParam(this.CsModified{end},'SignalLogging','off');
                        this.applyParam(this.CsModified{end},'SaveOutput','on');
                    end
                end
            else
                status=this.verifyLoaded(thisModel);
                cs=getActiveConfigSet(thisModel);
                if~isempty(this.LogMode)
                    if strcmpi(this.LogMode,'SignalLogging')
                        this.applyParam(cs,'SignalLogging','on');
                        this.applyParam(cs,'SaveOutput','off');
                    else
                        this.applyParam(cs,'SignalLogging','off');
                        this.applyParam(cs,'SaveOutput','on');
                    end
                end
                this.CsModified{end}=cs.copy();
                this.restoreLoaded(thisModel,status);
            end
            if strcmpi(this.CheckOutports,'on')
                this.checkTopModel();
            end
            this.createReport();
        end


        function IsOK=IsConfigForCGV(this)
            if this.SaveModel==true
                IsOK=true;
            elseif isempty(this.Changes)

                if isempty(this.AllMdls)
                    IsOK=false;
                else
                    this.createReport;
                    IsOK=isempty(this.Changes);
                end
            else
                IsOK=false;
            end
        end
    end

    methods(Static,Hidden)
        args=checkArgs(beginAt,name,options,displayOptions,list);
    end
end
