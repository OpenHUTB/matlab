function configParamsCallback(hSource,hDialog,tag,value)


    switch(tag)
    case 'DefaultBodyColor',
        value=str2num(value);
        if numel(value)==3
            if~((max(value)<=1)&&(min(value)>=0))
                hDialog.setWidgetValue(tag,'[1 0 0]');
                hSource.DefaultBodyColor='[1 0 0]';
                hDialog.show;
                error('Invalid parameter value. Should be 1x3 vector of RGB values between 0 and 1');
            end
        else
            hDialog.setWidgetValue(tag,'[1 0 0]');
            hSource.DefaultBodyColor='[1 0 0]';
            hDialog.show;
            error('Invalid parameter value. Should be 1x3 vector of RGB values between 0 and 1');
        end
    otherwise
    end
end

