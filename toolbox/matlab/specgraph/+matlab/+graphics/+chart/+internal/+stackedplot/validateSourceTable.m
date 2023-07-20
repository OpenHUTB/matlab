function validateSourceTable(tbl)




    if istabular(tbl)

    elseif iscell(tbl)
        if isempty(tbl)
            error(message('MATLAB:stackedplot:InvalidCellData'));
        elseif~isvector(tbl)
            error(message('MATLAB:stackedplot:InvalidCellDataArray'));
        end
        for i=1:numel(tbl)
            if~isa(tbl{i},'tabular')
                error(message('MATLAB:stackedplot:InvalidCellData'));
            end
        end
        tabularType=class(tbl{1});
        for i=2:numel(tbl)
            if~isa(tbl{i},tabularType)
                error(message('MATLAB:stackedplot:IncompatibleTableTypes'));
            end
        end
        if tabularType=="timetable"
            rowTimesType=class(tbl{1}.Properties.RowTimes);
            for i=2:numel(tbl)
                if~isa(tbl{i}.Properties.RowTimes,rowTimesType)
                    error(message('MATLAB:stackedplot:IncompatibleTimetableRowTimeTypes'));
                end
            end
        end
    else
        error(message('MATLAB:stackedplot:InvalidSourceTable'));
    end