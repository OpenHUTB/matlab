function importAction(obj,importType,varargin)










    if~any(strcmp(importType,{'Simulink','commandLine'}))

        if obj.IsChanged
            if strcmp(obj.Container,'ToolGroup')
                selection=questdlg([getString(message('phased:apps:arrayapp:importquest')),'?'],...
                getString(message('phased:apps:arrayapp:title')),...
                getString(message('phased:apps:arrayapp:yes')),...
                getString(message('phased:apps:arrayapp:no')),...
                getString(message('phased:apps:arrayapp:cancel')),...
                getString(message('phased:apps:arrayapp:yes')));
            else
                selection=uiconfirm(obj.ToolGroup,[getString(message('phased:apps:arrayapp:importquest')),'?'],...
                getString(message('phased:apps:arrayapp:title')),...
                'Options',{getString(message('phased:apps:arrayapp:yes')),...
                getString(message('phased:apps:arrayapp:no')),...
                getString(message('phased:apps:arrayapp:cancel'))},...
                'DefaultOption',getString(message('phased:apps:arrayapp:yes')));
            end





            switch selection
            case getString(message('phased:apps:arrayapp:yes'))
                saveFlag=true;
            case getString(message('phased:apps:arrayapp:no'))
                saveFlag=false;
            otherwise
                return;
            end


            if saveFlag
                saveAction(obj,'saveitem');
            else
                obj.IsChanged=true;
            end
        end
    end


    setAppStatus(obj,true);


    switch importType
    case 'workspaceitem'



        dialogStr=[getString(message('phased:apps:arrayapp:importws')),':'];


        obj.importData=phased.apps.internal.importDialog(dialogStr);



        if isempty(obj.importData)||~isValidData(obj)
            setAppStatus(obj,false);
            return
        end





        dialogTags=updateDialogTags(obj.importData);
        updateUI(obj,dialogTags);


        updateOpenPlots(obj)
    case 'fileitem'



        obj.importData=importFromFile(obj);
        setAppTitle(obj,obj.DefaultSessionName)



        if isempty(obj.importData)||~isValidData(obj)
            setAppStatus(obj,false);
            return
        end





        dialogTags=updateDialogTags(obj.importData);
        updateUI(obj,dialogTags);


        updateOpenPlots(obj)
    case 'Simulink'


        if isempty(varargin)

            sensorData=obj.pSysObj;
            obj.importData=obj.pSysObj.Sensor;
        else

            sensorData=varargin{1};
            obj.importData=varargin{1}.Sensor;
        end



        if isempty(obj.importData)||~isValidData(obj)
            setAppStatus(obj,false);
            return
        end




        if isa(obj.importData,'phased.internal.AbstractArray')||...
            isa(obj.importData,'phased.ReplicatedSubarray')||...
            isa(obj.importData,'phased.PartitionedArray')
            dialogstr=updateDialogTags(obj.importData);
        else

            arrayData=phased.ConformalArray('Element',obj.importData);
            dialogstr=getDataString(arrayData);
            sensorData.Sensor=arrayData;
        end
        obj.importData=sensorData;
        updateUI(obj,dialogstr);

        updateOpenPlots(obj)
    otherwise


        obj.importData=varargin{1};


        dialogTags=updateDialogTags(obj.importData);
        updateUI(obj,dialogTags);


        updateOpenPlots(obj)
    end


    disableAnalyzeButton(obj);


    setAppStatus(obj,false);
end

function updatedTags=updateDialogTags(data)

    if isa(data,'phased.ReplicatedSubarray')
        dialogTags=getDataString(data.Subarray);
        updatedTags=[dialogTags,{'replicatedsubarray'}];
    elseif isa(data,'phased.PartitionedArray')
        dialogTags=getDataString(data.Array);
        updatedTags=[dialogTags,{'partitionedarray'}];
    else
        updatedTags=getDataString(data);
    end
end

function dialogTags=getDataString(data)



    dialogTags=[];
    if isa(data,'phased.internal.AbstractArray')
        arr=data;
        elem=data.Element;
        if isa(arr,'phased.ULA')
            dialogTags{1}='ula';
        elseif isa(arr,'phased.UCA')
            dialogTags{1}='uca';
        elseif isa(arr,'phased.URA')
            dialogTags{1}='ura';
        elseif isa(arr,'phased.ConformalArray')
            dialogTags{1}='arbitraryarray';
        end
    else
        elem=data;
    end

    if isa(elem,'phased.IsotropicAntennaElement')
        dialogTags{end+1}='isotropicantenna';
    elseif isa(elem,'phased.CosineAntennaElement')
        dialogTags{end+1}='cosineantenna';
    elseif isa(elem,'phased.SincAntennaElement')
        dialogTags{end+1}='sincantenna';
    elseif isa(elem,'phased.GaussianAntennaElement')
        dialogTags{end+1}='gaussianantenna';
    elseif isa(elem,'phased.CardioidAntennaElement')
        dialogTags{end+1}='cardioidantenna';
    elseif isa(elem,'phased.CustomAntennaElement')
        if isPolarizationCapable(elem)
            dialogTags{end+1}='custompolarizedantenna';
        else
            dialogTags{end+1}='customantenna';
        end
    elseif isa(elem,'phased.OmnidirectionalMicrophoneElement')
        dialogTags{end+1}='omnidirectionalmicrophone';
    elseif isa(elem,'phased.CustomMicrophoneElement')
        dialogTags{end+1}='custommicrophone';
    elseif isa(elem,'phased.IsotropicHydrophone')
        dialogTags{end+1}='hydrophone';
    elseif isa(elem,'phased.IsotropicProjector')
        dialogTags{end+1}='projector';
    elseif isa(elem,'phased.ShortDipoleAntennaElement')
        dialogTags{end+1}='shortdipoleantenna';
    elseif isa(elem,'phased.CrossedDipoleAntennaElement')
        dialogTags{end+1}='crosseddipoleantenna';
    elseif isa(elem,'phased.NRAntennaElement')
        dialogTags{end+1}='nrantenna';
    elseif isa(elem,'em.Antenna')
        dialogTags{end+1}='custompolarizedantenna';
    end

end

function flag=isValidData(obj)

    data=obj.importData;
    try
        if~phased.apps.internal.SensorArrayApp.isValidSensorArray(data)
            error(message('phased:apps:arrayapp:invalidimport'))
        end


        phased.apps.internal.SensorArrayApp.crossValidation(data);
        flag=true;
    catch me
        throwError(obj,me);
        flag=false;
        return;
    end

end