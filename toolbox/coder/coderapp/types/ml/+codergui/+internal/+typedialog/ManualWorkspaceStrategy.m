

classdef(Sealed)ManualWorkspaceStrategy<codergui.internal.typedialog.WorkspaceStrategy




    properties
        Variables=cell(0,2)
    end

    properties(Dependent,SetAccess=immutable)
WhosInfo
    end

    properties(Access=private,Transient)
PreviousWhosInfo
        Suppress=false
Stack
    end

    methods
        function this=ManualWorkspaceStrategy(vars)
            if nargin>0
                this.Variables=vars;
            end
        end

        function addVariable(this,varName,value)
            this.Variables(end+1,:)={varName,value};
        end

        function setVariable(this,varName,value)
            [~,idx]=ismember(varName,this.Variables(:,1));
            if idx~=0
                nextVars=this.Variables;
                nextVars{idx,2}=value;
                this.Variables=nextVars;
            else
                this.addVariable(varName,value);
            end
        end

        function removeVariable(this,varName)
            this.Variables(strcmp(this.Variables(:,1),varName),:)=[];
        end

        function set.Variables(this,variables)
            validateattributes(variables,{'cell'},{'ncols',2});
            assert(iscellstr(variables(:,1)));%#ok<ISCLSTR>
            if numel(unique(variables(:,1)))~=size(variables,1)
                error('Duplicate variable names');
            end
            this.PreviousWhosInfo=[];%#ok<MCSUP>
            this.Variables=variables;
            this.Stack=dbstack(1);%#ok<MCSUP>

            if~this.Suppress %#ok<MCSUP>
                this.requestWorkspaceUpdate();
            end
        end

        function whosInfo=get.WhosInfo(this)
            if isstruct(this.PreviousWhosInfo)
                whosInfo=this.PreviousWhosInfo;
                return
            end
            whosInfo=repmat(whos('this'),size(this.Variables,1),1);
            for i=1:size(this.Variables,1)
                [name,tempValueVar]=this.Variables{i,:};%#ok<ASGLU>
                whosInfo(i)=whos('tempValueVar');
                whosInfo(i).name=name;
            end
            isBase=repmat({true},size(whosInfo));
            [whosInfo.isBase]=isBase{:};
            this.PreviousWhosInfo=whosInfo;
        end

        function requestWorkspaceUpdate(this)
            if isempty(this.Stack)
                stack=dbstack(1);
            else
                stack=this.Stack;
            end
            this.notify('WorkspaceChanged',...
            codergui.internal.typedialog.WorkspaceEventData(...
            this.WhosInfo,stack,true));
        end

        function promise=readInWorkspace(this,varsOrCode)
            varsOrCode=cellstr(varsOrCode);
            results=cell2struct(cell(numel(varsOrCode),2),{'value','error'},2);
            for i=1:numel(varsOrCode)
                results(i).value=evalInTemporary(this.Variables,varsOrCode{i});
            end
            promise=codergui.internal.util.when(results,'alwayspromise');
        end

        function promise=writeVariable(this,varName,uniqify,value)
            allNames=this.Variables(:,1);
            if uniqify
                count=0;
                while ismember(varName,allNames)
                    count=count+1;
                    varName=sprintf('%s%d',varName,count);
                end
                idx=numel(this.Variables)+1;
            else
                [~,idx]=ismember(varName,allNames);
                if idx==0
                    idx=size(this.Variables,1)+1;
                end
            end
            this.Suppress=true;
            this.Variables(idx,:)={varName,value};
            this.Suppress=false;
            result.varName=varName;
            result.error=[];
            promise=codergui.internal.util.when(result,'alwayspromise');
        end
    end
end


function result___=evalInTemporary(vars___,expression___)





    for i___=1:size(vars___,1)
        assignin('caller',vars___{i___,1},vars___{i___,2});
    end
    result___=evalin('caller',expression___);
end
