classdef SimulationObserver < handle
% simevents.SimulationObserver Simulation observer superclass for SimEvents models
%   Subclass from this class and implement the abstract methods to create 
%   your own model observer.
%
    methods (Access = protected)
        function obj = SimulationObserver(modelName)
        % Constructor: Chain call in subclass
            obj.fSimObserverHelper = slde.SimulationObserverHelper(modelName, obj);
        end
    end
    methods (Access = public)
        function simStarted(obj) %#ok
        % Override to define behavior at simulation start
        end
        
        function simPaused(obj) %#ok
        % Override to define behavior when simulation is paused
        end
        
        function simResumed(obj) %#ok
        % Override to define behavior when simulation resumes after being paused
        end

        function simTerminating(obj) %#ok
        % Override to define behavior when simulation is terminating
        end

        function blks = getBlocksToNotify(obj) %#ok
        % Override to return a cell array of full block paths for
        % notification of run-time events. All storage associated with specified
        % blocks are notified. Return an empty cell array if there are
        % no blocks of interest to notify. Return the string 'ALL' for notifying
        % all blocks and storages in model
            blks = {};
        end
        
        function n = notifyEventCalendarEvents(obj) %#ok
        % Override to return true if you desire notification of all
        % events executed in the event calendar. Otherwise, return false
            n = false;
        end
        
        function postEntry(obj, evSrc, evData) %#ok
        % Override to specify listener for entry into a storage (queue/server)
        end
        
        function preExit(obj, evSrc, evData) %#ok
        % Override to specify listener for exit from a storage (queue/server)
        % evData contains block, storage, and entity handles
        end

        function preExecute(obj, evSrc, evData) %#ok
        % Override to specify listener for event calendar event        
        % evData contains block, storage, and entity handles
        end
    end
    
    methods (Access = protected)
        function mName = getModelName(obj)
        % Utility: Get name of associated model
            mName = obj.fSimObserverHelper.getModelName();
        end
        function addBlockNotification(obj, blkPath)
        % Utility: Add event notification for specified block
            obj.fSimObserverHelper.addBlockNotification(blkPath)
        end
        function removeBlockNotification(obj, blkPath)
        % Utility: Remove event notification for specified block
            obj.fSimObserverHelper.removeBlockNotification(blkPath)
        end
        function evcal = getEventCalendars(obj)
        % Utility: Return all event calendars
            evcal = obj.fSimObserverHelper.getEventCalendars();
        end
        function allBlkPaths = getAllBlockWithStorages(obj)
        % Utility: Return paths to all block with storages in them
            allBlkPaths = obj.fSimObserverHelper.getAllBlockWithStorages();
        end
        function blkHandle = getHandleToBlock(obj, blkPath)
        % Utility: Get block handle from block path
            blkHandle = obj.fSimObserverHelper.getHandleToBlock(blkPath);
        end
        function storagesForBlock = getHandlesToBlockStorages(obj, blkPath)
        % Utility: Get storage handles for block
            storagesForBlock = obj.fSimObserverHelper.getHandlesToBlockStorages(blkPath);
        end
    end
    
    properties (Access = private)
        fSimObserverHelper
    end
end

