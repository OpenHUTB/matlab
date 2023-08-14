classdef(Hidden)Utility








    properties(Constant)


        MW_MQTTASYNC_RESPONSE_CODE_PLACEHOLDER=1;


        MQTTASYNC_SUCCESS=0;
        MQTTASYNC_FAILURE=-1;
        MQTTASYNC_PERSISTENCE_ERROR=-2;
        MQTTASYNC_DISCONNECTED=-3;
        MQTTASYNC_MAX_MESSAGES_INFLIGHT=-4;
        MQTTASYNC_BAD_UTF8_STRING=-5;
        MQTTASYNC_NULL_PARAMETER=-6;
        MQTTASYNC_TOPICNAME_TRUNCATED=-7;
        MQTTASYNC_BAD_STRUCTURE=-8;
        MQTTASYNC_BAD_QOS=-9;
        MQTTASYNC_NO_MORE_MSGIDS=-10;
        MQTTASYNC_OPERATION_INCOMPLETE=-11;
        MQTTASYNC_MAX_BUFFERED_MESSAGES=-12;
        MQTTASYNC_SSL_NOT_SUPPORTED=-13;
        MQTTASYNC_BAD_PROTOCOL=-14;
        MQTTASYNC_BAD_MQTT_OPTION=-15;
        MQTTASYNC_WRONG_MQTT_VERSION=-16;

    end

    methods(Static)
        function checkLicense()
            try

                matlab.internal.licensing.checkoutProductLicense('OT');
            catch
                error(message('icomm_mqtt:MQTTClient:NotLicensed'));
            end
        end
    end
end