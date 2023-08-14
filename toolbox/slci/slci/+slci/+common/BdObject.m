


classdef BdObject<handle

    properties(Access=private)
        fSID='';
        fName='';

        fLibSID='';
        fConstraints={};
    end

    properties(Access=protected)
        fClassName='';
        fClassNames='';
    end

    properties(Access=private,Transient)
        fUDDObject=[];
    end

    methods

        function out=ParentChart(aObj)%#ok
            out=[];
        end

        function out=ParentBlock(aObj)%#ok
            out=[];
        end

        function out=ParentModel(aObj)%#ok
            out=[];
        end

        function out=checkCompatibility(aObj)
            out=[];
            for idx=1:numel(aObj.fConstraints)
                [failures,preReqConstraintFailure]=aObj.fConstraints{idx}.checkCompatibility();



                if~preReqConstraintFailure
                    out=[out,failures];%#ok
                end
            end
        end

        function listCompatibility(aObj)
            for idx=1:numel(aObj.fConstraints)
                aObj.fConstraints{idx}.list()
            end
        end

        function out=getClassName(aObj)
            out=aObj.fClassName;
        end

        function out=getClassNames(aObj)
            out=aObj.fClassNames;
        end

        function out=getSID(aObj)
            out=aObj.fSID;
        end

        function out=getParam(aObj,aParameterName)
            out=get_param(aObj.fSID,aParameterName);
        end

        function setParam(aObj,aParameterName,aParameterValue)
            try
                set_param(aObj.fSID,aParameterName,aParameterValue);
            catch ME
                if strcmpi(ME.identifier,'Simulink:ConfigSet:ConfigSetRef_SetParamNotAllowed')
                    cs=getActiveConfigSet(aObj.fSID);
                    if isa(cs,'Simulink.ConfigSetRef')
                        set_param(cs.getRefConfigSet,aParameterName,aParameterValue);
                        stage=slci.internal.turnOnDiagnosticView('SLCI',aObj.getName);%#ok
                        slci.internal.outputMessage('Slci:compatibility:ReferenceConfigSetUpdated','warning');
                    end
                end
            end
        end

        function setSID(aObj,aSID)
            aObj.fSID=aSID;
        end


        function setLibSID(aObj,aLibSID)
            aObj.fLibSID=aLibSID;
        end


        function out=getLibSID(aObj)
            out=aObj.fLibSID;
        end

        function out=getName(aObj)
            out=aObj.fName;
        end

        function setName(aObj,aName)
            aObj.fName=aName;
        end

        function out=getUDDObject(aObj)
            out=aObj.fUDDObject;
        end

        function setUDDObject(aObj,aObject)
            aObj.fUDDObject=aObject;
        end

        function out=getConstraints(aObj)
            out=aObj.fConstraints;
        end

        function setConstraint(aObj,aConstraint,index)
            aConstraint.setOwner(aObj);
            aObj.fConstraints{index}=aConstraint;
        end

        function addConstraint(aObj,aConstraint)
            aConstraint.setOwner(aObj);
            aObj.fConstraints{end+1}=aConstraint;
        end



        function setConstraints(aObj,aConstraints)
            assert(iscell(aConstraints));
            for k=1:numel(aConstraints)
                aConstraint=aConstraints{k};
                aConstraint.setOwner(aObj);
            end
            if~isempty(aObj.fConstraints)
                existing=aObj.fConstraints;
                aObj.fConstraints=[existing,aConstraints];
            else
                aObj.fConstraints=aConstraints;
            end
        end

        function updateConstraint(aObj,aConstraint)
            constraints=aObj.getConstraints;
            for i=1:numel(constraints)
                if strcmp(class(constraints{i}),class(aConstraint))
                    aObj.setConstraint(aConstraint,i);
                    break;
                end
            end
        end



        function removeConstraint(aObj,constraintID)
            constraints=aObj.getConstraints;
            for i=1:numel(constraints)
                if strcmp(constraints{i}.getID,constraintID)
                    aObj.fConstraints=[aObj.fConstraints(1:i-1)...
                    ,aObj.fConstraints(i+1:end)];
                    break;
                end
            end
        end


        function removeConstraints(aObj,toRemove)
            assert(iscell(toRemove));
            existingIDs=cellfun(@getID,aObj.fConstraints,...
            'UniformOutput',false);
            [~,remainingIDs]=setdiff(sort(existingIDs),sort(toRemove));
            if isempty(remainingIDs)
                aObj.fConstraints={};
            else
                aObj.fConstraints=aObj.fConstraints(remainingIDs);
            end
        end

    end
end
