function[values,times,statuses]=afvalues2matlab(afValues)

    if isa(afValues,'OSIsoft.AF.Asset.AFValues')
        [values,times,statuses]=afValues.GetValueArrays();
        [values,statuses]=NETUtilities.AFValue.ConvertValueAndStatuses(values,statuses);
        values=double(values);
        times=icomm.pi.internal.dotnetdatetime2datetime(times);
        statuses=cell(statuses);
        badStatusIndex=find(contains(statuses,','));
        for statusIndex=badStatusIndex
            parts=strsplit(statuses{statusIndex},',');
            statuses{statusIndex}=strtrim(parts{end});
        end

        statuses=icomm.pi.internal.AFValueStatus(cell(statuses));
    elseif isa(afValues,'OSIsoft.AF.Asset.AFValue')
        [values,times,statuses]=afvalue2matlab(afValues);
    else
        error(...
        'Fx:InvalidAFValues',...
        'Invalid type "%s".',...
        class(afValues));
    end
end


function[value,time,status]=afvalue2matlab(afValue)
    value=icomm.pi.internal.double(afValue.Value);
    time=icomm.pi.internal.dotnetdatetime2datetime(afValue.Timestamp.UtcTime);
    status=icomm.pi.internal.AFValueStatus.fromPiSdk(afValue.Status);
end

