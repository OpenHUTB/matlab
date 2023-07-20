classdef(ConstructOnLoad)Display3DEventData<event.EventData





    properties

Volume
Label
VolumeAlphamap
VolumeColormap
LabelAlphamap
LabelColormap
SliceIndex
Dimension

    end

    methods

        function data=Display3DEventData(vol,labels,amapVol,cmapVol,amapLabel,cmapLabel,sliceidx,dim)

            data.Volume=vol;
            data.Label=labels;
            data.VolumeAlphamap=amapVol;
            data.VolumeColormap=cmapVol;
            data.LabelAlphamap=amapLabel;
            data.LabelColormap=cmapLabel;
            data.SliceIndex=sliceidx;
            data.Dimension=dim;

        end

    end

end