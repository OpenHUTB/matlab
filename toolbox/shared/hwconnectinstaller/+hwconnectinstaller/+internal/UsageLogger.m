classdef(Sealed)UsageLogger<handle




    properties(Access=public)
        ComponentName=''
        Enabled=false
        LocalLoggingFcn=function_handle.empty
    end

    properties(Constant,Access=private)
        APPLICATION_NAME='Support Package Installer';
    end

    properties(Access=private)
WebService
        KeyValuePairsToSend={};
    end

    methods(Static)
        function formattedString=getFormattedBaseCodeString(pkgName,pkgBaseCode)




            formattedString=['Product=',pkgName,', ','Basecode=',pkgBaseCode];
        end
    end

    methods

        function set.LocalLoggingFcn(obj,fcn)
            validateattributes(fcn,{'function_handle'},{},'set.LocalLoggingFcn');
            obj.LocalLoggingFcn=fcn;
        end

        function obj=UsageLogger






        end

        function sendBaseCodeWhenEnabled(obj,pkgName,pkgBaseCode)
            assert(ischar(pkgName)&&ischar(pkgBaseCode));
            eventValue=obj.getFormattedBaseCodeString(pkgName,pkgBaseCode);
            obj.send({...
            'PRODUCT_BASECODE',eventValue
            });
        end

        function sendEventWhenEnabled(obj,event,resourceName,resourceURI)
            assert(ischar(event)&&ischar(resourceName));
            if exist('resourceURI','var')
                assert(ischar(resourceURI));
                obj.send({...
                'CLIENT_EVENT',event
                'RESOURCE_NAME',resourceName
                'RESOURCE_URI',resourceURI
                });
            else
                obj.send({...
                'CLIENT_EVENT',event
                'RESOURCE_NAME',resourceName
                });
            end
        end

        function sendLoginWhenEnabled(obj,mwaUserName,mwaLoginToken)
            assert(ischar(mwaUserName)&&ischar(mwaLoginToken));
            obj.send({...
            'MWACCOUNT_EMAIL',mwaUserName
            'LOGIN',mwaLoginToken
            });
        end

        function set.ComponentName(obj,componentName)
            assert(ischar(componentName));
            obj.ComponentName=componentName;
        end

        function set.Enabled(obj,doEnable)
            assert(islogical(doEnable));
            obj.Enabled=doEnable;
            if obj.Enabled
                obj.flushSendQueue();
            end
        end

    end


    methods(Access=private)
        function flushSendQueue(obj)
            if isempty(obj.KeyValuePairsToSend)
                return;
            end
        end

        function send(obj,newKeyValuePairs)
            obj.KeyValuePairsToSend=[obj.KeyValuePairsToSend;newKeyValuePairs];
            if obj.Enabled
                obj.flushSendQueue();
            end
        end
    end


end
