classdef TargetListener<RTW.TargetListener




    methods
        function event(~,hEvent)
            if isequal(hEvent,'reset')||isequal(hEvent,'testreset')
                codertarget.TargetRegistry.manageInstance('destroy');
                codertarget.TargetBoardRegistry.manageInstance('destroy');
                codertarget.TargetBoardRegistry.setSlTargetsLoadedState(false);
                codertarget.Registry.manageInstance('destroy');




                clear(fullfile(matlabroot,'toolbox','target','codertarget',...
                '+codertarget','+target','getIsOneClickEnabled'));
            end
        end
    end
    methods(Static=true)
        function addListenerToTargetRegistry(tr)
            mlock;
            assert(isa(tr,'coder.targetreg.internal.TargetRegistry'),'codertarget.TargetListeners can only be added to an instance of coder.targetreg.internal.TargetRegistry');
            listenerType=cellfun(@(x)isa(x,'codertarget.TargetListener'),tr.Listeners);
            if isempty(listenerType)||~any(listenerType)
                listener=codertarget.TargetListener;
                tr.registerListener(listener);
            end
        end
    end
end
