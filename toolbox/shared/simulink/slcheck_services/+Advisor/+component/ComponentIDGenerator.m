classdef ComponentIDGenerator



    methods(Static)



















        function id=generateID(varargin)
            p=inputParser();
            p.addParameter('SID','',@ischar);



            p.addParameter('File','',@ischar);
            p.addParameter('Callstack',{},@iscell);






            p.addParameter('LibrarySID','',@ischar);

            p.parse(varargin{:});
            in=p.Results;


            if isempty(in.SID)&&isempty(in.File)
                DAStudio.error('Advisor:base:Components_NoComponentID');
            else
                id=Advisor.component.internal.generateID(in);
            end
        end
    end
end

