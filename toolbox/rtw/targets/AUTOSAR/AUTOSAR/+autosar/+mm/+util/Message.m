



classdef Message<handle



    properties(GetAccess=public,SetAccess=public)
        type;
        component;
        identifier;
        source;
        summary;
        details;
    end

    methods(Access=public)



        function self=Message(msgType,msgId,msgDetails,msgSummary,msgSource,msgReportedBy)
            if nargin>0
                self.type=msgType;
            end
            if nargin>1
                self.identifier=msgId;
            end
            if nargin>2
                self.details=self.fixViewer(msgDetails);
            end
            if nargin>3
                self.summary=self.fixViewer(msgSummary);
            end
            if nargin>4
                self.source=msgSource;
            end
            if nargin>5
                self.component=self.fixComponent(msgReportedBy);
            end
        end

    end

    methods(Static,Access=private)
        function ret=fixViewer(details)






            if isa(details,'message')||isa(details,'MException')

                ret=details;
            else


                ret=strrep(details,'matlab:SCPDiagViewer.','matlab:autosar.mm.util.MessageReporter.');
            end
        end

        function ret=fixComponent(component)


            ret=component;
            if strcmp(component,'SCP')
                ret='autosar';
            end
        end
    end
end
