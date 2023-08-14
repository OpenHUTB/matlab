


classdef LockedLibraryChecker<simulink.search.internal.model.ReadOnlyChecker

    methods(Access=public)
        function obj=LockedLibraryChecker()
        end

        function checkerName=getName(this)
            checkerName='LockedLibraryChecker';
        end

        function isReadOnly=check(this,blockUri,propertyname)
            try
                try
                    fullPath=getfullname(blockUri);
                catch

                    chartId=sfprivate('getChartOf',blockUri);
                    sfChartObject=idToHandle(sfroot,chartId);
                    if(isempty(sfChartObject))
                        sfObject=idToHandle(sfroot,blockUri);
                        fullPath=sfObject.Path;
                    else
                        fullPath=sfChartObject.Path;
                    end
                end
                rootName=bdroot(fullPath);
                isReadOnly=strcmp(get_param(rootName,'Lock'),'on');
            catch ex
                isReadOnly=false;
            end
        end

        function msg=getMessage(this,blockUri,propertyname)
            try
                msg=message(...
'simulink_ui:search:resources:LockedLibraryReadOnlyMessage'...
                ).getString();
            catch ex
                msg='';
            end
        end
    end
end
