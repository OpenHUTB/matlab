function HDLScalarizePorts(obj)



    if isReleaseOrEarlier(obj.ver,'R2020a')

        if hdlcoderui.isslhdlcinstalled

            optionVal=hdlget_param(obj.modelName,'ScalarizePorts');

            if strcmpi(optionVal,'dutlevel')


                obj.appendRules('<slprops.hdlmdlprops<Array<Cell|"DUTLevel":repval "on">>>');
            end
        end
    end
end
