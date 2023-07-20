


classdef LibraryLinkReadOnlyChecker<simulink.search.internal.model.ReadOnlyChecker

    methods(Access=public)
        function obj=LibraryLinkReadOnlyChecker()
        end

        function checkerName=getName(this)
            checkerName='LibraryLinkReadOnlyChecker';
        end

        function isReadOnly=check(this,objectUri,propertyname)
            try
                isReadOnly=false;

                try
                    objectType=get_param(objectUri,'Type');

                    if strcmp(objectType,'block')
                        isReadOnly=strcmp(get_param(objectUri,'LinkStatus'),'implicit');
                    elseif strcmp(objectType,'annotation')
                        parent=get_param(objectUri,'Parent');
                        parentType=get_param(parent,'Type');
                        if strcmp(parentType,'block')
                            parentLinkStatus=get_param(parent,'LinkStatus');
                            isReadOnly=strcmp(parentLinkStatus,'implicit')||strcmp(parentLinkStatus,'resolved');
                        end
                    elseif strcmp(objectType,'port')
                        parentBlock=get_param(objectUri,'Parent');
                        parentLinkStatus=get_param(parentBlock,'LinkStatus');
                        isReadOnly=strcmp(parentLinkStatus,'implicit');
                    end
                catch ex

                    chartId=sfprivate('getChartOf',objectUri);
                    sfChartObject=idToHandle(sfroot,chartId);
                    if isempty(sfChartObject)
                        sfObject=idToHandle(sfroot,objectUri);
                        sfObjectPath=sfObject.Path;
                    else
                        sfObjectPath=sfChartObject.Path;
                    end

                    isReadOnly=strcmp(get_param(sfObjectPath,'LinkStatus'),'implicit');
                end
            catch ex
            end
        end

        function msg=getMessage(this,objectUri,propertyname)
            try
                msg=message(...
'simulink_ui:search:resources:LibraryLinkReadOnlyMessage'...
                ).getString();
            catch
                msg='';
            end
        end
    end
end
