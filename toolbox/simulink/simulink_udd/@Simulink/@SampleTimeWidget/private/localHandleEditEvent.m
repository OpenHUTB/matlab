function editbox=localHandleEditEvent(editbox,prmIndex,prmValue,source,methods)





    if prmIndex>=0

        editbox.Value=prmValue;
        editbox.ObjectMethod='handleEditEvent';
        editbox.MethodArgs={'%value',prmIndex,'%dialog'};
        editbox.ArgDataTypes={'mxArray','int32','handle'};
    else

        if~isempty(methods)
            editbox.Source=source;
            editbox.Value=prmValue;
            if isfield(methods,'ObjectMethod')
                editbox.ObjectMethod=methods.ObjectMethod;
                editbox.MethodArgs=methods.MethodArgs;
                editbox.ArgDataTypes=methods.ArgDataTypes;
            end
        else
            stName='SampleTime';

            if strcmp(get_param(source.getBlock().Handle,'BlockType'),'SubSystem')

                stName='SystemSampleTime';
            end


            editbox.ObjectProperty=stName;
            editbox.MatlabMethod='handleEditEvent';
            editbox.MatlabArgs={source,'%value',find(strcmp(source.paramsMap,stName))-1,'%dialog'};
        end
    end
