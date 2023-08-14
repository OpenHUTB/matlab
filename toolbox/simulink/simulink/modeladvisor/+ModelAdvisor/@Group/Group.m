classdef(CaseInsensitiveProperties=true)Group<ModelAdvisor.Node

    properties(SetAccess=public,Hidden=true)
        ChildrenMACIndex={};
        ChildrenIndex={};
        AllChildrenIndex={};




        InputParametersLayoutGrid=[];

        InputParametersCallback=[];
    end

    properties(SetAccess=public)
        Children={};

        OrigChildren={};
        ExtensiveAnalysis=true;
        LaunchReport=false;
        CheckTitleIDs={};
        CheckIndex={};
        StartMessage='';
    end

    properties(NonCopyable)
        ChildrenObj={};
    end

    properties(SetAccess=private,Hidden=true)

        ReportStyle='ModelAdvisor.Report.TaskAdvisorStandardStyle';
    end

    methods(Hidden=true)
        function setReportStyle(obj,val)
            obj.ReportStyle=val;
        end
    end

    methods
        dlgStruct=getDialogSchema(this,name);
    end

    methods(Access=protected)

        function output=copyElement(this)
            output=copyElement@matlab.mixin.Copyable(this);
            for m=1:numel(this.InputParameters)
                output.InputParameters{m}=copy(this.InputParameters{m});
            end
        end
    end

    methods
        function this=Group(varargin)
mlock
            if nargin==0
            else
                ID=convertStringsToChars(varargin{1});
                if ischar(ID)
                    this.ID=ID;
                elseif isa(ID,'Simulink.MdlAdvisorTask')

                    this.ID=ID.TitleID;
                    this.DisplayName=ID.Title;
                    this.CheckTitleIDs=ID.CheckTitleIDs;
                    this.Description=ID.TitleTips;
                    this.Visible=ID.Visible;
                    this.Enable=ID.Enable;
                    this.Value=ID.Value;
                    this.Selected=ID.Selected;
                    this.TitleIsDuplicate=ID.TitleIsDuplicate;

                    this.Index=ID.Index;
                    this.Published=true;
                else
                    DAStudio.error('Simulink:tools:MAInvalidParam','string')
                end
            end
        end
    end


end
