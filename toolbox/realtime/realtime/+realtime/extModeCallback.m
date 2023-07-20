function out=extModeCallback(hObj,hDlg,fieldName,action)





    tagprefix='Tag_ConfigSet_RTT_Settings_';
    tag=[tagprefix,fieldName];

    out='';
    cs=hObj.getParent;

    switch fieldName
    case 'Enable_external_mode'
        if isequal(action,'init')
            val=get_param(cs,'ExtMode');
            out=isequal(val,'on');
        elseif isequal(action,'changed')
            offonval={'off','on'};
            val=hDlg.getWidgetValue(tag);
            set_param(cs,'ExtMode',offonval{val+1});
            if(val==1)
                fname=realtime.getDataFileName('targetInfo',hObj.TargetExtensionPlatform);
                targetInfo=realtime.TargetInfo(fname,hObj.TargetExtensionPlatform,cs.getModel);
                set_param(cs,'ExtModeTransport',targetInfo.ExtModeTransport);
                set_param(cs,'ExtModeMexArgs',targetInfo.ExtModeMexArgsInit);
            end
        end
    case{'COM_port_number','COM_port_baud_rate'}
        idx=2+isequal(fieldName,'COM_port_baud_rate');
        if isequal(action,'init')
            args=get_param(cs,'ExtModeMexArgs');
            t=realtime.parseExtModeMexArgs(args);
            out=t{idx};
        elseif isequal(action,'changed')
            argsstr=get_param(cs,'ExtModeMexArgs');
            args=realtime.parseExtModeMexArgs(argsstr);
            newval=hDlg.getWidgetValue(tag);
            switch(idx)
            case(1)

            case(2)
                portstr=str2num(newval);%#ok<ST2NM>
                portnum=int32(portstr);
                if~isempty(portstr)&&isscalar(portnum)&&isreal(portnum)&&...
                    (portnum>0)&&isequal(portstr,portnum)
                    args{idx}=newval;


                    if coder.oneclick.Utils.isFeaturedOn
                        hObj.TargetExtensionData.(fieldName)=newval;
                    end
                else
                    DAStudio.error('realtime:build:InvalidExTModePortNumber');
                    hDlg.setWidgetValue(tag,args{idx});
                end
            case(3)
                bauderatestr=str2num(newval);%#ok<ST2NM>
                bauderatenum=int32(bauderatestr);
                if~isempty(bauderatestr)&&isscalar(bauderatenum)&&isreal(bauderatenum)&&...
                    (bauderatenum>0)&&isequal(bauderatestr,bauderatenum)
                    args{idx}=newval;
                else
                    hDlg.setWidgetValue(tag,args{idx});
                    DAStudio.error('realtime:build:InvalidExTModeBaudrate');
                end
            end
            if isempty(args{1})
                args{1}='0';
            end
            set_param(cs,'ExtModeMexArgs',[args{1},' ',args{2},' ',args{3}]);
        end
    case{'port'}


        if isequal(action,'init')
            args=get_param(cs,'ExtModeMexArgs');
            t=realtime.parseExtModeMexArgs(args);
            if isempty(t{3})
                out='17725';
            else
                out=t{3};
            end
        elseif isequal(action,'changed')
            newVal=hDlg.getWidgetValue(tag);
            if~i_isValidPort(newVal)
                oldVal=hObj.TargetExtensionData.(fieldName);
                hDlg.setWidgetValue(tag,oldVal);
                DAStudio.error('realtime:build:InvalidTcpPort');
            end
            argsstr=get_param(cs,'ExtModeMexArgs');
            args=realtime.parseExtModeMexArgs(argsstr);
            set_param(cs,'ExtModeMexArgs',[args{1},' ',args{2},' ',newVal]);


            if coder.oneclick.Utils.isFeaturedOn
                hObj.TargetExtensionData.(fieldName)=newVal;
            end
        end
    end
end


function ret=i_isValidPort(portStr)
    portStr=strtrim(portStr);
    portNum=uint16(str2double(portStr));
    if~isscalar(portNum)||isnan(portNum)||~isreal(portNum)||...
        (portNum<1024)||(portNum>65535)||...
        ~isequal(portStr,int2str(portNum))
        ret=false;
    else
        ret=true;
    end
end