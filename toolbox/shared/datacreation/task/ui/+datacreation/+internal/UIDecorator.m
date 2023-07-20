classdef UIDecorator<handle




    methods(Static)


        function decorateUITableHeaders(appStateData,uiTableObj)

            if appStateData.isTimeBased
                if strcmpi(appStateData.StorageType,'timetable')
                    uiTableObj.ColumnName={...
                    message('datacreation:datacreation:tableTimeColumn').getString...
                    ,appStateData.ColumnName...
                    };
                else
                    uiTableObj.ColumnName={...
                    message('datacreation:datacreation:tableTimeColumn').getString...
                    ,message('datacreation:datacreation:tableDataColumn').getString...
                    };
                end
            else
                uiTableObj.ColumnName={...
                message('datacreation:datacreation:tableDataColumn').getString...
                };
            end


        end


    end
end

