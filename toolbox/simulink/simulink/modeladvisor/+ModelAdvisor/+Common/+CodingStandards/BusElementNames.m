
classdef BusElementNames<ModelAdvisor.Common.CodingStandards.Base

    methods(Access=public)

        function this=BusElementNames(system,messagePrefix)
            this@ModelAdvisor.Common.CodingStandards.Base(...
            system,messagePrefix);
            this.flaggedObjects=struct(...
            'Name',{},...
            'Source',{},...
            'Type',{},...
            'Users',{},...
            'Elements',{},...
            'Conflicts',{});
        end

        function algorithm(this)

            busInfo=this.getInformationOnUsedBusses();

            for i=1:numel(busInfo)
                conflictList=[];
                for j=1:numel(busInfo)
                    if any(strcmp(busInfo(i).Name,busInfo(j).Elements))
                        if isempty(conflictList)
                            conflictList=busInfo(j);
                        else
                            conflictList(end+1)=busInfo(j);%#ok<AGROW>
                        end
                    end
                end
                if~isempty(conflictList)
                    this.addFlaggedObject(busInfo(i),conflictList);
                end
            end

            if this.getNumFlaggedObjects()==0
                this.localResultStatus=true;
            else
                this.localResultStatus=false;
            end

        end

        function report(this)

            resultTable=ModelAdvisor.FormatTemplate('TableTemplate');
            resultTable.setCheckText(this.getMessage('CheckText'));
            resultTable.setSubBar(false);
            resultTable.setColTitles({...
            this.getMessage('ResultTableHeader1'),...
            this.getMessage('ResultTableHeader2'),...
            this.getMessage('ResultTableHeader3')});
            for i=1:this.getNumFlaggedObjects()
                flaggedObject=this.getFlaggedObjects(i);
                resultTable.addRow({...
                this.makeBusName(flaggedObject),...
                this.makeUsedAsBusElementNames(flaggedObject),...
                this.makeUsedInModel(flaggedObject)});
            end

            if this.getNumFlaggedObjects()==0
                resultTable.setSubResultStatus('pass');
                resultTable.setSubResultStatusText(this.getMessage(...
                'SubResultStatusText_Pass'));
            else
                resultTable.setSubResultStatus('warn');
                resultTable.setSubResultStatusText(this.getMessage(...
                'SubResultStatusText_Fail'));
                resultTable.setRecAction(this.getMessage(...
                'Action'));
            end

            this.addReportObject(resultTable);

        end

    end

    methods(Access=protected)

        function addFlaggedObject(this,busInfo,conflictList)
            flaggedObject=busInfo;
            flaggedObject.Conflicts=conflictList;
            this.flaggedObjects(end+1)=flaggedObject;
        end

    end

    methods(Access=private)

        function busInfo=getInformationOnUsedBusses(this)
            usedVariables=Simulink.findVars(this.system,...
            'SearchMethod','cached');
            resultCells=cell(numel(usedVariables),5);
            keep=false(numel(usedVariables),1);
            for i=1:numel(usedVariables)
                thisVar=usedVariables(i);





                if strcmp(thisVar.SourceType,'data dictionary')||...
                    strcmp(thisVar.SourceType,'base workspace')




                    if existsInGlobalScope(this.rootSystem,thisVar.Name)
                        instance=evalinGlobalScope(...
                        this.rootSystem,thisVar.Name);
                        if isa(instance,'Simulink.Bus')
                            keep(i)=true;
                            busElements=instance.Elements;
                            resultCells{i,1}=thisVar.Name;
                            resultCells{i,2}=thisVar.Source;
                            resultCells{i,3}=thisVar.SourceType;
                            resultCells{i,4}=thisVar.Users;
                            resultCells{i,5}={busElements.Name};
                        end
                    end

                end
            end
            resultCells=resultCells(keep,:);
            busInfo=cell2struct(resultCells,...
            {'Name','Source','Type','Users','Elements'},2);
        end

        function entry=makeBusName(this,flaggedObject)
            entry=this.makeTextWithHyperlinkToBusEditor(...
            flaggedObject.Name,...
            flaggedObject.Type,...
            flaggedObject.Source,...
            flaggedObject.Name,...
            '');
        end

        function entry=makeUsedAsBusElementNames(this,flaggedObject)
            entry=ModelAdvisor.List;
            entry.Type='Numbered';
            for i=1:numel(flaggedObject.Conflicts)
                conflict=flaggedObject.Conflicts(i);
                bus=this.makeTextWithHyperlinkToBusEditor(...
                conflict.Name,...
                conflict.Type,...
                conflict.Source,...
                conflict.Name,...
                '');
                element=this.makeTextWithHyperlinkToBusEditor(...
                flaggedObject.Name,...
                conflict.Type,...
                conflict.Source,...
                conflict.Name,...
                flaggedObject.Name);

                item=ModelAdvisor.Text([bus,'.',element]);
                entry.addItem(item);
            end
            numElements=numel(entry.Items);
            if numElements==1
                entry.setAttribute('style','list-style-type: none;');
            end
        end

        function entry=makeUsedInModel(this,flaggedObject)
            entry=ModelAdvisor.List;
            entry.Type='Numbered';
            entry.CollapsibleMode='all';
            entry.HiddenContent=ModelAdvisor.Text(...
            this.getMessage('UsedByListCollapsed'));
            entry.DefaultCollapsibleState='collapsed';
            Users=flaggedObject.Users;
            for i=1:numel(Users)
                entry.addItem(Users(i));
            end
            numElements=numel(entry.Items);
            if numElements==1
                entry.setAttribute('style','list-style-type: none;');
            end
        end

        function text=makeTextWithHyperlinkToBusEditor(this,...
            text,type,source,bus,element)
            application='matlab';
            helperFunction='modeladvisorprivate';
            hiliteFunction='hiliteBusObject';
            hyperlink=sprintf('%s: %s(''%s'',''%s'',''%s'',''%s'',''%s'')',...
            application,helperFunction,hiliteFunction,type,source,bus,element);
            text=this.makeTextWithHyperlink(text,hyperlink);
        end

        function result=makeTextWithHyperlink(~,text,hyperlink)
            result=['<a href="',hyperlink,'">',text,'</a>'];
        end

    end

end

