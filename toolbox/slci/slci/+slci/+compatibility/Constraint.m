


classdef Constraint<handle

    properties(Access=private)
        fOwner=[];
        enum=[];
        compileNeeded=-1;
        fFatal=true;
        preRequisiteConstraints={};

        preRequisiteConstraintsFailures={};
        HTMLEncode=false;
    end

    methods(Access=protected)


        function blk_class_name=resolveBlockClassName(aObj)
            if isa(aObj.ParentBlock,'slci.simulink.MatlabFunctionBlock')
                blk_class_name='MATLAB function';
            elseif isa(aObj.ParentBlock,'slci.simulink.StateflowBlock')
                blk_class_name='Stateflow chart';
            else
                assert(false,'This line should not be reached.');
            end
        end

        function out=getCatalogCode(aObj)
            out=aObj.getEnum;
        end

        function out=getIncompatibilityTextOrObj(...
            aObj,aTextOrObj,varargin)%#ok
            args='';
            for i=1:nargin-2
                args=[args,'varargin{',num2str(i),'}'];%#ok
                if i<nargin-2
                    args=[args,', '];%#ok
                end
            end
            if strcmpi(aTextOrObj,'text')
                cmd=['out = slci.compatibility.getIncompatibilityText('...
                ,args,');'];
            else
                cmd=['out = slci.compatibility.Incompatibility(aObj, '...
                ,args,');'];
            end
            eval(cmd)
        end

        function out=getIncompatibility(aObj)
            out=aObj.getIncompatibilityTextOrObj('obj');
        end

    end

    methods
        function out=getDescription(aObj)
            out=aObj.getIncompatibilityTextOrObj('text');
        end

        function addPreRequisiteConstraint(aObj,constraint)
            aObj.preRequisiteConstraints{end+1}=constraint;
        end

        function out=getPreRequisiteConstraints(aObj)
            out=aObj.preRequisiteConstraints;
        end


        function out=hasAutoFix(~)
            out=false;
        end




        function addPreRequisiteConstraintFailures(aObj,constraint)
            aObj.preRequisiteConstraintsFailures{end+1}=constraint;
        end


        function out=getPreRequisiteConstraintsFailures(aObj)
            out=aObj.preRequisiteConstraintsFailures;
        end

        function setHTMLEncode(aObj,flag)
            aObj.HTMLEncode=flag;
        end

        function htmlEncode=getHTMLEncode(aObj)
            htmlEncode=aObj.HTMLEncode;
        end

        function out=ParentData(aObj)
            out=aObj.fOwner;
        end

        function out=ParentEvent(aObj)
            out=aObj.fOwner;
        end

        function out=ParentJunction(aObj)
            out=aObj.fOwner;
        end

        function out=ParentTransition(aObj)
            out=aObj.fOwner;
        end

        function out=ParentState(aObj)
            out=aObj.fOwner;
        end

        function out=ParentChart(aObj)
            if isa(aObj.fOwner,'slci.stateflow.Chart')||...
                isa(aObj.fOwner,'slci.matlab.EMChart')
                out=aObj.fOwner;
            else
                out=aObj.fOwner.ParentChart();
            end
        end

        function out=ParentBlock(aObj)
            if isa(aObj.fOwner,'slci.simulink.Block')
                out=aObj.fOwner;
            else
                out=aObj.fOwner.ParentBlock();
            end
        end

        function out=ParentModel(aObj)
            out=aObj.fOwner.ParentModel();
        end

        function out=getFatal(aObj)
            out=aObj.fFatal;
        end

        function setFatal(aObj,aFatal)
            aObj.fFatal=aFatal;
        end

        function out=getOwner(aObj)
            out=aObj.fOwner;
        end

        function setOwner(aObj,aOwner)
            aObj.fOwner=aOwner;
            dConstraints=aObj.getPreRequisiteConstraints;
            for i=1:numel(dConstraints)
                dConstraints{i}.setOwner(aOwner);
            end
        end

        function setEnum(aObj,aEnum)
            aObj.enum=aEnum;
        end

        function out=getCompileNeeded(aObj)
            out=aObj.compileNeeded;
        end

        function setCompileNeeded(aObj,compileFlag)
            assert(compileFlag==0||compileFlag==1);
            aObj.compileNeeded=compileFlag;
        end

        function out=getEnum(aObj)
            out=aObj.enum;
        end


        function out=getID(aObj)
            out=aObj.enum;
        end

        function out=getSID(aObj)
            out=aObj.fOwner.getSID();
        end

        function[SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,varargin)
            status=varargin{1};
            id=strrep(class(aObj),'slci.compatibility.','');
            if status
                status='Pass';
            else
                status='Warn';
            end
            StatusText=DAStudio.message(['Slci:compatibility:',id,status]);
            RecAction=DAStudio.message(['Slci:compatibility:',id,'RecAction']);
            SubTitle=DAStudio.message(['Slci:compatibility:',id,'SubTitle']);
            Information=DAStudio.message(['Slci:compatibility:',id,'Info']);
        end

        function[SubTitle,Information,StatusText,RecAction]=getMAStrings(aObj,status,varargin)
            [SubTitle,Information,StatusText,RecAction]=getSpecificMAStrings(aObj,status,varargin{:});
            if~status&&aObj.getFatal
                StatusText=[StatusText,DAStudio.message('Slci:compatibility:FatalIncompatibilityAppendage')];
            elseif~status&&~isempty(varargin)&&strcmpi(varargin{1},'fix')
                StatusText=[StatusText,DAStudio.message('Slci:compatibility:Notfixed')];
            end
        end

        function list(aObj)
            if aObj.fFatal
                disp(['   FATAL: ',aObj.getDescription()]);
            else
                disp(['   nonfatal: ',aObj.getDescription()]);
            end
        end

        function out=fix(aObj,aIncompatibility)%#ok
            out=true;
        end

        function out=setOwnerSetting(aObj,aOption,aValidSetting)
            out=false;
            try
                eval(sprintf('aObj.getOwner().getUDDObject.%s = ''%s''',aOption,aValidSetting));
                out=true;
            catch
            end
        end






        function out=getListOfStrings(aObj,aList,forHTML)
            out='';
            for idx=1:numel(aList)
                if forHTML&&aObj.HTMLEncode
                    aList{idx}=strrep(aList{idx},'<','&lt;');
                    aList{idx}=strrep(aList{idx},'>','&gt;');
                end
                out=[out,'''',aList{idx},''''];%#ok
                if idx==numel(aList)-1
                    out=[out,' ',DAStudio.message('Slci:compatibility:SLCIor'),' '];%#ok
                elseif idx<numel(aList)
                    out=[out,', '];%#ok
                end
            end
        end

        function[failures,preReqConstraintFailure]=checkCompatibility(aObj)
            failures=[];
            prereqConstraints=aObj.getPreRequisiteConstraints();
            if~isempty(prereqConstraints)
                for i=1:numel(prereqConstraints)
                    [recurseFailures,~]=prereqConstraints{i}.checkCompatibility();
                    if~isempty(recurseFailures)
                        aObj.addPreRequisiteConstraintFailures(...
                        prereqConstraints{i});
                    end
                    failures=[failures,recurseFailures];%#ok
                end
            end
            if isempty(failures)
                failures=aObj.check();
                preReqConstraintFailure=false;
            else
                for i=1:numel(failures)
                    failures(i).setpreReqFailureFlag(true);
                end
                preReqConstraintFailure=true;
            end
        end




        function flag=isOwnerVirtualBlock(aObj)
            flag=false;
            sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);%#ok<NASGU>
            if isa(aObj.getOwner(),'slci.simulink.Block')
                if(aObj.getCompileNeeded()==1)
                    obj=aObj.getOwner().getParam('Object');
                    flag=obj.isPostCompileVirtual;
                end
            end
        end

    end

    methods

        function out=check(aObj)%#ok
            out=[];
        end

    end


end


