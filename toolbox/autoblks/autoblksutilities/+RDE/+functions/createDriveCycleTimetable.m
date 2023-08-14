function data=createDriveCycleTimetable(t,v,opMode)













    data=timetable(v,opMode,'RowTimes',seconds(t));
    data.Properties.DimensionNames{1}='t';
    data.Properties.RowTimes.Format='hh:mm:ss';
end