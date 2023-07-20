classdef(ConstructOnLoad)OrientationAxesChangedEventData<event.EventData





    properties

Show
ShowWireframe

    end

    methods

        function data=OrientationAxesChangedEventData(TF,wireframeTF)

            data.Show=TF;
            data.ShowWireframe=wireframeTF;

        end

    end

end