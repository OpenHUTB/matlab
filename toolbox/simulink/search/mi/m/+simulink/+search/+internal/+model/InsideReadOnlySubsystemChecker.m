

classdef InsideReadOnlySubsystemChecker<simulink.search.internal.model.ReadOnlyChecker

    methods(Access=public)
        function obj=InsideReadOnlySubsystemChecker()
        end

        function checkerName=getName(this)
            checkerName='InsideReadOnlySubsystemChecker';
        end

        function isReadOnly=check(this,objectUri,propertyname)
            try
                isReadOnly=false;
                try
                    objectType=get_param(objectUri,'Type');

                    if strcmp(objectType,'block')||strcmp(objectType,'annotation')
                        parent=get_param(objectUri,'Parent');
                        parentType=get_param(parent,'Type');
                    elseif strcmp(objectType,'port')
                        parentBlock=get_param(objectUri,'Parent');
                        parent=get_param(parentBlock,'Parent');
                        parentType=get_param(parent,'Type');
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
                    parent=get_param(sfObjectPath,'Parent');
                    parentType=get_param(parent,'Type');
                end

                while strcmp(parentType,'block')
                    permissions=get_param(parent,'Permissions');
                    if~strcmp(permissions,'ReadWrite')
                        isReadOnly=true;
                        break;
                    else
                        parent=get_param(parent,'Parent');
                        parentType=get_param(parent,'Type');
                    end
                end
            catch ex
                isReadOnly=false;
            end
        end

        function msg=getMessage(this,objectUri,propertyname)
            try
                msg=message(...
'simulink_ui:search:resources:ReadOnlyAncestorMessage'...
                ).getString();
            catch ex
                msg='';
            end
        end
    end
end
