classdef(ConstructOnLoad)VolumeLoadedEventData<event.EventData





    properties

Volume
Label
VolumeAlphamap
VolumeColormap
LabelAlphamap
LabelColormap
SliceIndex
Dimension
Datatype

    end

    methods

        function data=VolumeLoadedEventData(vol,labels,amapVol,cmapVol,amapLabel,cmapLabel,sliceidx,dim,volData)

            data.Volume=vol;
            data.Label=labels;
            data.VolumeAlphamap=amapVol;
            data.VolumeColormap=cmapVol;
            data.LabelAlphamap=amapLabel;
            data.LabelColormap=cmapLabel;
            data.SliceIndex=sliceidx;
            data.Dimension=dim;
            data.Datatype=volData;

        end

    end

end