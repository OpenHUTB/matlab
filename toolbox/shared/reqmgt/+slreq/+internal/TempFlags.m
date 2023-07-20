classdef TempFlags<handle




    properties(Access=private)
        IsRedirectingLibObj=true;
        CurrentDASDDGTag='';
        IsMigratingDotReq=false;
        InTestingMode=false;
        BacklinksCleanupViaAPI=[];




        DeferModelPostLoadActions=false;

        AllFlags;
    end


    methods(Access=private)
        function this=TempFlags()
        end
    end

    methods
        function set(this,propName,value)
            this.(propName)=value;
        end

        function out=get(this,propName)
            out=this.(propName);
        end

        function refreshFlags(this)
            this.AllFlags=containers.Map({...
            'IsRedirectingLibObj',...
            'CurrentDASDDGTag',...
            'IsMigratingDotReq',...
            'InTestingMode',...
            'BacklinksCleanupViaAPI',...
'DeferModelPostLoadActions'...
            },...
            {true,'',false,false,[],false});
        end

        function tf=isValidFlag(this,flagName)
            tf=isKey(this.AllFlags,flagName);
        end
    end

    methods(Static)
        function obj=getInstance()
            persistent tempFlags;
            if isempty(tempFlags)||~isvalid(tempFlags)

                tempFlags=slreq.internal.TempFlags;
                tempFlags.refreshFlags();
            end
            obj=tempFlags;
        end

        function resetCallback=changeFlag(flagName,flagValue)
            obj=slreq.internal.TempFlags.getInstance;
            if~obj.isValidFlag(flagName)
                errorMessage=sprintf(['Error using temp flags. the valid flags are: \n',obj.getAllTempFlagNames()]);
                error(errorMessage);
            end
            origValue=obj.get(flagName);
            obj.set(flagName,flagValue);

            resetCallback=onCleanup(@()obj.set(flagName,origValue));
        end

        function out=getAllTempFlagNames
            obj=slreq.internal.TempFlags.getInstance;
            allFlags=obj.AllFlags.keys;
            out='';
            for index=1:length(allFlags)
                cFlag=allFlags{index};
                defaultValue=string(obj.AllFlags(cFlag));
                out=sprintf('%s\t%s   -- %s\n',out,cFlag,defaultValue);
            end
        end
    end
end
