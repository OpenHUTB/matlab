classdef(ConstructOnLoad)NameChangedEventData<event.EventData





    properties

OldLabel
NewLabel

    end

    methods

        function data=NameChangedEventData(name,newname)

            data.OldLabel=name;
            data.NewLabel=newname;

        end

    end

end