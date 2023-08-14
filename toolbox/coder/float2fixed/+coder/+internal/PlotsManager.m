classdef PlotsManager<handle


    properties
isActive

currentRunTimeStamp
isWithinGroup
currentGroupTitle
figuresPriorToCurrentGroup
    end

    methods
        function this=PlotsManager()
            this.isActive=false;
            this.isWithinGroup=false;
            this.currentGroupTitle={};
            this.activate();
            this.newRun();
        end

        function activate(this)
            if~this.isActive
                this.isActive=true;
            end
        end

        function deactivate(this)
            if this.isActive
                this.isActive=false;
            end
        end

        function newRun(this)
            if this.isWithinGroup
                this.endGroup();
            end
            this.currentRunTimeStamp=this.getTimeStampString();
        end

        function newGroup(this,groupTitle)
            if this.isWithinGroup
                this.endGroup();
            end
            this.isWithinGroup=true;
            this.currentGroupTitle=groupTitle;
            this.figuresPriorToCurrentGroup=findall(0,'Type','figure');
        end

        function endGroup(this)
            assert(this.isWithinGroup);
            this.isWithinGroup=false;

            ts=this.currentRunTimeStamp;

            figsNow=findall(0,'Type','figure');
            figsOpened=setdiff(figsNow,this.figuresPriorToCurrentGroup);
            this.figuresPriorToCurrentGroup=[];

            if~isempty(this.currentGroupTitle)
                prefix=this.currentGroupTitle{1};
                suffix=this.currentGroupTitle{2};
            else
                prefix='';
                suffix='';
            end

            for ii=1:numel(figsOpened)
                f=figsOpened(ii);
                try
                    f.NumberTitle='off';
                    name=f.Name;
                    if~isempty(name)
                        if~isspace(name(end))&&~isempty(suffix)
                            name(end+1)=' ';
                        end

                        if~isspace(name(1))&&~isempty(prefix)
                            name=[' ',name];
                        end
                    end
                    f.Name=[prefix,name,suffix,' ',ts];
                    f.WindowStyle='docked';
                catch ex
                end
            end
            this.currentGroupTitle={};
        end

        function ts=getTimeStampString(~)
            t=int32(clock());
            ts=sprintf('(%02d:%02d:%02d)',t(4),t(5),t(6));
        end

        function delete(this)
            if this.isWithinGroup
                this.endGroup();
            end
            this.deactivate();
        end
    end
end


