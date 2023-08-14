classdef Constraint<handle

























    properties(Hidden=true)
        IsRootConstraint=false;
        ResultStatus=false;
    end

    properties(SetAccess=protected,Hidden=true)
        HasFix=false;
        FixIt=false;
        WasFixed=false;
        Status=false;
        WasChecked=false;
        IsInformational=false;
        CheckingErrorMessage='';
    end

    properties(Access=protected)
        PreRequisiteConstraintHandles={};
    end

    properties(SetAccess=protected)
        PreRequisiteConstraintIDs={};
    end

    properties
        ID='';
    end

    properties(SetAccess=protected,Hidden=true)





        CompileState='None';
        SupportLibrary=false;
        SupportExclusion=false;
    end


    methods

        function addPreRequisiteConstraintID(this,ConstraintID)

            if~ischar(ConstraintID)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','addPreRequisiteConstraint');
            end

            this.PreRequisiteConstraintIDs{end+1}=ConstraintID;
        end


        function idcell=getPreRequisiteConstraintIDs(this)
            idcell=this.PreRequisiteConstraintIDs;
        end


        function setID(this,ID)
            if ischar(ID)
                this.ID=ID;
            else
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setID');
            end
        end


        function ID=getID(this)
            ID=this.ID;
        end


        function out=getPreRequisiteConstraintObjects(this)
            out=this.PreRequisiteConstraintHandles;
        end
    end

    methods(Access=protected)

        function setPreRequisiteConstraintIDs(this,ids)
            if~iscellstr(ids)
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','setRequisiteConstraintIDs');
            end

            for n=1:length(ids)
                this.addPreRequisiteConstraintID(ids{n});
            end
        end
    end

    methods(Abstract)

        [status,objs]=check(this)


        fixIncompatability(this,system)


        data=getConstraintResultData(this);
    end

    methods(Abstract,Access=protected)

        scanDOMNode(this,constraintNode)
    end

    methods(Hidden)


        function status=parseInformationalDependencies(node)
            status=true;

            if node.IsInformational
                status=true;
            else
                if~isempty(node.PreRequisiteConstraintHandles)

                    for n=1:length(node.PreRequisiteConstraintHandles)
                        preRequisiteConstraint=node.PreRequisiteConstraintHandles{n};

                        status=status&&preRequisiteConstraint.parseInformationalDependencies();
                    end
                else


                    status=false;
                end
            end
        end


        function addPreRequisiteConstraintObject(this,handle)
            if isa(handle,'Advisor.authoring.Constraint')
                this.PreRequisiteConstraintHandles{end+1}=handle;
            else
                DAStudio.error('Advisor:engine:UnsupportedMethodInput','addPreRequisiteConstraintObject');
            end
        end





        function status=hasOnlyInformationalDependencies(this)
            if isempty(this.PreRequisiteConstraintHandles)
                status=false;
            else
                status=true;

                for n=1:length(this.PreRequisiteConstraintHandles)
                    preRequisiteConstraint=this.PreRequisiteConstraintHandles{n};

                    status=status&&...
                    preRequisiteConstraint.parseInformationalDependencies();
                end
            end
        end


        function status=getPreRequisiteConstraintStatus(this)
            status=true;

            for n=1:length(this.PreRequisiteConstraintHandles)
                status=status&&this.PreRequisiteConstraintHandles{n}.Status;
                if~status
                    return;
                end
            end
        end




        function status=getOutputStatus(this)
            status=true;




            if this.IsInformational||(this.hasOnlyInformationalDependencies&&...
                ~this.getPreRequisiteConstraintStatus)
                status=false;
            end
        end



        function refreshStatus(this)
            this.Status=false;
            this.WasChecked=false;
            this.WasFixed=false;
            this.FixIt=false;
            this.ResultStatus=false;

            this.CheckingErrorMessage='';
        end
    end
end

