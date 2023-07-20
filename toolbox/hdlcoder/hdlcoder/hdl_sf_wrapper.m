function hdl_sf_wrapper(chartHandle,machine,entityName,CGScopeObj,emlTextBufferMap,clockDrivenOutput,isRegisteredOutput)


    chartID=sfprivate('block2chart',chartHandle);
    sf('Cg','set_hdl_scope',chartID,CGScopeObj);
    sf('Cg','set_eml_text_buffer_map',chartID,emlTextBufferMap);


    sf('set',chartID,'chart.unique.codegenName',entityName);




    sf('set',chartID,'chart.hdlInfo.isClockDrivenOutput',clockDrivenOutput);




    sf('set',chartID,'chart.hdlInfo.isRegisteredOutput',isRegisteredOutput);

    try

        sfprivate('autobuild_driver','buildchart',machine,'slhdlc','no','yes',chartHandle);
    catch sfBuildException

        exceptionMsg=sfBuildException.message;

        chartName=sf('get',chartID,'chart.name');
        hdlStateflowError=message('hdlcoder:stateflow:hdlstateflowerror',chartName,chartID);

        errMsg=[exceptionMsg,newline,hdlStateflowError.getString()];
        sfprivate('construct_error',chartID,'Build',errMsg,1);
    end

end
