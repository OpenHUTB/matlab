function[tab1,tab2,tab3]=createradpattableinfo(parseobj,MagE,...
    az,el)





    [minval,~,Umin]=engunits(min(min(MagE)));
    [maxval,~,Umax]=engunits(max(max(MagE)));

    minval=num2str(minval,3);
    maxval=num2str(maxval,3);


    [freq,~,U]=engunits(parseobj.Results.frequency);
    frequnit=strcat(U,'Hz');

    if isfield(parseobj.Results,'Type')
        [output,unit]=em.FieldAnalysisWithFeed.getfieldlabels(parseobj.Results.Type);
        if any(strcmpi(parseobj.Results.Type,{'Magnitude','complex'}))
            output='RCS';
            if strcmpi(parseobj.Results.Scale,'log')
                unit='dBsm';
            else
                unit='';
            end
        end
    end

    if isscalar(freq)
        if isscalar(az)
            str1=num2str(freq,6);
            str2=sprintf('%s\x00b0',num2str(az));
            str3=sprintf('[%s\x00b0 , %s\x00b0]',num2str(min(el)),num2str(max(el)));
        elseif isscalar(el)
            str1=num2str(freq,6);
            str2=sprintf('[%s\x00b0 , %s\x00b0]',num2str(min(az)),num2str(max(az)));
            str3=sprintf('%s\x00b0',num2str(el));
        else
            str1=num2str(freq,6);
            str2=sprintf('[%s\x00b0 , %s\x00b0]',num2str(min(az)),num2str(max(az)));
            str3=sprintf('[%s\x00b0 , %s\x00b0]',num2str(min(el)),num2str(max(el)));
        end
    else
        str1='variation';
        frequnit=[];
        if isscalar(az)&&isscalar(el)
            str2=sprintf('%s\x00b0',num2str(az));
            str3=sprintf('%s\x00b0',num2str(el));
        elseif isscalar(az)
            str2=sprintf('%s\x00b0',num2str(az));
            str3=sprintf('[%s\x00b0 , %s\x00b0]',num2str(min(el)),num2str(max(el)));
        else
            str2=sprintf('[%s\x00b0 , %s\x00b0]',num2str(min(az)),num2str(max(az)));
            str3=sprintf('%s\x00b0',num2str(el));
        end
    end

    if(parseobj.Results.Normalize)
        output=sprintf('%s %s',output,'(norm)');
        unit='';
        minval=min(min(MagE));
        minval=num2str(minval,3);
        Umin='';
    end

    if strcmpi(parseobj.Results.CoordinateSystem,'uv')
        if isscalar(freq)
            str1=num2str(freq,6);
        else
            str1='variation';
        end
        if isscalar(az)
            str2=num2str(az);
        else
            str2=sprintf('[%s , %s]',num2str(min(az),2),num2str(max(az),2));
        end
        if isscalar(el)
            str3=num2str(el);
        else
            str3=sprintf('[%s , %s]',num2str(min(el),2),num2str(max(el),2));
        end
        tab1={'Output','Frequency','Max value','Min value','u','v'};
        tab3=sprintf('%s \n%s %s\n%s %s%s\n%s %s%s\n%s \n%s',...
        output,str1,frequnit,maxval,Umax,unit,minval,Umin,unit,...
        str2,str3);
    else
        tab1={'Output','Frequency','Max value','Min value','Azimuth','Elevation'};
        tab3=sprintf('%s \n%s %s\n%s %s%s\n%s %s%s\n%s\n%s',...
        output,str1,frequnit,maxval,Umax,unit,minval,Umin,unit,...
        str2,str3);
    end
    tab2=sprintf(':\n:\n:\n:\n:\n:');

    if~strcmpi(parseobj.Results.Polarization,'combined')
        tab1=[tab1,{'Polarization'}];
        tab3=[tab3,sprintf('\n%s',parseobj.Results.Polarization)];
        tab2=[tab2,sprintf('\n:')];
    end


    if isfield(parseobj.Results,'ElementNumber')&&~isempty(parseobj.Results.ElementNumber)
        tab1=[tab1,{'ElementNumber'}];
        tab3=[tab3,sprintf('\n%s',num2str(parseobj.Results.ElementNumber))];
        tab2=[tab2,sprintf('\n:')];
    end

end

