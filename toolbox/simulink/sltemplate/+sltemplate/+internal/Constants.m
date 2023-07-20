classdef Constants<handle




    methods(Access=private)
        function obj=Constants
        end
    end

    methods(Access=public,Static=true)
        function groupName=getDefaultTemplateGroup
            groupName='My Templates';
        end

        function ext=getTemplateFileExtension
            ext='.sltx';
        end

        function iconFile=getDialogIcon(varargin)
            p=inputParser;
            p.addOptional('icoFormat',false,@islogical);
            p.parse(varargin{:});

            if p.Results.icoFormat
                ext='.ico';
            else
                ext='.png';
            end

            iconFile=fullfile(matlabroot,'toolbox','simulink',...
            'sltemplate','resources',['sl_dialog_icon',ext]);
        end
    end
end
