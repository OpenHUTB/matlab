function resetHDLWATask(taskID)




    hdlwaDriver=hdlwa.hdlwaDriver.getHDLWADriverObj;
    tableObj=hdlwaDriver.getTaskObj(taskID);
    tableObj.reset;

end


