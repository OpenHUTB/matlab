classdef Violation<matlab.mixin.SetGet




    properties
        Subject;
        Issue;
        Reason;
    end


    methods

        function obj=Violation(Subject,Issue,Reason)
            switch nargin
            case 0

            case 1
                obj.Subject=Subject;
            case 2
                obj.Subject=Subject;
                obj.Issue=Issue;
            otherwise
                obj.Subject=Subject;
                obj.Issue=Issue;
                obj.Reason=Reason;
            end
        end
    end


    methods
        function bSubject=hasSubject(this)
            bSubject=~isempty(this.Subject);
        end

        function bIssue=hasIssue(this)
            bIssue=~isempty(this.Issue);
        end

        function bReason=hasReason(this)
            bReason=~isempty(this.Reason);
        end

        function[bSubject,bIssue,bReason]=hasProperties(this)
            bSubject=~isempty(this.Subject);
            bIssue=~isempty(this.Issue);
            bReason=~isempty(this.Reason);
        end
    end
end

