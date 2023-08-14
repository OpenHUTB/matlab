function schema






    mlock;

    schema.package('hdlshared');


    if isempty(findtype('SimulinkObjectHandle'))
        schema.UserType('SimulinkObjectHandle','handle',@checkSimulinkObjectHandle);
    end


    if isempty(findtype('HDLTargetLanguage'))
        schema.EnumType('HDLTargetLanguage',...
        {'vhdl','verilog','systemverilog'});
    end




    function checkSimulinkObjectHandle(h)
        if~isempty(h)&&~isa(h,'Simulink.Object')
            error(message('HDLShared:hdlshared:invalidporthandle'))
        end



