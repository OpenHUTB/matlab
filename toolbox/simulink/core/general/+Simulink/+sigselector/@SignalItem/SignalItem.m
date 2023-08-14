classdef SignalItem<Simulink.sigselector.AbstractItem









    properties
Selected
Icon
    end
    properties(Hidden=true,Transient=true)
TreeID
    end


    methods

        function obj=SignalItem()
            obj=obj@Simulink.sigselector.AbstractItem();
            obj.Selected=false;
            obj.Icon=Simulink.sigselector.getSigSelectorResourceFile('signal.gif');
        end
    end

end


