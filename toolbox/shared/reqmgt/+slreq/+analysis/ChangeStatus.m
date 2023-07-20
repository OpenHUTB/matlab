classdef ChangeStatus
    enumeration
Fail
InvalidLink
UnsupportedArtifact
Pass
Undecided
UpToDate
    end

    methods
        function out=toString(changeStatus)

            switch changeStatus
            case slreq.analysis.ChangeStatus.Fail
                out=getString(message('Slvnv:slreq:ChangeStatusFail'));
            case slreq.analysis.ChangeStatus.Pass
                out=getString(message('Slvnv:slreq:ChangeStatusPass'));
            case slreq.analysis.ChangeStatus.InvalidLink
                out=getString(message('Slvnv:slreq:ChangeStatusInvalidLink'));
            case slreq.analysis.ChangeStatus.UnsupportedArtifact
                out=getString(message('Slvnv:slreq:ChangeStatusUnsupportedArtifact'));
            case slreq.analysis.ChangeStatus.Undecided
                out=getString(message('Slvnv:slreq:ChangeStatusUndecided'));
            end
        end


        function out=toInteger(changeStatus)

            switch changeStatus
            case slreq.analysis.ChangeStatus.Fail
                out=0;
            case slreq.analysis.ChangeStatus.Pass
                out=1;
            otherwise
                out=-1;
            end
        end


        function tf=isFail(this)
            tf=this==slreq.analysis.ChangeStatus.Fail;
        end


        function tf=isUndecided(this)
            tf=this==slreq.analysis.ChangeStatus.Undecided;
        end


        function tf=isPass(this)
            tf=this==slreq.analysis.ChangeStatus.Pass;
        end


        function tf=isInvalidLink(this)
            tf=this==slreq.analysis.ChangeStatus.InvalidLink;
        end


        function tf=isUnsupportedArtifact(this)
            tf=this==slreq.analysis.ChangeStatus.UnsupportedArtifact;
        end

    end
end